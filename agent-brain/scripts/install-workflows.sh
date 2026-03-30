#!/usr/bin/env bash
# install-workflows.sh — Install agent-brain workflows to global ~/.agent/workflows/
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKFLOW_DIR="${HOME}/.agent/workflows"

echo ""
echo "📋 Installing agent-brain workflows..."

mkdir -p "${WORKFLOW_DIR}"

for wf in "${SKILL_DIR}/workflows/"*.md; do
  [ -f "${wf}" ] || continue
  wf_name="$(basename "${wf}")"
  cp "${wf}" "${WORKFLOW_DIR}/${wf_name}"
  echo "   ✅ Installed: ${wf_name}"
done

echo ""
echo "🎉 Workflows installed to ${WORKFLOW_DIR}/"
echo ""
echo "   Available commands:"
echo "   • /save-brain     — Flush session memory (local only)"
echo "   • /upload-brain   — Push local changes to pCloud"
echo "   • /download-brain — Pull cloud changes to local"
echo "   • /sync-brain     — Bidirectional pCloud sync (with conflict resolution)"
echo "   • /load-brain     — Load cross-session memory into context"
echo ""
