---
name: mobile-design
description: iOS 和 Android 應用的行動優先設計思維與決策。觸控互動、效能模式、平台慣例。教導原則而非固定值。用於建構 React Native、Flutter 或原生行動應用。
allowed-tools: Read, Glob, Grep, Bash
---

# 行動設計系統

> **哲學：** 觸控優先。電池意識。尊重平台。離線能力。
> **核心原則：** 行動不是小桌面。思考行動約束，詢問平台選擇。

---

## 🔧 執行腳本

**執行這些進行驗證（不要閱讀，直接執行）：**

| 腳本 | 用途 | 使用方式 |
|------|------|----------|
| `scripts/mobile_audit.py` | 行動 UX 與觸控稽核 | `python scripts/mobile_audit.py <project_path>` |

---

## 🔴 必要：開始工作前閱讀參考檔案！

### 通用（始終閱讀）

| 檔案 | 內容 | 狀態 |
|------|------|------|
| **[mobile-design-thinking.md](mobile-design-thinking.md)** | **反記憶：強制思考** | **⬜ 最關鍵** |
| **[touch-psychology.md](touch-psychology.md)** | **費茲定律、手勢、觸覺、拇指區** | **⬜ 關鍵** |
| **[mobile-performance.md](mobile-performance.md)** | **RN/Flutter 效能、60fps、記憶體** | **⬜ 關鍵** |
| **[mobile-backend.md](mobile-backend.md)** | **推播通知、離線同步、行動 API** | **⬜ 關鍵** |
| **[mobile-testing.md](mobile-testing.md)** | **測試金字塔、E2E、平台特定** | **⬜ 關鍵** |
| **[mobile-debugging.md](mobile-debugging.md)** | **原生 vs JS 除錯、Flipper、Logcat** | **⬜ 關鍵** |
| [mobile-navigation.md](mobile-navigation.md) | Tab/Stack/Drawer、深連結 | ⬜ 閱讀 |
| [mobile-typography.md](mobile-typography.md) | 系統字型、動態字型、無障礙 | ⬜ 閱讀 |
| [mobile-color-system.md](mobile-color-system.md) | OLED、暗色模式、電池意識 | ⬜ 閱讀 |
| [decision-trees.md](decision-trees.md) | 框架/狀態/儲存選擇 | ⬜ 閱讀 |

### 平台特定

| 平台 | 檔案 | 何時閱讀 |
|------|------|----------|
| **iOS** | [platform-ios.md](platform-ios.md) | 為 iPhone/iPad 建構 |
| **Android** | [platform-android.md](platform-android.md) | 為 Android 建構 |
| **跨平台** | 以上兩者 | React Native / Flutter |

---

## ⚠️ 關鍵：假設前先詢問（必要）

### 未指定時必須詢問：

| 面向 | 詢問 | 原因 |
|------|------|------|
| **平台** | 「iOS、Android 還是兩者？」 | 影響每個設計決策 |
| **框架** | 「React Native、Flutter 還是原生？」 | 決定模式和工具 |
| **導航** | 「Tab bar、抽屜還是堆疊式？」 | 核心 UX 決策 |
| **狀態** | 「什麼狀態管理？」 | 架構基礎 |
| **離線** | 「需要離線工作嗎？」 | 影響資料策略 |

### ⛔ AI 行動反模式

#### 效能罪過

| ❌ 絕不 | 為什麼錯 | ✅ 始終 |
|---------|----------|---------|
| **ScrollView 用於長列表** | 渲染所有項目，記憶體爆炸 | 使用 `FlatList` / `FlashList` |
| **行內 renderItem 函式** | 每次渲染都新函式 | `useCallback` + `React.memo` |
| **缺少 keyExtractor** | 索引鍵在重排序時有 bug | 資料中的唯一穩定 ID |
| **生產環境 console.log** | 嚴重阻塞 JS 執行緒 | 發布前移除 |

#### 觸控/UX 罪過

| ❌ 絕不 | 為什麼錯 | ✅ 始終 |
|---------|----------|---------|
| **觸控目標 < 44px** | 無法準確點擊 | 最小 44pt(iOS)/48dp(Android) |
| **無載入狀態** | 使用者以為應用當掉 | 始終顯示載入回饋 |
| **無錯誤狀態** | 使用者卡住 | 帶重試的錯誤顯示 |
| **忽略平台慣例** | 使用者困惑 | iOS 感覺像 iOS |

#### 安全罪過

| ❌ 絕不 | 為什麼錯 | ✅ 始終 |
|---------|----------|---------|
| **Token 存在 AsyncStorage** | 在 root 裝置容易存取 | `SecureStore` / `Keychain` |
| **寫死 API 金鑰** | 從 APK/IPA 反向工程 | 環境變數、安全儲存 |

---

## 📱 平台決策矩陣

### 快速參考：平台預設

| 元素 | iOS | Android |
|------|-----|---------|
| **主要字型** | SF Pro | Roboto |
| **最小觸控目標** | 44pt × 44pt | 48dp × 48dp |
| **返回導航** | 邊緣左滑 | 系統返回按鈕/手勢 |
| **底部 Tab 圖示** | SF Symbols | Material Symbols |

---

## 🧠 行動 UX 心理（快速參考）

### 觸控的費茲定律

```
桌面：游標精確（1px）
行動：手指不精確（~7mm 接觸面積）

→ 觸控目標必須至少 44-48px
→ 重要動作放在拇指區（螢幕底部）
→ 破壞性動作遠離容易觸及之處
```

### 拇指區（單手使用）

```
┌─────────────────────────────┐
│      難以觸及                │ ← 導航、選單、返回
│       （伸展）              │
├─────────────────────────────┤
│      尚可觸及                │ ← 次要動作
│      （自然）               │
├─────────────────────────────┤
│      容易觸及                │ ← 主要 CTA、tab bar
│   （拇指自然弧線）          │ ← 主要內容互動
└─────────────────────────────┘
        [  HOME  ]
```

---

## 🔧 框架決策樹

```
你要建構什麼？
        │
        ├── 需要 OTA 更新 + 快速迭代 + Web 團隊
        │   └── ✅ React Native + Expo
        │
        ├── 需要像素完美自訂 UI + 效能關鍵
        │   └── ✅ Flutter
        │
        ├── 深度原生功能 + 單一平台焦點
        │   ├── 僅 iOS → SwiftUI
        │   └── 僅 Android → Kotlin + Jetpack Compose
        │
        └── 企業 + 現有 Flutter 程式碼庫
            └── ✅ Flutter
```

---

## 📋 開發前檢查清單

### 開始任何行動專案前

- [ ] **平台已確認？**（iOS / Android / 兩者）
- [ ] **框架已選擇？**（RN / Flutter / 原生）
- [ ] **導航模式已決定？**（Tabs / Stack / Drawer）
- [ ] **狀態管理已選擇？**
- [ ] **離線需求已知？**
- [ ] **深連結從第一天就規劃？**

### 每個畫面前

- [ ] **觸控目標 ≥ 44-48px？**
- [ ] **主要 CTA 在拇指區？**
- [ ] **載入狀態存在？**
- [ ] **帶重試的錯誤狀態存在？**

---

> **記住：** 行動使用者沒有耐心、會被打斷、且在小螢幕上用不精確的手指。為最差條件設計：差網路、單手、大太陽、低電量。如果在那裡能運作，到處都能運作。
