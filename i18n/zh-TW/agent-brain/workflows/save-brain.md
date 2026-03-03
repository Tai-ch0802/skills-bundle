---
description: 將當前的 session 記憶寫入 agent-brain 並同步至 pCloud
---

這個 workflow 將強制觸發 agent-brain 的 session 結束程序。

// turbo-all

1. 產生 session 摘要並附加到 `~/.agent-brain/sessions/YYYY-MM-DD.md`（YYYY-MM-DD 為今日日期）。內容應包含：今日摘要、關鍵決策、學習心得、後續步驟。
2. 提取持久記憶：將影響未來 session 的技術決策或跨專案模式更新至 `~/.agent-brain/MEMORY.md`（若無新事實則跳過）。
3. 使用者偏好：若觀察到新的使用者偏好，更新 `~/.agent-brain/USER.md`（若無則跳過）。
4. 專案上下文：若有處理特定專案，更新 `~/.agent-brain/projects/{project-name}.md`，加上今日 session 的交叉連結。
5. 執行大腦索引器：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```
6. 同步資料至 pCloud：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push
   ```
7. 使用 notify_user 告知使用者："✅ 記憶已成功儲存並同步至 pCloud！"
