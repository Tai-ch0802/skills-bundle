---
name: react-best-practices
description: 來自 Vercel Engineering 的 React 和 Next.js 效能最佳化。用於建構 React 元件、最佳化效能、消除瀑布流、減少打包大小、審查效能問題或實作伺服器/客戶端最佳化。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Next.js & React 效能專家

> **來自 Vercel Engineering** — 57 條按影響優先排序的最佳化規則
> **哲學：** 先消除瀑布流，再最佳化打包，然後微觀最佳化。

---

## 🎯 選擇性閱讀規則（必要）

**僅閱讀與你任務相關的章節！** 查看下方內容地圖並載入你需要的。

> 🔴 **效能審查：從關鍵章節（1-2）開始，再到高/中。**

---

## 📑 內容地圖

| 檔案 | 影響 | 規則 | 何時閱讀 |
|------|------|------|----------|
| `1-async-eliminating-waterfalls.md` | 🔴 **關鍵** | 5 條 | 頁面載入慢、序列 API 呼叫、資料抓取瀑布流 |
| `2-bundle-bundle-size-optimization.md` | 🔴 **關鍵** | 5 條 | 打包大小過大、TTI 慢、首次載入問題 |
| `3-server-server-side-performance.md` | 🟠 **高** | 7 條 | SSR 慢、API 路由最佳化、伺服器端瀑布流 |
| `4-client-client-side-data-fetching.md` | 🟡 **中高** | 4 條 | 客戶端資料管理、SWR 模式、去重 |
| `5-rerender-re-render-optimization.md` | 🟡 **中** | 12 條 | 過多重新渲染、React 效能、記憶化 |
| `6-rendering-rendering-performance.md` | 🟡 **中** | 9 條 | 渲染瓶頸、虛擬化、圖片最佳化 |
| `7-js-javascript-performance.md` | ⚪ **低中** | 12 條 | 微觀最佳化、快取、迴圈效能 |
| `8-advanced-advanced-patterns.md` | 🔵 **不定** | 3 條 | 進階 React 模式、useLatest、init-once |

**總計：8 類別共 57 條規則**

---

## 🚀 快速決策樹

**你的效能問題是什麼？**

```
🐌 頁面載入慢 / TTI 長
  → 閱讀第 1 節：消除瀑布流
  → 閱讀第 2 節：打包大小最佳化

📦 打包大小過大（>200KB）
  → 閱讀第 2 節：打包大小最佳化
  → 檢查：動態引入、barrel imports、tree-shaking

🖥️ 伺服器端渲染慢
  → 閱讀第 3 節：伺服器端效能
  → 檢查：平行資料抓取、串流

🔄 太多重新渲染 / UI 卡頓
  → 閱讀第 5 節：重新渲染最佳化
  → 檢查：React.memo、useMemo、useCallback

🎨 渲染效能問題
  → 閱讀第 6 節：渲染效能
  → 檢查：虛擬化、layout thrashing

🌐 客戶端資料抓取問題
  → 閱讀第 4 節：客戶端資料抓取
  → 檢查：SWR 去重、localStorage
```

---

## 📊 影響優先指南

**全面最佳化時使用此順序：**

```
1️⃣ 關鍵（最大收益 — 先做）：
   ├─ 第 1 節：消除瀑布流
   │  └─ 每個瀑布流增加完整網路延遲（100-500ms+）
   └─ 第 2 節：打包大小最佳化
      └─ 影響 TTI 和 LCP

2️⃣ 高（顯著影響 — 其次）：
   └─ 第 3 節：伺服器端效能

3️⃣ 中（適度收益 — 第三）：
   ├─ 第 4 節：客戶端資料抓取
   ├─ 第 5 節：重新渲染最佳化
   └─ 第 6 節：渲染效能

4️⃣ 低（打磨 — 最後）：
   ├─ 第 7 節：JavaScript 效能
   └─ 第 8 節：進階模式
```

---

## ✅ 效能審查檢查清單

上線前：

**關鍵（必修）：**

- [ ] 無序列資料抓取（瀑布流已消除）
- [ ] 主包大小 < 200KB
- [ ] 應用程式碼中無 barrel imports
- [ ] 大型元件使用動態引入
- [ ] 盡可能平行資料抓取

**高優先：**

- [ ] 適當使用伺服器元件
- [ ] API 路由已最佳化（無 N+1 查詢）
- [ ] 使用 Suspense 邊界進行資料抓取
- [ ] 盡可能使用靜態生成

**中優先：**

- [ ] 昂貴計算已記憶化
- [ ] 列表渲染已虛擬化（如 >100 項）
- [ ] 圖片使用 next/image 最佳化
- [ ] 無不必要的重新渲染

---

## ❌ 反模式（常見錯誤）

**不要：**

- ❌ 對獨立操作使用序列 `await`
- ❌ 只需一個函式卻引入整個函式庫
- ❌ 在應用程式碼中使用 barrel exports（`index.ts` 重新匯出）
- ❌ 跳過大型元件/函式庫的動態引入
- ❌ 在 useEffect 中抓取資料不做去重

**要：**

- ✅ 使用 `Promise.all()` 平行抓取資料
- ✅ 使用動態引入：`const Comp = dynamic(() => import('./Heavy'))`
- ✅ 直接引入：`import { specific } from 'library/specific'`
- ✅ 使用 Suspense 邊界改善 UX
- ✅ 利用 React Server Components
- ✅ 最佳化前先測量效能

---

## 🎓 最佳實踐摘要

**黃金法則：**

1. **先測量** — 使用 React DevTools Profiler、Chrome DevTools
2. **最大影響優先** — 瀑布流 → 打包 → 伺服器 → 微觀
3. **不要過度最佳化** — 聚焦真正的瓶頸
4. **使用平台功能** — Next.js 有內建最佳化
5. **為使用者著想** — 真實世界條件很重要

---

**來源：** Vercel Engineering
**版本：** 1.0.0
**總規則數：** 8 類別共 57 條
