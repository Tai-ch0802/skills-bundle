#!/usr/bin/env bash
# bootstrap.sh — First-time setup for agent-brain
# Creates local directory structure and authenticates with pCloud
set -euo pipefail

BRAIN_DIR="${HOME}/.agent-brain"
ENV_FILE="${BRAIN_DIR}/.env"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# pCloud app credentials
PCLOUD_CLIENT_ID="hMoFuTa9OVH"
PCLOUD_API_HOST="api.pcloud.com"

echo "🧠 Agent Brain — Bootstrap"
echo "=========================="

# 1. Create directory structure
echo ""
echo "📁 Creating directory structure..."
mkdir -p "${BRAIN_DIR}/sessions"
mkdir -p "${BRAIN_DIR}/projects"
mkdir -p "${BRAIN_DIR}/tmp"
echo "   Created ${BRAIN_DIR}/"

# 2. Handle pCloud authentication
if [[ -f "${ENV_FILE}" ]]; then
  echo ""
  echo "✅ .env already exists, loading credentials..."
  source "${ENV_FILE}"
else
  echo ""
  echo "🔐 pCloud OAuth Authentication"
  echo "   Opening browser for authorization..."
  echo ""

  REDIRECT_URI="http://localhost:65112/oauth-callback"
  AUTH_URL="https://my.pcloud.com/oauth2/authorize?client_id=${PCLOUD_CLIENT_ID}&response_type=code&redirect_uri=${REDIRECT_URI}"

  echo "   If browser doesn't open, visit this URL:"
  echo "   ${AUTH_URL}"
  echo ""

  # Try to open browser
  if command -v open &>/dev/null; then
    open "${AUTH_URL}"
  elif command -v xdg-open &>/dev/null; then
    xdg-open "${AUTH_URL}"
  fi

  echo "   After authorizing, you'll be redirected to a URL containing a 'code' parameter."
  echo "   Paste the full redirect URL or just the code value here:"
  echo ""
  read -r -p "   Code: " AUTH_CODE

  # Extract code from URL if full URL was pasted
  if [[ "${AUTH_CODE}" == *"code="* ]]; then
    AUTH_CODE=$(echo "${AUTH_CODE}" | sed -n 's/.*code=\([^&]*\).*/\1/p')
  fi

  echo ""
  echo "   Exchanging code for access token..."

  # Read client secret
  read -r -s -p "   Client Secret: " CLIENT_SECRET
  echo ""

  TOKEN_RESPONSE=$(curl -s "https://${PCLOUD_API_HOST}/oauth2_token" \
    -d "client_id=${PCLOUD_CLIENT_ID}" \
    -d "client_secret=${CLIENT_SECRET}" \
    -d "code=${AUTH_CODE}")

  ACCESS_TOKEN=$(echo "${TOKEN_RESPONSE}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'access_token' in data:
    print(data['access_token'])
else:
    print('ERROR: ' + json.dumps(data), file=sys.stderr)
    sys.exit(1)
" 2>&1)

  if [[ "${ACCESS_TOKEN}" == ERROR:* ]]; then
    echo "   ❌ Failed to get access token: ${ACCESS_TOKEN}"
    exit 1
  fi

  # Detect locationid from token response
  LOCATION_ID=$(echo "${TOKEN_RESPONSE}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('locationid', 1))
")

  if [[ "${LOCATION_ID}" == "2" ]]; then
    PCLOUD_API_HOST="eapi.pcloud.com"
  fi

  # Write .env
  cat > "${ENV_FILE}" << EOF
PCLOUD_ACCESS_TOKEN=${ACCESS_TOKEN}
PCLOUD_API_HOST=${PCLOUD_API_HOST}
EOF
  chmod 600 "${ENV_FILE}"
  echo "   ✅ Credentials saved to ${ENV_FILE}"
fi

# 3. Initialize sync state
SYNC_MANIFEST="${BRAIN_DIR}/.sync-manifest.json"
if [[ ! -f "${SYNC_MANIFEST}" ]]; then
  echo '{"files": {}}' > "${SYNC_MANIFEST}"
fi

# 4. Initialize memory files if they don't exist
if [[ ! -f "${BRAIN_DIR}/MEMORY.md" ]]; then
  cat > "${BRAIN_DIR}/MEMORY.md" << 'EOF'
# Agent Brain — Long-Term Memory

> Last updated: (auto-updated by agent)

## Technical Knowledge


## Projects Overview

| Project | Repo | Status | Key Tech |
|---------|------|--------|----------|

## Cross-Project Patterns


## Environment


## Important Decisions

EOF
  echo "   📝 Created MEMORY.md"
fi

if [[ ! -f "${BRAIN_DIR}/USER.md" ]]; then
  cat > "${BRAIN_DIR}/USER.md" << 'EOF'
# User Profile

## Identity


## Coding Preferences


## Communication Style


## Workflow Habits


## Pet Peeves

EOF
  echo "   📝 Created USER.md"
fi

if [[ ! -f "${BRAIN_DIR}/STATE.md" ]]; then
  cat > "${BRAIN_DIR}/STATE.md" << 'EOF'
# Active State

> Updated: (auto-updated by agent)

## Current Focus


## Working Context


## Scratch Pad

EOF
  echo "   📝 Created STATE.md"
fi

# 5. Initialize SQLite database
echo ""
echo "🗄️  Initializing brain.db..."
python3 "${SKILL_DIR}/scripts/index-memory.py" init
echo "   ✅ brain.db ready"

# 6. Try to pull from pCloud if remote data exists
source "${ENV_FILE}"
echo ""
echo "☁️  Checking pCloud for existing brain data..."

REMOTE_CHECK=$(curl -s "https://${PCLOUD_API_HOST}/listfolder?path=/agent-brain&auth=${PCLOUD_ACCESS_TOKEN}" 2>/dev/null || echo '{"result": 2005}')
REMOTE_RESULT=$(echo "${REMOTE_CHECK}" | python3 -c "import sys, json; print(json.load(sys.stdin).get('result', 9999))")

if [[ "${REMOTE_RESULT}" == "0" ]]; then
  echo "   Found existing brain on pCloud! Pulling..."
  bash "${SKILL_DIR}/scripts/sync.sh" pull
  echo "   ✅ Pulled existing brain data"
  # Re-index after pull
  python3 "${SKILL_DIR}/scripts/index-memory.py" index
else
  echo "   No existing brain on pCloud (will create on first sync)"
  # Create remote folder
  curl -s "https://${PCLOUD_API_HOST}/createfolderifnotexists?path=/agent-brain&auth=${PCLOUD_ACCESS_TOKEN}" > /dev/null 2>&1 || true
fi

# 7. Offer to install global workflows
echo ""
echo "📋 Agent Brain includes global workflows for your AI agent:"
echo "   • /save-brain     — Flush session memory (local only)"
echo "   • /upload-brain   — Push local changes to pCloud"
echo "   • /download-brain — Pull cloud changes to local"
echo "   • /sync-brain     — Bidirectional pCloud sync (with conflict resolution)"
echo "   • /load-brain     — Load cross-session memory into context"
echo ""
read -r -p "   Install workflows to ~/.agent/workflows/? [Y/n] " INSTALL_WF
INSTALL_WF="${INSTALL_WF:-Y}"

if [[ "${INSTALL_WF}" =~ ^[Yy]$ ]]; then
  bash "${SKILL_DIR}/scripts/install-workflows.sh"
else
  echo ""
  echo "   ⏭️  Skipped. You can install later with:"
  echo "   bash ${SKILL_DIR}/scripts/install-workflows.sh"
  echo ""
fi

echo ""
echo "🧠 Agent Brain bootstrap complete!"
echo "   Local:  ${BRAIN_DIR}/"
echo "   Remote: pCloud /agent-brain/"
echo ""
echo "   Memory Ontology:"
echo "   • IDENTITY  → USER.md     (who the user is)"
echo "   • KNOWLEDGE → MEMORY.md   (durable facts)"
echo "   • EXPERIENCE→ sessions/   (what happened)"
echo "   • STATE     → STATE.md    (current work context, local only)"
echo ""
