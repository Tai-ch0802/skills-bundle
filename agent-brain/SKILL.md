---
name: agent-brain
description: "Persistent memory and digital twin brain for Antigravity sessions. Use this skill on EVERY session for: (1) loading cross-session memory at session start, (2) saving session summaries and learnings at session end, (3) syncing memory to pCloud cloud storage, (4) searching historical memory and past decisions, (5) managing per-project context. Triggers on: session start, session end signals (commit, release note, 告一段落, 收工, sync memory, save brain), memory recall requests (上次做了什麼, recall, search memory)."
---

# Agent Brain

Persistent file-first memory system. Every Antigravity session contributes to a growing knowledge base stored as Markdown files locally at `~/.agent-brain/` and synced to pCloud `/agent-brain/`.

## Goal

Build a **digital twin** — an agent that accumulates all session knowledge, user preferences, project context, and decisions over time.

## Memory Ontology

All information flowing through the agent's memory is classified into four ontological layers. Use this classification to decide **where** to store each piece of information.

### Four Layers

| Layer | Code | Nature | Mutability | Lifecycle | File |
|-------|------|--------|------------|-----------|------|
| **Identity** | `IDENTITY` | Who am I working with | Rarely changes (requires repeated observation) | Permanent | `USER.md` |
| **Knowledge** | `KNOWLEDGE` | What I know | Accumulative, compressible | Long-term (30+ days) | `MEMORY.md` |
| **Experience** | `EXPERIENCE` | What I did | Immutable (append-only) | Historical record | `sessions/*.md` |
| **State** | `STATE` | What I'm doing right now | Freely overwritable | Current work session | `STATE.md` |

### Classification Decision Flow

When new information emerges, route it through this decision tree:

```
New information →
├─ About the user's personal preferences/habits?  → IDENTITY (USER.md)
├─ A durable technical fact useful in 30+ days?    → KNOWLEDGE (MEMORY.md)
├─ Current task context (active bug, target file)? → STATE (STATE.md)
└─ None of the above, but worth recording?         → EXPERIENCE (sessions/*.md)
```

### Write Rules by Layer

| Layer | Write Mode | Sync Strategy | Conflict Resolution |
|-------|-----------|---------------|---------------------|
| Identity | Overwrite (requires multi-observation evidence) | Section merge | Keep longer version |
| Knowledge | Append durable facts only | Section merge | Keep longer version |
| Experience | Strict append-only | Append merge + dedup | Header fingerprint dedup |
| State | Free overwrite | **Never synced** (ephemeral) | N/A |

## Memory File Structure

```
~/.agent-brain/
├── .env                    # pCloud credentials (NEVER synced)
├── .sync-manifest.json     # SHA256 manifest for incremental sync
├── MEMORY.md               # Long-term persistent facts (KNOWLEDGE)
├── USER.md                 # User preferences & patterns (IDENTITY)
├── STATE.md                # Current work session context (STATE)
├── sessions/
│   └── YYYY-MM-DD.md       # Daily session logs (EXPERIENCE, append-only)
├── projects/
│   └── {project-name}.md   # Per-project accumulated context
├── tmp/                    # Temporary directory for conflict resolution (auto-cleaned)
└── brain.db                # SQLite FTS5 index
```

### File Roles

| File | Load at Start | Purpose |
|------|:---:|---------| 
| `MEMORY.md` | ✅ Full | Cross-session facts, decisions, learnings |
| `USER.md` | ✅ Full | User's coding style, tool preferences |
| `STATE.md` | ✅ Full | Resumable work context from last session |
| `sessions/today.md` | ✅ Full | Today's session summaries |
| `sessions/yesterday.md` | ✅ Full | Yesterday's context for continuity |
| `sessions/older` | ❌ On-demand | Search via grep or brain.db |
| `projects/*.md` | ❌ On-demand | Load when working on that project |
| `brain.db` | ❌ By script | SQLite FTS5 index for memory search |
| `.sync-manifest.json` | ❌ Internal | Tracks file SHA256 hashes for incremental sync |

## Session Start Procedure

Execute on **every** session:

1. **Check bootstrap**: If `~/.agent-brain/` does not exist, run:
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```

2. **Archive stale STATE**: If `~/.agent-brain/STATE.md` exists:
   - Read its `Updated:` timestamp
   - If the timestamp is from a **previous day** (not today): append a summary of its content to the corresponding `sessions/YYYY-MM-DD.md` as an archived state block, then clear STATE.md
   - If the timestamp is from **today**: keep it as-is (may be a continuation of the same work session)

3. **Load core memory** — read these files into context:
   - `~/.agent-brain/MEMORY.md` (full)
   - `~/.agent-brain/USER.md` (full)
   - `~/.agent-brain/STATE.md` (full, if exists and non-empty)
   - `~/.agent-brain/sessions/YYYY-MM-DD.md` for today (if exists)
   - `~/.agent-brain/sessions/YYYY-MM-DD.md` for yesterday (if exists)

4. **Load project context** (optional): If the current workspace clearly maps to a project, check if `~/.agent-brain/projects/{project-name}.md` exists and load it.

5. Proceed with the user's request, enriched by accumulated memory.

## Session End Procedure

### Trigger Detection

Activate memory flush when the user says or implies session ending:
- **Explicit**: `save brain`, `sync memory`, `記憶同步`, `更新記憶`
- **Implicit**: `commit`, `release note`, `告一段落`, `今天先到這`, `收工`, `結束`, `下班`, `先這樣`

### Memory Flush Steps (Local Only)

1. **Generate session summary** and append to `~/.agent-brain/sessions/YYYY-MM-DD.md`:
   ```markdown
   ## Session HH:MM:SS — {context}
   **Project**: [[projects/{name}]]
   **Workspace**: {repo or directory path}

   ### Summary
   {1-3 sentence summary of what was accomplished}

   ### Key Decisions
   - {decision 1}
   - {decision 2}

   ### Learnings
   - {new knowledge gained}

   ### Next Steps
   - [ ] {unfinished task}
   ```

2. **Update `MEMORY.md`** if new persistent facts emerged:
   - Technical decisions that affect future sessions
   - Cross-project patterns discovered
   - New architecture knowledge
   - Important URLs, credentials locations, environment details
   - Do NOT duplicate session-level detail — only promote **durable facts**

3. **Update `USER.md`** if new user preferences were observed:
   - Coding style, preferred tools, language preferences
   - Communication style, workflow habits

4. **Update `STATE.md`** — overwrite with current work context:
   - What task is in progress or was just completed
   - Key variables: active branch, target files, error codes being debugged
   - Scratch pad notes for next session continuity

5. **Update `projects/{name}.md`** with cross-link to today's session:
   ```markdown
   - YYYY-MM-DD: {brief description} [[sessions/YYYY-MM-DD#session-hhmmss]]
   ```
   Create the file if it doesn't exist, using the format in [memory-format.md](references/memory-format.md).

6. **Check MEMORY.md capacity**:
   - If MEMORY.md exceeds **400 lines**: warn `⚠ MEMORY.md approaching limit (XXX/500 lines). Consider compression.`
   - If MEMORY.md exceeds **500 lines**: trigger compression (remove entries older than 90 days not referenced, merge related entries, move project-specific details to `projects/`)

7. **Run indexer**:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```

> **Note**: Session end does NOT automatically sync to pCloud. Use `/upload-brain` to push changes or `/sync-brain` for full bidirectional sync.

## Memory Recall Procedure

When user asks about past work, decisions, or history:

1. **Specific project** → Read `~/.agent-brain/projects/{name}.md`
2. **Specific date** → Read `~/.agent-brain/sessions/YYYY-MM-DD.md`
3. **Keyword search** → Use `grep_search` on `~/.agent-brain/`
4. **Broad semantic search** → Run:
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py search "query"
   ```

## pCloud Sync

- **API Host**: `api.pcloud.com` (US data center)
- **Remote path**: `/agent-brain/`
- **Credentials**: `~/.agent-brain/.env`
- Refer to the `pcloud` skill for API details if needed

### Incremental Sync

The sync system uses a **SHA256 manifest** (`.sync-manifest.json`) to track which files have been synced. Only files whose content has changed since the last sync are transferred.

### Sync Commands

```bash
# Check sync status (dry-run — shows what would change, no writes)
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status

# Upload local changes to pCloud (incremental — only changed files)
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push

# Download from pCloud (incremental — only changed files)
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull

# Bidirectional sync with conflict resolution
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
```

### Conflict Resolution

When both local and remote versions of a file have changed since the last sync:

1. A `~/.agent-brain/tmp/` directory is created for staging
2. Remote files are downloaded to `tmp/`
3. Files are merged by type:
   - **Session logs** (`sessions/*.md`): Append-only merge — deduplicate session blocks by header fingerprint
   - **General Markdown** (`MEMORY.md`, `USER.md`, `projects/*.md`): Section-level merge using `##` headings as keys — both sides' unique sections are preserved, shared sections keep the longer version
   - **Other files**: Remote version wins
4. `tmp/` is cleaned up after merge
5. `brain.db` is **rebuilt from scratch** using `index-memory.py rebuild` — it is treated as a derived artifact and never merged directly
6. Final merged result (including rebuilt `brain.db`) is pushed to pCloud

## Memory Hygiene Rules

1. **MEMORY.md should stay under 500 lines**. If growing too large, compress: remove outdated facts, merge related entries, archive old sections to `projects/`.
2. **Sessions are append-only**. Never edit past session entries.
3. **Projects file per active project**. Archive inactive projects by adding `[ARCHIVED]` prefix.
4. **Cross-link everything**. Sessions reference `[[projects/name]]`, projects reference `[[sessions/date]]`.
5. **No secrets in memory files**. Credentials go in `.env` only.
6. **STATE.md is ephemeral**. Do not store durable facts in STATE — promote them to MEMORY.md. Stale STATE (from a previous day) is auto-archived on next session start.
7. **STATE.md is never synced**. It exists only on the local machine as a short-term working scratchpad.

## Workflows

Agent Brain ships with five global workflows that can be installed to `~/.agent/workflows/` during bootstrap (or manually via `install-workflows.sh`):

| Workflow | Slash Command | Purpose |
|----------|---------------|---------|
| `save-brain` | `/save-brain` | Flush session memory → update MEMORY/USER/STATE/projects → build index (local only) |
| `upload-brain` | `/upload-brain` | Push local changes to pCloud (one-way upload, incremental) |
| `download-brain` | `/download-brain` | Pull cloud changes to local (one-way download, incremental) |
| `sync-brain` | `/sync-brain` | Bidirectional pCloud sync with SHA-based incremental transfer and conflict resolution |
| `load-brain` | `/load-brain` | Load MEMORY.md, USER.md, STATE.md, today/yesterday sessions → load project context (local only) |

### Installing Workflows

Workflows are installed automatically during bootstrap. To install or reinstall manually:

```bash
bash ~/.gemini/antigravity/skills/agent-brain/scripts/install-workflows.sh
```

## Detailed References

- **Memory file format templates**: See [memory-format.md](references/memory-format.md)
- **Session lifecycle details**: See [session-lifecycle.md](references/session-lifecycle.md)
