# 6. 渲染效能 (Rendering Performance)

> **影響力：** 中 (MEDIUM)
> **焦點：** 優化渲染過程可減少瀏覽器需要執行的工作量。

---

## 概述

本章節包含 **9 個規則**，專注於渲染效能。

---

## 規則 6.1：動畫化 SVG 包裝層而非 SVG 元素本身 (Animate SVG Wrapper Instead of SVG Element)

**影響力：** 低 (LOW)  
**標籤：** rendering, svg, css, animation, performance  

## 動畫化 SVG 包裝層而非 SVG 元素本身

許多瀏覽器對於 SVG 元素上的 CSS3 動畫並不具備硬體加速。請將 SVG 包裝在一個 `<div>` 中，並改為動畫化該包裝層。

**錯誤範例 (直接動畫化 SVG - 無硬體加速)：**

```tsx
function LoadingSpinner() {
  return (
    <svg 
      className="animate-spin"
      width="24" 
      height="24" 
      viewBox="0 0 24 24"
    >
      <circle cx="12" cy="12" r="10" stroke="currentColor" />
    </svg>
  )
}
```

**正確範例 (動畫化包裝層 div - 具備硬體加速)：**

```tsx
function LoadingSpinner() {
  return (
    <div className="animate-spin">
      <svg 
        width="24" 
        height="24" 
        viewBox="0 0 24 24"
      >
        <circle cx="12" cy="12" r="10" stroke="currentColor" />
      </svg>
    </div>
  )
}
```

這適用於所有 CSS 變換與轉場 (`transform`, `opacity`, `translate`, `scale`, `rotate`)。包裝層 div 允許瀏覽器使用 GPU 加速以獲得更平滑的動畫。

---

## 規則 6.2：為長列表使用 CSS content-visibility (CSS content-visibility for Long Lists)

**影響力：** 高 (HIGH)  
**標籤：** rendering, css, content-visibility, long-lists  

## 為長列表使用 CSS content-visibility

應用 `content-visibility: auto` 以延遲螢幕外內容的渲染。

**CSS：**

```css
.message-item {
  content-visibility: auto;
  contain-intrinsic-size: 0 80px;
}
```

**範例：**

```tsx
function MessageList({ messages }: { messages: Message[] }) {
  return (
    <div className="overflow-y-auto h-screen">
      {messages.map(msg => (
        <div key={msg.id} className="message-item">
          <Avatar user={msg.author} />
          <div>{msg.content}</div>
        </div>
      ))}
    </div>
  )
}
```

對於 1000 條訊息，瀏覽器會跳過約 990 個螢幕外項目的佈局/繪製（初始渲染速度提昇 10 倍）。

---

## 規則 6.3：提升靜態 JSX 元素 (Hoist Static JSX Elements)

**影響力：** 低 (LOW)  
**標籤：** rendering, jsx, static, optimization  

## 提升靜態 JSX 元素

將靜態 JSX 提取到組件外部以避免重複創建。

**錯誤範例 (每次渲染都重新創建元素)：**

```tsx
function LoadingSkeleton() {
  return <div className="animate-pulse h-20 bg-gray-200" />
}

function Container() {
  return (
    <div>
      {loading && <LoadingSkeleton />}
    </div>
  )
}
```

**正確範例 (重用同一個元素)：**

```tsx
const loadingSkeleton = (
  <div className="animate-pulse h-20 bg-gray-200" />
)

function Container() {
  return (
    <div>
      {loading && loadingSkeleton}
    </div>
  )
}
```

這對於大型且靜態的 SVG 節點特別有幫助，因為它們在每次渲染時重新創建的開銷可能很高。

**注意：** 如果你的項目啟用了 [React Compiler](https://react.dev/learn/react-compiler)，編譯器會自動提升靜態 JSX 元素並優化組件重複渲染，因此手動提升是不必要的。

---

## 規則 6.4：優化 SVG 精度 (Optimize SVG Precision)

**影響力：** 低 (LOW)  
**標籤：** rendering, svg, optimization, svgo  

## 優化 SVG 精度

減少 SVG 座標精度以減少檔案大小。最佳精度取決於 viewBox 大小，但總體而言，應考慮減少精度。

**錯誤範例 (過度精確)：**

```svg
<path d="M 10.293847 20.847362 L 30.938472 40.192837" />
```

**正確範例 (1 位小數)：**

```svg
<path d="M 10.3 20.8 L 30.9 40.2" />
```

**使用 SVGO 自動化：**

```bash
npx svgo --precision=1 --multipass icon.svg
```

---

## 規則 6.5：在不閃爍的情況下防止水和不匹配 (Prevent Hydration Mismatch Without Flickering)

**影響力：** 中 (MEDIUM)  
**標籤：** rendering, ssr, hydration, localStorage, flicker  

## 在不閃爍的情況下防止水和不匹配

當渲染依賴於客戶端存儲（localStorage, cookies）的內容時，請注入同步腳本，在 React 水和 (Hydrate) 之前更新 DOM，以避免 SSR 損毀以及水和後的閃爍。

**錯誤範例 (損毀 SSR)：**

```tsx
function ThemeWrapper({ children }: { children: ReactNode }) {
  // localStorage 在伺服器端不可用 - 會拋出錯誤
  const theme = localStorage.getItem('theme') || 'light'
  
  return (
    <div className={theme}>
      {children}
    </div>
  )
}
```

由於 `localStorage` 是 undefined，伺服器端渲染將會失敗。

**錯誤範例 (視覺閃爍)：**

```tsx
function ThemeWrapper({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState('light')
  
  useEffect(() => {
    // 在水和後運行 - 會導致可見的閃爍
    const stored = localStorage.getItem('theme')
    if (stored) {
      setTheme(stored)
    }
  }, [])
  
  return (
    <div className={theme}>
      {children}
    </div>
  )
}
```

組件先以預設值 (`light`) 渲染，水和後再更新，造成不正確內容可見的閃爍。

**正確範例 (無閃爍、無水和不匹配)：**

```tsx
function ThemeWrapper({ children }: { children: ReactNode }) {
  return (
    <>
      <div id="theme-wrapper">
        {children}
      </div>
      <script
        dangerouslySetInnerHTML={{
          __html: `
            (function() {
              try {
                var theme = localStorage.getItem('theme') || 'light';
                var el = document.getElementById('theme-wrapper');
                if (el) el.className = theme;
              } catch (e) {}
            })();
          `,
        }}
      />
    </>
  )
}
```

內連腳本會在顯示元素之前同步執行，確保 DOM 已經具備正確的值。無閃爍，且無水和不匹配。

此模式對於主題切換 (Theme Toggles)、使用者偏好、驗證狀態以及任何應立即渲染而不閃爍預設值的客戶端專用資料特別有用。

---

## 規則 6.6：抑制預期內的水和不匹配 (Suppress Expected Hydration Mismatches)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** rendering, hydration, ssr, nextjs  

## 抑制預期內的水和不匹配

在 SSR 框架中，某些值在伺服器端與客戶端刻意有所不同（隨機 ID、日期、語系/時區格式化）。對於這些「預期內」的不匹配，請將動態文字包裝在帶有 `suppressHydrationWarning` 的元素中，以防止產生嘈雜的警告。不要用它來隱藏真實的 Bug，也不要過度使用。

**錯誤範例 (已知的匹配警告)：**

```tsx
function Timestamp() {
  return <span>{new Date().toLocaleString()}</span>
}
```

**正確範例 (僅抑制預期的不匹配)：**

```tsx
function Timestamp() {
  return (
    <span suppressHydrationWarning>
      {new Date().toLocaleString()}
    </span>
  )
}
```

---

## 規則 6.7：為顯示/隱藏使用 Activity 組件 (Use Activity Component for Show/Hide)

**影響力：** 中 (MEDIUM)  
**標籤：** rendering, activity, visibility, state-preservation  

## 為顯示/隱藏使用 Activity 組件

使用 React 的 `<Activity>` 來為頻繁切換顯示狀態的昂貴組件保留狀態/DOM。

**用法：**

```tsx
import { Activity } from 'react'

function Dropdown({ isOpen }: Props) {
  return (
    <Activity mode={isOpen ? 'visible' : 'hidden'}>
      <ExpensiveMenu />
    </Activity>
  )
}
```

避免了昂貴的重複渲染與狀態遺失。

---

## 規則 6.8：使用明確的條件渲染 (Use Explicit Conditional Rendering)

**影響力：** 低 (LOW)  
**標籤：** rendering, conditional, jsx, falsy-values  

## 使用明確的條件渲染

當條件可能是 `0`、`NaN` 或其他會導致渲染的假值 (Falsy values) 時，請使用明確的三元運算子 (`? :`) 而非 `&&`。

**錯誤範例 (在 count 為 0 時渲染出 "0")：**

```tsx
function Badge({ count }: { count: number }) {
  return (
    <div>
      {count && <span className="badge">{count}</span>}
    </div>
  )
}

// 當 count = 0, 渲染結果：<div>0</div>
// 當 count = 5, 渲染結果：<div><span class="badge">5</span></div>
```

**正確範例 (在 count 為 0 時完全不渲染內容)：**

```tsx
function Badge({ count }: { count: number }) {
  return (
    <div>
      {count > 0 ? <span className="badge">{count}</span> : null}
    </div>
  )
}

// 當 count = 0, 渲染結果：<div></div>
// 當 count = 5, 渲染結果：<div><span class="badge">5</span></div>
```

---

## 規則 6.9：優先使用 useTransition 而非手動載入狀態 (Use useTransition Over Manual Loading States)

**影響力：** 低 (LOW)  
**標籤：** rendering, transitions, useTransition, loading, state  

## 優先使用 useTransition 而非手動載入狀態

使用 `useTransition` 而非手動的 `useState` 來處理載入狀態。這提供了內建的 `isPending` 狀態，並能自動管理 Transition。

**錯誤範例 (手動載入狀態)：**

```tsx
function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isLoading, setIsLoading] = useState(false)

  const handleSearch = async (value: string) => {
    setIsLoading(true)
    setQuery(value)
    const data = await fetchResults(value)
    setResults(data)
    setIsLoading(false)
  }

  return (
    <>
      <input onChange={(e) => handleSearch(e.target.value)} />
      {isLoading && <Spinner />}
      <ResultsList results={results} />
    </>
  )
}
```

**正確範例 (使用具備內建 pending 狀態的 useTransition)：**

```tsx
import { useTransition, useState } from 'react'

function SearchResults() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState([])
  const [isPending, startTransition] = useTransition()

  const handleSearch = (value: string) => {
    setQuery(value) // 立即更新輸入欄位
    
    startTransition(async () => {
      // 抓取並更新結果
      const data = await fetchResults(value)
      setResults(data)
    })
  }

  return (
    <>
      <input onChange={(e) => handleSearch(e.target.value)} />
      {isPending && <Spinner />}
      <ResultsList results={results} />
    </>
  )
}
```

**效益：**

- **自動 Pending 狀態**：無需手動管理 `setIsLoading(true/false)`。
- **錯誤韌性**：即時 Transition 拋出錯誤，Pending 狀態也能正確重設。
- **更好的回應性**：在更新期間保持 UI 的回應力。
- **中斷處理**：新的 Transition 會自動取消之前的 Pending Transition。

參考資料：[useTransition](https://react.dev/reference/react/useTransition)
