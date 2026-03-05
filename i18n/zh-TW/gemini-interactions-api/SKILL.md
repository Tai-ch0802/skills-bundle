---
name: gemini-interactions-api
description: 當編寫呼叫 Gemini API 的程式碼時請使用此技能 用於文字生成、多輪對話、多模態理解、影像生成、串流回應、背景研究任務、函式呼叫、結構化輸出, 或從舊的 generateContent API 遷移。 此技能涵蓋 Interactions API，這是在 Python 和 TypeScript 中使用 Gemini 模型和代理的建議方式。
---

# Gemini Interactions API 技能

Interactions API 是與 Gemini 模型和代理互動的統一介面。 它是專為代理應用程式設計的 `generateContent` 的改良替代方案。 主要功能包括：
- **伺服器端狀態：** 透過 `previous_interaction_id` 將對話歷史記錄卸載到伺服器
- **背景執行：** 非同步執行長時間運作的任務（如深度研究）
- **串流：** 透過 Server-Sent Events (SSE) 接收漸進式回應
- **工具協調：** 函式呼叫、Google 搜尋、程式碼執行、URL 內容、檔案搜尋、遠端 MCP
- **代理：** 存取內建代理，如 Gemini Deep Research
- **思考：** 具備思考摘要的可設定推理深度

## 支援的模型與代理

**模型：**
- `gemini-3.1-pro-preview`: 1M tokens，複雜推理、寫程式、研究
- `gemini-3-flash-preview`: 1M tokens，速度與效能平衡、多模態
- `gemini-3.1-flash-lite-preview`: 成本效益高，針對高頻率及輕量級任務有最快效能
- `gemini-3-pro-image-preview`: 65k / 32k tokens，影像生成與編輯
- `gemini-3.1-flash-image-preview`: 65k / 32k tokens，影像生成與編輯
- `gemini-2.5-pro`: 1M tokens，複雜推理、寫程式、研究
- `gemini-2.5-flash`: 1M tokens，速度與效能平衡、多模態

**代理：**
- `deep-research-pro-preview-12-2025`: 深度研究代理

> [!IMPORTANT]
> 像是 `gemini-2.0-*` 或 `gemini-1.5-*` 這類的舊版模型已棄用。
> 您的內部知識可能也是舊的 — 請以本段落最新的模型與代理 ID 為準。
> **如果使用者要求使用已棄用的模型，請改用 `gemini-3-flash-preview` 或 `pro` 並告知替代方案。絕對不要產生使用已棄用模型 ID 的程式碼。**

## SDKs

- **Python**: `google-genai` >= `1.55.0` — 透過 `pip install -U google-genai` 安裝
- **JavaScript/TypeScript**: `@google/genai` >= `1.33.0` — 透過 `npm install @google/genai` 安裝

## 快速開始 (Quick Start)

### 與模型互動

#### Python
```python
from google import genai

client = genai.Client()

interaction = client.interactions.create(
    model="gemini-3-flash-preview",
    input="告訴我一個關於寫程式的笑話。"
)
print(interaction.outputs[-1].text)
```

#### JavaScript/TypeScript
```typescript
import { GoogleGenAI } from "@google/genai";

const client = new GoogleGenAI({});

const interaction = await client.interactions.create({
    model: "gemini-3-flash-preview",
    input: "告訴我一個關於寫程式的笑話。",
});
console.log(interaction.outputs[interaction.outputs.length - 1].text);
```

### 具狀態的對話 (Stateful Conversation)

#### Python
```python
from google import genai

client = genai.Client()

# 第一輪
interaction1 = client.interactions.create(
    model="gemini-3-flash-preview",
    input="嗨，我的名字是 Phil。"
)

# 第二輪 — 伺服器會記住上下文
interaction2 = client.interactions.create(
    model="gemini-3-flash-preview",
    input="我的名字是什麼？",
    previous_interaction_id=interaction1.id
)
print(interaction2.outputs[-1].text)
```

#### JavaScript/TypeScript
```typescript
import { GoogleGenAI } from "@google/genai";

const client = new GoogleGenAI({});

// 第一輪
const interaction1 = await client.interactions.create({
    model: "gemini-3-flash-preview",
    input: "嗨，我的名字是 Phil。",
});

// 第二輪 — 伺服器會記住上下文
const interaction2 = await client.interactions.create({
    model: "gemini-3-flash-preview",
    input: "我的名字是什麼？",
    previous_interaction_id: interaction1.id,
});
console.log(interaction2.outputs[interaction2.outputs.length - 1].text);
```

### 深度研究代理 (Deep Research Agent)

#### Python
```python
import time
from google import genai

client = genai.Client()

# 啟動背景研究
interaction = client.interactions.create(
    agent="deep-research-pro-preview-12-2025",
    input="研究 Google TPU 的歷史。",
    background=True
)

# 輪詢結果
while True:
    interaction = client.interactions.get(interaction.id)
    if interaction.status == "completed":
        print(interaction.outputs[-1].text)
        break
    elif interaction.status == "failed":
        print(f"Failed: {interaction.error}")
        break
    time.sleep(10)
```

#### JavaScript/TypeScript
```typescript
import { GoogleGenAI } from "@google/genai";

const client = new GoogleGenAI({});

// 啟動背景研究
const initialInteraction = await client.interactions.create({
    agent: "deep-research-pro-preview-12-2025",
    input: "研究 Google TPU 的歷史。",
    background: true,
});

// 輪詢結果
while (true) {
    const interaction = await client.interactions.get(initialInteraction.id);
    if (interaction.status === "completed") {
        console.log(interaction.outputs[interaction.outputs.length - 1].text);
        break;
    } else if (["failed", "cancelled"].includes(interaction.status)) {
        console.log(`Failed: ${interaction.status}`);
        break;
    }
    await new Promise(resolve => setTimeout(resolve, 10000));
}
```

### 串流 (Streaming)

#### Python
```python
from google import genai

client = genai.Client()

stream = client.interactions.create(
    model="gemini-3-flash-preview",
    input="用簡單白話解釋量子糾纏。",
    stream=True
)

for chunk in stream:
    if chunk.event_type == "content.delta":
        if chunk.delta.type == "text":
            print(chunk.delta.text, end="", flush=True)
    elif chunk.event_type == "interaction.complete":
        print(f"\n\nTotal Tokens: {chunk.interaction.usage.total_tokens}")
```

#### JavaScript/TypeScript
```typescript
import { GoogleGenAI } from "@google/genai";

const client = new GoogleGenAI({});

const stream = await client.interactions.create({
    model: "gemini-3-flash-preview",
    input: "用簡單白話解釋量子糾纏。",
    stream: true,
});

for await (const chunk of stream) {
    if (chunk.event_type === "content.delta") {
        if (chunk.delta.type === "text" && "text" in chunk.delta) {
            process.stdout.write(chunk.delta.text);
        }
    } else if (chunk.event_type === "interaction.complete") {
        console.log(`\n\nTotal Tokens: ${chunk.interaction.usage.total_tokens}`);
    }
}
```

## 資料模型 (Data Model)

一次 `Interaction` 回應包含了 `outputs` — 這是一個包含所有內容區塊的陣列。每個區塊都有獨立的 `type` 欄位：

- `text` — 產生的文字內容 (包含 `text` 欄位)
- `thought` — 模型的思考過程 (必須要有 `signature`，也可選填 `summary`)
- `function_call` — 工具呼叫請求 (包含 `id`, `name`, `arguments`)
- `function_result` — 回傳給模型的工具執行結果 (包含 `call_id`, `name`, `result`)
- `google_search_call` / `google_search_result` — Google 搜尋工具
- `code_execution_call` / `code_execution_result` — 程式碼執行工具
- `url_context_call` / `url_context_result` — 網頁上下文工具
- `mcp_server_tool_call` / `mcp_server_tool_result` — 遠端 MCP 工具
- `file_search_call` / `file_search_result` — 檔案搜尋工具
- `image` — 生成的影像或輸入影像 (包含 `data`, `mime_type`, 或 `uri`)

**回應範例 (函式呼叫)：**
```json
{
  "id": "v1_abc123",
  "model": "gemini-3-flash-preview",
  "status": "requires_action",
  "object": "interaction",
  "role": "model",
  "outputs": [
    {
      "type": "function_call",
      "id": "gth23981",
      "name": "get_weather",
      "arguments": { "location": "Boston, MA" }
    }
  ],
  "usage": {
    "total_input_tokens": 100,
    "total_output_tokens": 25,
    "total_thought_tokens": 0,
    "total_tokens": 125,
    "total_tool_use_tokens": 50
  }
}
```

**可能狀態值：** `completed`, `in_progress`, `requires_action`, `failed`, `cancelled`

## 與 generateContent 的主要差異

- `startChat()` + 自行維護歷史記錄 → 改用 `previous_interaction_id` (由伺服器管理狀態)
- `sendMessage()` → 改用 `interactions.create(previous_interaction_id=...)`
- `response.text` → 改用 `interaction.outputs[-1].text`
- 過去沒有背景執行機制 → 改用 `background=True` 於非同步任務
- 過去沒有代理功能 → 改用 `agent="deep-research-pro-preview-12-2025"`

## 注意事項

- Interactions **預設會被儲存** (`store=true`)。付費層保留 55 天，免費層保留 1 天。
- 您可設定 `store=false` 來取消儲存，但這將會停用 `previous_interaction_id` 和 `background=true` 的功能。
- `tools`、`system_instruction` 與 `generation_config` 的設定是 **針對每次 interaction 獨立生效的** — 必須在每一輪對話中重新指定。
- **代理 (Agents) 要求必須開啟** `background=True`。
- 您可以透過 `previous_interaction_id` 將**代理與傳統模型的 interactions 混合**在同一個對話中。

## 如何使用 Interactions API

如需詳細的 API 說明文件，請從以下官方網址獲取：

- [Interactions 完整文件](https://ai.google.dev/gemini-api/docs/interactions.md.txt)
- [Deep Research 代理完整文件](https://ai.google.dev/gemini-api/docs/deep-research.md.txt)
- [API Reference](https://ai.google.dev/static/api/interactions.md.txt)
- [OpenAPI 規格](https://ai.google.dev/static/api/interactions.openapi.json)

這些文件涵蓋了包含函式呼叫、內建工具（Google 搜尋、程式碼執行、URL 內容、檔案搜尋、Computer Use）、遠端 MCP、結構化輸出、設定「系統思考」、檔案操作、多模態生成與理解，以及串流等完整功能。
