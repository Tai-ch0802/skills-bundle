#!/usr/bin/env bash
# install-workflows.sh — 安裝 agent-brain 的 workflows 至全域 ~/.agent/workflows/
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORKFLOW_DIR="${HOME}/.agent/workflows"

echo ""
echo "📋 正在安裝 agent-brain workflows..."

mkdir -p "${WORKFLOW_DIR}"

for wf in "${SKILL_DIR}/workflows/"*.md; do
  [ -f "${wf}" ] || continue
  wf_name="$(basename "${wf}")"
  cp "${wf}" "${WORKFLOW_DIR}/${wf_name}"
  echo "   ✅ 已安裝：${wf_name}"
done

echo ""
echo "🎉 Workflows 已安裝至 ${WORKFLOW_DIR}/"
echo ""
echo "   可用指令："
echo "   • /save-brain — 沖刷 session 記憶並同步至 pCloud"
echo "   • /load-brain — 載入跨 session 記憶至當前上下文"
echo ""
