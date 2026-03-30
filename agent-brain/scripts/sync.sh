#!/usr/bin/env bash
# sync.sh — Incremental SHA-based pCloud sync for agent-brain
# Usage: sync.sh [push|pull|sync|status]
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

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

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

  local size
  size=$(wc -c < "${local_path}" | tr -d ' ')
  log "↑ ${remote_dir:+${remote_dir}/}${filename} (${size} bytes)"
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

  local size
  size=$(wc -c < "${local_path}" | tr -d ' ')
  log "↓ ${remote_path} (${size} bytes)"
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

# Check if a file should be excluded from ALL sync operations
is_excluded() {
  local relative="$1"
  case "${relative}" in
    /.env|/.sync-manifest.json|/.sync-state.json) return 0 ;;
    /STATE.md) return 0 ;;    # STATE is ephemeral, never synced
    /tmp|/tmp/*) return 0 ;;
    *) return 1 ;;
  esac
}

# Check if a file is a derived artifact (skip during download/compare, but still push)
is_derived() {
  local relative="$1"
  case "${relative}" in
    /brain.db|/brain.db-wal|/brain.db-shm) return 0 ;;
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
    # Support both HH:MM and HH:MM:SS formats
    blocks = re.split(r'(?=^## Session \d{2}:\d{2}(?::\d{2})?)', text, flags=re.MULTILINE)
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
# Strategy: section-level merge using ## headings as keys
merge_general_md() {
  local local_file="$1"
  local remote_file="$2"
  local output_file="$3"

  python3 -c "
import re, sys, os

def clean_merge_artifacts(text):
    \"\"\"Remove merge marker comments and duplicate preambles from previous syncs.\"\"\"
    # Remove <!-- merged from local --> markers
    text = re.sub(r'\n*<!-- merged from local -->\n*', '\n', text)
    # Remove duplicate '> Last updated:' lines (keep the first one only)
    lines = text.split('\n')
    seen_updated = False
    cleaned = []
    for line in lines:
        if re.match(r'^> Last updated:', line.strip()):
            if not seen_updated:
                seen_updated = True
                cleaned.append(line)
            # Skip subsequent duplicates
        else:
            cleaned.append(line)
    return '\n'.join(cleaned)

def parse_sections(text):
    \"\"\"Split markdown into (header, body) sections by ## headings.\"\"\"
    if not text.strip():
        return [], ''
    lines = text.split('\n')
    preamble_lines = []
    sections = []
    current_header = None
    current_body = []

    for line in lines:
        if re.match(r'^## ', line):
            if current_header is not None:
                sections.append((current_header, '\n'.join(current_body).strip()))
            current_header = line.strip()
            current_body = []
        elif current_header is None:
            preamble_lines.append(line)
        else:
            current_body.append(line)

    if current_header is not None:
        sections.append((current_header, '\n'.join(current_body).strip()))

    return sections, '\n'.join(preamble_lines).strip()

local_path, remote_path, output_path = sys.argv[1], sys.argv[2], sys.argv[3]

local_text = open(local_path, encoding='utf-8').read() if os.path.exists(local_path) else ''
remote_text = open(remote_path, encoding='utf-8').read()

# Clean up artifacts from previous merges
local_text = clean_merge_artifacts(local_text)
remote_text = clean_merge_artifacts(remote_text)

# If identical after cleanup, just use local
if local_text.strip() == remote_text.strip():
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(local_text)
    sys.exit(0)

local_sections, local_preamble = parse_sections(local_text)
remote_sections, remote_preamble = parse_sections(remote_text)

# Use the longer preamble (usually # Title + description)
preamble = local_preamble if len(local_preamble) >= len(remote_preamble) else remote_preamble

# Build section maps
local_map = {h: b for h, b in local_sections}
remote_map = {h: b for h, b in remote_sections}

all_headers = list(dict.fromkeys(
    [h for h, _ in remote_sections] + [h for h, _ in local_sections]
))

merged_sections = []
for header in all_headers:
    local_body = local_map.get(header)
    remote_body = remote_map.get(header)

    if local_body is not None and remote_body is not None:
        # Both have this section — keep the longer one (more content = more recent edits)
        merged_sections.append((header, local_body if len(local_body) >= len(remote_body) else remote_body))
    elif local_body is not None:
        merged_sections.append((header, local_body))
    else:
        merged_sections.append((header, remote_body))

result_parts = [preamble] if preamble else []
for header, body in merged_sections:
    if body:
        result_parts.append(header + '\n\n' + body)
    else:
        result_parts.append(header)

with open(output_path, 'w', encoding='utf-8') as f:
    f.write('\n\n'.join(result_parts) + '\n')
" "$local_file" "$remote_file" "$output_file"
}

# ─── Status: Dry-run preview of what would change ─────────────────────

do_status() {
  echo "📊 Sync Status ($(timestamp))"
  echo "════════════════════════════════════════════"

  local to_push=0
  local to_pull=0
  local conflicts=0
  local up_to_date=0

  echo ""
  echo "   Local changes (would push):"

  # Check local files
  while IFS= read -r -d '' file; do
    local relative="${file#${BRAIN_DIR}}"

    if is_excluded "${relative}"; then
      continue
    fi

    local current_sha
    current_sha=$(local_sha256 "${file}")
    local saved_sha
    saved_sha=$(manifest_sha "${relative}")

    if [[ "${current_sha}" != "${saved_sha}" ]]; then
      local size
      size=$(wc -c < "${file}" | tr -d ' ')
      log "   → ${relative} (${size} bytes)"
      to_push=$((to_push + 1))
    else
      up_to_date=$((up_to_date + 1))
    fi
  done < <(find "${BRAIN_DIR}" -type f \
    ! -name ".env" \
    ! -name ".sync-manifest.json" \
    ! -name ".sync-state.json" \
    ! -name "STATE.md" \
    ! -path "*/tmp/*" \
    ! -path "*/.git/*" \
    -print0)

  if [[ ${to_push} -eq 0 ]]; then
    log "   (none)"
  fi

  echo ""
  echo "   Remote changes (would pull):"

  local remote_files
  remote_files=$(list_remote_files 2>/dev/null || echo "")

  if [[ -n "${remote_files}" ]]; then
    while IFS= read -r remote_path; do
      if is_excluded "${remote_path}"; then
        continue
      fi
      if is_derived "${remote_path}"; then
        continue
      fi

      local local_path="${BRAIN_DIR}${remote_path}"

      if [[ -f "${local_path}" ]]; then
        local local_sha
        local_sha=$(local_sha256 "${local_path}")
        local r_sha
        r_sha=$(remote_sha256 "${remote_path}")

        if [[ -n "${r_sha}" && "${local_sha}" != "${r_sha}" ]]; then
          local saved_sha
          saved_sha=$(manifest_sha "${remote_path}")
          if [[ "${local_sha}" != "${saved_sha}" && "${r_sha}" != "${saved_sha}" ]]; then
            log "   ⚠ ${remote_path} (CONFLICT — both sides changed)"
            conflicts=$((conflicts + 1))
          elif [[ "${local_sha}" == "${saved_sha}" ]]; then
            log "   ← ${remote_path}"
            to_pull=$((to_pull + 1))
          fi
        fi
      else
        log "   ← ${remote_path} (new)"
        to_pull=$((to_pull + 1))
      fi
    done <<< "${remote_files}"
  fi

  if [[ ${to_pull} -eq 0 && ${conflicts} -eq 0 ]]; then
    log "   (none)"
  fi

  echo ""
  echo "════════════════════════════════════════════"
  echo "   Summary: ${to_push} to push, ${to_pull} to pull, ${conflicts} conflicts, ${up_to_date} up-to-date"
  echo ""
}

# ─── Push: Upload changed files to pCloud ─────────────────────────────

do_push() {
  echo "☁️  Pushing local changes to pCloud... ($(timestamp))"
  ensure_remote_folder ""

  local files_pushed=0
  local files_skipped=0
  local files_new=0

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

    if [[ -z "${saved_sha}" ]]; then
      files_new=$((files_new + 1))
    fi

    upload_file "${file}" "${dir}"
    update_manifest "${relative}" "${current_sha}"
    files_pushed=$((files_pushed + 1))
  done < <(find "${BRAIN_DIR}" -type f \
    ! -name ".env" \
    ! -name ".sync-manifest.json" \
    ! -name ".sync-state.json" \
    ! -name "STATE.md" \
    ! -path "*/tmp/*" \
    ! -path "*/.git/*" \
    -print0)

  echo ""
  echo "   ┌─────────────────────────────────┐"
  echo "   │ Push Summary                    │"
  echo "   ├─────────────────────────────────┤"
  printf "   │ %-20s %10s │\n" "Pushed (updated):" "$((files_pushed - files_new))"
  printf "   │ %-20s %10s │\n" "Pushed (new):" "${files_new}"
  printf "   │ %-20s %10s │\n" "Skipped (unchanged):" "${files_skipped}"
  printf "   │ %-20s %10s │\n" "Total files:" "$((files_pushed + files_skipped))"
  echo "   └─────────────────────────────────┘"
  echo ""
  log "✅ Push complete"
}

# ─── Pull: Download changed files from pCloud ─────────────────────────

do_pull() {
  echo "☁️  Pulling from pCloud... ($(timestamp))"

  local remote_files
  remote_files=$(list_remote_files)

  if [[ -z "${remote_files}" ]]; then
    log "No files found on pCloud /agent-brain/"
    return
  fi

  local files_pulled=0
  local files_new=0
  local files_skipped=0

  while IFS= read -r remote_path; do
    # Skip excluded patterns
    if is_excluded "${remote_path}"; then
      continue
    fi

    # Skip derived artifacts (brain.db is rebuilt locally)
    if is_derived "${remote_path}"; then
      continue
    fi

    local local_path="${BRAIN_DIR}${remote_path}"
    local is_new_file=false

    if [[ ! -f "${local_path}" ]]; then
      is_new_file=true
    fi

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
      if [[ "${is_new_file}" == true ]]; then
        files_new=$((files_new + 1))
      fi
    }
  done <<< "${remote_files}"

  echo ""
  echo "   ┌─────────────────────────────────┐"
  echo "   │ Pull Summary                    │"
  echo "   ├─────────────────────────────────┤"
  printf "   │ %-20s %10s │\n" "Pulled (updated):" "$((files_pulled - files_new))"
  printf "   │ %-20s %10s │\n" "Pulled (new):" "${files_new}"
  printf "   │ %-20s %10s │\n" "Skipped (unchanged):" "${files_skipped}"
  echo "   └─────────────────────────────────┘"
  echo ""
  log "✅ Pull complete"
}

# ─── Sync: Bidirectional with conflict resolution ─────────────────────

do_sync() {
  echo "🔄 Bidirectional sync with conflict resolution... ($(timestamp))"

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

      # Skip derived artifacts — brain.db will be rebuilt after merge
      if is_derived "${remote_path}"; then
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
      local local_size remote_size
      local_size=$(wc -c < "${local_path}" | tr -d ' ')
      log "⚠ Conflict: ${remote_path} (local: ${local_size} bytes)"
      conflicts=$((conflicts + 1))

      mkdir -p "$(dirname "${tmp_path}")"
      if ! download_file "${remote_path}" "${tmp_path}"; then
        continue
      fi
      remote_size=$(wc -c < "${tmp_path}" | tr -d ' ')

      # Merge based on file type
      case "${remote_path}" in
        /sessions/*.md)
          merge_session_md "${local_path}" "${tmp_path}" "${local_path}"
          log "   🔀 Merged session log (append dedup)"
          ;;
        *.md)
          merge_general_md "${local_path}" "${tmp_path}" "${local_path}"
          log "   🔀 Merged markdown (section merge, local: ${local_size}b, remote: ${remote_size}b)"
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

  # 4. Rebuild brain.db from merged markdown files
  #    brain.db is a derived artifact — never merged directly
  echo ""
  log "🧠 Rebuilding brain.db from merged markdown..."
  rm -f "${BRAIN_DIR}/brain.db" "${BRAIN_DIR}/brain.db-wal" "${BRAIN_DIR}/brain.db-shm"

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  python3 "${script_dir}/index-memory.py" rebuild

  # 5. Now push all local changes (including rebuilt brain.db)
  echo ""
  do_push

  if [[ ${conflicts} -gt 0 ]]; then
    echo ""
    echo "   ┌─────────────────────────────────┐"
    echo "   │ Conflict Resolution             │"
    echo "   ├─────────────────────────────────┤"
    printf "   │ %-20s %10s │\n" "Conflicts detected:" "${conflicts}"
    printf "   │ %-20s %10s │\n" "Auto-merged:" "${merged}"
    echo "   └─────────────────────────────────┘"
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
  status)
    do_status
    ;;
  *)
    echo "Usage: sync.sh [push|pull|sync|status]"
    echo "  push   — Upload changed files to pCloud (incremental)"
    echo "  pull   — Download changed files from pCloud (incremental)"
    echo "  sync   — Bidirectional sync with conflict resolution"
    echo "  status — Preview what would change (dry-run, no writes)"
    exit 1
    ;;
esac
