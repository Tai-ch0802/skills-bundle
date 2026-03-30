#!/usr/bin/env bash
# update.sh — Update installed agent-brain skill from source repo
#
# Automatically detects its own location and determines whether it's running
# from the source repo or the installed destination. Then copies skill files
# in the correct direction. Does NOT touch ~/.agent-brain/ data or credentials.
#
# Usage:
#   bash update.sh                                          # auto-discover source
#   bash update.sh /path/to/skills-bundle/agent-brain       # explicit source path
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

INSTALLED_HOME="${HOME}/.gemini/antigravity/skills/agent-brain"
WORKFLOW_HOME="${HOME}/.agent/workflows"
BRAIN_DIR="${HOME}/.agent-brain"
SOURCE_BREADCRUMB="${INSTALLED_HOME}/.update-source"

# ─── Determine mode based on relative position ───────────────────────
#   "pull" = we are the installed copy, need to find and pull FROM the repo
#   "push" = we are the repo source, push TO the installed location
# ─────────────────────────────────────────────────────────────────────

determine_mode() {
  if [[ "${SKILL_DIR}" == "${INSTALLED_HOME}" ]]; then
    # ── Home-level install (~/.gemini/antigravity/skills/agent-brain)
    MODE="pull"
    TARGET="${SKILL_DIR}"
    WORKFLOW_DIR="${WORKFLOW_HOME}"
    echo "📍 Detected: home-level install"

  elif [[ "${SKILL_DIR}" == */.agent/skills/agent-brain ]]; then
    # ── Project-level install (<project>/.agent/skills/agent-brain)
    MODE="pull"
    TARGET="${SKILL_DIR}"
    PROJECT_ROOT="${SKILL_DIR%/.agent/skills/agent-brain}"
    WORKFLOW_DIR="${PROJECT_ROOT}/.agent/workflows"
    echo "📍 Detected: project-level install (${PROJECT_ROOT})"

  else
    # ── Source repo (e.g., ~/Documents/.../skills-bundle/agent-brain)
    MODE="push"
    SOURCE="${SKILL_DIR}"
    TARGET="${INSTALLED_HOME}"
    WORKFLOW_DIR="${WORKFLOW_HOME}"
    echo "📍 Detected: source repo"
  fi
}

# ─── Find the source repo (only needed in pull mode) ─────────────────
find_source() {
  # Priority: 1) explicit arg  2) saved breadcrumb  3) auto-discover

  # 1) Explicit argument
  if [[ -n "${1:-}" ]]; then
    local candidate="$1"
    if [[ -f "${candidate}/SKILL.md" ]]; then
      SOURCE="${candidate}"
      echo "📦 Source (from argument): ${SOURCE}"
      echo "${SOURCE}" > "${SOURCE_BREADCRUMB}"
      return 0
    else
      echo "❌ Provided path is not a valid agent-brain directory: ${candidate}"
      exit 1
    fi
  fi

  # 2) Saved breadcrumb from a previous successful run
  if [[ -f "${SOURCE_BREADCRUMB}" ]]; then
    local saved
    saved="$(cat "${SOURCE_BREADCRUMB}")"
    if [[ -f "${saved}/SKILL.md" ]]; then
      SOURCE="${saved}"
      echo "📦 Source (saved): ${SOURCE}"
      return 0
    else
      echo "⚠️  Saved source path no longer valid: ${saved}"
      rm -f "${SOURCE_BREADCRUMB}"
    fi
  fi

  # 3) Auto-discover in common locations
  local candidates=(
    "${HOME}/Documents/personal/repo/skills-bundle/agent-brain"
    "${HOME}/skills-bundle/agent-brain"
    "${HOME}/repos/skills-bundle/agent-brain"
    "${HOME}/Projects/skills-bundle/agent-brain"
    "${HOME}/dev/skills-bundle/agent-brain"
  )
  for candidate in "${candidates[@]}"; do
    if [[ -f "${candidate}/SKILL.md" ]]; then
      SOURCE="${candidate}"
      echo "📦 Source (auto-discovered): ${SOURCE}"
      echo "${SOURCE}" > "${SOURCE_BREADCRUMB}"
      return 0
    fi
  done

  # Nothing found
  echo "❌ Cannot find source repo automatically."
  echo "   Please provide the path as an argument:"
  echo "   bash ${SCRIPT_DIR}/update.sh /path/to/skills-bundle/agent-brain"
  exit 1
}

# ─── Copy skill files from SOURCE to TARGET ──────────────────────────
do_update() {
  echo ""
  echo "🔄 Agent Brain — Update"
  echo "════════════════════════════════════════════"
  echo "   Source:    ${SOURCE}"
  echo "   Target:    ${TARGET}"
  echo "   Workflows: ${WORKFLOW_DIR}"
  echo ""

  # Ensure target exists
  if [[ ! -d "${TARGET}" ]]; then
    echo "📦 Target directory does not exist. Creating..."
    if ! mkdir -p "${TARGET}" 2>/dev/null; then
      echo "❌ Cannot create ${TARGET}"
      echo "   Please create it manually or run bootstrap.sh first."
      exit 1
    fi
  fi

  # Guard: source and target must be different
  if [[ "$(cd "${SOURCE}" && pwd)" == "$(cd "${TARGET}" && pwd)" ]]; then
    echo "❌ Source and target are the same directory. Nothing to do."
    exit 1
  fi

  local count=0

  echo "📋 Updating skill files..."

  # SKILL.md
  cp "${SOURCE}/SKILL.md" "${TARGET}/SKILL.md"
  echo "   ✅ SKILL.md"
  ((count++))

  # references/
  mkdir -p "${TARGET}/references"
  for ref in "${SOURCE}/references/"*.md; do
    [ -f "${ref}" ] || continue
    cp "${ref}" "${TARGET}/references/"
    echo "   ✅ references/$(basename "${ref}")"
    ((count++))
  done

  # scripts/ (skip __pycache__)
  mkdir -p "${TARGET}/scripts"
  for script in "${SOURCE}/scripts/"*.sh "${SOURCE}/scripts/"*.py; do
    [ -f "${script}" ] || continue
    cp "${script}" "${TARGET}/scripts/"
    if [[ "${script}" == *.sh ]]; then
      chmod +x "${TARGET}/scripts/$(basename "${script}")"
    fi
    echo "   ✅ scripts/$(basename "${script}")"
    ((count++))
  done

  # workflows/
  mkdir -p "${TARGET}/workflows"
  for wf in "${SOURCE}/workflows/"*.md; do
    [ -f "${wf}" ] || continue
    cp "${wf}" "${TARGET}/workflows/"
    echo "   ✅ workflows/$(basename "${wf}")"
    ((count++))
  done

  # ─── Install global workflows ──────────────────────────────────────
  echo ""
  echo "📋 Installing workflows → ${WORKFLOW_DIR}/"
  mkdir -p "${WORKFLOW_DIR}"

  for wf in "${SOURCE}/workflows/"*.md; do
    [ -f "${wf}" ] || continue
    local wf_name
    wf_name="$(basename "${wf}")"
    cp "${wf}" "${WORKFLOW_DIR}/${wf_name}"
    echo "   ✅ ${wf_name}"
  done

  # ─── Initialize STATE.md if missing ────────────────────────────────
  if [[ -d "${BRAIN_DIR}" && ! -f "${BRAIN_DIR}/STATE.md" ]]; then
    echo ""
    echo "📝 Creating STATE.md (new in v2)..."
    cat > "${BRAIN_DIR}/STATE.md" << 'STATEEOF'
# Active State

> Updated: (auto-updated by agent)

## Current Focus


## Working Context


## Scratch Pad

STATEEOF
    echo "   ✅ STATE.md created"
  fi

  # ─── Summary ───────────────────────────────────────────────────────
  echo ""
  echo "════════════════════════════════════════════"
  echo "✅ Update complete! (${count} files updated)"
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
}

# ─── Main ─────────────────────────────────────────────────────────────
determine_mode

if [[ "${MODE}" == "pull" ]]; then
  find_source "${1:-}"
else
  # push mode: SOURCE is already set by determine_mode
  echo "📦 Source: ${SOURCE}"
fi

do_update
