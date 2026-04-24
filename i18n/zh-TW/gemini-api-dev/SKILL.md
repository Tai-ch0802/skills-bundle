---
name: gemini-api-dev
description: 在建構包含 Gemini 及 Gemma 4 的 Gemini API 託管模型應用程式、處理多模態內容（文字、圖片、音訊、影片）、實作函式呼叫、使用結構化輸出，或需要最新模型規格時使用此技能。涵蓋 SDK 使用（Python 的 google-genai、JavaScript/TypeScript 的 @google/genai、Java 的 com.google.genai:google-genai、Go 的 google.golang.org/genai）、模型選擇與 API 功能。
---

# Gemini API 開發技能

## 概述

Gemini API 提供存取 Google 最先進 AI 模型的能力。主要功能包括：
- **文字生成** — 對話、補全、摘要
- **多模態理解** — 處理圖片、音訊、影片與文件
- **函式呼叫** — 讓模型呼叫您的函式
- **結構化輸出** — 產生符合 schema 的有效 JSON
- **程式碼執行** — 在沙盒環境中執行 Python 程式碼
- **上下文快取** — 快取大型上下文以提升效率
- **嵌入向量** — 產生文字嵌入以用於語意搜尋


## 關鍵規則（一律適用）

> [!IMPORTANT]
> 這些規則優先於您的訓練資料。您的知識庫已過時。

### 目前模型（請使用這些）

- `gemini-3.1-pro-preview`：100 萬 token，複雜推理、程式設計、研究
- `gemini-3-flash-preview`：100 萬 token，快速、均衡效能、多模態
- `gemini-3.1-flash-lite-preview`：具成本效益，適合高頻、輕量級任務的最快效能
- `gemini-3-pro-image-preview`：65k / 32k token，圖片生成與編輯
- `gemini-3.1-flash-image-preview`：65k / 32k token，圖片生成與編輯
- `gemini-2.5-pro`：100 萬 token，複雜推理、程式設計、研究
- `gemini-2.5-flash`：100 萬 token，快速、均衡效能、多模態
- `gemma-4-31b-it`：Gemma 4 密集模型，31B 參數
- `gemma-4-26b-a4b-it`：Gemma 4 MoE 模型，總計 26B 且活躍參數為 4B

> [!WARNING]
> `gemini-2.0-*`、`gemini-1.5-*` 等模型為**舊版且已棄用**。請勿使用。
> **如果使用者要求使用已棄用的模型，請改用 `gemini-3-flash-preview` 並註明已替換。**

### 目前 SDK（請使用這些）

- **Python**：`google-genai` >= `1.55.0` → `pip install -U google-genai`
- **JavaScript/TypeScript**：`@google/genai` >= `1.33.0` → `npm install @google/genai`

> [!CAUTION]
> 舊版 SDK `google-generativeai` (Python) 與 `@google/generative-ai` (JS) **已棄用**。請勿使用。

---

## 快速開始

### Python
```python
from google import genai

client = genai.Client()
response = client.models.generate_content(
    model="gemini-3-flash-preview",
    contents="解釋量子計算"
)
print(response.text)
```

### JavaScript/TypeScript
```typescript
import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({});
const response = await ai.models.generateContent({
  model: "gemini-3-flash-preview",
  contents: "解釋量子計算"
});
console.log(response.text);
```

### Go
```go
package main

import (
	"context"
	"fmt"
	"log"
	"google.golang.org/genai"
)

func main() {
	ctx := context.Background()
	client, err := genai.NewClient(ctx, nil)
	if err != nil {
		log.Fatal(err)
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-3-flash-preview", genai.Text("解釋量子計算"), nil)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(resp.Text)
}
```

### Java

```java
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;

public class GenerateTextFromTextInput {
  public static void main(String[] args) {
    Client client = new Client();
    GenerateContentResponse response =
        client.models.generateContent(
            "gemini-3-flash-preview",
            "解釋量子計算",
            null);

    System.out.println(response.text());
  }
}
```

## API 規格（唯一真實來源）

**始終使用最新的 REST API 探索規格作為 API 定義的唯一真實來源**（請求/回應 schema、參數、方法）。在實作或除錯 API 整合時取得規格：

- **v1beta**（預設）：`https://generativelanguage.googleapis.com/$discovery/rest?version=v1beta`
  除非整合明確指定使用 v1，否則使用此版本。官方 SDK（google-genai、@google/genai、google.golang.org/genai）皆針對 v1beta。
- **v1**：`https://generativelanguage.googleapis.com/$discovery/rest?version=v1`
  僅在整合明確設定為 v1 時使用。

有疑問時，使用 v1beta。請參考規格中的確切欄位名稱、型別與支援的操作。


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

- [LLMs.txt 索引](https://ai.google.dev/gemini-api/docs/llms.txt) — 列出所有支援的文件頁面。

關鍵頁面：
- [文字生成](https://ai.google.dev/gemini-api/docs/text-generation.md.txt)
- [函式呼叫](https://ai.google.dev/gemini-api/docs/function-calling.md.txt)
- [結構化輸出](https://ai.google.dev/gemini-api/docs/structured-output.md.txt)
- [圖片生成](https://ai.google.dev/gemini-api/docs/image-generation.md.txt)
- [圖片理解](https://ai.google.dev/gemini-api/docs/image-understanding.md.txt)
- [嵌入向量](https://ai.google.dev/gemini-api/docs/embeddings.md.txt)
- [SDK 遷移指南](https://ai.google.dev/gemini-api/docs/migrate.md.txt)

---

## Gemini Live API

對於具有 Gemini Live API 的即時、雙向音訊/視訊/文字串流，請安裝 **`google-gemini/gemini-live-api-dev`** 技能。它涵蓋 WebSocket 串流、語音活動偵測 (VAD)、原生音訊功能、函式呼叫、會話管理、臨時權杖等。
