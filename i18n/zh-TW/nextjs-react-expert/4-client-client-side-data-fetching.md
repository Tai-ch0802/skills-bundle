# 4. 客戶端資料抓取 (Client-Side Data Fetching)

> **影響力：** 中-高 (MEDIUM-HIGH)
> **焦點：** 自動去重與高效的資料抓取模式可減少冗餘的網路請求。

---

## 概述

本章節包含 **4 個規則**，專注於客戶端資料抓取。

---

## 規則 4.1：去重全域事件監聽器 (Deduplicate Global Event Listeners)

**影響力：** 低 (LOW)  
**標籤：** client, swr, event-listeners, subscription  

## 去重全域事件監聽器

使用 `useSWRSubscription()` 在不同組件實例間共享全域事件監聽器。

**錯誤範例 (N 個實例 = N 個監聽器)：**

```tsx
function useKeyboardShortcut(key: string, callback: () => void) {
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.metaKey && e.key === key) {
        callback()
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [key, callback])
}
```

當多次使用 `useKeyboardShortcut` 鉤子時，每個實例都會註冊一個新的監聽器。

**正確範例 (N 個實例 = 1 個監聽器)：**

```tsx
import useSWRSubscription from 'swr/subscription'

// 模組層級的 Map 用於追蹤每個按鍵的回呼
const keyCallbacks = new Map<string, Set<() => void>>()

function useKeyboardShortcut(key: string, callback: () => void) {
  // 在 Map 中註冊此回呼
  useEffect(() => {
    if (!keyCallbacks.has(key)) {
      keyCallbacks.set(key, new Set())
    }
    keyCallbacks.get(key)!.add(callback)

    return () => {
      const set = keyCallbacks.get(key)
      if (set) {
        set.delete(callback)
        if (set.size === 0) {
          keyCallbacks.delete(key)
        }
      }
    }
  }, [key, callback])

  useSWRSubscription('global-keydown', () => {
    const handler = (e: KeyboardEvent) => {
      if (e.metaKey && keyCallbacks.has(e.key)) {
        keyCallbacks.get(e.key)!.forEach(cb => cb())
      }
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  })
}

function Profile() {
  // 多個快捷鍵將共享同一個監聽器
  useKeyboardShortcut('p', () => { /* ... */ }) 
  useKeyboardShortcut('k', () => { /* ... */ })
  // ...
}
```

---

## 規則 4.2：為捲動效能使用被動事件監聽器 (Use Passive Event Listeners for Scrolling Performance)

**影響力：** 中 (MEDIUM)  
**標籤：** client, event-listeners, scrolling, performance, touch, wheel  

## 為捲動效能使用被動事件監聽器

在觸碰 (Touch) 與滾輪 (Wheel) 事件監聽器中加入 `{ passive: true }` 以啟用立即捲動。瀏覽器通常會等待監聽器結束以檢查是否調用了 `preventDefault()`，這會導致捲動延遲。

**錯誤範例：**

```typescript
useEffect(() => {
  const handleTouch = (e: TouchEvent) => console.log(e.touches[0].clientX)
  const handleWheel = (e: WheelEvent) => console.log(e.deltaY)
  
  document.addEventListener('touchstart', handleTouch)
  document.addEventListener('wheel', handleWheel)
  
  return () => {
    document.removeEventListener('touchstart', handleTouch)
    document.removeEventListener('wheel', handleWheel)
  }
}, [])
```

**正確範例：**

```typescript
useEffect(() => {
  const handleTouch = (e: TouchEvent) => console.log(e.touches[0].clientX)
  const handleWheel = (e: WheelEvent) => console.log(e.deltaY)
  
  document.addEventListener('touchstart', handleTouch, { passive: true })
  document.addEventListener('wheel', handleWheel, { passive: true })
  
  return () => {
    document.removeEventListener('touchstart', handleTouch)
    document.removeEventListener('wheel', handleWheel)
  }
}, [])
```

**何時使用 passive：** 追蹤/數據分析、日誌記錄，任何不需要調用 `preventDefault()` 的監聽器。

**何時「不」使用 passive：** 切實需要實作自定義滑動手勢、自定義縮放控制，或任何需要 `preventDefault()` 的監聽器。

---

## 規則 4.3：使用 SWR 進行自動去重 (Use SWR for Automatic Deduplication)

**影響力：** 中-高 (MEDIUM-HIGH)  
**標籤：** client, swr, deduplication, data-fetching  

## 使用 SWR 進行自動去重

SWR 可以在不同組件實例之間實現請求去重 (Deduplication)、快取與重新驗證。

**錯誤範例 (無去重，每個實例都會抓取)：**

```tsx
function UserList() {
  const [users, setUsers] = useState([])
  useEffect(() => {
    fetch('/api/users')
      .then(r => r.json())
      .then(setUsers)
  }, [])
}
```

**正確範例 (多個實例共享同一個請求)：**

```tsx
import useSWR from 'swr'

function UserList() {
  const { data: users } = useSWR('/api/users', fetcher)
}
```

**針對不可變資料 (Immutable Data)：**

```tsx
import { useImmutableSWR } from '@/lib/swr'

function StaticContent() {
  const { data } = useImmutableSWR('/api/config', fetcher)
}
```

**針對變更操作 (Mutations)：**

```tsx
import { useSWRMutation } from 'swr/mutation'

function UpdateButton() {
  const { trigger } = useSWRMutation('/api/user', updateUser)
  return <button onClick={() => trigger()}>Update</button>
}
```

參考資料：[https://swr.vercel.app](https://swr.vercel.app)

---

## 規則 4.4：版本化並最小化 localStorage 資料 (Version and Minimize localStorage Data)

**影響力：** 中 (MEDIUM)  
**標籤：** client, localStorage, storage, versioning, data-minimization  

## 版本化並最小化 localStorage 資料

在鍵名 (Keys) 中加入版本前綴，且只存儲必要的欄位。這可以防止架構衝突，並避免意外存儲敏感資料。

**錯誤範例：**

```typescript
// 無版本號、存儲完整物件、無錯誤處理
localStorage.setItem('userConfig', JSON.stringify(fullUserObject))
const data = localStorage.getItem('userConfig')
```

**正確範例：**

```typescript
const VERSION = 'v2'

function saveConfig(config: { theme: string; language: string }) {
  try {
    localStorage.setItem(`userConfig:${VERSION}`, JSON.stringify(config))
  } catch {
    // 在無痕模式/私密瀏覽、空間額滿或被禁用時會拋出錯誤
  }
}

function loadConfig() {
  try {
    const data = localStorage.getItem(`userConfig:${VERSION}`)
    return data ? JSON.parse(data) : null
  } catch {
    return null
  }
}

// 從 v1 遷移至 v2
function migrate() {
  try {
    const v1 = localStorage.getItem('userConfig:v1')
    if (v1) {
      const old = JSON.parse(v1)
      saveConfig({ theme: old.darkMode ? 'dark' : 'light', language: old.lang })
      localStorage.removeItem('userConfig:v1')
    }
  } catch {}
}
```

**僅存儲伺服器回應中的最小化欄位：**

```typescript
// 使用者物件有 20+ 個欄位，僅存儲 UI 需要的內容
function cachePrefs(user: FullUser) {
  try {
    localStorage.setItem('prefs:v1', JSON.stringify({
      theme: user.preferences.theme,
      notifications: user.preferences.notifications
    }))
  } catch {}
}
```

**務必使用 try-catch 包裝：** `getItem()` 與 `setItem()` 在無痕模式/私密瀏覽（如 Safari, Firefox）、儲存空間額滿或被禁用時會拋出錯誤。

**效益：** 透過版本控制實現架構演進、減少儲存體積、防止存儲權杖 (Tokens)/PII (個人識別資訊)/內部標記。
