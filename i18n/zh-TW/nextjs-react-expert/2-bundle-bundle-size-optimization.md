# 2. 封包體積優化 (Bundle Size Optimization)

> **影響力：** 關鍵 (CRITICAL)
> **焦點：** 減少初始封包體積 (Initial Bundle Size) 可提升「可互動時間 (Time to Interactive)」與「最大內容繪製 (Largest Contentful Paint)」。

---

## 概述

本章節包含 **5 個規則**，專注於封包體積的優化。

---

## 規則 2.1：避免桶文件匯入 (Avoid Barrel File Imports)

**影響力：** 關鍵 (CRITICAL)  
**標籤：** bundle, imports, tree-shaking, barrel-files, performance  

## 避免桶文件匯入

直接從原始文件匯入，而非透過桶文件 (Barrel Files) 以避免載入上千個未使用的模組。**桶文件**是那種重新導出多個模組的進入點（例如 `index.js` 內容為 `export * from './module'`）。

熱門的圖示與組件庫在進入點文件中可能有 **高達 10,000 個重新導出**。對於許多 React 套件，**單純匯入它們就需要 200-800ms**，這會影響開發速度與生產環境的冷啟動 (Cold Starts)。

**為什麼 Tree-shaking 沒效：** 當程式庫被標記為外部 (External)（未被打包）時，打包工具 (Bundler) 無法對其進行優化。如果你為了啟用 Tree-shaking 而打包它，建置過程會因為分析整個模組圖而變得非常緩慢。

**錯誤範例 (匯入整個程式庫)：**

```tsx
import { Check, X, Menu } from 'lucide-react'
// 載入 1,583 個模組，開發環境額外耗時 ~2.8s
// 運行時成本：每次冷啟動耗時 200-800ms

import { Button, TextField } from '@mui/material'
// 載入 2,225 個模組，開發環境額外耗時 ~4.2s
```

**正確範例 (只匯入所需的內容)：**

```tsx
import Check from 'lucide-react/dist/esm/icons/check'
import X from 'lucide-react/dist/esm/icons/x'
import Menu from 'lucide-react/dist/esm/icons/menu'
// 只載入 3 個模組 (~2KB vs ~1MB)

import Button from '@mui/material/Button'
import TextField from '@mui/material/TextField'
// 只載入你使用的內容
```

**替代方案 (Next.js 13.5+)：**

```js
// next.config.js - 使用 optimizePackageImports
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@mui/material']
  }
}

// 接著你可以保持直覺的桶文件匯入：
import { Check, X, Menu } from 'lucide-react'
// 在建置時會自動轉換為直接匯入
```

直接匯入可提供 15-70% 更快的開發啟動、28% 更快的建置、40% 更快的冷啟動，以及顯著更快的 HMR（熱模組替換）。

常見受影響的程式庫：`lucide-react`, `@mui/material`, `@mui/icons-material`, `@tabler/icons-react`, `react-icons`, `@headlessui/react`, `@radix-ui/react-*`, `lodash`, `ramda`, `date-fns`, `rxjs`, `react-use`。

參考資料：[How we optimized package imports in Next.js](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)

---

## 規則 2.2：條件式模組載入 (Conditional Module Loading)

**影響力：** 高 (HIGH)  
**標籤：** bundle, conditional-loading, lazy-loading  

## 條件式模組載入

僅在功能被啟用時才載入大型資料或模組。

**範例 (延遲載入動畫幀)：**

```tsx
function AnimationPlayer({ enabled, setEnabled }: { enabled: boolean; setEnabled: React.Dispatch<React.SetStateAction<boolean>> }) {
  const [frames, setFrames] = useState<Frame[] | null>(null)

  useEffect(() => {
    if (enabled && !frames && typeof window !== 'undefined') {
      import('./animation-frames.js')
        .then(mod => setFrames(mod.frames))
        .catch(() => setEnabled(false))
    }
  }, [enabled, frames, setEnabled])

  if (!frames) return <Skeleton />
  return <Canvas frames={frames} />
}
```

`typeof window !== 'undefined'` 的檢查可防止該模組在 SSR 時被打包，優化伺服器封包體積與建置速度。

---

## 規則 2.3：延遲非關鍵第三方程式庫 (Defer Non-Critical Third-Party Libraries)

**影響力：** 中 (MEDIUM)  
**標籤：** bundle, third-party, analytics, defer  

## 延遲非關鍵第三方程式庫

數據分析、日誌記錄與錯誤追蹤並不會阻塞使用者互動。請在水和 (Hydration) 後載入它們。

**錯誤範例 (阻塞初始封包)：**

```tsx
import { Analytics } from '@vercel/analytics/react'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

**正確範例 (水和後載入)：**

```tsx
import dynamic from 'next/dynamic'

const Analytics = dynamic(
  () => import('@vercel/analytics/react').then(m => m.Analytics),
  { ssr: false }
)

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

---

## 規則 2.4：針重大型組件使用動態匯入 (Dynamic Imports for Heavy Components)

**影響力：** 關鍵 (CRITICAL)  
**標籤：** bundle, dynamic-import, code-splitting, next-dynamic  

## 針重大型組件使用動態匯入

使用 `next/dynamic` 延遲載入那些在初始渲染中不需要的大型組件。

**錯誤範例 (Monaco 與主封包一起打包 ~300KB)：**

```tsx
import { MonacoEditor } from './monaco-editor'

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}
```

**正確範例 (Monaco 依需求載入)：**

```tsx
import dynamic from 'next/dynamic'

const MonacoEditor = dynamic(
  () => import('./monaco-editor').then(m => m.MonacoEditor),
  { ssr: false }
)

function CodePanel({ code }: { code: string }) {
  return <MonacoEditor value={code} />
}
```

---

## 規則 2.5：基於使用者意圖的預載 (Preload Based on User Intent)

**影響力：** 中 (MEDIUM)  
**標籤：** bundle, preload, user-intent, hover  

## 基於使用者意圖的預載

在需要大型封包之前先進行預載，以減少感知延遲。

**範例 (懸停/聚焦時預載)：**

```tsx
function EditorButton({ onClick }: { onClick: () => void }) {
  const preload = () => {
    if (typeof window !== 'undefined') {
      void import('./monaco-editor')
    }
  }

  return (
    <button
      onMouseEnter={preload}
      onFocus={preload}
      onClick={onClick}
    >
      Open Editor
    </button>
  )
}
```

**範例 (當功能標記開啟時預載)：**

```tsx
function FlagsProvider({ children, flags }: Props) {
  useEffect(() => {
    if (flags.editorEnabled && typeof window !== 'undefined') {
      void import('./monaco-editor').then(mod => mod.init())
    }
  }, [flags.editorEnabled])

  return <FlagsContext.Provider value={flags}>
    {children}
  </FlagsContext.Provider>
}
```

`typeof window !== 'undefined'` 的檢查可防止預載模組在 SSR 時被打包，優化伺服器封包體積與建置速度。
