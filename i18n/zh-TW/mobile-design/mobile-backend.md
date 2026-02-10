# 行動端後端模式

> **影響力：** 高
> **焦點：** 針對不穩定網路、節省資源與平台能力優化後端互動。

---

## 概述

行動端後端與 Web 後端不同。行動 App 運作於不穩定的網路環境中，對電量消耗敏感，且具備推播通知 (Push Notifications) 等獨特能力。

---

## 1. 推播通知 (Push Notifications)

推播不僅僅是傳送訊息，它是提升留存率的關鍵。

*   **FCM (Firebase Cloud Messaging)**: 跨平台推播的標準。
*   **APNs (Apple Push Notification service)**: 專屬 iOS 設備。
*   **靜默推播 (Silent Pushes)**: 背景更新資料，使用者無感。
*   **豐富通知 (Rich Notifications)**: 包含圖片、動作按鈕 (Actions) 與自定義 UI。

> [!WARNING]
> **濫用警報**：過多的非關鍵通知會導致使用者關閉通知權限或解除安裝 App。

---

## 2. 離線同步 (Offline Sync)

處理 App 在離線時發生的異動。

*   **悲觀同步 (Pessimistic)**: 網路不通即報錯。
*   **樂觀同步 (Optimistic)**: 先更新本地 UI，背景同步至伺服器。若失敗則進行復原 (Rollback)。
*   **衝突解決**: 
    *   **LWW (Last Write Wins)**: 以最後寫入為準。
    *   **CRDTs**: 無衝突複製資料類型（適用於協作編輯）。
    *   **手動解決**: 提示使用者選擇版本。

---

## 3. API 優化 (Mobile API Optimization)

為行動端打造窄頻寬友善的 API。

*   **BFF (Backend for Frontend)**: 針對行動裝置聚合多個後端服務，減少網路請求次數。
*   **資料減量 (Payload Reduction)**:
    *   僅回傳當前畫面需要的欄位。
    *   使用 JSON 壓縮或 Gzip。
*   **分頁 (Pagination)**:
    *   **Cursor-based**: 避免深分頁效能問題，適合無限捲動。
    *   **Page-based**: 適合跳轉式介面。

---

## 4. 版本控制 (API Versioning)

行動 App 的更新不由開發者控制。

*   **強制更新 (Forced Update)**: 當 API 有重大破壞性變更時，攔截舊版 App 指向更新頁。
*   **多版本並存**: 伺服器需同時支援 `v1`, `v2`, `v3`，直到舊版本使用者低於特定比例。
*   **標頭版本化 (Header Versioning)**: `Accept: application/vnd.myapi.v2+json`。

---

## 5. 身份驗證與安全 (Auth & Security)

*   **JWT 重新整理 (Refresh Token)**: 行動端應使用長效 Refresh Token，避免重複登入。
*   **OAuth 2.0 PKCE**: 行動端登入的最佳實踐。
*   **憑證固定 (SSL Pinning)**: 防止中間人攻擊 (MITM)，確保只相信特定憑證。
*   **App Attest / SafetyNet**: 驗證請求是否真的來自未經修改的原生 App。

---

## 6. 錯誤處理 (Error Handling)

回傳錯誤碼而非僅文字訊息。

*   **可重試錯誤**: 網路超時、伺服器 503。
*   **使用者需操作錯誤**: 密碼錯誤、權限不足。
*   **硬體相關錯誤**: 相機權限、GPS 關閉。

```json
{
  "code": "AUTH_001",
  "message": "Token expired",
  "action": "REFRESH_TOKEN"
}
```

---

## 7. 多媒體處理 (Media Handling)

*   **影像縮時處理**: 由後端提供預先縮放的 Thumbnail (微縮圖)，不要讓行動端下載 10MB 的原圖再進行縮放。
*   **分段上傳 (Chunked Upload)**: 處理大檔案上傳，網路中斷後可續傳。
*   **WebP 格式**: 提供更小的圖片體積。

---

## 8. 監控與分析 (Monitoring)

*   **崩潰報告 (Crash Reporting)**: Sentry, Firebase Crashlytics。
*   **API 延遲追蹤**: 區分網路延遲與伺服器處理延遲。
*   **使用者行為追蹤**: GA4, Mixpanel, Amplitude。

---

> [!TIP]
> **設計金律**：想像你的使用者正在電梯裡，網路每 3 秒中斷一次。在這種極端情況下仍然「好用」的後端設計，才是優秀的行動端後端。
