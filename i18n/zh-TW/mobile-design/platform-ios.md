# iOS 平台規範 (Human Interface Guidelines)

> **影響力：** 高
> **焦點：** 遵循 Apple 人機介面指南 (HIG)，打造直覺、精緻且具備高度流暢感的 iOS 體驗。

---

## 概述

iOS 的設計核心是 **清晰 (Clarity)**、**順從 (Deference)** 與 **深度 (Depth)**。App 應該尊重使用者的操作習慣，內容高於裝飾，並利用層級感引導使用者。

---

## 1. 核心設計原則

*   **清晰**: 文字在各種尺寸下都應易讀，圖示易於理解，佈局簡明。
*   **順從**: 介面不應干擾內容。使用半透明效果與輕盈的邊框。
*   **深度**: 透過視覺層次、陰影與過場動畫，在 2D 螢幕上傳達空間感。

---

## 2. 佈局與安全區域 (Layout & Safe Area)

*   **安全區域 (Safe Area)**: 避開瀏海 (Notch)、動態島 (Dynamic Island) 與底部 Home Indicator（橫條）。
*   **導覽列 (Navigation Bar)**: 預設高度為 44pt，標題通常居中。iOS 11+ 引入了「大標題 (Large Title)」模式。
*   **標準間距**: 通常使用 16pt 或 20pt 的邊距。

---

## 3. 字體與色彩 (Typography & Color)

*   **字體**: 系統預設字體為 **SF Pro**。對於 Traditional Chinese，系統會自動使用 **PingFang TC** (蘋方-繁)。
*   **語義化色彩 (System Colors)**: 使用 `SystemBlue`, `SystemRed` 等，它們會自動適應深淺色模式。
*   **動態文字 (Dynamic Type)**: App 必須支援根據系統設定縮放字體大小。

---

## 4. 導覽與手勢 (Navigation & Gestures)

*   **標籤列 (Tab Bar)**: 位於底部，通常有 3-5 個圖示。切換時頁面不應閃動。
*   **堆疊導覽**: 進入子頁面時，標題導覽列應具備流暢的「推入」感。
*   **邊緣向右滑動 (Edge Swipe)**: 使用者期望在任何子頁面中，從左邊緣滑動即可返回上一頁。這在 iOS 是強制性的感官體驗。
*   **下拉式選單與上下文選單 (Context Menus)**: 長按物件顯示操作選單（取代舊有的 3D Touch）。

---

## 5. 控制元件與組件 (UI Components)

*   **按鈕 (Buttons)**: 樣式應明確且具備點選回饋。
*   **開關 (Switches)**: 用於啟用/停用設定（預設為綠色）。
*   **分段控制項 (Segmented Controls)**: 用於切換同一視圖內的內容。
*   **工作表 (Action Sheets)** 與 **警告框 (Alerts)**: 用於確認或警告使用者。

---

## 6. SF Symbols

*   **圖示庫**: 優先選用 SF Symbols 中的 5000+ 圖示。它們與 SF Pro 字體完美對齊，支援多種權重。

---

## 7. 感官體驗 (Sensory Experience)

*   **觸覺回饋 (Haptics)**: 利用 **Taptic Engine** 提供觸角回饋。例如：成功時的雙擊感，警告時的長震動。
*   **視覺震盪 (Friction)**: 當滑動到清單底部時，應有「回彈 (Bounce)」效果。

---

## 8. 輔助功能 (Accessibility, A11y)

*   **VoiceOver**: 確保每個介面元素都有正確的標籤與提示。
*   **最小點擊區域**: 44 x 44 pt。
*   **降低動態**: 尊重使用者「減少動態效果」的系統設定。

---

> [!TIP]
> **開發提示**：iOS 使用者對細節極度挑剔。請確保你的 **「滑動返回」** 動畫不卡頓，且 **「啟動畫面」** 與 App 第一幀能完美銜接。
