---
description: 將當前 session 記憶沖刷至 agent-brain（僅限本地儲存）
---

此 workflow 強制觸發 agent-brain 的 session 結束程序。僅在本地儲存記憶，不會同步至 pCloud — 使用 `/upload-brain` 推送至雲端或 `/sync-brain` 進行完整雙向同步。

// turbo-all

1. 產生 session 摘要並附加到 `~/.agent-brain/sessions/YYYY-MM-DD.md`（YYYY-MM-DD = 今天的日期）。使用 `## Session HH:MM:SS` 標頭格式。包含：摘要、關鍵決策、學習心得、後續步驟。
2. 擷取持久記憶：以影響未來 session 的技術決策或跨專案模式更新 `~/.agent-brain/MEMORY.md`（若無新事實則跳過）。使用本體論：僅**知識 KNOWLEDGE** 層級的事實存放於此。
3. 使用者偏好：如果觀察到新的使用者偏好，更新 `~/.agent-brain/USER.md`（若無則跳過）。這是**身分 IDENTITY** 層級的資料。
4. 工作狀態：以當前工作上下文覆寫 `~/.agent-brain/STATE.md` — 任務焦點、關鍵變數、供下次 session 延續的便條筆記。這是**狀態 STATE** 層級的資料。
5. 專案上下文：如果有特定專案被處理，以今天 session 的交叉連結更新 `~/.agent-brain/projects/{project-name}.md`。
6. 檢查 MEMORY.md 容量：
   ```bash
   wc -l ~/.agent-brain/MEMORY.md
   ```
   如果超過 400 行，警告使用者。如果超過 500 行，觸發壓縮。
7. 執行 brain 索引器：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
8. 使用 notify_user 通知使用者：「✅ 記憶已在本地儲存！使用 `/upload-brain` 推送至雲端或 `/sync-brain` 進行完整同步。」
