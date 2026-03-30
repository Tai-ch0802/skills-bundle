---
description: 從 agent-brain 載入跨 session 記憶至當前上下文
---

此 workflow 強制觸發 agent-brain 的 session 啟動程序，從本地儲存載入持久記憶至當前對話上下文。如需從 pCloud 取得最新資料，請先使用 `/download-brain`。

// turbo-all

1. 檢查 `~/.agent-brain/` 目錄是否存在。如果不存在，執行引導：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```
2. 檢查過期 STATE：如果 `~/.agent-brain/STATE.md` 存在且其 `Updated:` 時間戳記是前一天的，將其內容摘要歸檔到對應的 session 日誌，然後清空 STATE.md。
3. 載入核心記憶 — 使用 view_file 讀取以下檔案（如果存在）：
   - `~/.agent-brain/MEMORY.md`（完整）
   - `~/.agent-brain/USER.md`（完整）
   - `~/.agent-brain/STATE.md`（完整，如果存在且非空）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（今天的日期，如果存在）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（昨天的日期，如果存在）
4. 載入專案上下文（可選）：如果當前工作區對應某個專案，讀取 `~/.agent-brain/projects/{project-name}.md`（如果存在）。
5. 使用 notify_user 通知使用者：「✅ 記憶已載入！」，附帶已載入哪些檔案和記憶中關鍵資訊的簡要摘要。
