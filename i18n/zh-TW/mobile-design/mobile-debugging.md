# 行動端除錯策略

> **影響力：** 高
> **焦點：** 超越單純的 `console.log`，深入原生層與網路模擬來解決行動端特有的問題。

---

## 概述

行動端除錯比 Web 複雜得多。你不能只是打開 Inspect 元素；你需要處理原生崩潰、快取不一致、執行緒競爭以及各種零碎的硬體差異。

---

## 1. 放棄 console.log，擁抱原生工具 (Stop console.log)

單純的 log 會淹沒在系統訊息中。

*   **React Native**: 使用 **Flipper**。它能檢查 Network、Database、Layout 與 Redux 狀態。
*   **Android**: 使用 **Logcat** (Android Studio)。查看系統級別的崩潰報告。
*   **iOS**: 使用 **Xcode Console**。偵測記憶體洩漏與渲染瓶頸。

---

## 2. 網路狀況模擬 (Network Simulation)

在開發辦公室的超快 Wi-Fi 中，App 永遠都很流暢。

*   **實機除錯**: 使用 **Charles Proxy** 或 **Proxyman**。
*   **模擬限制**: 在模擬器中設定「3G/Edge」開發。
*   **斷網測試**: 確保 App 在完全沒有網路時不會無限載入或閃退。

---

## 3. 視圖層級除錯 (Layout Debugging)

*   **Overdraw (過度繪製)**: iOS 的 "Color Blended Layers" 與 Android 的 "Show overdraw"。如果一個區域被畫了三次（背景、卡片、背景色），會導致掉幀。
*   **Inspector**: 使用 React Native Debugger 或 Flutter Inspector 檢查組件的 padding/margin。

---

## 4. 特異性問題定位

| 現象 | 檢查方向 |
| :-- | :-- |
| **只在 iOS 發生** | 安全區域 (Safe Area)、原生權限 (Permissions)、Safari 渲染 Bug |
| **只在 Android 發生** | 軟體鍵盤模式、硬體返回鍵處理、多樣化螢幕比例 |
| **Release 版閃退** | 代碼混淆 (ProGuard/R8)、未包含的原生資產、JS 引擎差異 (Hermes/JSC) |

---

## 5. 效能剖析 (Profiling)

*   **Frames Per Second (FPS)**: 確保維持在 60 FPS (或 120 FPS)。
*   **JS Thread vs UI Thread**: 找出是邏輯太重還是 UI 渲染太重。
*   **Interaction Manager**: 監測互動期間的阻塞情況。

---

> [!IMPORTANT]
> **除錯金律**：絕不要在模擬器上驗證效能。模擬器使用電腦的處理器，無法反映真實手機的發熱、電量管理與記憶體限制。**永遠在實機上測試。**
