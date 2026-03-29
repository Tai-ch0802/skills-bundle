---
name: gemini-live-api-dev
description: 處理使用 Gemini Live API 的即時、雙向串流應用程式時使用此技能。涵蓋基於 WebSocket 的音訊/視訊/文字串流、語音活動偵測 (VAD)、原生音訊功能、函式呼叫、會話管理、用戶端身分驗證的臨時權杖，以及所有 Live API 設定選項。涵蓋的 SDK - google-genai (Python)、@google/genai (JavaScript/TypeScript)。
---

# Gemini Live API 開發技能

## 概述

Live API 支援透過 WebSockets 與 Gemini 進行**低延遲、即時的語音和視訊互動**。它能處理連續的音訊、視訊或文字串流，並提供即時、擬真的口語回應。

主要功能：
- **雙向音訊串流** — 即時的麥克風對喇叭對話
- **視訊串流** — 將攝影機/螢幕畫面與音訊一起傳送
- **文字輸入/輸出** — 在即時會話中傳送和接收文字
- **音訊轉錄** — 取得輸入和輸出音訊的文字轉錄
- **語音活動偵測 (VAD)** — 自動處理中斷
- **原生音訊** — 思考（透過可設定的 `thinkingLevel`）
- **函式呼叫** — 同步的工具使用
- **Google 搜尋背景資訊 (Grounding)** — 將回應建立在即時的搜尋結果上
- **會話管理** — 上下文壓縮、會話恢復、GoAway 訊號
- **臨時權杖** — 安全的用戶端身分驗證

> [!NOTE]
> Live API 目前**僅支援 WebSockets**。如需 WebRTC 支援或簡化的整合，請使用[合作夥伴整合](#合作夥伴整合)。

## 模型

- `gemini-3.1-flash-live-preview` — 針對低延遲、即時對話進行最佳化。原生音訊輸出、思考（透過 `thinkingLevel`）。128k 上下文視窗。**這是所有 Live API 案例的建議模型。**

> [!WARNING]
> 以下 Live API 模型**已棄用**並將被關閉。請遷移至 `gemini-3.1-flash-live-preview`。
> - `gemini-2.5-flash-native-audio-preview-12-2025` — 請遷移至 `gemini-3.1-flash-live-preview`。
> - `gemini-live-2.5-flash-preview` — 於 2025 年 6 月 17 日發布。關閉時間：2025 年 12 月 9 日。
> - `gemini-2.0-flash-live-001` — 於 2025 年 4 月 9 日發布。關閉時間：2025 年 12 月 9 日。

## 音訊格式

- **輸入**：原始 PCM，小端序 (little-endian)，16 位元，單聲道。原生為 16kHz（將重新取樣其他頻率）。MIME 類型：`audio/pcm;rate=16000`
- **輸出**：原始 PCM，小端序 (little-endian)，16 位元，單聲道。取樣率為 24kHz。

> [!IMPORTANT]
> 請使用 `send_realtime_input` / `sendRealtimeInput` 處理所有即時使用者輸入（音訊、視訊**和文字**）。`send_client_content` / `sendClientContent` **僅支援**用於設定初始上下文歷史記錄（需要在 `history_config` 中設定 `initial_history_in_client_content`）。**請勿**使用它在對話期間傳送新的使用者訊息。

> [!WARNING]
> 請**勿**在 `sendRealtimeInput` 中使用 `media`。請使用特定鍵值：`audio` 用於音訊資料、`video` 用於圖片/視訊影格、`text` 用於文字輸入。

---

## 快速入門

### 身分驗證

#### Python

```python
from google import genai

client = genai.Client(api_key="YOUR_API_KEY")
```

#### JavaScript

```js
import { GoogleGenAI } from '@google/genai';

const ai = new GoogleGenAI({ apiKey: 'YOUR_API_KEY' });
```

### 連接至 Live API

#### Python
```python
from google.genai import types

config = types.LiveConnectConfig(
    response_modalities=[types.Modality.AUDIO],
    system_instruction=types.Content(
        parts=[types.Part(text="你是一個樂於助人的助手。")]
    )
)

async with client.aio.live.connect(model="gemini-3.1-flash-live-preview", config=config) as session:
    pass  # 會話現已啟動
```

#### JavaScript
```js
const session = await ai.live.connect({
  model: 'gemini-3.1-flash-live-preview',
  config: {
    responseModalities: ['audio'],
    systemInstruction: { parts: [{ text: '你是一個樂於助人的助手。' }] }
  },
  callbacks: {
    onopen: () => console.log('已連接'),
    onmessage: (response) => console.log('訊息:', response),
    onerror: (error) => console.error('錯誤:', error),
    onclose: () => console.log('已關閉')
  }
});
```

### 傳送文字

#### Python
```python
await session.send_realtime_input(text="你好，你好嗎？")
```

#### JavaScript
```js
session.sendRealtimeInput({ text: '你好，你好嗎？' });
```

### 傳送音訊

#### Python
```python
await session.send_realtime_input(
    audio=types.Blob(data=chunk, mime_type="audio/pcm;rate=16000")
)
```

#### JavaScript
```js
session.sendRealtimeInput({
  audio: { data: chunk.toString('base64'), mimeType: 'audio/pcm;rate=16000' }
});
```

### 傳送視訊

#### Python
```python
# frame：原始 JPEG 編碼位元組
await session.send_realtime_input(
    video=types.Blob(data=frame, mime_type="image/jpeg")
)
```

#### JavaScript
```js
session.sendRealtimeInput({
  video: { data: frame.toString('base64'), mimeType: 'image/jpeg' }
});
```

### 接收音訊與文字

> [!IMPORTANT]
> 單一伺服器事件可**同時包含多個內容部分**（例如音訊區塊和文字轉錄）。請務必在每個事件中處理**所有**部分，以避免遺漏內容。

#### Python
```python
async for response in session.receive():
    content = response.server_content
    if content:
        # 音訊 — 在每個事件中處理所有部分
        if content.model_turn:
            for part in content.model_turn.parts:
                if part.inline_data:
                    audio_data = part.inline_data.data
        # 轉錄
        if content.input_transcription:
            print(f"User: {content.input_transcription.text}")
        if content.output_transcription:
            print(f"Gemini: {content.output_transcription.text}")
        # 中斷
        if content.interrupted is True:
            pass  # 停止播放，清除音訊佇列
```

#### JavaScript
```js
// 在 onmessage 回呼函式中
const content = response.serverContent;
if (content?.modelTurn?.parts) {
  for (const part of content.modelTurn.parts) {
    if (part.inlineData) {
      const audioData = part.inlineData.data; // Base64 編碼
    }
  }
}
if (content?.inputTranscription) console.log('User:', content.inputTranscription.text);
if (content?.outputTranscription) console.log('Gemini:', content.outputTranscription.text);
if (content?.interrupted) { /* 停止播放，清除音訊佇列 */ }
```

---

## 限制

- **回應模態** — 每個會話僅限 `TEXT` **或** `AUDIO`，無法兩者兼具
- **純音訊會話** — 不壓縮情況下可達 15 分鐘
- **音訊+視訊會話** — 不壓縮情況下可達 2 分鐘
- **連線壽命** — 約 10 分鐘（請使用會話恢復）
- **上下文視窗** — 128k 個 token（原生音訊）/ 32k 個 token（標準）
- **程式碼執行** — 不支援
- **URL 上下文** — 不支援

## 最佳實踐

1. 測試麥克風音訊時請**使用耳機**，以防產生回音/自我中斷
2. 針對超過 15 分鐘的會話**啟用上下文視窗壓縮**
3. **實作會話恢復**以優雅地處理連線重設
4. 為用戶端部署**使用臨時權杖** — 切勿在瀏覽器中暴露 API 金鑰
5. **針對所有即時使用者輸入使用 `send_realtime_input`**（音訊、視訊、文字）。僅保留 `send_client_content` 來注入對話歷史記錄
6. 在麥克風暫停時**傳送 `audioStreamEnd`** 以排空快取的音訊
7. 在收到中斷訊號時**清除音訊播放佇列**

## 如何使用 Gemini API

如需詳細的 API 文件，請從官方文件索引取得：

**llms.txt URL**：`https://ai.google.dev/gemini-api/docs/llms.txt`

此索引包含所有文件頁面的 `.md.txt` 格式連結。使用網路擷取工具來：

1. 取得 `llms.txt` 以探索可用的文件頁面
2. 取得特定頁面（例如 `https://ai.google.dev/gemini-api/docs/live-session.md.txt`）

### 重要文件頁面

> [!IMPORTANT]
> 以下並非所有文件頁面。請使用 `llms.txt` 索引來探索可用的文件頁面。

- [Live API 概述](https://ai.google.dev/gemini-api/docs/live.md.txt) — 快速入門、原始 WebSocket 使用
- [Live API 功能指南](https://ai.google.dev/gemini-api/docs/live-guide.md.txt) — 語音設定、轉錄設定、原生音訊（思考）、VAD 設定、媒體解析度
- [Live API 工具使用](https://ai.google.dev/gemini-api/docs/live-tools.md.txt) — 函式呼叫（同步）、Google 搜尋背景資訊
- [會話管理](https://ai.google.dev/gemini-api/docs/live-session.md.txt) — 上下文視窗壓縮、會話恢復、GoAway 訊號
- [臨時權杖](https://ai.google.dev/gemini-api/docs/ephemeral-tokens.md.txt) — 適用於瀏覽器/行動裝置的安全用戶端身分驗證
- [WebSockets API 參考](https://ai.google.dev/api/live.md.txt) — 原始 WebSocket 協定詳細資料

## 支援語言

Live API 支援 70 種語言，包括：英文、西班牙文、法文、德文、義大利文、葡萄牙文、中文、日文、韓文、印地文、阿拉伯文、俄文等。原生音訊模型會自動偵測並切換語言。
