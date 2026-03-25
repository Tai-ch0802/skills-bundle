---
name: claude-api
description: 使用 Claude API 或 Anthropic SDK 建構應用程式。觸發條件：程式碼匯入 `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`，或使用者要求使用 Claude API、Anthropic SDK 或 Agent SDK。不觸發條件：程式碼匯入 `openai`/其他 AI SDK、一般程式設計或 ML/資料科學任務。
license: 完整條款請見 LICENSE.txt
---

# 使用 Claude 建構 LLM 驅動的應用程式

此技能幫助你使用 Claude 建構 LLM 驅動的應用程式。根據你的需求選擇合適的介面，偵測專案語言，然後閱讀相關的語言特定文件。

## 預設值

除非使用者另有要求：

對於 Claude 模型版本，請使用 Claude Opus 4.6，可透過精確模型字串 `claude-opus-4-6` 存取。預設使用自適應思維（`thinking: {type: "adaptive"}`）處理任何稍微複雜的任務。最後，對於可能涉及長輸入、長輸出或高 `max_tokens` 的請求，預設使用串流傳輸 — 這可以防止請求超時。使用 SDK 的 `.get_final_message()` / `.finalMessage()` 輔助方法取得完整回應（如果不需要處理個別串流事件）。

---

## 語言偵測

在閱讀程式碼範例之前，判斷使用者使用的語言：

1. **檢查專案檔案**以推斷語言：

   - `*.py`, `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile` → **Python** — 從 `python/` 讀取
   - `*.ts`, `*.tsx`, `package.json`, `tsconfig.json` → **TypeScript** — 從 `typescript/` 讀取
   - `*.js`, `*.jsx`（無 `.ts` 檔案）→ **TypeScript** — JS 使用相同 SDK，從 `typescript/` 讀取
   - `*.java`, `pom.xml`, `build.gradle` → **Java** — 從 `java/` 讀取
   - `*.kt`, `*.kts`, `build.gradle.kts` → **Java** — Kotlin 使用 Java SDK，從 `java/` 讀取
   - `*.scala`, `build.sbt` → **Java** — Scala 使用 Java SDK，從 `java/` 讀取
   - `*.go`, `go.mod` → **Go** — 從 `go/` 讀取
   - `*.rb`, `Gemfile` → **Ruby** — 從 `ruby/` 讀取
   - `*.cs`, `*.csproj` → **C#** — 從 `csharp/` 讀取
   - `*.php`, `composer.json` → **PHP** — 從 `php/` 讀取

2. **如果偵測到多種語言**（例如同時有 Python 和 TypeScript 檔案）：
   - 檢查使用者當前檔案或問題涉及哪種語言
   - 如果仍然模糊，詢問：「我偵測到 Python 和 TypeScript 檔案。你的 Claude API 整合使用哪種語言？」

3. **如果無法推斷語言**（空專案、無原始碼檔案或不支援的語言）：
   - 提供選項：Python、TypeScript、Java、Go、Ruby、cURL/raw HTTP、C#、PHP
   - 如果無法詢問，預設顯示 Python 範例並註明：「顯示 Python 範例。如果需要其他語言請告知。」

4. **如果偵測到不支援的語言**（Rust、Swift、C++、Elixir 等）：
   - 建議 `curl/` 中的 cURL/raw HTTP 範例並提及可能存在社群 SDK
   - 提供 Python 或 TypeScript 範例作為參考實作

5. **如果使用者需要 cURL/raw HTTP 範例**，從 `curl/` 讀取。

### 語言特定功能支援

| 語言 | Tool Runner | Agent SDK | 備註 |
| --- | --- | --- | --- |
| Python | 是（beta）| 是 | 完整支援 — `@beta_tool` 裝飾器 |
| TypeScript | 是（beta）| 是 | 完整支援 — `betaZodTool` + Zod |
| Java | 是（beta）| 否 | 使用標註類別的 Beta 工具 |
| Go | 是（beta）| 否 | `toolrunner` 套件中的 `BetaToolRunner` |
| Ruby | 是（beta）| 否 | beta 中的 `BaseTool` + `tool_runner` |
| cURL | 不適用 | 不適用 | 原始 HTTP，無 SDK 功能 |
| C# | 否 | 否 | 官方 SDK |
| PHP | 是（beta）| 否 | `BetaRunnableTool` + `toolRunner()` |

---

## 應該使用哪個介面？

> **從簡單開始。** 預設使用符合需求的最簡單層級。單一 API 呼叫和工作流程可處理大多數用例 — 只有在任務真正需要開放式、模型驅動的探索時才使用代理。

| 用例 | 層級 | 建議介面 | 原因 |
| --- | --- | --- | --- |
| 分類、摘要、擷取、問答 | 單一 LLM 呼叫 | **Claude API** | 一次請求，一次回應 |
| 批次處理或嵌入 | 單一 LLM 呼叫 | **Claude API** | 專用端點 |
| 程式碼控制邏輯的多步驟管線 | 工作流程 | **Claude API + 工具使用** | 你控制循環 |
| 使用自訂工具的自訂代理 | 代理 | **Claude API + 工具使用** | 最大靈活性 |
| 具有檔案/網頁/終端存取的 AI 代理 | 代理 | **Agent SDK** | 內建工具、安全性和 MCP 支援 |
| 代理式編碼助手 | 代理 | **Agent SDK** | 專為此用例設計 |
| 需要內建權限和防護措施 | 代理 | **Agent SDK** | 包含安全功能 |

> **注意：** Agent SDK 適用於你需要內建的檔案/網頁/終端工具、權限和即開即用的 MCP 時。如果你想使用自己的工具建構代理，Claude API 是正確的選擇 — 使用 tool runner 自動處理循環，或使用手動循環進行精細控制（審批關卡、自訂日誌、條件執行）。

### 決策樹

```
你的應用程式需要什麼？

1. 單一 LLM 呼叫（分類、摘要、擷取、問答）
   └── Claude API — 一次請求，一次回應

2. Claude 是否需要讀寫檔案、瀏覽網頁或執行 shell 命令
   作為工作的一部分？（不是：你的應用程式讀取檔案並交給 Claude —
   是 Claude 本身需要發現並存取檔案/網頁/shell？）
   └── 是 → Agent SDK — 內建工具，不需要重新實作
       範例：「掃描程式碼庫中的 bug」、「摘要目錄中的每個檔案」、
             「使用子代理找 bug」、「透過網頁搜尋研究主題」

3. 工作流程（多步驟、程式碼編排、使用自訂工具）
   └── 具有工具使用的 Claude API — 你控制循環

4. 開放式代理（模型決定自己的軌跡，使用自訂工具）
   └── Claude API 代理循環（最大靈活性）
```

### 是否應該建構代理？

在選擇代理層級之前，檢查所有四個標準：

- **複雜度** — 任務是否為多步驟且難以事先完全指定？（例如：「將此設計文件轉為 PR」vs.「從此 PDF 擷取標題」）
- **價值** — 結果是否合理化較高的成本和延遲？
- **可行性** — Claude 是否有能力完成此類任務？
- **錯誤成本** — 錯誤是否可被捕獲並恢復？（測試、審閱、回滾）

如果任何一項的答案為「否」，請保持在較簡單的層級（單一呼叫或工作流程）。

---

## 架構

所有功能都透過 `POST /v1/messages` 端點。工具和輸出限制是此單一端點的功能 — 不是獨立的 API。

**使用者定義工具** — 你定義工具（透過裝飾器、Zod schema 或原始 JSON），SDK 的 tool runner 負責呼叫 API、執行你的函數並循環直到 Claude 完成。如需完全控制，你可以手動編寫循環。

**伺服器端工具** — 在 Anthropic 基礎設施上執行的 Anthropic 託管工具。程式碼執行完全在伺服器端（在 `tools` 中宣告，Claude 自動執行程式碼）。電腦使用可以是伺服器託管或自行託管。

**結構化輸出** — 限制 Messages API 回應格式（`output_config.format`）和/或工具參數驗證（`strict: true`）。建議方法是 `client.messages.parse()`，它會自動根據你的 schema 驗證回應。注意：舊的 `output_format` 參數已棄用；在 `messages.create()` 上使用 `output_config: {format: {...}}`。

**支援端點** — 批次（`POST /v1/messages/batches`）、檔案（`POST /v1/files`）和 Token 計數為 Messages API 請求提供支援。

---

## 當前模型（快取：2026-02-17）

| 模型 | 模型 ID | 上下文 | 輸入 $/1M | 輸出 $/1M |
| --- | --- | --- | --- | --- |
| Claude Opus 4.6 | `claude-opus-4-6` | 200K（1M beta）| $5.00 | $25.00 |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | 200K（1M beta）| $3.00 | $15.00 |
| Claude Haiku 4.5 | `claude-haiku-4-5` | 200K | $1.00 | $5.00 |

**除非使用者明確指定不同模型，否則始終使用 `claude-opus-4-6`。** 這是不可妥協的。除非使用者確實說「使用 sonnet」或「使用 haiku」，否則不要使用其他模型。絕不為了成本而降級 — 那是使用者的決定，不是你的。

**關鍵：僅使用上表中的精確模型 ID 字串 — 它們已經是完整的。不要附加日期後綴。**

---

## 思維與功力（快速參考）

**Opus 4.6 — 自適應思維（建議）：** 使用 `thinking: {type: "adaptive"}`。Claude 動態決定何時以及思考多少。不需要 `budget_tokens` — `budget_tokens` 在 Opus 4.6 和 Sonnet 4.6 上已棄用，不得使用。自適應思維也自動啟用交錯思維（無需 beta 標頭）。

**功力參數（GA，無需 beta 標頭）：** 透過 `output_config: {effort: "low"|"medium"|"high"|"max"}` 控制思維深度和整體 token 消耗（在 `output_config` 內，非頂層）。預設為 `high`（等同於省略）。`max` 僅限 Opus 4.6。在 Sonnet 4.5/Haiku 4.5 上會出錯。結合自適應思維以獲得最佳成本-品質權衡。

**Sonnet 4.6：** 支援自適應思維（`thinking: {type: "adaptive"}`）。`budget_tokens` 在 Sonnet 4.6 上已棄用。

**舊模型（僅在明確要求時）：** 如果使用者特別要求 Sonnet 4.5 或其他舊模型，使用 `thinking: {type: "enabled", budget_tokens: N}`。`budget_tokens` 必須小於 `max_tokens`（最少 1024）。

---

## 壓縮（快速參考）

**Beta，僅限 Opus 4.6。** 對於可能超過 200K 上下文窗口的長時間對話，啟用伺服器端壓縮。API 在接近觸發閾值（預設：150K tokens）時自動摘要較早的上下文。需要 beta 標頭 `compact-2026-01-12`。

**關鍵：** 每輪都將 `response.content`（不僅是文字）附加回你的訊息中。回應中的壓縮區塊必須保留 — API 使用它們在下次請求中替換已壓縮的歷史。僅擷取文字字串將靜默丟失壓縮狀態。

參見 `{lang}/claude-api/README.md`（壓縮章節）以取得程式碼範例。透過 `shared/live-sources.md` 中的 WebFetch 取得完整文件。

---

## 提示詞快取（快速參考）

**前綴比對（Prefix match）。** 前綴中任何位元組的變更都會使之後的所有內容失效。渲染順序為 `tools` → `system` → `messages`。將穩定的內容放在最前面（固定的系統提示、確定性的工具列表），將變動的內容（時間戳、每次請求的 ID、變化的問題）放在最後一個 `cache_control` 斷點之後。

**頂層自動快取**（在 `messages.create()` 上設定 `cache_control: {type: "ephemeral"}`）是不需要精細放置快取斷點時最簡單的選擇。每個請求最多 4 個斷點。最小可快取前綴約為 1024 個 token — 較短的前綴會靜默地不被快取。

**使用 `usage.cache_read_input_tokens` 進行驗證** — 如果在重複請求中它都為零，表示存在靜默的失效因素（例如系統提示中的 `datetime.now()`、未排序的 JSON、變動的工具集）。

如需了解放置模式、架構指南與靜默失效因素稽核清單：請閱讀 `shared/prompt-caching.md`。語言特定語法：閱讀 `{lang}/claude-api/README.md`（提示詞快取/Prompt Caching 章節）。

---

## 閱讀指南

偵測語言後，根據使用者需求閱讀相關檔案：

### 快速任務參考

**單一文字分類/摘要/擷取/問答：**
→ 僅閱讀 `{lang}/claude-api/README.md`

**聊天 UI 或即時回應顯示：**
→ 閱讀 `{lang}/claude-api/README.md` + `{lang}/claude-api/streaming.md`

**長時間對話（可能超過上下文窗口）：**
→ 閱讀 `{lang}/claude-api/README.md` — 參見壓縮章節

**提示詞快取（Prompt caching）/ 最佳化快取 / 「為什麼我的快取命中率很低」：**
→ 閱讀 `shared/prompt-caching.md` + `{lang}/claude-api/README.md`（提示詞快取章節）

**函數呼叫/工具使用/代理：**
→ 閱讀 `{lang}/claude-api/README.md` + `shared/tool-use-concepts.md` + `{lang}/claude-api/tool-use.md`

**批次處理（非延遲敏感）：**
→ 閱讀 `{lang}/claude-api/README.md` + `{lang}/claude-api/batches.md`

**跨多個請求的檔案上傳：**
→ 閱讀 `{lang}/claude-api/README.md` + `{lang}/claude-api/files-api.md`

**具有內建工具的代理（檔案/網頁/終端）：**
→ 閱讀 `{lang}/agent-sdk/README.md` + `{lang}/agent-sdk/patterns.md`

### Claude API（完整檔案參考）

閱讀**語言特定的 Claude API 資料夾**（`{language}/claude-api/`）：

1. **`{language}/claude-api/README.md`** — **先閱讀此檔。** 安裝、快速入門、常見模式、錯誤處理。
2. **`shared/tool-use-concepts.md`** — 當使用者需要函數呼叫、程式碼執行、記憶或結構化輸出時閱讀。涵蓋概念基礎。
3. **`{language}/claude-api/tool-use.md`** — 語言特定工具使用程式碼範例。
4. **`{language}/claude-api/streaming.md`** — 建構逐步顯示回應的聊天 UI 或介面時閱讀。
5. **`{language}/claude-api/batches.md`** — 離線處理大量請求（非延遲敏感）時閱讀。以 50% 成本非同步執行。
6. **`{language}/claude-api/files-api.md`** — 跨多個請求發送同一檔案而不重新上傳時閱讀。
7. **`shared/prompt-caching.md`** — 當加入或最佳化提示詞快取時閱讀。涵蓋前綴穩定性設計、斷點放置，以及會靜默使快取失效的反模式。
8. **`shared/error-codes.md`** — 除錯 HTTP 錯誤或實作錯誤處理時閱讀。
9. **`shared/live-sources.md`** — 取得最新官方文件的 WebFetch URL。

> **注意：** Java、Go、Ruby、C#、PHP 和 cURL — 各有一個涵蓋所有基礎的單一檔案。根據需要閱讀該檔案加上 `shared/tool-use-concepts.md` 和 `shared/error-codes.md`。

### Agent SDK

閱讀**語言特定的 Agent SDK 資料夾**（`{language}/agent-sdk/`）。Agent SDK 僅適用於 **Python 和 TypeScript**。

1. **`{language}/agent-sdk/README.md`** — 安裝、快速入門、內建工具、權限、MCP、hooks。
2. **`{language}/agent-sdk/patterns.md`** — 自訂工具、hooks、子代理、MCP 整合、session 恢復。
3. **`shared/live-sources.md`** — 當前 Agent SDK 文件的 WebFetch URL。

---

## 何時使用 WebFetch

在以下情況使用 WebFetch 取得最新文件：

- 使用者要求「最新」或「當前」資訊
- 快取資料似乎不正確
- 使用者詢問此處未涵蓋的功能

即時文件 URL 在 `shared/live-sources.md` 中。

## 常見陷阱

- 將檔案或內容傳遞給 API 時不要截斷輸入。如果內容太長無法放入上下文窗口，通知使用者並討論選項（分塊、摘要等）而非靜默截斷。
- **Opus 4.6 / Sonnet 4.6 思維：** 使用 `thinking: {type: "adaptive"}` — 不要使用 `budget_tokens`（在 Opus 4.6 和 Sonnet 4.6 上已棄用）。舊模型的 `budget_tokens` 必須小於 `max_tokens`（最少 1024）。
- **Opus 4.6 prefill 已移除：** 助手訊息 prefill 在 Opus 4.6 上回傳 400 錯誤。改用結構化輸出（`output_config.format`）或系統提示指令來控制回應格式。
- **`max_tokens` 預設值：** 不要低估 `max_tokens` — 達到上限會使輸出在中途被截斷，並需要重試。對於非串流請求，預設為 `~16000`（保持回應在 SDK HTTP 超時限制內）。對於串流請求，預設為 `~64000`（不需擔心超時，給予模型更多空間）。除非有明確理由（例如分類任務約 `~256`、成本上限或故意要求簡短輸出），否則不要設定更低的值。
- **128K 輸出 tokens：** Opus 4.6 支援最多 128K `max_tokens`，但 SDK 對大型 `max_tokens` 需要串流以避免 HTTP 超時。使用 `.stream()` 搭配 `.get_final_message()` / `.finalMessage()`。
- **工具呼叫 JSON 解析（Opus 4.6）：** Opus 4.6 可能在工具呼叫 `input` 欄位中產生不同的 JSON 字串跳脫。始終使用 `json.loads()` / `JSON.parse()` 解析工具輸入 — 絕不對序列化的輸入做原始字串比對。
- **結構化輸出（所有模型）：** 在 `messages.create()` 上使用 `output_config: {format: {...}}` 而非已棄用的 `output_format` 參數。
- **不要重新實作 SDK 功能：** SDK 提供高階輔助方法 — 使用它們而非從頭建構。具體來說：使用 `stream.finalMessage()` 而非將 `.on()` 事件包裝在 `new Promise()` 中；使用強型別例外類別（例如 `Anthropic.RateLimitError`）而非對錯誤訊息進行字串比對；使用 SDK 型別（`Anthropic.MessageParam`、`Anthropic.Tool`、`Anthropic.Message` 等）而非重新定義等效的介面。
- **不要為 SDK 資料結構定義自訂型別：** SDK 匯出所有 API 物件的型別。訊息請使用 `Anthropic.MessageParam`，工具定義請使用 `Anthropic.Tool`，工具結果請使用 `Anthropic.ToolUseBlock` / `Anthropic.ToolResultBlockParam`，回應請使用 `Anthropic.Message`。自行定義 `interface ChatMessage { role: string; content: unknown }` 會重複 SDK 已提供的內容並失去型別安全。
- **報告和文件輸出：** 程式碼執行沙盒預裝了 `python-docx`、`python-pptx`、`matplotlib`、`pillow` 和 `pypdf`。Claude 可以生成格式化檔案（DOCX、PDF、圖表）並透過 Files API 回傳。
