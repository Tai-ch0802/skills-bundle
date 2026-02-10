# 行動端效能優化

> **影響力：** 關鍵
> **焦點：** 確保 60 FPS 的流暢度、極速啟動以及智慧的資源管理。

---

## 概述

在行動端，效能就是 UI。哪怕是 100 毫秒的延遲，也會破壞「直接操縱感」，讓 App 顯得笨重。

---

## 1. 啟動時間優化 (Startup Performance)

*   **冷啟動 (Cold Start)**: 越快越好（目標 < 2s）。
*   **延遲載入 (Lazy Loading)**: 不要在一開始就載入所有的原生模組與 JS 代碼。
*   **預啟動畫面**: 顯示一個靜態的 Launch Screen，讓使用者覺得 App 已經在運作了。

---

## 2. 列表渲染 (List Performance)

這是行動 App 效能最容易崩潰的地方。

*   **回收機制 (Windowing)**: 只渲染螢幕上可見的項目。
    *   **React Native**: 使用 `FlashList` (Shopify) 或 `FlatList`。
    *   **Flutter**: 使用 `ListView.builder`。
*   **固定高度**: 如果可能，提供 `getItemLayout` 以避免動態測量。
*   **圖片快取與縮放**: 使用 `SDWebImage` (iOS) 或 `Glide` (Android) 等原生快取程式庫。

---

## 3. 動畫與執行緒 (Animations & Threads)

*   **使用原生驅動 (Native Driver)**: 將動畫運算交給原生主執行緒，不要阻塞 JS 橋接。
*   **InteractionManager**: 等待動畫結束後再執行繁重的邏輯（如：API 請求或渲染大組件）。
*   **保持 JS 執行緒通暢**: 長時間的 JS 鎖定會導致手勢點擊無反應。

---

## 4. 記憶體管理 (Memory Management)

*   **垃圾回收 (GC)**: 頻繁的物件建立會導致 GC 頻繁啟動造成卡頓。
*   **清理 Effect**: 確保所有的計時器、事件監聽器與訂閱在頁面銷毀時被清除。
*   **圖片記憶體**: 這是最常見的 OOM (OutOfMemory) 原因。及時釋放不在畫面上的圖片資源。

---

## 5. 電量與熱能 (Battery & Thermal)

*   **背景作業**: 除非必要，否則不要在背景執行 CPU 密集任務。
*   **定位頻率**: 不要持續請求最高精度的 GPS，根據需求調整頻率。
*   **OLED 優化**: 在低電量時使用深色背景。

---

## 6. 網路效能 (Network Performance)

*   **快取策略**: 使用 HTTP Cache 或本地 DB 減少數據傳輸。
*   **預加載 (Pre-fetching)**: 在使用者進入頁面前就開始載入資料。
*   **資料壓縮**: 使用 Protobuf 或精簡的 JSON 格式。

---

## 7. 渲染工具檢測

*   **FPS 監控器**: 在開發階段開啟效能疊加圖層。
*   **火焰圖 (Flame Graph)**: 找出耗時最長的渲染組件。

---

> [!CAUTION]
> **效能陷阱**：絕不要在高端旗艦機（如 iPhone Pro Max 或 Pixel XL）上進行效能驗證。**請在千元等級的低端 Android 手機上測試。** 如果那裡跑得順，那才是真的順。
