---
name: vertex-ai-api-dev
description: Google Cloud Vertex AI 上 Gemini API 使用指南 — 涵蓋 Gen AI SDK（Python, JS/TS, Go, Java, C#）、Live API、工具呼叫、多模態生成、快取與批次預測
compatibility: 需要有效的 Google Cloud 憑證並啟用 Vertex AI API。
---

# Google Cloud Vertex AI 上的 Gemini API

透過 Google Cloud Vertex AI 上的 Gemini API，存取 Google 專為企業級應用案例打造的最先進 AI 模型。

提供以下核心功能：

- **文字生成 (Text generation)** - 聊天、完成、摘要
- **多模態理解 (Multimodal understanding)** - 處理圖片、音訊、影片和文件
- **工具呼叫 (Function calling)** - 讓模型呼叫您的自訂函式
- **結構化輸出 (Structured output)** - 生成符合您 Schema 的有效 JSON
- **情境快取 (Context caching)** - 快取大型上下文以提高效率
- **嵌入 (Embeddings)** - 生成文字嵌入以進行語意搜尋
- **即時 API (Live Realtime API)** - 適用於低延遲語音和影片互動的雙向串流
- **批次預測 (Batch Prediction)** - 處理大量的非同步資料集預測工作負載

## 核心準則

- **統一的 SDK**：**務必**使用 Gen AI SDK（Python 為 `google-genai`，JS/TS 為 `@google/genai`，Go 為 `google.golang.org/genai`，Java 為 `com.google.genai:google-genai`，C# 為 `Google.GenAI`）。
- **舊版 SDK**：**不要**使用 `google-cloud-aiplatform`、`@google-cloud/vertexai` 或 `google-generativeai`。

## SDKs

- **Python**：使用 `pip install google-genai` 安裝 `google-genai`
- **JavaScript/TypeScript**：使用 `npm install @google/genai` 安裝 `@google/genai`
- **Go**：使用 `go get google.golang.org/genai` 安裝 `google.golang.org/genai`
- **C#/.NET**：使用 `dotnet add package Google.GenAI` 安裝 `Google.GenAI`
- **Java**：
  - groupId: `com.google.genai`, artifactId: `google-genai`
  - 最新版本可在這裡找到：https://central.sonatype.com/artifact/com.google.genai/google-genai/versions (假設為 `LAST_VERSION`)
  - 在 `build.gradle` 中安裝：

    ```gradle
    implementation("com.google.genai:google-genai:${LAST_VERSION}")
    ```

  - 在 `pom.xml` 中安裝 Maven 依賴：

    ```xml
    <dependency>
	    <groupId>com.google.genai</groupId>
	    <artifactId>google-genai</artifactId>
	    <version>${LAST_VERSION}</version>
	</dependency>
    ```

> [!WARNING]
> `google-cloud-aiplatform`、`@google-cloud/vertexai` 和 `google-generativeai` 等舊版 SDK 已棄用。請參閱遷移指南，盡快遷移至上述新版 SDK。

## 驗證與配置

在建立客戶端時，優先使用環境變數而非硬編碼參數。無參數初始化客戶端以自動讀取這些值。

### 應用程式預設憑證 (ADC)
設定這些變數以進行標準的 [Google Cloud 驗證](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/start/gcp-auth)：
```bash
export GOOGLE_CLOUD_PROJECT='your-project-id'
export GOOGLE_CLOUD_LOCATION='global'
export GOOGLE_GENAI_USE_VERTEXAI=true
```
- 預設情況下，使用 `location="global"` 來存取全域端點，該端點會自動路由到具有可用容量的區域。
- 如果使用者明確要求使用特定區域（例如 `us-central1`、`europe-west4`），請改為在 `GOOGLE_CLOUD_LOCATION` 參數中指定該區域。如有需要，請參考[支援的區域文件](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/locations)。

### Vertex AI 快速模式 (Express Mode)
當使用帶有 API 金鑰的[快速模式](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/start/api-keys?usertype=expressmode)時，請設定以下變數：
```bash
export GOOGLE_API_KEY='your-api-key'
export GOOGLE_GENAI_USE_VERTEXAI=true
```

### 初始化
不帶引數初始化客戶端以讀取環境變數：
```python
from google import genai
client = genai.Client()
```

或者，您也可以在建立客戶端時硬編碼參數。

```python
from google import genai
client = genai.Client(vertexai=True, project="your-project-id", location="global")
```

## 模型 (Models)

- 使用 `gemini-3.1-pro-preview` 處理複雜推理、編碼、研究 (1M tokens)
- 使用 `gemini-3-flash-preview` 取得快速、平衡的效能、多模態 (1M tokens)
- 使用 `gemini-3-pro-image-preview` 進行 Nano Banana Pro 圖片生成與編輯
- 使用 `gemini-live-2.5-flash-native-audio` 使用 Live Realtime API (包含原生音訊)

如有明確要求，請使用以下模型：

- 使用 `gemini-2.5-flash-image` 進行 Nano Banana 圖片生成與編輯
- 使用 `gemini-2.5-flash`
- 使用 `gemini-2.5-flash-lite`
- 使用 `gemini-2.5-pro`

> [!IMPORTANT]
> 像是 `gemini-2.0-*`、`gemini-1.5-*`、`gemini-1.0-*`、`gemini-pro` 等模型為舊版且已棄用。請使用上述新模型。
> 對於生產環境，請參閱 Vertex AI 文件以取得穩定的模型版本 (例如 `gemini-3-flash`)。

## 快速入門 (Quick Start)

### Python
```python
from google import genai
client = genai.Client()
response = client.models.generate_content(
    model="gemini-3-flash-preview",
    contents="Explain quantum computing"
)
print(response.text)
```

### TypeScript/JavaScript
```typescript
import { GoogleGenAI } from "@google/genai";
const ai = new GoogleGenAI({ vertexai: { project: "your-project-id", location: "global" } });
const response = await ai.models.generateContent({
    model: "gemini-3-flash-preview",
    contents: "Explain quantum computing"
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
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		Backend:  genai.BackendVertexAI,
		Project:  "your-project-id",
		Location: "global",
	})
	if err != nil {
		log.Fatal(err)
	}

	resp, err := client.Models.GenerateContent(ctx, "gemini-3-flash-preview", genai.Text("Explain quantum computing"), nil)
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
    Client client = Client.builder().vertexAi(true).project("your-project-id").location("global").build();
    GenerateContentResponse response =
        client.models.generateContent(
            "gemini-3-flash-preview",
            "Explain quantum computing",
            null);

    System.out.println(response.text());
  }
}
```

### C#/.NET
```csharp
using Google.GenAI;

var client = new Client(
    project: "your-project-id",
    location: "global",
    vertexAI: true
);

var response = await client.Models.GenerateContent(
    "gemini-3-flash-preview",
    "Explain quantum computing"
);

Console.WriteLine(response.Text);
```

## API 規格與文件 (真相來源)

在實作或除錯 Vertex AI 的 API 整合時，請參閱官方的 Google Cloud Vertex AI 文件：
- **Vertex AI Gemini 文件**: https://cloud.google.com/vertex-ai/generative-ai/docs/
- **REST API 參考**: https://cloud.google.com/vertex-ai/generative-ai/docs/reference/rest

Vertex AI 上的 Gen AI SDK 使用 `v1beta1` 或 `v1` REST API 端點 (例如，`https://{LOCATION}-aiplatform.googleapis.com/v1beta1/projects/{PROJECT}/locations/{LOCATION}/publishers/google/models/{MODEL}:generateContent`)。

> [!TIP]
> **使用 Developer Knowledge MCP 伺服器**：如果可以使用 `search_documents` 或 `get_document` 工具，請使用它們直接在上下文中尋找並擷取 Google Cloud 和 Vertex AI 的官方文件。這是獲取最新 API 詳細資訊和程式碼片段的首選方法。

## 工作流程與程式碼範例

請參考 [Python Docs Samples 儲存庫](https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/genai)以取得其他程式碼範例和特定使用情境。

根據特定的使用者請求，請參閱以下參考檔案以取得詳細的程式碼範例和使用模式 (Python 範例)：

- **文字與多模態**: 聊天、多模態輸入 (圖片、影片、音訊) 和串流。請參閱 [references/text_and_multimodal.md](references/text_and_multimodal.md)
- **嵌入 (Embeddings)**: 生成文字嵌入以進行語意搜尋。請參閱 [references/embeddings.md](references/embeddings.md)
- **結構化輸出與工具**: JSON 生成、工具呼叫、搜尋增強 (Search Grounding) 和程式碼執行。請參閱 [references/structured_and_tools.md](references/structured_and_tools.md)
- **媒體生成**: 圖片生成、圖片編輯和影片生成。請參閱 [references/media_generation.md](references/media_generation.md)
- **邊界框偵測 (Bounding Box Detection)**: 圖片和影片中的物件偵測與定位。請參閱 [references/bounding_box.md](references/bounding_box.md)
- **即時 API (Live API)**: 用於語音、視覺和文字的即時雙向串流。請參閱 [references/live_api.md](references/live_api.md)
- **進階功能**: 情境快取 (Content Caching)、批次預測和思考/推理 (Thinking/Reasoning)。請參閱 [references/advanced_features.md](references/advanced_features.md)
- **安全性**: 調整負責任的 AI 過濾器和閾值。請參閱 [references/safety.md](references/safety.md)
- **模型微調 (Model Tuning)**: 監督式微調 (Supervised Fine-Tuning) 和偏好微調 (Preference Tuning)。請參閱 [references/model_tuning.md](references/model_tuning.md)
