---
description: 從 agent-brain 載入跨 session 記憶至當前上下文
---

這個 workflow 將強制觸發 agent-brain 的 session 啟動程序，將持久化記憶載入至當前對話上下文。

// turbo-all

1. 檢查 `~/.agent-brain/` 目錄是否存在。若不存在，執行引導程序：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. 從 pCloud 拉取最新記憶資料：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull
   ```
3. 載入核心記憶 — 使用 view_file 讀取以下檔案（若存在）：
   - `~/.agent-brain/MEMORY.md`（完整讀取）
   - `~/.agent-brain/USER.md`（完整讀取）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（今天的日期，若存在）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（昨天的日期，若存在）
4. 載入專案上下文（可選）：若當前工作區對應某專案，讀取 `~/.agent-brain/projects/{project-name}.md`（若存在）。
5. 使用 notify_user 告知使用者："✅ 記憶已載入！" 並附上簡短的摘要，說明載入了哪些檔案以及記憶中的關鍵資訊。
