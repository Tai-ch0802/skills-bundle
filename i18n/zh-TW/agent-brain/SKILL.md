---
name: agent-brain
description: "Antigravity session 的持久化記憶與數位孿生大腦。每次 session 皆觸發此技能：(1) 在 session 開始時載入跨 session 記憶、(2) 在 session 結束時儲存摘要與學習心得、(3) 將記憶同步至 pCloud 雲端儲存、(4) 搜尋歷史記憶與過去決策、(5) 管理各專案的上下文。觸發條件：session 開始、session 結束訊號（commit、release note、告一段落、收工、sync memory、save brain）、記憶回想請求（上次做了什麼、recall、search memory）。"
---

# Agent Brain

持久化檔案優先記憶系統。每次 Antigravity session 都會貢獻到一個日益增長的知識庫，以 Markdown 檔案儲存在本地 `~/.agent-brain/`，並同步到 pCloud `/agent-brain/`。

## 目標

建構一個**數位孿生** — 一個隨時間累積所有 session 知識、使用者偏好、專案上下文和決策的代理人。

## 記憶本體論

所有流經代理人記憶的資訊都被分類成四個本體層次。使用此分類來決定**每筆資訊該儲存在哪裡**。

### 四層分類

| 層次 | 代碼 | 本質 | 可變性 | 生命週期 | 對應檔案 |
|------|------|------|--------|---------|---------|
| **身分** | `IDENTITY` | 我跟誰共事 | 極少變動（需多次觀察才更新） | 永久 | `USER.md` |
| **知識** | `KNOWLEDGE` | 我知道什麼 | 累積式、可壓縮 | 長期 (30+ 天) | `MEMORY.md` |
| **經驗** | `EXPERIENCE` | 我做過什麼 | 不可變（僅增不減） | 歷史記錄 | `sessions/*.md` |
| **狀態** | `STATE` | 我正在做什麼 | 可自由覆寫 | 當次工作區間 | `STATE.md` |

### 分類決策流程

當新資訊出現時，依此決策樹判定路由：

```
新資訊 →
├─ 是關於使用者本人的偏好或習慣？       → 身分 IDENTITY (USER.md)
├─ 30 天後仍然有用的持久技術事實？       → 知識 KNOWLEDGE (MEMORY.md)
├─ 目前正在處理的任務上下文？            → 狀態 STATE (STATE.md)
└─ 以上皆非，但值得記錄？               → 經驗 EXPERIENCE (sessions/*.md)
```

### 各層次寫入規則

| 層次 | 寫入方式 | 同步策略 | 衝突解決 |
|------|---------|----------|---------|
| 身分 | 覆寫（需多次觀察佐證） | 區段合併 | 取較長版本 |
| 知識 | 僅追加持久事實 | 區段合併 | 取較長版本 |
| 經驗 | 嚴格僅增不減 | 追加合併 + 去重 | 標頭指紋去重 |
| 狀態 | 自由覆寫 | **永不同步**（臨時性） | 不適用 |

## 記憶檔案結構

```
~/.agent-brain/
├── .env                    # pCloud 認證資訊（永不同步）
├── .sync-manifest.json     # 增量同步用的 SHA256 清單
├── MEMORY.md               # 長期持久事實（知識）
├── USER.md                 # 使用者偏好與行為模式（身分）
├── STATE.md                # 當前工作 session 上下文（狀態）
├── sessions/
│   └── YYYY-MM-DD.md       # 每日 session 日誌（經驗，僅增不減）
├── projects/
│   └── {project-name}.md   # 各專案累積上下文
├── tmp/                    # 衝突解決用暫存目錄（自動清理）
└── brain.db                # SQLite FTS5 索引
```

### 檔案角色

| 檔案 | 啟動時載入 | 用途 |
|------|:---:|---------| 
| `MEMORY.md` | ✅ 完整 | 跨 session 事實、決策、學習心得 |
| `USER.md` | ✅ 完整 | 使用者的編碼風格、工具偏好 |
| `STATE.md` | ✅ 完整 | 上次 session 可恢復的工作上下文 |
| `sessions/今天.md` | ✅ 完整 | 今天的 session 摘要 |
| `sessions/昨天.md` | ✅ 完整 | 昨天的上下文以維持連續性 |
| `sessions/更早` | ❌ 按需 | 透過 grep 或 brain.db 搜尋 |
| `projects/*.md` | ❌ 按需 | 處理該專案時載入 |
| `brain.db` | ❌ 由腳本 | SQLite FTS5 索引用於記憶搜尋 |
| `.sync-manifest.json` | ❌ 內部 | 追蹤檔案 SHA256 雜湊值用於增量同步 |

## Session 啟動程序

在**每次** session 執行：

1. **檢查引導**：如果 `~/.agent-brain/` 不存在，執行：
   ```bash
   bash ~/.gemini/antigravity/skills/agent-brain/scripts/bootstrap.sh
   ```

2. **歸檔過期 STATE**：如果 `~/.agent-brain/STATE.md` 存在：
   - 讀取其 `Updated:` 時間戳記
   - 如果時間戳記是**前一天的**（非今天）：將其內容摘要追加到對應的 `sessions/YYYY-MM-DD.md` 作為歸檔狀態區塊，然後清空 STATE.md
   - 如果時間戳記是**今天的**：保持原樣（可能是同一工作區間的延續）

3. **載入核心記憶** — 將以下檔案讀入上下文：
   - `~/.agent-brain/MEMORY.md`（完整）
   - `~/.agent-brain/USER.md`（完整）
   - `~/.agent-brain/STATE.md`（完整，如果存在且非空）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（今天，如果存在）
   - `~/.agent-brain/sessions/YYYY-MM-DD.md`（昨天，如果存在）

4. **載入專案上下文**（可選）：如果當前工作區明確對應某個專案，檢查 `~/.agent-brain/projects/{project-name}.md` 是否存在並載入。

5. 帶著累積的知識上下文，繼續處理使用者的請求。

## Session 結束程序

### 觸發偵測

當使用者表示或暗示 session 結束時，啟動記憶沖刷：
- **顯式**：`save brain`、`sync memory`、`記憶同步`、`更新記憶`
- **隱式**：`commit`、`release note`、`告一段落`、`今天先到這`、`收工`、`結束`、`下班`、`先這樣`

### 記憶沖刷步驟（僅限本地）

1. **產生 session 摘要**並附加到 `~/.agent-brain/sessions/YYYY-MM-DD.md`：
   ```markdown
   ## Session HH:MM:SS — {上下文}
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

4. **更新 `STATE.md`** — 以當前工作上下文覆寫：
   - 正在進行或剛完成的任務
   - 關鍵變數：活躍分支、目標檔案、正在除錯的錯誤碼
   - 供下次 session 延續的便條筆記

5. **更新 `projects/{name}.md`**，加上今天 session 的交叉連結：
   ```markdown
   - YYYY-MM-DD: {簡述} [[sessions/YYYY-MM-DD#session-hhmmss]]
   ```
   如果檔案不存在則建立，使用 [memory-format.md](references/memory-format.md) 中的格式。

6. **檢查 MEMORY.md 容量**：
   - 如果 MEMORY.md 超過 **400 行**：警告 `⚠ MEMORY.md 接近上限 (XXX/500 行)。建議壓縮。`
   - 如果 MEMORY.md 超過 **500 行**：觸發壓縮（移除 90 天未引用條目、合併相關條目、將專案細節移至 `projects/`）

7. **執行索引器**：
   ```bash
   python3 ~/.gemini/antigravity/skills/agent-brain/scripts/index-memory.py index
   ```

> **注意**：Session 結束時**不會**自動同步至 pCloud。請使用 `/upload-brain` 推送變更或 `/sync-brain` 進行完整雙向同步。

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

### 增量同步

同步系統使用 **SHA256 清單**（`.sync-manifest.json`）來追蹤已同步的檔案。只有自上次同步以來內容有變更的檔案才會被傳輸。

### 同步指令

```bash
# 檢查同步狀態（預覽模式 — 顯示會有哪些變更，不執行寫入）
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh status

# 上傳本地變更至 pCloud（增量 — 僅傳輸異動檔案）
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh push

# 從 pCloud 下載（增量 — 僅傳輸異動檔案）
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh pull

# 雙向同步（含衝突解決）
bash ~/.gemini/antigravity/skills/agent-brain/scripts/sync.sh sync
```

### 衝突解決

當本地和遠端版本的檔案自上次同步後都有變更時：

1. 建立 `~/.agent-brain/tmp/` 暫存目錄
2. 將遠端檔案下載至 `tmp/`
3. 根據檔案類型進行合併：
   - **Session 日誌**（`sessions/*.md`）：追加合併 — 以標頭指紋去重 session 區塊
   - **一般 Markdown**（`MEMORY.md`、`USER.md`、`projects/*.md`）：以 `##` 標題為 key 的區段級合併 — 雙方獨有的區段都保留，共有區段取較長的版本
   - **其他檔案**：以遠端版本為準
4. 合併完成後清理 `tmp/`
5. `brain.db` **從頭重建** — 使用 `index-memory.py rebuild` 重建，brain.db 視為衍生產物，永不直接合併
6. 最終合併結果（含重建的 `brain.db`）推送至 pCloud

## 記憶維護規則

1. **MEMORY.md 應保持在 500 行以內**。如果過大，進行壓縮：移除過時事實、合併相關條目、將舊區段歸檔到 `projects/`。
2. **Session 記錄僅增不減**。永不編輯過去的 session 條目。
3. **每個活躍專案一個檔案**。透過新增 `[ARCHIVED]` 前綴歸檔不活躍的專案。
4. **交叉連結一切**。Session 參考 `[[projects/name]]`，專案參考 `[[sessions/date]]`。
5. **記憶檔案中不放密鑰**。認證資訊只放在 `.env` 中。
6. **STATE.md 是臨時性的**。不要在 STATE 中儲存持久事實 — 應將其提升至 MEMORY.md。過期的 STATE（來自前一天的）會在下次 session 開始時自動歸檔。
7. **STATE.md 永不同步**。它僅存在於本地機器，作為短期工作便條簿。

## Workflows

Agent Brain 附帶五個全域 workflow，可在 bootstrap 過程中安裝至 `~/.agent/workflows/`（也可稍後手動透過 `install-workflows.sh` 安裝）：

| Workflow | Slash 指令 | 用途 |
|----------|-----------|------|
| `save-brain` | `/save-brain` | 沖刷 session 記憶 → 更新 MEMORY/USER/STATE/projects → 建立索引（僅限本地） |
| `upload-brain` | `/upload-brain` | 推送本地變更至 pCloud（單向上傳，增量） |
| `download-brain` | `/download-brain` | 從 pCloud 拉取變更至本地（單向下載，增量） |
| `sync-brain` | `/sync-brain` | 基於 SHA 增量傳輸的 pCloud 雙向同步（含衝突解決） |
| `load-brain` | `/load-brain` | 載入 MEMORY.md、USER.md、STATE.md、今日/昨日 session → 載入專案上下文（僅限本地） |

### 安裝 Workflows

Workflows 會在 bootstrap 過程中自動安裝。如需手動安裝或重新安裝：

```bash
bash ~/.gemini/antigravity/skills/agent-brain/scripts/install-workflows.sh
```

## 詳細參考

- **記憶檔案格式範本**：參閱 [memory-format.md](references/memory-format.md)
- **Session 生命週期詳情**：參閱 [session-lifecycle.md](references/session-lifecycle.md)
