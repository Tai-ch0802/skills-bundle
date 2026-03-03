#!/usr/bin/env bash
# sync.sh — Bidirectional pCloud sync for agent-brain
# Usage: sync.sh [push|pull|sync]
set -euo pipefail

BRAIN_DIR="${HOME}/.agent-brain"
ENV_FILE="${BRAIN_DIR}/.env"
SYNC_STATE="${BRAIN_DIR}/.sync-state.json"

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
    return
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

# ─── Push: Upload local changes to pCloud ────────────────────────────

do_push() {
  echo "☁️  Pushing local changes to pCloud..."
  ensure_remote_folder ""

  # Find all syncable files (exclude .env, .sync-state.json)
  local files_pushed=0

  while IFS= read -r -d '' file; do
    local relative="${file#${BRAIN_DIR}}"
    local dir
    dir=$(dirname "${relative}")
    # Normalize root "/" to empty string to avoid double-slash in remote paths
    [[ "${dir}" == "/" ]] && dir=""

    # Skip files that should not be synced
    case "${relative}" in
      /.env|/.sync-state.json) continue ;;
    esac

    upload_file "${file}" "${dir}"
    files_pushed=$((files_pushed + 1))
  done < <(find "${BRAIN_DIR}" -type f \
    ! -name ".env" \
    ! -name ".sync-state.json" \
    ! -path "*/.git/*" \
    -print0)

  # Update sync state
  python3 -c "
import json, time
state = {'last_sync': time.strftime('%Y-%m-%dT%H:%M:%S%z'), 'direction': 'push', 'files_count': ${files_pushed}}
with open('${SYNC_STATE}', 'w') as f:
    json.dump(state, f, indent=2)
"

  log ""
  log "✅ Pushed ${files_pushed} files to pCloud /agent-brain/"
}

# ─── Pull: Download from pCloud to local ─────────────────────────────

do_pull() {
  echo "☁️  Pulling from pCloud..."

  local remote_files
  remote_files=$(list_remote_files)

  if [[ -z "${remote_files}" ]]; then
    log "No files found on pCloud /agent-brain/"
    return
  fi

  local files_pulled=0
  while IFS= read -r remote_path; do
    local local_path="${BRAIN_DIR}${remote_path}"
    download_file "${remote_path}" "${local_path}"
    files_pulled=$((files_pulled + 1))
  done <<< "${remote_files}"

  # Update sync state
  python3 -c "
import json, time
state = {'last_sync': time.strftime('%Y-%m-%dT%H:%M:%S%z'), 'direction': 'pull', 'files_count': ${files_pulled}}
with open('${SYNC_STATE}', 'w') as f:
    json.dump(state, f, indent=2)
"

  log ""
  log "✅ Pulled ${files_pulled} files from pCloud /agent-brain/"
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
    do_pull
    echo ""
    do_push
    ;;
  *)
    echo "Usage: sync.sh [push|pull|sync]"
    echo "  push  — Upload local changes to pCloud"
    echo "  pull  — Download from pCloud to local"
    echo "  sync  — Pull first, then push (bidirectional)"
    exit 1
    ;;
esac
