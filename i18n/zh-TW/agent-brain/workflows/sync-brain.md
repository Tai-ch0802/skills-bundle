---
description: 將 agent-brain 記憶與 pCloud 雙向同步（含衝突解決）
---

這個 workflow 將本地 agent-brain 記憶與 pCloud 雲端儲存進行同步。使用 SHA 增量同步，僅傳輸有異動的檔案，並自動解決衝突。

// turbo-all

1. 檢查 `~/.agent-brain/` 目錄是否存在。若不存在，執行引導程序：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. 執行雙向同步（拉取遠端變更、解決衝突、推送本地變更）：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
   ```
3. 同步完成後重新建立索引，確保搜尋結果為最新：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
4. 使用 notify_user 告知使用者：「✅ 大腦已與 pCloud 同步完成！」包含推送/拉取了哪些檔案以及解決了哪些衝突的摘要。
