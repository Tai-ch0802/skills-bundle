# 行動端字體系統

> **影響力：** 高
> **焦點：** 針對行動裝置螢幕、動態類型 (Dynamic Type) 與平台原生字體進行優化。

---

## 概述

在手機上，字體不僅是為了「美感」，更是為了「閱讀效率」。不良的字體設定會讓使用者快速感到眼部疲勞。

---

## 1. 原生字體族群 (Native Families)

除非品牌極度特殊，否則應優先使用平台原生字體，這能保證一致性並減少 bundle size。

*   **iOS**: `SF Pro Display` (標題), `SF Pro Text` (內文)。支援動態字距調整。
*   **Android**: `Roboto`。在 Material 3 中則是 `Google Sans` 或 `Roboto`。

---

## 2. 動態類型 (Dynamic Type / Accessibility)

這是行動端最重要的字體特性。

*   **響應式縮放**: 使用者可以在系統設定中調整字體大小。
*   **iOS (UIFontMetrics)**: 使用與系統掛鉤的樣式（如：`Title 1`, `Body`, `Caption`），App 的字體將隨系統設定縮放。
*   **Android (sp)**: 字體大小應使用 `sp` (scale-independent pixels)，而非 `dp` 或 `px`。

---

## 3. 型態比例與階層 (Typography Scale)

建立清晰的資訊階層。

| 層級 | 推薦大小 | 粗細 | 建議用途 |
| :-- | :-- | :-- | :-- |
| **Headline** | 24 - 34 pt | Bold | 頁面標題 |
| **Subhead** | 20 - 22 pt | Semi-bold | 區域標題 |
| **Body** | 16 - 17 pt | Regular | 主要閱讀內容 |
| **Footnote** | 13 - 14 pt | Regular | 輔助說明 |
| **Caption** | 11 - 12 pt | Regular | 圖表標註 |

---

## 4. 可讀性優化 (Readability)

*   **最小尺寸**: 任何情況下，內文應不小於 **16pt** (17pt 為佳)，任何標註不應小於 **11pt**。
*   **行高 (Line Height)**: 行高應在字體大小的 **1.2 到 1.4 倍** 之間（例如：17/24）。
*   **段落寬度**: 每行約包含 **45 到 75 個字元** (中文約 22-38 字)。
*   **對比度**: 確保文字與背景對比度至少達 4.5:1。

---

## 5. 字體權重與情緒

*   **Bold**: 用於強調，但不宜過多，否則視覺太亂。
*   **Medium/Semi-bold**: 最適合行動端的內容概覽。
*   **Thin/Light**: 在深色模式下閱讀較為吃力，應謹慎使用。

---

## 6. 特殊處理 (Edge Cases)

*   **等寬字體 (Monospace)**: 用於顯示程式碼、訂單編號或金額，對齊效果更好。
*   **全形/半形**: 中文排版需注意標點符號的間距縮減。

---

## 7. 載入效能

*   **Custom Fonts**: 若使用網頁字體，請務必先將 .ttf / .otf 檔案嵌入 App 包中，避免 runtime 載入導致的文字閃動 (Flash of Unstyled Text)。

---

> [!IMPORTANT]
> **排版金律**：絕對不要在 App 裡「寫死 (Hardcode)」字體渲染。如果你不支援系統的字體縮放，對於老年使用者或視障使用者來說，你的 App 就是「壞掉」的。
