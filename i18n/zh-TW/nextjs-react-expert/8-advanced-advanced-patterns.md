# 8. 進階模式 (Advanced Patterns)

> **影響力：** 變動性 (VARIABLE)
> **焦點：** 用於特定情況的進階模式，需要謹慎實作。

---

## 概述

本章節包含 **3 個規則**，專注於進階模式。

---

## 規則 8.1：僅初始化 App 一次，而非每次掛載皆初始化 (Initialize App Once, Not Per Mount)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** initialization, useEffect, app-startup, side-effects  

## 僅初始化 App 一次，而非每次掛載皆初始化

不要將那些「每載入一次 App 僅需運行一次」的全域初始化邏輯放進組件的 `useEffect([])` 中。組件可能會重新掛載，導致 Effect 重複執行。請改用模組級別的守衛 (Guard) 或在進入點模組執行頂層初始化。

**錯誤範例 (在開發環境中運行兩次，且掛載時會重跑)：**

```tsx
function Comp() {
  useEffect(() => {
    loadFromStorage()
    checkAuthToken()
  }, [])

  // ...
}
```

**正確範例 (每次 App 載入僅執行一次)：**

```tsx
let didInit = false

function Comp() {
  useEffect(() => {
    if (didInit) return
    didInit = true
    loadFromStorage()
    checkAuthToken()
  }, [])

  // ...
}
```

參考資料：[Initializing the application](https://react.dev/learn/you-might-not-need-an-effect#initializing-the-application)

---

## 規則 8.2：將事件處理程序存儲在 Ref 中 (Store Event Handlers in Refs)

**影響力：** 低 (LOW)  
**標籤：** advanced, hooks, refs, event-handlers, optimization  

## 將事件處理程序存儲在 Ref 中

當事件處理程序被用在「不應因為回呼更動而重新訂閱」的 Effect 中時，請將回呼存儲在 Ref 中。

**錯誤範例 (每次渲染都會重新訂閱)：**

```tsx
function useWindowEvent(event: string, handler: (e) => void) {
  useEffect(() => {
    window.addEventListener(event, handler)
    return () => window.removeEventListener(event, handler)
  }, [event, handler])
}
```

**正確範例 (穩定的訂閱)：**

```tsx
function useWindowEvent(event: string, handler: (e) => void) {
  const handlerRef = useRef(handler)
  useEffect(() => {
    handlerRef.current = handler
  }, [handler])

  useEffect(() => {
    const listener = (e) => handlerRef.current(e)
    window.addEventListener(event, listener)
    return () => window.removeEventListener(event, listener)
  }, [event])
}
```

**替代方案：如果你使用的是最新版的 React，請使用 `useEffectEvent`：**

```tsx
import { useEffectEvent } from 'react'

function useWindowEvent(event: string, handler: (e) => void) {
  const onEvent = useEffectEvent(handler)

  useEffect(() => {
    window.addEventListener(event, onEvent)
    return () => window.removeEventListener(event, onEvent)
  }, [event])
}
```

`useEffectEvent` 為此模式提供了更簡潔的 API：它創造一個穩定的函式引用，且該引用始終會調用最新版本的處理程序。

---

## 規則 8.3：為穩定的回呼引用使用 useEffectEvent (useEffectEvent for Stable Callback Refs)

**影響力：** 低 (LOW)  
**標籤：** advanced, hooks, useEffectEvent, refs, optimization  

## 為穩定的回呼引用使用 useEffectEvent

在回呼中存取最新值，而無需將其加入依賴項陣列。這能防止 Effect 重複執行，同時又避免了過時閉包。

**錯誤範例 (每次回呼更動都會導致 Effect 重跑)：**

```tsx
function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')

  useEffect(() => {
    const timeout = setTimeout(() => onSearch(query), 300)
    return () => clearTimeout(timeout)
  }, [query, onSearch])
}
```

**正確範例 (使用 React 的 useEffectEvent)：**

```tsx
import { useEffectEvent } from 'react';

function SearchInput({ onSearch }: { onSearch: (q: string) => void }) {
  const [query, setQuery] = useState('')
  const onSearchEvent = useEffectEvent(onSearch)

  useEffect(() => {
    const timeout = setTimeout(() => onSearchEvent(query), 300)
    return () => clearTimeout(timeout)
  }, [query])
}
```
