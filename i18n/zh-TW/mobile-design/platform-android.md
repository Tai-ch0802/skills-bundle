# Android 平台規範 (Material Design 3)

> **影響力：** 高
> **焦點：** 遵循 Material Design 3 (Material You) 規範，打造具備通用性、表現力與動態性的 Android 體驗。

---

## 概述

Android 的核心哲學是 **Material (材質)**。在 MD3 中，引入了「動態色彩 (Dynamic Color)」與強調個人化的體驗。遵循這些規範能確保你的 App 在各種廠牌的手機上都顯得協調。

---

## 1. 核心哲學：材質 (Material You)

MD3 的三大核心支柱：
*   **舒適 (Comfortable)**: 導覽與佈局需考量大螢幕與單手操作。
*   **表現力 (Expressive)**: 透過字體、色調與自定義造型展現品牌。
*   **動態 (Dynamic)**: 色彩系統會根據使用者的桌布自動演化。

---

## 2. 佈局與網格 (Layout & Grid)

*   **8dp 網格系統**: 所有的間隔、邊距與對齊應採用 8dp 的倍數。
*   **側邊距 (Side Margins)**:
    *   **手機**: 16dp。
    *   **平板**: 24dp。
*   **斷點 (Breakpoints)**: 針對 Compact (手機), Medium (小折疊/平板), Expanded (大平板) 進行佈局適配。

---

## 3. 色彩系統 (Color System)

MD3 引入了基於色調 (Tonal Palettes) 的色彩生成。

*   **動態配色**: 使用 `Monet` 引擎根據壁紙生成色彩主題。
*   **語義角色**: `Primary`, `Secondary`, `Tertiary`, `Error` 及其對應的容器色彩 (Container)。
*   **狀態色彩 (Surface)**: 區分基礎表面、混合表面（陰影效果改由色調混合取代）。

---

## 4. 導覽模式 (Navigation)

*   **導覽列 (Navigation Bar)**: 位於底部，包含 3-5 個目的地。
*   **導覽軌 (Navigation Rail)**: 適用於平板或橫向模式，位於側邊。
*   **導覽抽屜 (Navigation Drawer)**: 適合層級較深或較不常用的功能。
*   **系統返回鍵**: Android 具備硬體（或手勢）返回鍵。確保 App 內部導覽不會與系統手勢衝突。

---

## 5. 核心組件 (Key Components)

*   **頂部應用程式列 (Top App Bar)**: 
    *   *Center-aligned*: 適合主頻。
    *   *Large/Medium*: 適合內容頁，具備捲動後的收縮效果。
*   **浮動動作按鈕 (FAB)**: 螢幕中最顯眼的主操作（例如：新增、傳送）。
*   **卡片 (Cards)**: 提供 Elevated (有影), Outlined (有框), Filled (填色) 三種風格。
*   **對話框 (Dialogs)**: MD3 的對話框不再有邊線，完全靠色塊區隔。

---

## 6. 微互動與動作 (Motion)

MD3 的動作強調「回饋」與「引導」。
*   **強調對象**: 當使用者點選物件時，該物件應像實體物品一樣擴大或移動。
*   **轉換模式 (Transitions)**:
    *   進場：由中心向外展開。
    *   退場：向中心縮小或向下滑動。
*   **波紋回饋 (Ripple Effect)**: 觸碰時的視覺漣漪是 Android 的標誌性回饋。

---

## 7. 輔助功能 (Accessibility)

*   **TalkBack 支援**: 確保所有的圖示皆有 `contentDescription`。
*   **最小觸控尺寸**: 48 x 48 dp。
*   **色彩對比**: 確保文字至少符合 WCAG AA 級（4.5:1）。

---

## 8. Android 13+ 特色

*   **主題圖示 (Themed Icons)**: 支援 Launcher 圖示跟隨主題配色。
*   **每 App 語言設定**: 讓使用者為特定 App 選擇不同於系統的語言。
*   **預測性回退 (Predictive Back)**: 顯示回退後的目標畫面預覽。

---

> [!TIP]
> **開發提示**：在開發 Android 版時，請務必測試 **「深色模式」** 與 **「動態顏色」**。確保你的品牌色在這些自動化的色彩變更後，標籤文字依然清晰可讀。
