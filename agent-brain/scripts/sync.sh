#!/usr/bin/env bash
# sync.sh — Incremental SHA-based pCloud sync for agent-brain
# Usage: sync.sh [push|pull|sync]
set -euo pipefail

BRAIN_DIR="${HOME}/.agent-brain"
ENV_FILE="${BRAIN_DIR}/.env"
MANIFEST="${BRAIN_DIR}/.sync-manifest.json"
TMP_DIR="${BRAIN_DIR}/tmp"

# Validate environment
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "❌ No .env found. Run bootstrap.sh first."
  exit 1
fi

source "${ENV_FILE}"
API="https://${PCLOUD_API_HOST}"
AUTH_HEADER="Authorization: Bearer ${PCLOUD_ACCESS_TOKEN}"
REMOTE_BASE="/agent-brain"

MODE="${1:-sync}"

# ─── Helper Functions ────────────────────────────────────────────────

log() { echo "   $1"; }

# Compute SHA256 of a local file (macOS + Linux compatible)
local_sha256() {
  local file="$1"
  if command -v shasum &>/dev/null; then
    shasum -a 256 "$file" | cut -d' ' -f1
  else
    sha256sum "$file" | cut -d' ' -f1
  fi
}

# Get manifest SHA for a given relative path (returns empty if not found)
manifest_sha() {
  local rel_path="$1"
  if [[ ! -f "${MANIFEST}" ]]; then
    echo ""
    return
  fi
  python3 -c "
import json, sys
try:
    with open('${MANIFEST}') as f:
        m = json.load(f)
    print(m.get('files', {}).get(sys.argv[1], {}).get('sha256', ''))
except:
    print('')
" "$rel_path"
}

# Update manifest entry for a file
update_manifest() {
  local rel_path="$1"
  local sha="$2"
  python3 -c "
import json, time, sys, os

manifest_path = '${MANIFEST}'
try:
    with open(manifest_path) as f:
        m = json.load(f)
except:
    m = {}

if 'files' not in m:
    m['files'] = {}

m['files'][sys.argv[1]] = {
    'sha256': sys.argv[2],
    'synced_at': time.strftime('%Y-%m-%dT%H:%M:%S%z')
}

with open(manifest_path, 'w') as f:
    json.dump(m, f, indent=2, ensure_ascii=False)
" "$rel_path" "$sha"
}

# Remove a file entry from manifest
remove_from_manifest() {
  local rel_path="$1"
  python3 -c "
import json, sys

manifest_path = '${MANIFEST}'
try:
    with open(manifest_path) as f:
        m = json.load(f)
    m.get('files', {}).pop(sys.argv[1], None)
    with open(manifest_path, 'w') as f:
        json.dump(m, f, indent=2, ensure_ascii=False)
except:
    pass
" "$rel_path"
}

# Ensure remote folder exists (creates recursively)
ensure_remote_folder() {
  local remote_path="$1"
  local current_path="${REMOTE_BASE}"

  # 1. Base folder
  curl -s -H "${AUTH_HEADER}" "${API}/createfolderifnotexists?path=${current_path}" > /dev/null 2>&1 || true

  # 2. Subfolders sequentially
  if [[ -n "${remote_path}" && "${remote_path}" != "/" && "${remote_path}" != "." ]]; then
    local clean_path="${remote_path#/}"
    IFS='/' read -ra PARTS <<< "${clean_path}"
    for part in "${PARTS[@]}"; do
      if [[ -n "${part}" ]]; then
        current_path="${current_path}/${part}"
        curl -s -H "${AUTH_HEADER}" "${API}/createfolderifnotexists?path=${current_path}" > /dev/null 2>&1 || true
      fi
    done
  fi
}

# Upload a single file to pCloud (delete-then-upload to avoid duplicates)
upload_file() {
  local local_path="$1"
  local remote_dir="$2"

  ensure_remote_folder "${remote_dir}"

  local filename
  filename=$(basename "${local_path}")
  local remote_file_path="${REMOTE_BASE}${remote_dir}/${filename}"

  # Delete existing file first (ignore errors if file doesn't exist)
  curl -s -H "${AUTH_HEADER}" "${API}/deletefile?path=${remote_file_path}" > /dev/null 2>&1 || true

  curl -s -X POST "${API}/uploadfile" \
    -H "${AUTH_HEADER}" \
    -F "path=${REMOTE_BASE}${remote_dir}" \
    -F "filename=${filename}" \
    -F "file=@${local_path}" > /dev/null 2>&1

  log "↑ ${remote_dir:+${remote_dir}/}${filename}"
}

# Download a file from pCloud
download_file() {
  local remote_path="$1"
  local local_path="$2"

  # Get file link
  local link_response
  link_response=$(curl -s -H "${AUTH_HEADER}" "${API}/getfilelink?path=${REMOTE_BASE}${remote_path}")

  local result
  result=$(echo "${link_response}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('result',9999))")

  if [[ "${result}" != "0" ]]; then
    log "⚠ Skip ${remote_path} (not found)"
    return 1
  fi

  local download_url
  download_url=$(echo "${link_response}" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('https://' + d['hosts'][0] + d['path'])
")

  mkdir -p "$(dirname "${local_path}")"
  curl -s -o "${local_path}" "${download_url}"
  log "↓ ${remote_path}"
  return 0
}

# Get remote file SHA256 via pCloud checksumfile API
remote_sha256() {
  local remote_path="$1"
  local response
  response=$(curl -s -H "${AUTH_HEADER}" "${API}/checksumfile?path=${REMOTE_BASE}${remote_path}")

  echo "${response}" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    if d.get('result') == 0:
        print(d.get('sha256', ''))
    else:
        print('')
except:
    print('')
"
}

# List all files in a remote pCloud folder recursively
list_remote_files() {
  local remote_path="${1:-}"
  local response
  response=$(curl -s -H "${AUTH_HEADER}" "${API}/listfolder?path=${REMOTE_BASE}${remote_path}&recursive=1")

  echo "${response}" | python3 -c "
import sys, json

def collect_files(metadata, prefix=''):
    files = []
    for item in metadata.get('contents', []):
        path = prefix + '/' + item['name']
        if item.get('isfolder'):
            files.extend(collect_files(item, path))
        else:
            files.append(path)
    return files

try:
    data = json.load(sys.stdin)
    if data.get('result') == 0:
        for f in collect_files(data['metadata']):
            print(f)
except:
    pass
"
}

# Check if a file should be excluded from sync
is_excluded() {
  local relative="$1"
  case "${relative}" in
    /.env|/.sync-manifest.json|/.sync-state.json) return 0 ;;
    /tmp|/tmp/*) return 0 ;;
    *) return 1 ;;
  esac
}

# ─── Merge Logic ─────────────────────────────────────────────────────

# Merge two markdown files (session logs: append-only dedup)
merge_session_md() {
  local local_file="$1"
  local remote_file="$2"
  local output_file="$3"

  python3 -c "
import re, sys

def extract_sessions(text):
    \"\"\"Extract session blocks from a session markdown file.\"\"\"
    blocks = re.split(r'(?=^## Session \d{2}:\d{2})', text, flags=re.MULTILINE)
    return [b.strip() for b in blocks if b.strip()]

local_path, remote_path, output_path = sys.argv[1], sys.argv[2], sys.argv[3]

local_text = open(local_path, encoding='utf-8').read() if __import__('os').path.exists(local_path) else ''
remote_text = open(remote_path, encoding='utf-8').read()

# Extract header (# Sessions — date) and session blocks
local_blocks = extract_sessions(local_text)
remote_blocks = extract_sessions(remote_text)

# Use content fingerprints to dedup
seen = set()
merged = []

for block in local_blocks + remote_blocks:
    # Use first 2 lines as fingerprint
    fingerprint = '\\n'.join(block.split('\\n')[:2])
    if fingerprint not in seen:
        seen.add(fingerprint)
        merged.append(block)

with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\\n\\n---\\n\\n'.join(merged) + '\\n')
" "$local_file" "$remote_file" "$output_file"
}

# Merge two general markdown files (MEMORY.md, USER.md, projects/*.md)
merge_general_md() {
  local local_file="$1"
  local remote_file="$2"
  local output_file="$3"

  python3 -c "
import sys, os

local_path, remote_path, output_path = sys.argv[1], sys.argv[2], sys.argv[3]

local_text = open(local_path, encoding='utf-8').read() if os.path.exists(local_path) else ''
remote_text = open(remote_path, encoding='utf-8').read()

local_lines = set(local_text.strip().split('\\n'))
remote_lines = set(remote_text.strip().split('\\n'))

# If identical, just use local
if local_text.strip() == remote_text.strip():
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(local_text)
    sys.exit(0)

# Strategy: use remote as base, append local-only lines at the end
remote_sections = remote_text.strip().split('\\n')
local_only = [l for l in local_text.strip().split('\\n') if l not in remote_lines and l.strip()]

if local_only:
    result = remote_text.rstrip() + '\\n\\n<!-- merged from local -->\\n' + '\\n'.join(local_only) + '\\n'
else:
    result = remote_text

with open(output_path, 'w', encoding='utf-8') as f:
    f.write(result)
" "$local_file" "$remote_file" "$output_file"
}

# Merge SQLite databases: import local records into remote db
merge_brain_db() {
  local local_db="$1"
  local remote_db="$2"
  local output_db="$3"

  python3 -c "
import sqlite3, sys, os, shutil

local_db_path, remote_db_path, output_db_path = sys.argv[1], sys.argv[2], sys.argv[3]

# Start with remote as base
shutil.copy2(remote_db_path, output_db_path)

if not os.path.exists(local_db_path):
    sys.exit(0)

try:
    local_conn = sqlite3.connect(local_db_path)
    output_conn = sqlite3.connect(output_db_path)

    # Get local chunks not in remote (by file_path + chunk_index)
    local_chunks = local_conn.execute(
        'SELECT file_path, chunk_index, content, file_hash, updated_at FROM chunks'
    ).fetchall()

    existing = set()
    for row in output_conn.execute('SELECT file_path, chunk_index FROM chunks'):
        existing.add((row[0], row[1]))

    inserted = 0
    for file_path, chunk_index, content, file_hash, updated_at in local_chunks:
        if (file_path, chunk_index) not in existing:
            output_conn.execute(
                'INSERT INTO chunks (file_path, chunk_index, content, file_hash, updated_at) VALUES (?, ?, ?, ?, ?)',
                (file_path, chunk_index, content, file_hash, updated_at)
            )
            inserted += 1

    # Similarly merge file_state
    local_states = local_conn.execute(
        'SELECT file_path, file_hash, indexed_at FROM file_state'
    ).fetchall()

    for file_path, file_hash, indexed_at in local_states:
        output_conn.execute(
            'INSERT OR REPLACE INTO file_state (file_path, file_hash, indexed_at) VALUES (?, ?, ?)',
            (file_path, file_hash, indexed_at)
        )

    output_conn.commit()
    local_conn.close()
    output_conn.close()

    if inserted > 0:
        print(f'   🔀 Merged {inserted} chunks into brain.db')
except Exception as e:
    print(f'   ⚠ DB merge error: {e}', file=sys.stderr)
    # Fall back to remote version
    shutil.copy2(remote_db_path, output_db_path)
" "$local_db" "$remote_db" "$output_db"
}

# ─── Push: Upload changed files to pCloud ─────────────────────────────

do_push() {
  echo "☁️  Pushing local changes to pCloud..."
  ensure_remote_folder ""

  local files_pushed=0
  local files_skipped=0

  while IFS= read -r -d '' file; do
    local relative="${file#${BRAIN_DIR}}"

    # Skip excluded files
    if is_excluded "${relative}"; then
      continue
    fi

    local dir
    dir=$(dirname "${relative}")
    [[ "${dir}" == "/" ]] && dir=""

    # Compute SHA and compare with manifest
    local current_sha
    current_sha=$(local_sha256 "${file}")
    local saved_sha
    saved_sha=$(manifest_sha "${relative}")

    if [[ "${current_sha}" == "${saved_sha}" ]]; then
      files_skipped=$((files_skipped + 1))
      continue
    fi

    upload_file "${file}" "${dir}"
    update_manifest "${relative}" "${current_sha}"
    files_pushed=$((files_pushed + 1))
  done < <(find "${BRAIN_DIR}" -type f \
    ! -name ".env" \
    ! -name ".sync-manifest.json" \
    ! -name ".sync-state.json" \
    ! -path "*/tmp/*" \
    ! -path "*/.git/*" \
    -print0)

  log ""
  log "✅ Pushed ${files_pushed} files (${files_skipped} unchanged)"
}

# ─── Pull: Download changed files from pCloud ─────────────────────────

do_pull() {
  echo "☁️  Pulling from pCloud..."

  local remote_files
  remote_files=$(list_remote_files)

  if [[ -z "${remote_files}" ]]; then
    log "No files found on pCloud /agent-brain/"
    return
  fi

  local files_pulled=0
  local files_skipped=0

  while IFS= read -r remote_path; do
    # Skip excluded patterns
    if is_excluded "${remote_path}"; then
      continue
    fi

    local local_path="${BRAIN_DIR}${remote_path}"

    # Check if local file exists and compare SHA
    if [[ -f "${local_path}" ]]; then
      local local_sha
      local_sha=$(local_sha256 "${local_path}")
      local r_sha
      r_sha=$(remote_sha256 "${remote_path}")

      if [[ -n "${r_sha}" && "${local_sha}" == "${r_sha}" ]]; then
        files_skipped=$((files_skipped + 1))
        continue
      fi
    fi

    download_file "${remote_path}" "${local_path}" && {
      # Update manifest with new SHA
      local new_sha
      new_sha=$(local_sha256 "${local_path}")
      update_manifest "${remote_path}" "${new_sha}"
      files_pulled=$((files_pulled + 1))
    }
  done <<< "${remote_files}"

  log ""
  log "✅ Pulled ${files_pulled} files (${files_skipped} unchanged)"
}

# ─── Sync: Bidirectional with conflict resolution ─────────────────────

do_sync() {
  echo "🔄 Bidirectional sync with conflict resolution..."

  # 1. Prepare tmp directory
  mkdir -p "${TMP_DIR}"

  # 2. Get list of remote files
  local remote_files
  remote_files=$(list_remote_files)

  local conflicts=0
  local merged=0

  if [[ -n "${remote_files}" ]]; then
    while IFS= read -r remote_path; do
      if is_excluded "${remote_path}"; then
        continue
      fi

      local local_path="${BRAIN_DIR}${remote_path}"
      local tmp_path="${TMP_DIR}${remote_path}"

      # If local file doesn't exist, just download
      if [[ ! -f "${local_path}" ]]; then
        download_file "${remote_path}" "${local_path}" && {
          local new_sha
          new_sha=$(local_sha256 "${local_path}")
          update_manifest "${remote_path}" "${new_sha}"
        }
        continue
      fi

      # Both exist — check for conflict
      local local_sha
      local_sha=$(local_sha256 "${local_path}")
      local saved_sha
      saved_sha=$(manifest_sha "${remote_path}")
      local r_sha
      r_sha=$(remote_sha256 "${remote_path}")

      # If remote hasn't changed, skip (local is authoritative)
      if [[ -n "${r_sha}" && "${saved_sha}" == "${r_sha}" ]]; then
        continue
      fi

      # If local hasn't changed since last sync, just pull remote
      if [[ "${local_sha}" == "${saved_sha}" ]]; then
        download_file "${remote_path}" "${local_path}" && {
          local new_sha
          new_sha=$(local_sha256 "${local_path}")
          update_manifest "${remote_path}" "${new_sha}"
        }
        continue
      fi

      # Both changed — CONFLICT! Download remote to tmp and merge
      log "⚠ Conflict: ${remote_path}"
      conflicts=$((conflicts + 1))

      mkdir -p "$(dirname "${tmp_path}")"
      if ! download_file "${remote_path}" "${tmp_path}"; then
        continue
      fi

      # Merge based on file type
      case "${remote_path}" in
        /sessions/*.md)
          merge_session_md "${local_path}" "${tmp_path}" "${local_path}"
          log "   🔀 Merged session log"
          ;;
        /brain.db)
          merge_brain_db "${local_path}" "${tmp_path}" "${local_path}"
          log "   🔀 Merged brain.db"
          ;;
        *.md)
          merge_general_md "${local_path}" "${tmp_path}" "${local_path}"
          log "   🔀 Merged markdown"
          ;;
        *)
          # For other files, remote wins
          cp "${tmp_path}" "${local_path}"
          log "   ← Used remote version"
          ;;
      esac

      merged=$((merged + 1))
    done <<< "${remote_files}"
  fi

  # 3. Clean up tmp
  rm -rf "${TMP_DIR}"

  # 4. Now push all local changes
  echo ""
  do_push

  if [[ ${conflicts} -gt 0 ]]; then
    log ""
    log "🔀 Resolved ${merged}/${conflicts} conflicts"
  fi
}

# ─── Main ────────────────────────────────────────────────────────────

case "${MODE}" in
  push)
    do_push
    ;;
  pull)
    do_pull
    ;;
  sync)
    do_sync
    ;;
  *)
    echo "Usage: sync.sh [push|pull|sync]"
    echo "  push  — Upload changed files to pCloud (incremental)"
    echo "  pull  — Download changed files from pCloud (incremental)"
    echo "  sync  — Bidirectional sync with conflict resolution"
    exit 1
    ;;
esac
