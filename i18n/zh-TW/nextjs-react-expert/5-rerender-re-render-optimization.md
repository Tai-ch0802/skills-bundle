# 5. 重複渲染優化 (Re-render Optimization)

> **影響力：** 中 (MEDIUM)
> **焦點：** 減少不必要的重複渲染可最小化浪費的計算，並提昇 UI 的回應度。

---

## 概述

本章節包含 **12 個規則**，專注於重複渲染的優化。

---

## 規則 5.1：在渲染期間計算衍生狀態 (Calculate Derived State During Rendering)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, derived-state, useEffect, state  

## 在渲染期間計算衍生狀態

如果一個值可以從當前的 Props 或 State 中計算得出，請不要將其存儲在 State 中或在 Effect 中更新它。在渲染期間直接推導出它，以避免額外的渲染與狀態偏差 (State Drift)。不要僅僅為了回應 Prop 變化而在 Effect 中設定狀態；優先使用衍生值或帶 Key 的重設。

**錯誤範例 (冗餘的狀態與 Effect)：**

```tsx
function Form() {
  const [firstName, setFirstName] = useState('First')
  const [lastName, setLastName] = useState('Last')
  const [fullName, setFullName] = useState('')

  useEffect(() => {
    setFullName(firstName + ' ' + lastName)
  }, [firstName, lastName])

  return <p>{fullName}</p>
}
```

**正確範例 (渲染時推導)：**

```tsx
function Form() {
  const [firstName, setFirstName] = useState('First')
  const [lastName, setLastName] = useState('Last')
  const fullName = firstName + ' ' + lastName

  return <p>{fullName}</p>
}
```

參考資料：[You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)

---

## 規則 5.2：將狀態讀取延遲至使用點 (Defer State Reads to Usage Point)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, searchParams, localStorage, optimization  

## 將狀態讀取延遲至使用點

如果你僅在回呼函式 (Callbacks) 內部讀取動態狀態（如 `searchParams`, `localStorage`），則不要主動訂閱它們。

**錯誤範例 (訂閱了所有 searchParams 的變化)：**

```tsx
function ShareButton({ chatId }: { chatId: string }) {
  const searchParams = useSearchParams()

  const handleShare = () => {
    const ref = searchParams.get('ref')
    shareChat(chatId, { ref })
  }

  return <button onClick={handleShare}>Share</button>
}
```

**正確範例 (按需求讀取，不訂閱)：**

```tsx
function ShareButton({ chatId }: { chatId: string }) {
  const handleShare = () => {
    const params = new URLSearchParams(window.location.search)
    const ref = params.get('ref')
    shareChat(chatId, { ref })
  }

  return <button onClick={handleShare}>Share</button>
}
```

---

## 規則 5.3：不要對原始結果類型的簡單表達式使用 useMemo (Do not wrap a simple expression with a primitive result type in useMemo)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** rerender, useMemo, optimization  

## 不要對原始結果類型的簡單表達式使用 useMemo

當表達式很簡單（僅有少數邏輯或算術運算子）且結果為原始型別（布林、數字、字串）時，不要將其封裝在 `useMemo` 中。調用 `useMemo` 與比較鉤子依賴項所消耗的資源可能比表達式本身還要多。

**錯誤範例：**

```tsx
function Header({ user, notifications }: Props) {
  const isLoading = useMemo(() => {
    return user.isLoading || notifications.isLoading
  }, [user.isLoading, notifications.isLoading])

  if (isLoading) return <Skeleton />
  // 回傳標記
}
```

**正確範例：**

```tsx
function Header({ user, notifications }: Props) {
  const isLoading = user.isLoading || notifications.isLoading

  if (isLoading) return <Skeleton />
  // 回傳標記
}
```

---

## 規則 5.4：將被記憶組件中的非原始預設值提取為常量 (Extract Default Non-primitive Parameter Value from Memoized Component to Constant)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, memo, optimization  

## 將被記憶組件中的非原始預設值提取為常量

當被記憶 (Memoized) 的組件對於某些非原始的可選參數（如陣列、函式或物件）設有預設值時，如果不傳入該參數就調用組件，將會破壞記憶化。這是因為每次重複渲染時都會創建新的值實例，它們無法通過 `memo()` 內部的嚴格相等比較。

為了解決此問題，請將該預設值提取為常量。

**錯誤範例 (`onClick` 在每次渲染時都有不同的值)：**

```tsx
const UserAvatar = memo(function UserAvatar({ onClick = () => {} }: { onClick?: () => void }) {
  // ...
})

// 使用時未提供可選的 onClick
<UserAvatar />
```

**正確範例 (穩定的預設值)：**

```tsx
const NOOP = () => {};

const UserAvatar = memo(function UserAvatar({ onClick = NOOP }: { onClick?: () => void }) {
  // ...
})

// 使用時未提供可選的 onClick
<UserAvatar />
```

---

## 規則 5.5：提取為被記憶組件 (Extract to Memoized Components)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, memo, useMemo, optimization  

## 提取為被記憶組件

將昂貴的工作提取到被記憶 (Memoized) 的組件中，以便在計算前能實現早期回傳 (Early Returns)。

**錯誤範例 (即使在載入中也會計算頭像)：**

```tsx
function Profile({ user, loading }: Props) {
  const avatar = useMemo(() => {
    const id = computeAvatarId(user)
    return <Avatar id={id} />
  }, [user])

  if (loading) return <Skeleton />
  return <div>{avatar}</div>
}
```

**正確範例 (載入時跳過計算)：**

```tsx
const UserAvatar = memo(function UserAvatar({ user }: { user: User }) {
  const id = useMemo(() => computeAvatarId(user), [user])
  return <Avatar id={id} />
})

function Profile({ user, loading }: Props) {
  if (loading) return <Skeleton />
  return (
    <div>
      <UserAvatar user={user} />
    </div>
  )
}
```

**注意：** 如果你的項目啟用了 [React Compiler](https://react.dev/learn/react-compiler)，則無需手動使用 `memo()` 與 `useMemo()` 的優化。編譯器會自動優化重複渲染。

---

## 規則 5.6：縮短 Effect 依賴項 (Narrow Effect Dependencies)

**影響力：** 低 (LOW)  
**標籤：** rerender, useEffect, dependencies, optimization  

## 縮短 Effect 依賴項

指定原始型別的依賴項而非整個物件，以最小化 Effect 的重新執行。

**錯誤範例 (在任何 user 欄位變動時都會重跑)：**

```tsx
useEffect(() => {
  console.log(user.id)
}, [user])
```

**正確範例 (僅在 id 變動時重跑)：**

```tsx
useEffect(() => {
  console.log(user.id)
}, [user.id])
```

**針對衍生狀態，在 Effect 外部計算：**

```tsx
// 錯誤：寬度為 767, 766, 765... 時都會執行
useEffect(() => {
  if (width < 768) {
    enableMobileMode()
  }
}, [width])

// 正確：僅在布林值變換時執行
const isMobile = width < 768
useEffect(() => {
  if (isMobile) {
    enableMobileMode()
  }
}, [isMobile])
```

---

## 規則 5.7：將互動邏輯放入事件處理程序 (Put Interaction Logic in Event Handlers)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, useEffect, events, side-effects, dependencies  

## 將互動邏輯放入事件處理程序

如果一個副作用是由特定的使用者行為（提交、點擊、拖拽）觸發的，請在該事件處理程序中運行它。不要將該行為模型化為「狀態 + Effect」；這會導致 Effect 在無關的變動時重新執行，並可能導致行為重複。

**錯誤範例 (事件被模型化為狀態 + Effect)：**

```tsx
function Form() {
  const [submitted, setSubmitted] = useState(false)
  const theme = useContext(ThemeContext)

  useEffect(() => {
    if (submitted) {
      post('/api/register')
      showToast('Registered', theme)
    }
  }, [submitted, theme])

  return <button onClick={() => setSubmitted(true)}>Submit</button>
}
```

**正確範例 (在處理程序中執行)：**

```tsx
function Form() {
  const theme = useContext(ThemeContext)

  function handleSubmit() {
    post('/api/register')
    showToast('Registered', theme)
  }

  return <button onClick={handleSubmit}>Submit</button>
}
```

參考資料：[Should this code move to an event handler?](https://react.dev/learn/removing-effect-dependencies#should-this-code-move-to-an-event-handler)

---

## 規則 5.8：訂閱衍生狀態 (Subscribe to Derived State)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, derived-state, media-query, optimization  

## 訂閱衍生狀態

訂閱衍生的布林狀態而非連續變動的值，以減少渲染頻率。

**錯誤範例 (像素每次變動都會渲染)：**

```tsx
function Sidebar() {
  const width = useWindowWidth()  // 持續更新
  const isMobile = width < 768
  return <nav className={isMobile ? 'mobile' : 'desktop'} />
}
```

**正確範例 (僅在布林值變動時渲染)：**

```tsx
function Sidebar() {
  const isMobile = useMediaQuery('(max-width: 767px)')
  return <nav className={isMobile ? 'mobile' : 'desktop'} />
}
```

---

## 規則 5.9：使用函式型 setState 更新 (Use Functional setState Updates)

**影響力：** 中 (MEDIUM)  
**標籤：** react, hooks, useState, useCallback, callbacks, closures  

## 使用函式型 setState 更新

當根據當前狀態值更新狀態時，請使用 setState 的函式更新形式，而非直接引用狀態變數。這能防止過時閉包 (Stale Closures)，消除不必要的依賴項，並創造穩定的回呼引用。

**錯誤範例 (需要 state 作為依賴項)：**

```tsx
function TodoList() {
  const [items, setItems] = useState(initialItems)
  
  // 回呼必須依賴於 items，在每次 items 變動時都會重新創建
  const addItems = useCallback((newItems: Item[]) => {
    setItems([...items, ...newItems])
  }, [items])  // ❌ items 依賴項導致重新創建
  
  // 如果遺漏了依賴項，會面臨過時閉包的風險
  const removeItem = useCallback((id: string) => {
    setItems(items.filter(item => item.id !== id))
  }, [])  // ❌ 遺漏 items 依賴項 - 將使用過時的 items！
  
  return <ItemsEditor items={items} onAdd={addItems} onRemove={removeItem} />
}
```

第一個回呼會在每次 `items` 變動時重新創建，這會導致子組件產生不必要的重複渲染。第二個回呼有過時閉包的 Bug — 它將永遠引用初始的 `items` 值。

**正確範例 (穩定的回呼，無過時閉包風險)：**

```tsx
function TodoList() {
  const [items, setItems] = useState(initialItems)
  
  // 穩定的回呼，永不重新創建
  const addItems = useCallback((newItems: Item[]) => {
    setItems(curr => [...curr, ...newItems])
  }, [])  // ✅ 無需依賴項
  
  // 總是使用最新的狀態，無過時閉包風險
  const removeItem = useCallback((id: string) => {
    setItems(curr => curr.filter(item => item.id !== id))
  }, [])  // ✅ 安全且穩定
  
  return <ItemsEditor items={items} onAdd={addItems} onRemove={removeItem} />
}
```

**效益：**

1. **穩定的回呼引用** - 當狀態變動時，回呼不需要重新創建
2. **無過時閉包** - 總是對最新的狀態值進行操作
3. **更少的依賴項** - 簡化依賴項陣列並減少記憶體洩漏
4. **防止 Bug** - 消除了 React 閉包 Bug 最常見的來源

**何時該使用函式型更新：**

- 任何依賴於當前狀態值的 setState
- 當在 useCallback/useMemo 內部需要狀態時
- 引用了狀態的事件處理程序
- 更新狀態的非同步操作

**何時直接更新即可：**

- 將狀態設定為靜態值：`setCount(0)`
- 僅從 Props/參數設定狀態：`setName(newName)`
- 狀態不依賴於前一個值

**注意：** 如果你的項目啟用了 [React Compiler](https://react.dev/learn/react-compiler)，編譯器可以自動優化部分情況，但為了正確性以及防止過時閉包 Bug，仍推薦使用函式型更新。

---

## 規則 5.10：使用延遲狀態初始化 (Use Lazy State Initialization)

**影響力：** 中 (MEDIUM)  
**標籤：** react, hooks, useState, performance, initialization  

## 使用延遲狀態初始化

對於開銷昂貴的初始值，請向 `useState` 傳入一個函式。如果不使用函式形式，初始化程式會在每次渲染時執行，儘管該值僅在第一次被使用。

**錯誤範例 (每次渲染都會執行)：**

```tsx
function FilteredList({ items }: { items: Item[] }) {
  // buildSearchIndex() 在「每一次」渲染都會執行，即使在初始化之後
  const [searchIndex, setSearchIndex] = useState(buildSearchIndex(items))
  const [query, setQuery] = useState('')
  
  // 當 query 變動時，buildSearchIndex 會無謂地再次執行
  return <SearchResults index={searchIndex} query={query} />
}

function UserProfile() {
  // JSON.parse 在每一次渲染都會執行
  const [settings, setSettings] = useState(
    JSON.parse(localStorage.getItem('settings') || '{}')
  )
  
  return <SettingsForm settings={settings} onChange={setSettings} />
}
```

**正確範例 (僅執行一次)：**

```tsx
function FilteredList({ items }: { items: Item[] }) {
  // buildSearchIndex() 僅在「初始」渲染時執行
  const [searchIndex, setSearchIndex] = useState(() => buildSearchIndex(items))
  const [query, setQuery] = useState('')
  
  return <SearchResults index={searchIndex} query={query} />
}

function UserProfile() {
  // JSON.parse 僅在初始渲染時執行
  const [settings, setSettings] = useState(() => {
    const stored = localStorage.getItem('settings')
    return stored ? JSON.parse(stored) : {}
  })
  
  return <SettingsForm settings={settings} onChange={setSettings} />
}
```

當從 localStorage/sessionStorage 計算初始值、構建資料結構（索、Map）、從 DOM 讀取或執行繁重轉換時，請使用延遲初始化。

對於簡單的原始型別 (`useState(0)`)、直接引用 (`useState(props.value)`) 或廉價的物件字面值 (`useState({})`)，則無需使用函式形式。

---

## 規則 5.11：為非緊急更新使用 Transition (Use Transitions for Non-Urgent Updates)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, transitions, startTransition, performance  

## 為非緊急更新使用 Transition

標記頻繁且非緊急的狀態更新為 Transition，以保持 UI 的回應度。

**錯誤範例 (每次捲動都會阻塞 UI)：**

```tsx
function ScrollTracker() {
  const [scrollY, setScrollY] = useState(0)
  useEffect(() => {
    const handler = () => setScrollY(window.scrollY)
    window.addEventListener('scroll', handler, { passive: true })
    return () => window.removeEventListener('scroll', handler)
  }, [])
}
```

**正確範例 (非阻塞更新)：**

```tsx
import { startTransition } from 'react'

function ScrollTracker() {
  const [scrollY, setScrollY] = useState(0)
  useEffect(() => {
    const handler = () => {
      startTransition(() => setScrollY(window.scrollY))
    }
    window.addEventListener('scroll', handler, { passive: true })
    return () => window.removeEventListener('scroll', handler)
  }, [])
}
```

---

## 規則 5.12：為瞬時值使用 useRef (Use useRef for Transient Values)

**影響力：** 中 (MEDIUM)  
**標籤：** rerender, useref, state, performance  

## 為瞬時值使用 useRef

當一個值頻繁變動且你不希望每次更新都觸發重複渲染時（例如滑鼠追蹤器、計時器、瞬時標記），請將其存儲在 `useRef` 中而非 `useState`。將組件狀態保留給 UI；對於臨時且與 DOM 緊邻的值，請使用 Ref。更新 Ref 不會觸發重複渲染。

**錯誤範例 (每次更新都會渲染)：**

```tsx
function Tracker() {
  const [lastX, setLastX] = useState(0)

  useEffect(() => {
    const onMove = (e: MouseEvent) => setLastX(e.clientX)
    window.addEventListener('mousemove', onMove)
    return () => window.removeEventListener('mousemove', onMove)
  }, [])

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: lastX,
        width: 8,
        height: 8,
        background: 'black',
      }}
    />
  )
}
```

**正確範例 (追蹤時不觸發渲染)：**

```tsx
function Tracker() {
  const lastXRef = useRef(0)
  const dotRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const onMove = (e: MouseEvent) => {
      lastXRef.current = e.clientX
      const node = dotRef.current
      if (node) {
        node.style.transform = `translateX(${e.clientX}px)`
      }
    }
    window.addEventListener('mousemove', onMove)
    return () => window.removeEventListener('mousemove', onMove)
  }, [])

  return (
    <div
      ref={dotRef}
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        width: 8,
        height: 8,
        background: 'black',
        transform: 'translateX(0px)',
      }}
    />
  )
}
```
