---
description: 上傳本地 agent-brain 變更至 pCloud（單向推送，增量）
---

此 workflow 將本地 agent-brain 記憶變更推送到 pCloud 雲端儲存。僅上傳自上次同步以來有變更的檔案。適合在 `/save-brain` 後使用，將最新記憶備份到雲端。

如需完整雙向同步，請使用 `/sync-brain`。如需下載雲端資料，請使用 `/download-brain`。

// turbo-all

1. 檢查 `~/.agent-brain/` 目錄是否存在。如果不存在，執行引導：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. 預覽將會上傳的內容：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status
   ```
3. 推送本地變更至 pCloud（增量 — 僅傳輸異動檔案）：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push
   ```
4. 使用 notify_user 通知使用者：「✅ Brain 已上傳至 pCloud！」，附帶推送了多少檔案的摘要。
