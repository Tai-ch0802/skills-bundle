---
name: gemini-api-dev
description: 在建構 Gemini 模型應用程式、使用 Gemini API、處理多模態內容（文字、圖片、音訊、影片）、實作函式呼叫、使用結構化輸出，或需要最新模型規格時使用此技能。涵蓋 SDK 使用（Python 的 google-genai、JavaScript/TypeScript 的 @google/genai、Java 的 com.google.genai:google-genai、Go 的 google.golang.org/genai）、模型選擇與 API 功能。
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

## 目前 Gemini 模型

- `gemini-3-pro-preview`：100 萬 token，複雜推理、程式設計、研究
- `gemini-3-flash-preview`：100 萬 token，快速、均衡效能、多模態
- `gemini-3-pro-image-preview`：65k / 32k token，圖片生成與編輯


> [!IMPORTANT]
> `gemini-2.5-*`、`gemini-2.0-*`、`gemini-1.5-*` 等模型已為舊版且已棄用。請使用上方的新模型。您的知識庫可能已過時。

## SDK

- **Python**：`google-genai`，安裝指令 `pip install google-genai`
- **JavaScript/TypeScript**：`@google/genai`，安裝指令 `npm install @google/genai`
- **Go**：`google.golang.org/genai`，安裝指令 `go get google.golang.org/genai`
- **Java**：
  - groupId：`com.google.genai`，artifactId：`google-genai`
  - 最新版本可在此找到：https://central.sonatype.com/artifact/com.google.genai/google-genai/versions（我們稱之為 `LAST_VERSION`）
  - 在 `build.gradle` 中安裝：
    ```
    implementation("com.google.genai:google-genai:${LAST_VERSION}")
    ```
  - 在 `pom.xml` 中安裝 Maven 相依性：
    ```
    <dependency>
	    <groupId>com.google.genai</groupId>
	    <artifactId>google-genai</artifactId>
	    <version>${LAST_VERSION}</version>
	</dependency>
    ```

> [!WARNING]
> 舊版 SDK `google-generativeai`（Python）和 `@google/generative-ai`（JS）已棄用。請儘速遷移至上方的新 SDK，並參閱遷移指南。

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

## 如何使用 Gemini API

如需詳細的 API 文件，請從官方文件索引取得：

**llms.txt 網址**：`https://ai.google.dev/gemini-api/docs/llms.txt`

此索引包含所有文件頁面的 `.md.txt` 格式連結。使用網路擷取工具來：

1. 取得 `llms.txt` 以探索可用的文件頁面
2. 取得特定頁面（例如 `https://ai.google.dev/gemini-api/docs/function-calling.md.txt`）

### 重要文件頁面

> [!IMPORTANT]
> 以下並非所有文件頁面。請使用 `llms.txt` 索引來探索可用的文件頁面。

- [模型](https://ai.google.dev/gemini-api/docs/models.md.txt)
- [Google AI Studio 快速入門](https://ai.google.dev/gemini-api/docs/ai-studio-quickstart.md.txt)
- [Nano Banana 圖片生成](https://ai.google.dev/gemini-api/docs/image-generation.md.txt)
- [使用 Gemini API 進行函式呼叫](https://ai.google.dev/gemini-api/docs/function-calling.md.txt)
- [結構化輸出](https://ai.google.dev/gemini-api/docs/structured-output.md.txt)
- [文字生成](https://ai.google.dev/gemini-api/docs/text-generation.md.txt)
- [圖片理解](https://ai.google.dev/gemini-api/docs/image-understanding.md.txt)
- [嵌入向量](https://ai.google.dev/gemini-api/docs/embeddings.md.txt)
- [互動 API](https://ai.google.dev/gemini-api/docs/interactions.md.txt)
- [SDK 遷移指南](https://ai.google.dev/gemini-api/docs/migrate.md.txt)
