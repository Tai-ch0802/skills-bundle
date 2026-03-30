---
description: 從 pCloud 下載 agent-brain 記憶至本地（單向拉取，增量）
---

此 workflow 從 pCloud 雲端儲存拉取最新的 agent-brain 記憶到本地。僅下載在遠端有變更的檔案。適合在切換機器時，或需要取得最新雲端狀態時使用。

如需完整雙向同步，請使用 `/sync-brain`。如需上傳本地資料，請使用 `/upload-brain`。

// turbo-all

1. 檢查 `~/.agent-brain/` 目錄是否存在。如果不存在，執行引導：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. 預覽將會下載的內容：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status
   ```
3. 從 pCloud 拉取變更（增量 — 僅傳輸異動檔案）：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull
   ```
4. 拉取後重新索引以保持搜尋最新：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
5. 使用 notify_user 通知使用者：「✅ Brain 已從 pCloud 下載！」，附帶拉取了多少檔案的摘要。
