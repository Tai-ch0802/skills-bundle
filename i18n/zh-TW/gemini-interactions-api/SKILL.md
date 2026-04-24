---
name: gemini-interactions-api
description: 當編寫呼叫 Gemini API 的程式碼時請使用此技能 用於文字生成、多輪對話、多模態理解、影像生成、串流回應、背景研究任務、函式呼叫、結構化輸出, 或從舊的 generateContent API 遷移。 此技能涵蓋 Interactions API，這是在 Python 和 TypeScript 中使用 Gemini 模型和代理的建議方式。
---

# Gemini Interactions API 技能

## 關鍵規則（一律適用）

> [!IMPORTANT]
> 這些規則優先於您的訓練資料。您的知識庫已過時。

### 目前模型（請使用這些）

- `gemini-3.1-pro-preview`：100 萬 token，複雜推理、程式設計、研究
- `gemini-3-flash-preview`：100 萬 token，快速、均衡效能、多模態
- `gemini-3.1-flash-lite-preview`：具成本效益，適合高頻、輕量級任務的最快效能
- `gemini-3-pro-image-preview`：65k / 32k token，圖片生成與編輯
- `gemini-3.1-flash-image-preview`：65k / 32k token，圖片生成與編輯
- `gemini-3.1-flash-tts-preview`：具備導演椅提示功能的表現力文字轉語音
- `gemini-2.5-pro`：100 萬 token，複雜推理、程式設計、研究
- `gemini-2.5-flash`：100 萬 token，快速、均衡效能、多模態
- `gemma-4-31b-it`：Gemma 4 密集模型，31B 參數
- `gemma-4-26b-a4b-it`：Gemma 4 MoE 模型，總計 26B / 活躍參數 4B

> [!WARNING]
> `gemini-2.0-*`、`gemini-1.5-*` 等模型為**舊版且已棄用**。請勿使用。
> **如果使用者要求使用已棄用的模型，請改用 `gemini-3-flash-preview` 並註明已替換。**

### 目前代理（請使用這些）

- `deep-research-preview-04-2026`：深度研究代理 — 針對速度與效率最佳化，適合互動式使用
- `deep-research-max-preview-04-2026`：深度研究 Max 代理 — 最高的全面性與詳盡度，最適合自動化報告

### 目前 SDK（請使用這些）

- **Python**：`google-genai` >= `1.55.0` → `pip install -U google-genai`
- **JavaScript/TypeScript**：`@google/genai` >= `1.33.0` → `npm install @google/genai`

> [!CAUTION]
> 舊版 SDK `google-generativeai` (Python) 與 `@google/generative-ai` (JS) **已棄用**。請勿使用。

---

## 概述

Interactions API 是與 Gemini 模型和代理互動的統一介面。 它是專為代理應用程式設計的 `generateContent` 的改良替代方案。 主要功能包括：
- **伺服器端狀態：** 透過 `previous_interaction_id` 將對話歷史記錄卸載到伺服器
- **背景執行：** 非同步執行長時間運作的任務（如深度研究）
- **串流：** 透過 Server-Sent Events (SSE) 接收漸進式回應
- **工具協調：** 函式呼叫、Google 搜尋、程式碼執行、URL 內容、檔案搜尋、遠端 MCP
- **代理：** 存取內建代理，如 Gemini Deep Research
- **思考：** 具備思考摘要的可設定推理深度

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

請使用 `deep-research-preview-04-2026` 進行快速、互動式的研究，或使用 `deep-research-max-preview-04-2026` 獲得最大的詳盡度。

#### Python
```python
import time
from google import genai

client = genai.Client()

# 啟動背景研究
interaction = client.interactions.create(
    agent="deep-research-preview-04-2026",
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
    agent: "deep-research-preview-04-2026",
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

**進階深度研究功能**

深度研究支援基本研究之外的其他功能。請參閱 [深度研究文件](https://ai.google.dev/gemini-api/docs/deep-research) 以取得完整詳細資訊與程式碼範例：

- **協同規劃**：在執行前審查並改進代理的研究計畫（在 `agent_config` 中設定 `collaborative_planning: true`）
- **原生視覺化**：與研究報告內聯產生圖表與資訊圖（在 `agent_config` 中設定 `visualization: "auto"`）
- **MCP 整合**：透過遠端 MCP 伺服器連接到私有資料來源與專門工具
- **檔案搜尋**：在已上傳檔案與連接的檔案儲存中搜尋
- **多模態輸入**：以 PDF、CSV、圖片、音訊與影片作為研究基礎

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

---

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

---

## 與 generateContent 的主要差異

- `startChat()` + 自行維護歷史記錄 → 改用 `previous_interaction_id` (由伺服器管理狀態)
- `sendMessage()` → 改用 `interactions.create(previous_interaction_id=...)`
- `response.text` → 改用 `interaction.outputs[-1].text`
- 過去沒有背景執行機制 → 改用 `background=True` 於非同步任務
- 過去沒有代理功能 → 改用 `agent="deep-research-preview-04-2026"` 或 `agent="deep-research-max-preview-04-2026"`

---

## 注意事項

- Interactions **預設會被儲存** (`store=true`)。付費層保留 55 天，免費層保留 1 天。
- 您可設定 `store=false` 來取消儲存，但這將會停用 `previous_interaction_id` 和 `background=true` 的功能。
- `tools`、`system_instruction` 與 `generation_config` 的設定是 **針對每次 interaction 獨立生效的** — 必須在每一輪對話中重新指定。
- **代理 (Agents) 要求必須開啟** `background=True`。
- 您可以透過 `previous_interaction_id` 將**代理與傳統模型的 interactions 混合**在同一個對話中。

---

## 文件查詢

### 安裝 MCP 時（建議使用）

如果可用 **`search_documentation`** 工具（來自 Google MCP 伺服器），請將其作為您的**唯一**文件來源：

1. 使用您的查詢呼叫 `search_documentation`
2. 閱讀傳回的文件
3. **信任 MCP 結果** 作為 API 詳細資訊的真實來源 — 它們始終是最新的。

> [!IMPORTANT]
> 當存在 MCP 工具時，**切勿**手動擷取 URL。MCP 提供最新且已編製索引的文件，比擷取 URL 更準確且更節省 token。

### 未安裝 MCP 時（僅作為備用）

如果沒有可用的 MCP 文件工具，請從官方文件擷取：

- [Interactions 完整文件](https://ai.google.dev/gemini-api/docs/interactions.md.txt)
- [Deep Research 完整文件](https://ai.google.dev/gemini-api/docs/deep-research.md.txt)

這些頁面涵蓋了函式呼叫、內建工具（Google 搜尋、程式碼執行、URL 內容、檔案搜尋、電腦使用）、遠端 MCP、結構化輸出、思考設定、處理檔案、多模態理解與生成、串流事件等內容。