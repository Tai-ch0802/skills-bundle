#!/usr/bin/env bash
# update.sh — Update installed agent-brain skill files from repo source
#
# This script copies skill definition files (SKILL.md, references, scripts,
# workflows) from the repo to the installed location. It does NOT touch:
#   - ~/.agent-brain/  (your memory data, .env credentials, brain.db)
#   - Any runtime state
#
# Usage:
#   bash agent-brain/scripts/update.sh          # from repo root
#   bash ~/.gemini/antigravity/skills/agent-brain/scripts/update.sh  # from installed location
#
set -euo pipefail

# ─── Detect source directory ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Validate that this looks like the agent-brain skill directory
if [[ ! -f "${SKILL_SRC}/SKILL.md" ]]; then
  echo "❌ Cannot find SKILL.md in ${SKILL_SRC}"
  echo "   Run this script from the agent-brain skill directory."
  exit 1
fi

# ─── Target directories ──────────────────────────────────────────────
INSTALLED_SKILL="${HOME}/.gemini/antigravity/skills/agent-brain"
WORKFLOW_DIR="${HOME}/.agent/workflows"
BRAIN_DIR="${HOME}/.agent-brain"

echo ""
echo "🔄 Agent Brain — Update"
echo "════════════════════════════════════════════"
echo "   Source:    ${SKILL_SRC}"
echo "   Target:    ${INSTALLED_SKILL}"
echo "   Workflows: ${WORKFLOW_DIR}"
echo ""

# ─── Check if this is a first-time install or an update ───────────────
if [[ ! -d "${INSTALLED_SKILL}" ]]; then
  echo "📦 First-time install detected. Creating target directory..."
  if ! mkdir -p "${INSTALLED_SKILL}" 2>/dev/null; then
    echo "❌ Cannot create ${INSTALLED_SKILL}"
    echo "   Please run bootstrap.sh first, or create the directory manually:"
    echo "   sudo mkdir -p ${INSTALLED_SKILL} && sudo chown -R $(whoami) $(dirname "${INSTALLED_SKILL}")"
    exit 1
  fi
fi

# ─── Copy skill files ────────────────────────────────────────────────
echo "📋 Updating skill files..."

# SKILL.md
cp "${SKILL_SRC}/SKILL.md" "${INSTALLED_SKILL}/SKILL.md"
echo "   ✅ SKILL.md"

# references/
mkdir -p "${INSTALLED_SKILL}/references"
for ref in "${SKILL_SRC}/references/"*.md; do
  [ -f "${ref}" ] || continue
  cp "${ref}" "${INSTALLED_SKILL}/references/"
  echo "   ✅ references/$(basename "${ref}")"
done

# scripts/ (skip __pycache__)
mkdir -p "${INSTALLED_SKILL}/scripts"
for script in "${SKILL_SRC}/scripts/"*.{sh,py}; do
  [ -f "${script}" ] || continue
  cp "${script}" "${INSTALLED_SKILL}/scripts/"
  # Ensure shell scripts are executable
  if [[ "${script}" == *.sh ]]; then
    chmod +x "${INSTALLED_SKILL}/scripts/$(basename "${script}")"
  fi
  echo "   ✅ scripts/$(basename "${script}")"
done

# workflows/
mkdir -p "${INSTALLED_SKILL}/workflows"
for wf in "${SKILL_SRC}/workflows/"*.md; do
  [ -f "${wf}" ] || continue
  cp "${wf}" "${INSTALLED_SKILL}/workflows/"
  echo "   ✅ workflows/$(basename "${wf}")"
done

# ─── Install global workflows ────────────────────────────────────────
echo ""
echo "📋 Installing global workflows..."
mkdir -p "${WORKFLOW_DIR}"

for wf in "${SKILL_SRC}/workflows/"*.md; do
  [ -f "${wf}" ] || continue
  wf_name="$(basename "${wf}")"
  cp "${wf}" "${WORKFLOW_DIR}/${wf_name}"
  echo "   ✅ ${wf_name} → ${WORKFLOW_DIR}/"
done

# ─── Initialize STATE.md if missing ──────────────────────────────────
if [[ -d "${BRAIN_DIR}" && ! -f "${BRAIN_DIR}/STATE.md" ]]; then
  echo ""
  echo "📝 Creating STATE.md (new in v2)..."
  cat > "${BRAIN_DIR}/STATE.md" << 'EOF'
# Active State

> Updated: (auto-updated by agent)

## Current Focus


## Working Context


## Scratch Pad

EOF
  echo "   ✅ STATE.md created"
fi

# ─── Summary ─────────────────────────────────────────────────────────
echo ""
echo "════════════════════════════════════════════"
echo "✅ Update complete!"
echo ""
echo "   Preserved (untouched):"
echo "   • ${BRAIN_DIR}/.env          (credentials)"
echo "   • ${BRAIN_DIR}/MEMORY.md     (knowledge)"
echo "   • ${BRAIN_DIR}/USER.md       (identity)"
echo "   • ${BRAIN_DIR}/STATE.md      (state)"
echo "   • ${BRAIN_DIR}/sessions/     (experience)"
echo "   • ${BRAIN_DIR}/projects/     (project context)"
echo "   • ${BRAIN_DIR}/brain.db      (search index)"
echo ""
echo "   Available commands:"
echo "   • /save-brain     — Flush session memory (local only)"
echo "   • /upload-brain   — Push local changes to pCloud"
echo "   • /download-brain — Pull cloud changes to local"
echo "   • /sync-brain     — Bidirectional pCloud sync"
echo "   • /load-brain     — Load cross-session memory"
echo ""
