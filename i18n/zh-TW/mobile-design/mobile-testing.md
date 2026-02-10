# 行動端測試策略

> **影響力：** 高
> **焦點：** 透過金子塔測試模型，確保在不同 OS 版本、螢幕比例與網路環境下的穩定性。

---

## 概述

行動端測試不僅僅是檢查邏輯。你必須檢查 UI 在 4 吋與 6.7 吋螢幕上的表現，並測試在進入電梯（網路中斷）時會發生什麼。

---

## 1. 測試金字塔 (Testing Pyramid)

1.  **單元測試 (Unit Tests)**: 商業邏輯、工具函數、API 轉換。
    *   *Tool*: Jest。
2.  **組件測試 (Component / Integration Tests)**: 測試組件在不同 Props 下的互動。
    *   *Tool*: React Native Testing Library (RNTL) / Flutter Widget Testing。
3.  **端到端測試 (E2E Tests)**: 在真實模擬器或實機上跑完整流程。
    *   *Tool*: Detox (iOS/Android), Maestro (跨平台)。

---

## 2. 硬體與環境測試 (Hardware & Environment)

*   **螢幕尺寸**: 測試超長比例與超短比例。檢查內容是否會被底部按鈕蓋住。
*   **語言與時區**: 測試 Traditional Chinese、English 與阿拉伯語（RTL 佈局）。
*   **字體縮放 (Accessibility)**: 當使用者將手機字體調到最大時，佈局是否崩潰？

---

## 3. 網路模擬測試 (Network Edge Cases)

*   **Offline Mode**: 關閉 Wi-Fi/Data，確認 App 有正確的 Loading/Retry 邏輯。
*   **Flaky Network**: 模擬 2% 的資料包遺失，確認 App 不會死當。
*   **Low Latency**: 模擬極慢的請求，確保 UI 依然可操作。

---

## 4. 平台特有測試

*   **Permissions**: 測試使用者「拒絕」權限（如：相機、GPS）後的降級處理。
*   **Push Notifications**: 驗證點擊通知是否能正確導覽至特定內容。
*   **Deep Links**: 驗證外部網址開啟 App 的正確性。

---

## 5. 打包與發佈測試

*   **Release Build**: 必在 Release 模式下測試，因為 JS 引擎（Hermes）與原生優化在 Release 下的表現不同。
*   **升級測試**: 安裝舊版 App，升級到新版，確保本地資料庫 (SQLite/MMKV) 不會損毀。

---

## 6. 工具推薦

| 類型 | 推薦工具 |
| :-- | :-- |
| **視覺回歸** | Applitools / Percy |
| **E2E 自動化** | **Maestro** (極度推薦，簡單且強大) |
| **崩潰監控** | Sentry / Firebase Crashlytics |
| **遠端設備雲** | BrowserStack / Sauce Labs |

---

> [!TIP]
> **測試原則**：不要試圖 100% 覆蓋 E2E 測試，它們很慢且容易失效。應將 80% 的心力放在快速的「單元測試」與「組件隔離測試」，剩下的核心流程（如：登入、下單）由 E2E 守護。
