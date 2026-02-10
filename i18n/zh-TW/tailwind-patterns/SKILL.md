---
name: tailwind-patterns
description: Tailwind CSS v4 原則。CSS 優先配置、容器查詢、現代模式、設計 token 架構。
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Tailwind CSS 模式（v4 - 2025）

> 使用 CSS 原生配置的現代 utility-first CSS。

---

## 1. Tailwind v4 架構

### 從 v3 的變更

| v3（舊版） | v4（當前）|
|------------|----------|
| `tailwind.config.js` | 基於 CSS 的 `@theme` 指令 |
| PostCSS 外掛 | Oxide 引擎（快 10 倍）|
| JIT 模式 | 原生、始終開啟 |
| 外掛系統 | CSS 原生功能 |
| `@apply` 指令 | 仍可用，不建議 |

### v4 核心概念

| 概念 | 描述 |
|------|------|
| **CSS 優先** | 在 CSS 中配置，而非 JavaScript |
| **Oxide 引擎** | 基於 Rust 的編譯器，更快 |
| **原生巢狀** | 不需要 PostCSS 的 CSS 巢狀 |
| **CSS 變數** | 所有 token 暴露為 `--*` 變數 |

---

## 2. 基於 CSS 的配置

### 主題定義

```
@theme {
  /* 顏色 - 使用語義名稱 */
  --color-primary: oklch(0.7 0.15 250);
  --color-surface: oklch(0.98 0 0);
  --color-surface-dark: oklch(0.15 0 0);

  /* 間距比例 */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 2rem;

  /* 排版 */
  --font-sans: 'Inter', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}
```

### 何時擴展 vs 覆蓋

| 動作 | 適用時機 |
|------|----------|
| **擴展** | 在預設值旁新增新值 |
| **覆蓋** | 完全替換預設比例 |
| **語義 token** | 專案特定命名（primary、surface）|

---

## 3. 容器查詢（v4 原生）

### 斷點 vs 容器

| 類型 | 回應項目 |
|------|----------|
| **斷點** (`md:`) | 視窗寬度 |
| **容器** (`@container`) | 父元素寬度 |

### 容器查詢使用

| 模式 | 類別 |
|------|------|
| 定義容器 | 父元素上 `@container` |
| 容器斷點 | 子元素上 `@sm:`、`@md:`、`@lg:` |
| 命名容器 | `@container/card` 用於特定性 |

### 何時使用

| 情境 | 使用 |
|------|------|
| 頁面級佈局 | 視窗斷點 |
| 元件級響應式 | 容器查詢 |
| 可重用元件 | 容器查詢（情境無關）|

---

## 4. 響應式設計

### 斷點系統

| 前綴 | 最小寬度 | 目標 |
|------|----------|------|
| （無）| 0px | 行動優先基準 |
| `sm:` | 640px | 大手機 / 小平板 |
| `md:` | 768px | 平板 |
| `lg:` | 1024px | 筆電 |
| `xl:` | 1280px | 桌機 |
| `2xl:` | 1536px | 大螢幕桌機 |

### 行動優先原則

1. 先寫行動樣式（無前綴）
2. 用前綴新增大螢幕覆蓋
3. 範例：`w-full md:w-1/2 lg:w-1/3`

---

## 5. 暗色模式

### 配置策略

| 方法 | 行為 | 適用時機 |
|------|------|----------|
| `class` | `.dark` 類別切換 | 手動主題切換器 |
| `media` | 跟隨系統偏好 | 無使用者控制 |
| `selector` | 自訂選擇器（v4）| 複雜主題 |

### 暗色模式模式

| 元素 | 亮色 | 暗色 |
|------|------|------|
| 背景 | `bg-white` | `dark:bg-zinc-900` |
| 文字 | `text-zinc-900` | `dark:text-zinc-100` |
| 邊框 | `border-zinc-200` | `dark:border-zinc-700` |

---

## 6. 現代佈局模式

### Flexbox 模式

| 模式 | 類別 |
|------|------|
| 置中（兩軸）| `flex items-center justify-center` |
| 垂直堆疊 | `flex flex-col gap-4` |
| 水平列 | `flex gap-4` |
| 兩端對齊 | `flex justify-between items-center` |
| 換行網格 | `flex flex-wrap gap-4` |

### Grid 模式

| 模式 | 類別 |
|------|------|
| Auto-fit 響應式 | `grid grid-cols-[repeat(auto-fit,minmax(250px,1fr))]` |
| 非對稱（Bento）| `grid grid-cols-3 grid-rows-2` 搭配 spans |
| 側邊欄佈局 | `grid grid-cols-[auto_1fr]` |

> **注意：** 優先使用非對稱/Bento 佈局而非對稱三欄網格。

---

## 7. 現代色彩系統

### OKLCH vs RGB/HSL

| 格式 | 優勢 |
|------|------|
| **OKLCH** | 感知均勻、更適合設計 |
| **HSL** | 直覺的色相/飽和度 |
| **RGB** | 舊版相容 |

### 色彩 Token 架構

| 層級 | 範例 | 用途 |
|------|------|------|
| **原始** | `--blue-500` | 原始色彩值 |
| **語義** | `--color-primary` | 基於用途的命名 |
| **元件** | `--button-bg` | 元件特定 |

---

## 8. 排版系統

### 字型堆疊模式

| 類型 | 推薦 |
|------|------|
| Sans | `'Inter', 'SF Pro', system-ui, sans-serif` |
| Mono | `'JetBrains Mono', 'Fira Code', monospace` |
| Display | `'Outfit', 'Poppins', sans-serif` |

---

## 9. 動畫與過渡

### 內建動畫

| 類別 | 效果 |
|------|------|
| `animate-spin` | 持續旋轉 |
| `animate-ping` | 注意脈衝 |
| `animate-pulse` | 微妙透明度脈衝 |
| `animate-bounce` | 彈跳效果 |

### 過渡模式

| 模式 | 類別 |
|------|------|
| 所有屬性 | `transition-all duration-200` |
| 特定 | `transition-colors duration-150` |
| 帶緩動 | `ease-out` 或 `ease-in-out` |
| Hover 效果 | `hover:scale-105 transition-transform` |

---

## 10. 元件抽取

### 何時抽取

| 信號 | 動作 |
|------|------|
| 相同類別組合 3+ 次 | 抽取元件 |
| 複雜狀態變體 | 抽取元件 |
| 設計系統元素 | 抽取 + 文件 |

### 抽取方法

| 方法 | 適用時機 |
|------|----------|
| **React/Vue 元件** | 動態、需要 JS |
| **CSS 中的 @apply** | 靜態、不需 JS |
| **設計 token** | 可重用的值 |

---

## 11. 反模式

| 不要 | 要 |
|------|-----|
| 到處用任意值 | 使用設計系統比例 |
| `!important` | 正確修復特定性 |
| 行內 `style=` | 使用 utilities |
| 重複冗長類別清單 | 抽取元件 |
| 混合 v3 配置和 v4 | 完全遷移到 CSS 優先 |
| 大量使用 `@apply` | 優先元件 |

---

## 12. 效能原則

| 原則 | 實作 |
|------|------|
| **清除未使用** | v4 自動 |
| **避免動態** | 不用範本字串類別 |
| **使用 Oxide** | v4 預設、快 10 倍 |
| **快取建構** | CI/CD 快取 |

---

> **記住：** Tailwind v4 是 CSS 優先的。擁抱 CSS 變數、容器查詢和原生功能。配置檔現在是可選的。
