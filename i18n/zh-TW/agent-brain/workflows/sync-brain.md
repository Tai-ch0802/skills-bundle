---
description: 將 agent-brain 記憶同步至 pCloud（雙向含衝突解決）
---

此 workflow 將本地 agent-brain 記憶與 pCloud 雲端儲存進行同步。使用基於 SHA 的增量同步，僅傳輸有變更的檔案，並自動解決衝突。

如需較簡單的單向操作，請使用 `/upload-brain`（僅推送）或 `/download-brain`（僅拉取）。

// turbo-all

1. 檢查 `~/.agent-brain/` 目錄是否存在。如果不存在，執行引導：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. 預覽同步狀態，向使用者顯示將會發生什麼：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status
   ```
3. 執行雙向同步（拉取遠端變更、解決衝突、推送本地變更）：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
   ```
4. 同步後重新索引以保持搜尋最新：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
5. 使用 notify_user 通知使用者：「✅ Brain 已與 pCloud 同步！」，附帶推送/拉取檔案數量和已解決衝突的摘要。
