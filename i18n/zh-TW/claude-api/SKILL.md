---
name: claude-api
description: 使用 Claude API 或 Anthropic SDK 建構應用程式。觸發條件：程式碼匯入 `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`，或使用者要求使用 Claude API、Anthropic SDK 或 Agent SDK。不觸發條件：程式碼匯入 `openai`/其他 AI SDK、一般程式設計或 ML/資料科學任務。
license: 完整條款請見 LICENSE.txt
---
# 使用 Claude 建構 LLM 驅動的應用程式

此技能幫助你使用 Claude 建構 LLM 驅動的應用程式。根據你的需求選擇合適的介面，偵測專案語言，然後閱讀相關的語言特定文件。

## 在你開始之前

掃描目標檔案（或，如果沒有目標檔案，掃描提示詞和專案）尋找非 Anthropic 提供者的標記 — `import openai`, `from openai`, `langchain_openai`, `OpenAI(`, `gpt-4`, `gpt-5`，像 `agent-openai.py` 或 `*-generic.py` 的檔案名稱，或任何明確指示保持程式碼不依賴特定提供者的指令。如果你找到任何標記，請停下來並告訴使用者此技能會產生 Claude/Anthropic SDK 程式碼；詢問他們是否要將檔案切換為 Claude，或想要非 Claude 的實作。不要使用 Anthropic SDK 呼叫編輯非 Anthropic 檔案。

## 輸出要求

當使用者要求你加入、修改或實作 Claude 功能時，你的程式碼必須透過以下其中一種方式呼叫 Claude：

1. 適用於該專案語言的 **官方 Anthropic SDK**（`anthropic`, `@anthropic-ai/sdk`, `com.anthropic.*` 等）。只要該專案有支援的 SDK，這就是預設值。
2. **原始 HTTP**（`curl`, `requests`, `fetch`, `httpx` 等） — 僅在使用者明確要求 cURL/REST/原始 HTTP、專案是 shell/cURL 專案，或該語言沒有官方 SDK 時。

絕不要混合這兩種方式 — 不要僅僅因為覺得比較輕量就在 Python 或 TypeScript 專案中使用 `requests`/`fetch`。絕不要退而求其次使用與 OpenAI 相容的墊片(shims)。

**絕不要猜測 SDK 使用方式。** 函數名稱、類別名稱、命名空間、方法簽名和匯入路徑必須來自明確的文件 — 要麼是此技能中的 `{lang}/` 檔案，要麼是官方 SDK 儲存庫或列在 `shared/live-sources.md` 中的文件連結。如果你需要的綁定在技能檔案中沒有明確記錄，在編寫程式碼之前請從 `shared/live-sources.md` WebFetch 相關的 SDK 儲存庫。不要從 cURL 形狀或其他語言的 SDK 推斷 Ruby/Java/Go/PHP/C# API。

## 預設值

除非使用者另有要求：

對於 Claude 模型版本，請使用 Claude Opus 4.6，可透過精確模型字串 `claude-opus-4-6` 存取。預設使用自適應思維（`thinking: {type: "adaptive"}`）處理任何稍微複雜的任務。最後，對於可能涉及長輸入、長輸出或高 `max_tokens` 的請求，預設使用串流傳輸 — 這可以防止請求超時。使用 SDK 的 `.get_final_message()` / `.finalMessage()` 輔助方法取得完整回應（如果不需要處理個別串流事件）。

---

## 子命令 (Subcommands)

如果此提示詞底部的使用者要求是一個簡單的子命令字串（沒有散文），請搜尋此文件中的每個 **Subcommands** 表格 — 包括附加在下方任何區塊中的表格 — 並直接遵循相符的 Action 欄位。這允許使用者透過 `/claude-api <subcommand>` 呼叫特定的流程。如果文件中沒有表格相符，則將要求視為一般散文處理。

<!-- 子命令表格在下方的每個區塊定義；此標頭區塊僅包含派發規則，以便功能控制區塊可以添加自己的表格，而不會將字串洩露到非控制構建中。 -->

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
   - `*.cs`, `*.csproj`, `*.sln` → **C#** — 從 `csharp/` 讀取
   - `*.php`, `composer.json` → **PHP** — 從 `php/` 讀取
   - `*.sh`, `*.bash` 或僅有終端使用 → **cURL** — 從 `curl/` 讀取

2. **如果語言不明確**：
   - 如果要求是特定的（「使用 C# 呼叫 Claude」），依照要求使用。
   - 如果要求是不具體的（「給我一個腳本」），詢問使用者他們偏好的語言。
   - 提供選項：Python、TypeScript、Java、Go、Ruby、cURL/raw HTTP、C#、PHP

### 語言特定功能支援

| 語言 | Tool Runner | 管理代理 | 備註 |
| --- | --- | --- | --- |
| Python | 是（beta）| 是 (beta) | 完整支援 — `@beta_tool` 裝飾器 |
| TypeScript | 是（beta）| 是 (beta) | 完整支援 — `betaZodTool` + Zod |
| Java | 是（beta）| 是 (beta) | 使用標註類別的 Beta 工具 |
| Go | 是（beta）| 是 (beta) | `toolrunner` 套件中的 `BetaToolRunner` |
| Ruby | 是（beta）| 是 (beta) | beta 中的 `BaseTool` + `tool_runner` |
| C# | 否 | 否 | 官方 SDK |
| PHP | 是（beta）| 是 (beta) | `BetaRunnableTool` + `toolRunner()` |
| cURL | 不適用 | 是 (beta) | 原始 HTTP，無 SDK 功能 |

> **管理代理 (Managed Agents) 程式碼範例**：為 Python、TypeScript、Go、Ruby、PHP、Java 和 cURL 提供了專門的語言特定 README (`{lang}/managed-agents/README.md`、`curl/managed-agents.md`)。請閱讀你使用語言的 README 以及不限語言的 `shared/managed-agents-*.md` 概念檔案。**代理是持久的 — 建立一次，依 ID 引用。** 儲存由 `agents.create` 回傳的代理 ID，並將其傳遞給後續所有的 `sessions.create`；不要在請求路徑中呼叫 `agents.create`。Anthropic CLI 是一種從版本控制的 YAML 建立代理和環境的便捷方式 — 其 URL 位於 `shared/live-sources.md`。如果你需要的綁定沒有顯示在 README 中，請從 `shared/live-sources.md` WebFetch 相關項目，而不是猜測。C# 目前沒有管理代理支援；請對 API 使用 cURL 風格的原始 HTTP 請求。

---

## 我應該使用哪種介面？

> **從簡單開始。** 預設使用滿足你需求的最簡單層級。單次 API 呼叫和工作流程可處理大多數使用案例 — 只有當任務真正需要開放式、由模型驅動的探索時才使用代理。

| 使用案例 | 層級 | 推薦介面 | 原因 |
| --- | --- | --- | --- |
| 分類、摘要、擷取、問答 | 單次 LLM 呼叫 | **Claude API** | 一個請求，一個回應 |
| 批次處理或嵌入 | 單次 LLM 呼叫 | **Claude API** | 專用端點 |
| 具有程式碼控制邏輯的多步驟管道 | 工作流程 | **Claude API + 工具使用** | 你協調循環 |
| 使用自有工具的自訂代理 | 代理 | **Claude API + 工具使用** | 最大彈性 |
| 帶有工作區的伺服器管理有狀態代理 | 代理 | **管理代理 (Managed Agents)** | Anthropic 執行循環並代管工具執行沙盒 |
| 持久化、版本化的代理設定 | 代理 | **管理代理 (Managed Agents)** | 代理是儲存的物件；會話固定到一個版本 |
| 帶有檔案掛載的長時間運作、多輪代理 | 代理 | **管理代理 (Managed Agents)** | 每個會話的容器、SSE 事件流、技能 + MCP |

> **注意：** 當你希望 Anthropic 執行代理循環*並*代管工具執行所在的容器時，管理代理是正確的選擇 — 檔案操作、bash、程式碼執行都在每個會話的工作區中運作。如果你想自行代管運算或執行自己的自訂工具運行環境，Claude API + 工具使用是正確的選擇 — 使用工具執行器進行自動循環處理，或使用手動循環進行精細控制（審核閘門、自訂日誌記錄、條件執行）。

> **第三方提供者（Amazon Bedrock、Google Vertex AI、Microsoft Foundry）：** 在 Bedrock、Vertex 或 Foundry 上**無法使用**管理代理。如果你透過任何第三方提供者進行部署，請在所有使用案例中都使用 **Claude API + 工具使用** — 包括在其他情況下建議使用管理代理的案例。

### 決策樹

```
你的應用程式需要什麼？

0. 你是否透過 Amazon Bedrock、Google Vertex AI 或 Microsoft Foundry 部署？
   └── 是 → Claude API（如果需要代理，可使用工具） — 管理代理僅限第一方。
   否 → 繼續。

1. 單次 LLM 呼叫（分類、摘要、擷取、問答）
   └── Claude API — 一個請求，一個回應

2. 你是否希望 Anthropic 執行代理循環並代管一個每個會話的
   容器，讓 Claude 執行工具（bash、檔案操作、程式碼）？
   └── 是 → 管理代理 — 伺服器管理的會話、持久化的代理設定、
       SSE 事件流、技能 + MCP、檔案掛載。

3. 工作流程（多步驟、程式碼編排、使用自訂工具）或使用自訂工具環境的代理
   └── Claude API + 工具使用 — 最大靈活性，自訂工具和控制流
```

---

## 管理代理（Managed Agents - Beta 版）

使用管理代理時，API 會透過在它為你代管的沙盒環境中執行檔案操作、bash 指令和自訂程式碼（透過技能或 MCP）來自主解決問題。與基於用戶端的工具循環不同，你只需傳送一次初始請求，並以串流接收結果，伺服器會處理工具循環直到完成或需要你的輸入（審查或工具錯誤）。

> **第三方提供者：** 在 Bedrock、Vertex 或 Foundry 上無法使用。如果你透過任何第三方提供者進行部署，請使用 Claude API + 工具使用。

**強制流程：** 代理（一次）→ 會話（每次執行）。`model`/`system`/`tools` 存在於代理上，絕不是會話上。請參閱 `shared/managed-agents-overview.md` 以取得完整的閱讀指南、beta 標頭和陷阱。

**Beta 標頭：** `managed-agents-2026-04-01` — SDK 會自動為所有 `client.beta.{agents,environments,sessions,vaults}.*` 呼叫設定此標頭。技能 API 使用 `skills-2025-10-02`，檔案 API 使用 `files-api-2025-04-14`，但你不需要為 `/v1/skills` 和 `/v1/files` 以外的端點明確傳遞這些標頭。

**子命令** — 透過 `/claude-api <subcommand>` 直接呼叫：

| 子命令 | 動作 |
|---|---|
| `managed-agents-onboard` | 引導使用者從頭開始設定管理代理。**立即閱讀 `shared/managed-agents-onboarding.md`** 並遵循其訪談腳本：心智模型 → 了解或探索分支 → 範本設定 → 會話設定 → 輸出程式碼。不要總結 — 執行訪談。 |

**閱讀指南：** 從 `shared/managed-agents-overview.md` 開始，接著閱讀各主題的 `shared/managed-agents-*.md` 檔案（核心、環境、工具、事件、用戶端模式、入職、API 參考）。對於 Python、TypeScript、Go、Ruby、PHP 和 Java，閱讀 `{lang}/managed-agents/README.md` 以獲取程式碼範例。對於 cURL，閱讀 `curl/managed-agents.md`。**代理是持久的 — 建立一次，依 ID 引用。** 儲存由 `agents.create` 回傳的代理 ID，並將其傳遞給後續所有的 `sessions.create`；不要在請求路徑中呼叫 `agents.create`。Anthropic CLI 是一種從版本控制的 YAML（URL 位於 `shared/live-sources.md`）建立代理和環境的便捷方式。如果你需要的綁定沒有顯示在語言 README 中，請從 `shared/live-sources.md` WebFetch 相關項目，而不是猜測。C# 目前沒有管理代理支援；請使用 `curl/managed-agents.md` 中的原始 HTTP 作為參考。

**當使用者想從頭開始設定管理代理時**（例如「我該如何開始」、「引導我建立一個」、「設定一個新的代理」）：閱讀 `shared/managed-agents-onboarding.md` 並執行其訪談 — 與 `managed-agents-onboard` 子命令的流程相同。

**當使用者詢問「我該如何為 X 撰寫用戶端程式碼」時：** 取用 `shared/managed-agents-client-patterns.md` — 涵蓋無損串流重新連線、`processed_at` 佇列/處理閘門、中斷、`tool_confirmation` 往返、正確的閒置/終止中斷閘門、閒置後狀態競爭、串流優先排序、檔案掛載陷阱、透過自訂工具在主機端保留憑證等。

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

**代理設計（Agent design - 工具介面、上下文管理、快取策略）：**
→ 閱讀 `shared/agent-design.md`

**批次處理（非延遲敏感）：**
→ 閱讀 `{lang}/claude-api/README.md` + `{lang}/claude-api/batches.md`

**跨多個請求的檔案上傳：**
→ 閱讀 `{lang}/claude-api/README.md` + `{lang}/claude-api/files-api.md`

**管理代理（Managed Agents - 帶有工作區的伺服器管理有狀態代理）：**
→ 閱讀 `shared/managed-agents-overview.md` + 其餘的 `shared/managed-agents-*.md` 檔案。對於 Python、TypeScript、Go、Ruby、PHP 和 Java，閱讀 `{lang}/managed-agents/README.md` 獲取程式碼範例。對於 cURL，閱讀 `curl/managed-agents.md`。**代理是持久的 — 建立一次，依 ID 引用。** 儲存由 `agents.create` 回傳的代理 ID，並將其傳遞給後續所有的 `sessions.create`；不要在請求路徑中呼叫 `agents.create`。Anthropic CLI 是一種從版本控制的 YAML（URL 位於 `shared/live-sources.md`）建立代理和環境的便捷方式。如果你需要的綁定沒有顯示在語言 README 中，請從 `shared/live-sources.md` WebFetch 相關項目，而不是猜測。C# 目前不支援管理代理 — 請使用 `curl/managed-agents.md` 中的原始 HTTP 作為參考。

### Claude API（完整檔案參考）

閱讀**語言特定的 Claude API 資料夾**（`{language}/claude-api/`）：

1. **`{language}/claude-api/README.md`** — **先閱讀此檔。** 安裝、快速入門、常見模式、錯誤處理。
2. **`shared/tool-use-concepts.md`** — 當使用者需要函數呼叫、程式碼執行、記憶或結構化輸出時閱讀。涵蓋概念基礎。
3. **`shared/agent-design.md`** — 設計代理時閱讀：bash 與專用工具、編程工具呼叫、工具搜尋/技能、上下文編輯與壓縮與記憶、快取原則。
4. **`{language}/claude-api/tool-use.md`** — 語言特定工具使用程式碼範例（工具執行器、手動循環、程式碼執行、記憶、結構化輸出）。
5. **`{language}/claude-api/streaming.md`** — 建構逐步顯示回應的聊天 UI 或介面時閱讀。
6. **`{language}/claude-api/batches.md`** — 離線處理大量請求（非延遲敏感）時閱讀。以 50% 成本非同步執行。
7. **`{language}/claude-api/files-api.md`** — 跨多個請求發送同一檔案而不重新上傳時閱讀。
8. **`shared/prompt-caching.md`** — 當加入或最佳化提示詞快取時閱讀。涵蓋前綴穩定性設計、斷點放置，以及會靜默使快取失效的反模式。
9. **`shared/error-codes.md`** — 除錯 HTTP 錯誤或實作錯誤處理時閱讀。
10. **`shared/live-sources.md`** — 取得最新官方文件的 WebFetch URL。

> **注意：** Java、Go、Ruby、C#、PHP 和 cURL — 各有一個涵蓋所有基礎的單一檔案。根據需要閱讀該檔案加上 `shared/tool-use-concepts.md` 和 `shared/error-codes.md`。

> **注意：** 有關管理代理檔案參考，請參見上方的 `## 管理代理（Managed Agents - Beta 版）` 區塊 — 它列出了每個 `shared/managed-agents-*.md` 檔案和語言特定的 README。

---

## 何時使用 WebFetch

在以下情況使用 WebFetch 取得最新文件：

- 使用者要求「最新」或「當前」資訊
- 快取資料似乎不正確
- 使用者詢問此處未涵蓋的功能

即時文件 URL 在 `shared/live-sources.md` 中。

## 常見陷阱

- 將檔案或內容傳遞給 API 時不要截斷輸入。如果內容太長無法放入上下文窗口，通知使用者並討論選項（分塊、摘要等）而非靜默截斷。
- **Opus 4.6 / Sonnet 4.6 思維：** 使用 `thinking: {type: "adaptive"}` — 不要使用 `budget_tokens`（在 Opus 4.6 和 Sonnet 4.6 上已棄用）。舊模型的 `budget_tokens` 必須小於 `max_tokens`（最少 1024）。這如果設定錯誤會拋出錯誤。
- **Opus 4.6 prefill 已移除：** 助手訊息 prefill (last-assistant-turn prefills) 在 Opus 4.6 上回傳 400 錯誤。改用結構化輸出（`output_config.format`）或系統提示指令來控制回應格式。
- **`max_tokens` 預設值：** 不要低估 `max_tokens` — 達到上限會使輸出在中途被截斷，並需要重試。對於非串流請求，預設為 `~16000`（保持回應在 SDK HTTP 超時限制內）。對於串流請求，預設為 `~64000`（不需擔心超時，給予模型更多空間）。除非有明確理由（例如分類任務約 `~256`、成本上限或故意要求簡短輸出），否則不要設定更低的值。
- **128K 輸出 tokens：** Opus 4.6 支援最多 128K `max_tokens`，但 SDK 對大型 `max_tokens` 需要串流以避免 HTTP 超時。使用 `.stream()` 搭配 `.get_final_message()` / `.finalMessage()`。
- **工具呼叫 JSON 解析（Opus 4.6）：** Opus 4.6 可能在工具呼叫 `input` 欄位中產生不同的 JSON 字串跳脫 (例如，Unicode 或正斜線跳脫)。始終使用 `json.loads()` / `JSON.parse()` 解析工具輸入 — 絕不對序列化的輸入做原始字串比對。
- **結構化輸出（所有模型）：** 在 `messages.create()` 上使用 `output_config: {format: {...}}` 而非已棄用的 `output_format` 參數。這是一個通用的 API 變更，不僅限於 4.6 版。
- **不要重新實作 SDK 功能：** SDK 提供高階輔助方法 — 使用它們而非從頭建構。具體來說：使用 `stream.finalMessage()` 而非將 `.on()` 事件包裝在 `new Promise()` 中；使用強型別例外類別（例如 `Anthropic.RateLimitError`）而非對錯誤訊息進行字串比對；使用 SDK 型別（`Anthropic.MessageParam`、`Anthropic.Tool`、`Anthropic.Message` 等）而非重新定義等效的介面。
- **不要為 SDK 資料結構定義自訂型別：** SDK 匯出所有 API 物件的型別。訊息請使用 `Anthropic.MessageParam`，工具定義請使用 `Anthropic.Tool`，工具結果請使用 `Anthropic.ToolUseBlock` / `Anthropic.ToolResultBlockParam`，回應請使用 `Anthropic.Message`。自行定義 `interface ChatMessage { role: string; content: unknown }` 會重複 SDK 已提供的內容並失去型別安全。
- **報告和文件輸出：** 程式碼執行沙盒預裝了 `python-docx`、`python-pptx`、`matplotlib`、`pillow` 和 `pypdf`。Claude 可以生成格式化檔案（DOCX、PDF、圖表）並透過 Files API 回傳 — 考慮針對「報告」或「文件」類型的請求使用此方法，而不是純粹的 stdout 文本。
