---
name: agent-brain
description: "Antigravity session 的持久化記憶與數位孿生大腦。每次 session 皆觸發此技能：(1) 在 session 開始時載入跨 session 記憶、(2) 在 session 結束時儲存摘要與學習心得、(3) 將記憶同步至 pCloud 雲端儲存、(4) 搜尋歷史記憶與過去決策、(5) 管理各專案的上下文。觸發條件：session 開始、session 結束訊號（commit、release note、告一段落、收工、sync memory、save brain）、記憶回想請求（上次做了什麼、recall、search memory）。"
---

# Agent Brain

持久化檔案優先記憶系統。每次 Antigravity session 都會貢獻到一個日益增長的知識庫，以 Markdown 檔案儲存在本地 `~/.agent-brain/`，並同步到 pCloud `/agent-brain/`。

## 目標

建構一個**數位孿生** — 一個隨時間累積所有 session 知識、使用者偏好、專案上下文和決策的代理人。

## 記憶檔案結構

```
~/.agent-brain/
├── .env                    # pCloud 認證資訊（永不同步）
├── .sync-state.json        # 同步中繼資料
├── MEMORY.md               # 長期持久事實
├── USER.md                 # 使用者偏好與行為模式
├── sessions/
│   └── YYYY-MM-DD.md       # 每日 session 日誌（僅增不減）
├── projects/
│   └── {project-name}.md   # 各專案累積上下文
└── brain.db                # SQLite FTS5 索引
```

### 檔案角色

| 檔案 | 啟動時載入 | 用途 |
|------|:---:|---------|
| `MEMORY.md` | ✅ 完整 | 跨 session 事實、決策、學習心得 |
| `USER.md` | ✅ 完整 | 使用者的編碼風格、工具偏好 |
| `sessions/今天.md` | ✅ 完整 | 今天的 session 摘要 |
| `sessions/昨天.md` | ✅ 完整 | 昨天的上下文以維持連續性 |
| `sessions/更早` | ❌ 按需 | 透過 grep 或 brain.db 搜尋 |
| `projects/*.md` | ❌ 按需 | 處理該專案時載入 |
| `brain.db` | ❌ 由腳本 | SQLite FTS5 索引用於記憶搜尋 |

## Session 啟動程序

在**每次** session 執行：

1. **檢查引導**：如果 `~/.agent-brain/` 不存在，執行：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```

2. **載入核心記憶** — 將以下檔案讀入上下文：
   - `~/.agent-brain/MEMORY.md`（完整）
   - `~/.agent-brain/USER.md`（完整）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（今天，如果存在）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（昨天，如果存在）

3. **載入專案上下文**（可選）：如果當前工作區明確對應某個專案，檢查 `~/.agent-brain/projects/{project-name}.md` 是否存在並載入。

4. 帶著累積的知識上下文，繼續處理使用者的請求。

## Session 結束程序

### 觸發偵測

當使用者表示或暗示 session 結束時，啟動記憶沖刷：
- **顯式**：`save brain`、`sync memory`、`記憶同步`、`更新記憶`
- **隱式**：`commit`、`release note`、`告一段落`、`今天先到這`、`收工`、`結束`、`下班`、`先這樣`

### 記憶沖刷步驟

1. **產生 session 摘要**並附加到 `~/.agent-brain/sessions/YYYY-MM-DD.md`：
   ```markdown
   ## Session HH:MM — {上下文}
   **專案**：[[projects/{name}]]
   **工作區**：{repo 或目錄路徑}

   ### 摘要
   {1-3 句話說明完成了什麼}

   ### 關鍵決策
   - {決策 1}
   - {決策 2}

   ### 學習心得
   - {獲得的新知識}

   ### 後續步驟
   - [ ] {未完成的任務}
   ```

2. **更新 `MEMORY.md`**（如果有新的持久事實出現）：
   - 影響未來 session 的技術決策
   - 發現的跨專案模式
   - 新的架構知識
   - 重要的 URL、憑證位置、環境細節
   - 不要**複製** session 級別的細節 — 只提升**持久事實**

3. **更新 `USER.md`**（如果觀察到新的使用者偏好）

4. **更新 `projects/{name}.md`**，加上今天 session 的交叉連結

5. **執行索引器**：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```

6. **同步至 pCloud**：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push
   ```

## 記憶回想程序

當使用者詢問過去的工作、決策或歷史時：

1. **特定專案** → 讀取 `~/.agent-brain/projects/{name}.md`
2. **特定日期** → 讀取 `~/.agent-brain/sessions/YYYY-MM-DD.md`
3. **關鍵字搜尋** → 在 `~/.agent-brain/` 上使用 `grep_search`
4. **廣泛語意搜尋** → 執行：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py search "查詢"
   ```

## pCloud 同步

- **API 主機**：`api.pcloud.com`（美國資料中心）
- **遠端路徑**：`/agent-brain/`
- **認證資訊**：`~/.agent-brain/.env`
- 如需 API 詳情，請參考 `pcloud` 技能

### 同步指令

```bash
# 推送本地變更至 pCloud
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push

# 從 pCloud 拉取（新裝置引導）
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull

# 雙向同步（先拉取，再推送）
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
```

## 記憶維護規則

1. **MEMORY.md 應保持在 500 行以內**。如果過大，進行壓縮：移除過時事實、合併相關條目、將舊區段歸檔到 `projects/`。
2. **Session 記錄僅增不減**。永不編輯過去的 session 條目。
3. **每個活躍專案一個檔案**。透過新增 `[ARCHIVED]` 前綴歸檔不活躍的專案。
4. **交叉連結一切**。Session 參考 `[[projects/name]]`，專案參考 `[[sessions/date]]`。
5. **記憶檔案中不放密鑰**。認證資訊只放在 `.env` 中。

## Workflows

Agent Brain 附帶兩個全域 workflow，可在 bootstrap 過程中安裝至 `~/.agent/workflows/`（也可稍後手動透過 `install-workflows.sh` 安裝）：

| Workflow | Slash 指令 | 用途 |
|----------|-----------|------|
| `save-brain` | `/save-brain` | 沖刷 session 記憶 → 更新 MEMORY/USER/projects → 建立索引 → 推送至 pCloud |
| `load-brain` | `/load-brain` | 從 pCloud 拉取最新資料 → 載入 MEMORY.md、USER.md、今日/昨日 session → 載入專案上下文 |

### 安裝 Workflows

Workflows 會在 bootstrap 過程中自動安裝。如需手動安裝或重新安裝：

```bash
bash ~/.gemini/antigravity/skills/agent-brain/scripts/install-workflows.sh
```

## 詳細參考

- **記憶檔案格式範本**：參閱 [memory-format.md](references/memory-format.md)
- **Session 生命週期詳情**：參閱 [session-lifecycle.md](references/session-lifecycle.md)
