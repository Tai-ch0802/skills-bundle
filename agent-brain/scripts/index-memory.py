#!/usr/bin/env python3
"""index-memory.py — SQLite FTS5 indexer for agent-brain memory files.

Usage:
    python3 index-memory.py init              # Initialize database schema
    python3 index-memory.py index             # Index/re-index changed markdown files
    python3 index-memory.py rebuild           # Delete brain.db and rebuild from scratch
    python3 index-memory.py search "query"    # Full-text search across memory
"""

import os
import sys
import sqlite3
import hashlib
from pathlib import Path
from datetime import datetime

BRAIN_DIR = Path.home() / ".agent-brain"
DB_PATH = BRAIN_DIR / "brain.db"

# Chunking parameters
CHUNK_SIZE = 400   # approximate tokens per chunk (chars / 4)
CHUNK_OVERLAP = 80  # token overlap between chunks
CHARS_PER_TOKEN = 4  # rough estimate


def get_db():
    """Get database connection."""
    db = sqlite3.connect(str(DB_PATH))
    db.execute("PRAGMA journal_mode=WAL")
    return db


def init_db():
    """Initialize the database schema."""
    BRAIN_DIR.mkdir(parents=True, exist_ok=True)
    db = get_db()
    db.executescript("""
        CREATE TABLE IF NOT EXISTS chunks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_path TEXT NOT NULL,
            chunk_index INTEGER NOT NULL,
            content TEXT NOT NULL,
            file_hash TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(file_path, chunk_index)
        );

        CREATE VIRTUAL TABLE IF NOT EXISTS chunks_fts USING fts5(
            content,
            file_path,
            content='chunks',
            content_rowid='id',
            tokenize='porter unicode61'
        );

        CREATE TABLE IF NOT EXISTS file_state (
            file_path TEXT PRIMARY KEY,
            file_hash TEXT NOT NULL,
            indexed_at TEXT NOT NULL
        );

        -- Triggers to keep FTS in sync
        CREATE TRIGGER IF NOT EXISTS chunks_ai AFTER INSERT ON chunks BEGIN
            INSERT INTO chunks_fts(rowid, content, file_path)
            VALUES (new.id, new.content, new.file_path);
        END;

        CREATE TRIGGER IF NOT EXISTS chunks_ad AFTER DELETE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content, file_path)
            VALUES ('delete', old.id, old.content, old.file_path);
        END;

        CREATE TRIGGER IF NOT EXISTS chunks_au AFTER UPDATE ON chunks BEGIN
            INSERT INTO chunks_fts(chunks_fts, rowid, content, file_path)
            VALUES ('delete', old.id, old.content, old.file_path);
            INSERT INTO chunks_fts(rowid, content, file_path)
            VALUES (new.id, new.content, new.file_path);
        END;
    """)
    db.commit()
    db.close()
    print(f"✅ Database initialized at {DB_PATH}")


def file_hash(path: Path) -> str:
    """Get SHA256 hash of file content."""
    return hashlib.sha256(path.read_bytes()).hexdigest()[:16]


def chunk_text(text: str) -> list[str]:
    """Split text into overlapping chunks."""
    chunk_chars = CHUNK_SIZE * CHARS_PER_TOKEN
    overlap_chars = CHUNK_OVERLAP * CHARS_PER_TOKEN

    if len(text) <= chunk_chars:
        return [text] if text.strip() else []

    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_chars

        # Try to break at a paragraph or line boundary
        if end < len(text):
            # Look for paragraph break near the end
            para_break = text.rfind("\n\n", start + chunk_chars // 2, end + overlap_chars)
            if para_break > start:
                end = para_break + 2
            else:
                # Fall back to line break
                line_break = text.rfind("\n", start + chunk_chars // 2, end + overlap_chars)
                if line_break > start:
                    end = line_break + 1

        chunks.append(text[start:end].strip())
        start = end - overlap_chars

    return [c for c in chunks if c]


def rebuild_db():
    """Delete brain.db and rebuild from scratch."""
    if DB_PATH.exists():
        DB_PATH.unlink()
    # Also remove WAL/SHM files if present
    for suffix in ["-wal", "-shm"]:
        wal_path = DB_PATH.parent / (DB_PATH.name + suffix)
        if wal_path.exists():
            wal_path.unlink()

    print("🗑  Deleted old brain.db")
    init_db()
    index_files(force=True)


def index_files(force: bool = False):
    """Index all markdown files in the brain directory."""
    if not DB_PATH.exists():
        init_db()

    db = get_db()

    # Collect all markdown files
    md_files = []
    for pattern in ["*.md", "sessions/*.md", "projects/*.md"]:
        md_files.extend(BRAIN_DIR.glob(pattern))

    # Get current file states
    existing = {}
    if not force:
        try:
            for row in db.execute("SELECT file_path, file_hash FROM file_state"):
                existing[row[0]] = row[1]
        except sqlite3.DatabaseError:
            # FTS5 index corrupted — fall back to full rebuild
            print("⚠ Database corrupted, performing full rebuild...")
            db.close()
            rebuild_db()
            return

    indexed = 0
    skipped = 0
    now = datetime.now().isoformat()

    for md_file in md_files:
        relative = str(md_file.relative_to(BRAIN_DIR))
        current_hash = file_hash(md_file)

        # Skip if unchanged (unless force rebuild)
        if not force and relative in existing and existing[relative] == current_hash:
            skipped += 1
            continue

        # Read and chunk the file
        content = md_file.read_text(encoding="utf-8")
        chunks = chunk_text(content)

        try:
            # Remove old chunks for this file
            db.execute("DELETE FROM chunks WHERE file_path = ?", (relative,))

            # Insert new chunks
            for i, chunk in enumerate(chunks):
                db.execute(
                    "INSERT INTO chunks (file_path, chunk_index, content, file_hash, updated_at) "
                    "VALUES (?, ?, ?, ?, ?)",
                    (relative, i, chunk, current_hash, now),
                )

            # Update file state
            db.execute(
                "INSERT OR REPLACE INTO file_state (file_path, file_hash, indexed_at) "
                "VALUES (?, ?, ?)",
                (relative, current_hash, now),
            )

            indexed += 1
        except sqlite3.DatabaseError:
            # FTS5 index corrupted mid-operation — fall back to full rebuild
            print("⚠ Database error during indexing, performing full rebuild...")
            db.close()
            rebuild_db()
            return

    # Clean up files that no longer exist
    current_files = {str(f.relative_to(BRAIN_DIR)) for f in md_files}
    for old_file in set(existing.keys()) - current_files:
        db.execute("DELETE FROM chunks WHERE file_path = ?", (old_file,))
        db.execute("DELETE FROM file_state WHERE file_path = ?", (old_file,))

    db.commit()
    db.close()

    total_files = indexed + skipped
    print(f"✅ Indexed {indexed} files ({skipped} unchanged, {total_files} total)")


def search(query: str, limit: int = 10):
    """Full-text search across all indexed memory."""
    if not DB_PATH.exists():
        print("❌ brain.db not found. Run 'index' first.")
        sys.exit(1)

    db = get_db()

    try:
        results = db.execute(
            """
            SELECT
                c.file_path,
                c.chunk_index,
                snippet(chunks_fts, 0, '>>>', '<<<', '...', 64) as snippet,
                rank
            FROM chunks_fts
            JOIN chunks c ON chunks_fts.rowid = c.id
            WHERE chunks_fts MATCH ?
            ORDER BY rank
            LIMIT ?
            """,
            (query, limit),
        ).fetchall()
    except sqlite3.DatabaseError:
        print("⚠ FTS5 index corrupted. Rebuilding...")
        db.close()
        rebuild_db()
        print("🔄 Rebuild complete. Please re-run your search.")
        return

    if not results:
        print(f"No results found for: {query}")
        return

    print(f"🔍 Found {len(results)} results for: {query}\n")
    for file_path, chunk_idx, snippet, rank in results:
        print(f"📄 {file_path} (chunk {chunk_idx})")
        print(f"   {snippet}")
        print()

    db.close()


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]

    if command == "init":
        init_db()
    elif command == "index":
        index_files()
    elif command == "rebuild":
        rebuild_db()
    elif command == "search":
        if len(sys.argv) < 3:
            print("Usage: index-memory.py search \"query\"")
            sys.exit(1)
        search(" ".join(sys.argv[2:]))
    else:
        print(f"Unknown command: {command}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()

