# Session 生命週期參考

agent-brain session 生命週期各階段的詳細程序。

## 階段 1：Session 啟動

### 引導檢查

```
如果 ~/.agent-brain/ 不存在：
  1. 執行 bootstrap.sh
  2. 這會建立目錄結構 + .env + 如果有資料的話從 pCloud 拉取
  3. 如果引導失敗（無網路、無 pCloud 令牌），建立僅限本地的結構
```

### 過期 STATE 歸檔

載入記憶之前，處理前一個 session 遺留的 STATE：

```
如果 ~/.agent-brain/STATE.md 存在 且 非空：
  1. 讀取 STATE.md 中的 "Updated:" 時間戳記
  2. 如果時間戳記是前一天的（非今天）：
     a. 產生 STATE.md 內容的簡要摘要
     b. 追加到 sessions/YYYY-MM-DD.md（使用 STATE 的日期）為：
        ### Archived State
        > 從 STATE.md 帶入 (YYYY-MM-DD HH:MM)
        - {摘要內容}
     c. 清空 STATE.md（寫入帶有當前時間戳記的空範本）
  3. 如果時間戳記是今天的：
     a. 保持 STATE.md 原樣（同一工作區間的延續）
  4. 如果沒有時間戳記或檔案格式異常：
     a. 歸檔內容到今天的 session 日誌，然後清空
```

### 記憶載入優先順序

依此順序載入檔案以管理 token 預算：

1. `MEMORY.md` — 始終完整載入（應 < 500 行）
2. `USER.md` — 始終完整載入（應 < 100 行）
3. `STATE.md` — 如果存在且非空則完整載入（應 < 50 行）
4. `sessions/YYYY-MM-DD.md`（今天）— 完整載入
5. `sessions/（昨天）.md` — 完整載入
6. `projects/{current-project}.md` — 如果工作區匹配已知專案則載入

**Token 預算目標**：記憶載入應消耗 < 3500 tokens。如果 MEMORY.md 超出此範圍，需要壓縮（參見下方記憶維護）。

### 工作區到專案的對應

從工作區路徑偵測當前專案：
- `/Users/Tai.Tai/Documents/personal/repo/skills-bundle` → `skills-bundle`
- 擷取工作區根目錄的最後一個路徑元件作為專案名稱
- 檢查 `~/.agent-brain/projects/{name}.md` 是否存在

## 階段 2：Session 進行中

在正常 session 操作期間，代理人帶著已載入的記憶上下文正常工作。

### STATE 更新

代理人應在以下情況更新 STATE.md：
- **開始新任務時**：記錄任務焦點和關鍵上下文變數
- **有重要發現時**：記錄正在處理的錯誤碼、檔案路徑或設定值
- **切換上下文時**：更新「Current Focus」區段
- **累積便條筆記時**：將中間發現加入「Scratch Pad」

**重要**：STATE 更新是靜默的 — 不要打斷使用者的工作流程來宣布 STATE 寫入。只在上下文有顯著變化時靜默覆寫 STATE.md。

### 被動觀察

記下任何應在 session 結束時捕獲的使用者偏好、決策或學習心得。不要打斷使用者的工作流程來寫入記憶。

## 階段 3：Session 結束（僅限本地）

### 觸發偵測

監控使用者訊息中的這些模式：

**高信賴度（總是觸發）**：
- `save brain`、`sync memory`、`記憶同步`、`更新記憶`
- `brain sync`、`save memory`

**中信賴度（附帶確認觸發）**：
- `commit`、`幫我 commit`
- `release note`、`生成 release note`
- `告一段落`、`今天先到這`、`先這樣`
- `收工`、`下班`、`結束`
- `部署完成`、`deploy done`

偵測到中信賴度觸發時，將記憶沖刷作為工作流程的自然部分。不要詢問「要不要儲存記憶？」— 只需順暢地執行。

> **重要**：Session 結束時僅在本地儲存記憶。雲端同步是透過 `/upload-brain` 或 `/sync-brain` 的獨立操作。

### 摘要產生規則

1. **簡潔**：每個 session 摘要最多 5-15 行
2. **聚焦決策**：記錄決定了什麼及為什麼，而非逐步操作記錄
3. **記錄意外**：發現的 bug、使用的變通方案、意外行為
4. **追蹤連續性**：始終包含「後續步驟」供未來 session 參考
5. **標記專案**：始終包含 `[[projects/{name}]]` 連結
6. **使用 HH:MM:SS 格式**：Session 標頭使用 `## Session HH:MM:SS` 以防止同一分鐘內多個 session 的碰撞

### 儲存時的記憶分類

儲存時應用本體論分類來決定資訊存放位置：

| 資訊類型 | 路由至 | 範例 |
|---------|--------|------|
| 使用者說「我偏好 X」 | `USER.md`（身分） | 「使用者偏好 tabs 而非 spaces」 |
| 發現 API 特性 | `MEMORY.md`（知識） | 「pCloud API 路徑不能有尾斜線」 |
| 目前正在除錯 bug #123 | `STATE.md`（狀態） | 「正在處理 file.ts 的 issue #123」 |
| 今天修了一個特定的 bug | `sessions/*.md`（經驗） | Session 摘要條目 |

### MEMORY.md 更新規則

僅在事實符合以下條件時才提升至 MEMORY.md：
- **持久的**：30 天後仍然相關
- **跨 session 的**：超出此特定 session 有用
- **非顯而易見的**：代理人無法僅從程式碼推斷

應提升的範例：
- 「skills-bundle 使用特定目錄結構，i18n/zh-TW 映射」
- 「使用者偏好 UI 用繁體中文、程式碼註釋用英文」
- 「pCloud 應用程式憑證儲存在 ~/.agent-brain/.env」

不應提升的範例：
- 「修正了 config.js 第 42 行的錯字」（太短暫）
- 「JavaScript 用 const 宣告常數」（顯而易見的知識）

### USER.md 更新規則

僅在觀察到**尚未記錄的新模式**時更新：
- 首次看到使用者偏好特定工具
- 使用者明確表達的偏好
- 重複的行為模式（3 次以上）

### Session 結束時的 STATE.md 更新

以當前工作上下文覆寫 STATE.md：
- 最後正在處理的任務
- 任何未完成的事項或開放問題
- 用於恢復的關鍵檔案路徑、分支名稱或識別碼

### MEMORY.md 容量檢查

更新 MEMORY.md 後，檢查其行數：

```
如果 MEMORY.md > 400 行：
  警告「⚠ MEMORY.md 接近上限 (XXX/500 行)。建議壓縮。」
如果 MEMORY.md > 500 行：
  1. 移除 90 天以上未被引用的條目
  2. 將相關條目合併成簡潔的陳述
  3. 將專案特定的細節移至 projects/{name}.md
  4. 歸檔過時的技術事實
```

## 記憶維護

### MEMORY.md 壓縮

當 MEMORY.md 超過 500 行時：

1. 移除 90 天以上未被引用的條目
2. 將相關條目合併成簡潔的陳述
3. 將專案特定的細節移至 `projects/{name}.md`
4. 歸檔過時的技術事實（已淘汰的工具、已完成的專案）

### 專案歸檔

當一個專案 60 天以上未被引用時：
1. 在 MEMORY.md 中的專案名稱前加上 `[ARCHIVED]` 前綴
2. 保留 `projects/{name}.md` 檔案（不要刪除 — 它是可搜尋的）

### STATE.md 維護

- STATE.md 應保持在 50 行以內
- 如果 STATE 長度過大，代理人放了太多東西 — 應將持久事實提升至 MEMORY.md
- STATE 永不同步至 pCloud，也永不索引到 brain.db

## 衝突解決（pCloud 同步）

當本地和遠端檔案自上次同步後都有變更時會發生衝突（透過比較當前 SHA256 與 `.sync-manifest.json` 記錄來偵測）。

### 解決流程

1. **建立暫存區**：建立 `~/.agent-brain/tmp/`
2. **下載衝突的遠端檔案**至 `tmp/`
3. **根據檔案類型合併**：

| 檔案類型 | 策略 |
|---------|------|
| `sessions/*.md` | 追加合併：擷取 session 區塊，以標頭去重，合併 |
| `MEMORY.md`、`USER.md`、`projects/*.md` | 以 `##` 標題為 key 的區段級合併 — 雙方獨有區段保留，共有區段取較長版本 |
| `STATE.md` | **永不同步** — 排除在所有同步操作之外 |
| `brain.db` | 合併後從頭重建（衍生產物） |
| 其他檔案 | 以遠端版本為準 |

4. **清理**：合併後移除 `tmp/`
5. **推送合併結果**：最終狀態推送至 pCloud，更新 SHA 清單

### 三方 SHA 偵測

同步使用三方比較：
- **manifest SHA** = 上次同步狀態（來自 `.sync-manifest.json`）
- **local SHA** = 當前本地檔案雜湊
- **remote SHA** = 當前 pCloud 檔案雜湊（透過 `checksumfile` API）

| Manifest SHA | Local SHA | Remote SHA | 動作 |
|:---:|:---:|:---:|--------|
| A | A | A | 跳過（無變更） |
| A | A | B | 拉取遠端（僅遠端有變更） |
| A | B | A | 推送本地（僅本地有變更） |
| A | B | C | **衝突** — 透過 tmp/ 合併 |
| — | B | — | 推送（新本地檔案） |
| — | — | B | 拉取（新遠端檔案） |

## 錯誤處理

| 情境 | 動作 |
|------|------|
| pCloud 無法連線 | 跳過同步、記錄警告、下次重試 |
| .env 遺失/無效 | 提示使用者重新執行 bootstrap.sh |
| brain.db 損毀 | 刪除並用 index-memory.py 重新產生 |
| 合併衝突錯誤 | 退回至遠端版本、記錄警告 |
| 磁碟空間不足 | 警告使用者、跳過 brain.db 更新 |
