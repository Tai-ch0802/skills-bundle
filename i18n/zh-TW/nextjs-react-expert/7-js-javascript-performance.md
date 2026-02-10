# 7. JavaScript 效能 (JavaScript Performance)

> **影響力：** 低-中 (LOW-MEDIUM)
> **焦點：** 針對熱點路徑 (Hot Paths) 的微優化累加起來能產生有意義的改進。

---

## 概述

本章節包含 **12 個規則**，專注於 JavaScript 效能。

---

## 規則 7.1：避免佈局抖動 (Avoid Layout Thrashing)

**影響力：** 中 (MEDIUM)  
**標籤：** javascript, dom, css, performance, reflow, layout-thrashing  

## 避免佈局抖動

避免將樣式寫入 (Style Writes) 與佈局讀取 (Layout Reads) 交錯執行。當你在兩次樣式更改之間讀取佈局屬性（如 `offsetWidth`, `getBoundingClientRect()`, 或 `getComputedStyle()`）時，瀏覽器會被強制觸發同步重排 (Reflow)。

**這沒問題（瀏覽器會批次處理樣式更動）：**
```typescript
function updateElementStyles(element: HTMLElement) {
  // 每一行都會使樣式失效，但瀏覽器會批次進行重新計算
  element.style.width = '100px'
  element.style.height = '200px'
  element.style.backgroundColor = 'blue'
  element.style.border = '1px solid black'
}
```

**錯誤範例 (交錯的讀取與寫入強制觸發多次重排)：**
```typescript
function layoutThrashing(element: HTMLElement) {
  element.style.width = '100px'
  const width = element.offsetWidth  // 強制重排
  element.style.height = '200px'
  const height = element.offsetHeight  // 再次強制重排
}
```

**正確範例 (批次寫入，然後讀取一次)：**
```typescript
function updateElementStyles(element: HTMLElement) {
  // 批次完成所有寫入
  element.style.width = '100px'
  element.style.height = '200px'
  element.style.backgroundColor = 'blue'
  element.style.border = '1px solid black'
  
  // 在所有寫入完成後才讀取 (單次重排)
  const { width, height } = element.getBoundingClientRect()
}
```

**正確範例 (批次讀取，然後寫入)：**
```typescript
function avoidThrashing(element: HTMLElement) {
  // 讀取階段 - 先執行所有的佈局查詢
  const rect1 = element.getBoundingClientRect()
  const offsetWidth = element.offsetWidth
  const offsetHeight = element.offsetHeight
  
  // 寫入階段 - 隨後執行所有的樣式更改
  element.style.width = '100px'
  element.style.height = '200px'
}
```

**更好的做法：使用 CSS 類別**
```css
.highlighted-box {
  width: 100px;
  height: 200px;
  background-color: blue;
  border: 1px solid black;
}
```
```typescript
function updateElementStyles(element: HTMLElement) {
  element.classList.add('highlighted-box')
  
  const { width, height } = element.getBoundingClientRect()
}
```

**React 範例：**
```tsx
// 錯誤範例：樣式變動與佈局查詢交錯執行
function Box({ isHighlighted }: { isHighlighted: boolean }) {
  const ref = useRef<HTMLDivElement>(null)
  
  useEffect(() => {
    if (ref.current && isHighlighted) {
      ref.current.style.width = '100px'
      const width = ref.current.offsetWidth // 強制佈局計算
      ref.current.style.height = '200px'
    }
  }, [isHighlighted])
  
  return <div ref={ref}>Content</div>
}

// 正確範例：切換 CSS 類別
function Box({ isHighlighted }: { isHighlighted: boolean }) {
  return (
    <div className={isHighlighted ? 'highlighted-box' : ''}>
      Content
    </div>
  )
}
```

優先考慮使用 CSS 類別而非內連樣式。CSS 文件會被瀏覽器快取，且類別能提供更好的關注點分離、易於維護。

更多關於強制佈局操作的資訊，請參見 [此 Gist](https://gist.github.com/paulirish/5d52fb081b3570c81e3a) 以及 [CSS Triggers](https://csstriggers.com/)。

---

## 規則 7.2：為重複查找建立索引 Map (Build Index Maps for Repeated Lookups)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, map, indexing, optimization, performance  

## 為重複查找建立索引 Map

針對同一鍵的多個 `.find()` 調用，應使用 Map。

**錯誤範例 (每次查找皆為 O(n))：**

```typescript
function processOrders(orders: Order[], users: User[]) {
  return orders.map(order => ({
    ...order,
    user: users.find(u => u.id === order.userId)
  }))
}
```

**正確範例 (每次查找皆為 O(1))：**

```typescript
function processOrders(orders: Order[], users: User[]) {
  const userById = new Map(users.map(u => [u.id, u]))

  return orders.map(order => ({
    ...order,
    user: userById.get(order.userId)
  }))
}
```

一次性建立 Map (O(n))，隨後的所有查找均為 O(1)。
針對 1000 份訂單 × 1000 個使用者：運算量從 100萬 次降至 2000 次。

---

## 規則 7.3：在迴圈中快取屬性存取 (Cache Property Access in Loops)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, loops, optimization, caching  

## 在迴圈中快取屬性存取

在熱點路徑中快取物件屬性的查找。

**錯誤範例 (3 次查找 × N 次迭代)：**

```typescript
for (let i = 0; i < arr.length; i++) {
  process(obj.config.settings.value)
}
```

**正確範例 (總共 1 次查找)：**

```typescript
const value = obj.config.settings.value
const len = arr.length
for (let i = 0; i < len; i++) {
  process(value)
}
```

---

## 規則 7.4：快取重複的函式調用 (Cache Repeated Function Calls)

**影響力：** 中 (MEDIUM)  
**標籤：** javascript, cache, memoization, performance  

## 快取重複的函式調用

當同一個函式在渲染期間以相同的輸入被重複調用時，使用模組層級的 Map 快取結果。

**錯誤範例 (冗餘計算)：**

```typescript
function ProjectList({ projects }: { projects: Project[] }) {
  return (
    <div>
      {projects.map(project => {
        // slugify() 為同一個項目名稱被調用了 100 多次
        const slug = slugify(project.name)
        
        return <ProjectCard key={project.id} slug={slug} />
      })}
    </div>
  )
}
```

**正確範例 (快取結果)：**

```typescript
// 模組層級快取
const slugifyCache = new Map<string, string>()

function cachedSlugify(text: string): string {
  if (slugifyCache.has(text)) {
    return slugifyCache.get(text)!
  }
  const result = slugify(text)
  slugifyCache.set(text, result)
  return result
}

function ProjectList({ projects }: { projects: Project[] }) {
  return (
    <div>
      {projects.map(project => {
        // 針對每個唯一的項目名稱僅計算一次
        const slug = cachedSlugify(project.name)
        
        return <ProjectCard key={project.id} slug={slug} />
      })}
    </div>
  )
}
```

**單一值的簡單模式：**

```typescript
let isLoggedInCache: boolean | null = null

function isLoggedIn(): boolean {
  if (isLoggedInCache !== null) {
    return isLoggedInCache
  }
  
  isLoggedInCache = document.cookie.includes('auth=')
  return isLoggedInCache
}

// 當驗證狀態改變時清除快取
function onAuthChange() {
  isLoggedInCache = null
}
```

使用 Map（而非 Hook），以便它能在任何地方運作：工具函式、事件處理程序，而不僅限於 React 組件。

參考資料：[How we made the Vercel Dashboard twice as fast](https://vercel.com/blog/how-we-made-the-vercel-dashboard-twice-as-fast)

---

## 規則 7.5：快取存儲 API 調用 (Cache Storage API Calls)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, localStorage, storage, caching, performance  

## 快取存儲 API 調用

`localStorage`, `sessionStorage`, 以及 `document.cookie` 都是同步且昂貴的操作。請在記憶體中快取讀取結果。

**錯誤範例 (每次調用都讀取儲存)：**

```typescript
function getTheme() {
  return localStorage.getItem('theme') ?? 'light'
}
// 調用 10 次 = 執行 10 次儲存讀取
```

**正確範例 (Map 快取)：**

```typescript
const storageCache = new Map<string, string | null>()

function getLocalStorage(key: string) {
  if (!storageCache.has(key)) {
    storageCache.set(key, localStorage.getItem(key))
  }
  return storageCache.get(key)
}

function setLocalStorage(key: string, value: string) {
  localStorage.setItem(key, value)
  storageCache.set(key, value)  // 保持快取同步
}
```

使用 Map（而非 Hook），以便它能在任何地方運作：工具函式、事件處理程序，而不僅限於 React 組件。

**Cookie 快取：**

```typescript
let cookieCache: Record<string, string> | null = null

function getCookie(name: string) {
  if (!cookieCache) {
    cookieCache = Object.fromEntries(
      document.cookie.split('; ').map(c => c.split('='))
    )
  }
  return cookieCache[name]
}
```

**重要（針對外部變動使其失效）：**

如果儲存空間可能在外部被更改（如另一個分頁、伺服器設置的 Cookie），請使快取失效：

```typescript
window.addEventListener('storage', (e) => {
  if (e.key) storageCache.delete(e.key)
})

document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible') {
    storageCache.clear()
  }
})
```

---

## 規則 7.6：合併多個陣列迭代 (Combine Multiple Array Iterations)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, arrays, loops, performance  

## 合併多個陣列迭代

多個 `.filter()` 或 `.map()` 調用會對陣列進行多次迭代。請將其合併為單個迴圈。

**錯誤範例 (3 次迭代)：**

```typescript
const admins = users.filter(u => u.isAdmin)
const testers = users.filter(u => u.isTester)
const inactive = users.filter(u => !u.isActive)
```

**正確範例 (1 次迭代提高效能)：**

```typescript
const admins: User[] = []
const testers: User[] = []
const inactive: User[] = []

for (const user of users) {
  if (user.isAdmin) admins.push(user)
  if (user.isTester) testers.push(user)
  if (!user.isActive) inactive.push(user)
}
```

---

## 規則 7.7：陣列比較的早期長度檢查 (Early Length Check for Array Comparisons)

**影響力：** 中-高 (MEDIUM-HIGH)  
**標籤：** javascript, arrays, performance, optimization, comparison  

## 陣列比較的早期長度檢查

當使用昂貴的操作（排序、深層相等比較、序列化）比較陣列時，先檢查長度。如果長度不同，陣列就不可能相等。

在實際應用中，這項優化在熱點路徑（事件處理程序、渲染迴圈）中特別有價值。

**錯誤範例 (總是執行昂貴的比較)：**

```typescript
function hasChanges(current: string[], original: string[]) {
  // 即使長度不同，也總是進行排序與合併字串
  return current.sort().join() !== original.sort().join()
}
```

即使 `current.length` 為 5 且 `original.length` 為 100，仍會執行兩次 O(n log n) 的排序，並伴隨合併陣列與字串比較的開銷。

**正確範例 (先執行 O(1) 的長度檢查)：**

```typescript
function hasChanges(current: string[], original: string[]) {
  // 如果長度不同則早期回傳
  if (current.length !== original.length) {
    return true
  }
  // 僅在長度匹配時才進行排序比較
  const currentSorted = current.toSorted()
  const originalSorted = original.toSorted()
  for (let i = 0; i < currentSorted.length; i++) {
    if (currentSorted[i] !== originalSorted[i]) {
      return true
    }
  }
  return false
}
```

新方法更高效，因為：
- 避免了長度不平時的排序與合併開銷。
- 避免了為合併字串消耗記憶體（對於大型陣列尤為重要）。
- 避免了變動原始陣列。
- 在發現差異時立即回傳。

---

## 規則 7.8：函式的早期回傳 (Early Return from Functions)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, functions, optimization, early-return  

## 函式的早期回傳

當結果已確定時，儘快回傳以跳過不必要的處理。

**錯誤範例 (發現錯誤後仍處理所有項目)：**

```typescript
function validateUsers(users: User[]) {
  let hasError = false
  let errorMessage = ''
  
  for (const user of users) {
    if (!user.email) {
      hasError = true
      errorMessage = 'Email required'
    }
    if (!user.name) {
      hasError = true
      errorMessage = 'Name required'
    }
    // 發現錯誤後仍繼續檢查其餘使用者
  }
  
  return hasError ? { valid: false, error: errorMessage } : { valid: true }
}
```

**正確範例 (發現第一個錯誤即刻回傳)：**

```typescript
function validateUsers(users: User[]) {
  for (const user of users) {
    if (!user.email) {
      return { valid: false, error: 'Email required' }
    }
    if (!user.name) {
      return { valid: false, error: 'Name required' }
    }
  }

  return { valid: true }
}
```

---

## 規則 7.9：提升 RegExp 的建立 (Hoist RegExp Creation)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, regexp, optimization, memoization  

## 提升 RegExp 的建立

不要在渲染期間建立 RegExp。請將其提升至模組級別，或使用 `useMemo()` 進行記憶化。

**錯誤範例 (每次渲染都建立新的 RegExp)：**

```tsx
function Highlighter({ text, query }: Props) {
  const regex = new RegExp(`(${query})`, 'gi')
  const parts = text.split(regex)
  return <>{parts.map((part, i) => ...)}</>
}
```

**正確範例 (記憶化或提升)：**

```tsx
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

function Highlighter({ text, query }: Props) {
  const regex = useMemo(
    () => new RegExp(`(${escapeRegex(query)})`, 'gi'),
    [query]
  )
  const parts = text.split(regex)
  return <>{parts.map((part, i) => ...)}</>
}
```

**警告 (全域 Regex 帶有可變狀態)：**

全域 Regex (`/g`) 帶有可變的 `lastIndex` 狀態：

```typescript
const regex = /foo/g
regex.test('foo')  // true, lastIndex = 3
regex.test('foo')  // false, lastIndex = 0
```

---

## 規則 7.10：為最小值/最大值使用迴圈而非排序 (Use Loop for Min/Max Instead of Sort)

**影響力：** 低 (LOW)  
**標籤：** javascript, arrays, performance, sorting, algorithms  

## 為最小值/最大值使用迴圈而非排序

尋找最小值或最大值僅需遍歷陣列一次。排序既浪費又緩慢。

**錯誤範例 (O(n log n) - 透過排序尋找最新項目)：**

```typescript
interface Project {
  id: string
  name: string
  updatedAt: number
}

function getLatestProject(projects: Project[]) {
  const sorted = [...projects].sort((a, b) => b.updatedAt - a.updatedAt)
  return sorted[0]
}
```

為了找出一個最大值而對整個陣列進行了排序。

**錯誤範例 (O(n log n) - 透過排序尋找最舊與最新)：**

```typescript
function getOldestAndNewest(projects: Project[]) {
  const sorted = [...projects].sort((a, b) => a.updatedAt - b.updatedAt)
  return { oldest: sorted[0], newest: sorted[sorted.length - 1] }
}
```

**正確範例 (O(n) - 單次迴圈)：**

```typescript
function getLatestProject(projects: Project[]) {
  if (projects.length === 0) return null
  
  let latest = projects[0]
  
  for (let i = 1; i < projects.length; i++) {
    if (projects[i].updatedAt > latest.updatedAt) {
      latest = projects[i]
    }
  }
  
  return latest
}

function getOldestAndNewest(projects: Project[]) {
  if (projects.length === 0) return { oldest: null, newest: null }
  
  let oldest = projects[0]
  let newest = projects[0]
  
  for (let i = 1; i < projects.length; i++) {
    if (projects[i].updatedAt < oldest.updatedAt) oldest = projects[i]
    if (projects[i].updatedAt > newest.updatedAt) newest = projects[i]
  }
  
  return { oldest, newest }
}
```

單次遍歷陣列，無複製、無排序。

**替代方案 (針對小型陣列使用 Math.min/Math.max)：**

```typescript
const numbers = [5, 2, 8, 1, 9]
const min = Math.min(...numbers)
const max = Math.max(...numbers)
```

這在小陣列上可行，但由於展開運算子的限制，在特大型陣列上可能會更慢或拋出錯誤。最大陣列長度在 Chrome 約為 12.4 萬，Safari 約為 63.8 萬；具體數值可能有所不同。考慮到可靠性，請優先使用迴圈方案。

---

## 規則 7.11：為 O(1) 查找使用 Set/Map (Use Set/Map for O(1) Lookups)

**影響力：** 低-中 (LOW-MEDIUM)  
**標籤：** javascript, set, map, data-structures, performance  

## 為 O(1) 查找使用 Set/Map

將陣列轉換為 Set/Map，以實現高效的重複成員資格檢查。

**錯誤範例 (每次檢查皆為 O(n))：**

```typescript
const allowedIds = ['a', 'b', 'c', ...]
items.filter(item => allowedIds.includes(item.id))
```

**正確範例 (每次檢查皆為 O(1))：**

```typescript
const allowedIds = new Set(['a', 'b', 'c', ...])
items.filter(item => allowedIds.has(item.id))
```

---

## 規則 7.12：因應不可變性使用 toSorted() 而非 sort() (Use toSorted() Instead of sort() for Immutability)

**影響力：** 中-高 (MEDIUM-HIGH)  
**標籤：** javascript, arrays, immutability, react, state, mutation  

## 因應不可變性使用 toSorted() 而非 sort()

`.sort()` 會原位變動 (Mutate) 陣列，這在 React State 與 Props 中可能引發 Bug。使用 `.toSorted()` 創建一個新的排序陣列。

**錯誤範例 (變動了原始陣列)：**

```typescript
function UserList({ users }: { users: User[] }) {
  // 變動了 users 這個 Prop 陣列！
  const sorted = useMemo(
    () => users.sort((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
  return <div>{sorted.map(renderUser)}</div>
}
```

**正確範例 (創建新陣列)：**

```typescript
function UserList({ users }: { users: User[] }) {
  // 創建新的排序陣列，原始資料保持不變
  const sorted = useMemo(
    () => users.toSorted((a, b) => a.name.localeCompare(b.name)),
    [users]
  )
  return <div>{sorted.map(renderUser)}</div>
}
```

**為什麼這在 React 中很重要：**

1. 變動 Props/State 會破壞 React 的不可變性模型 - React 期望將它們視為唯讀。
2. 引發過時閉包 Bug - 在閉包（如回呼、Effect）中變動陣列會導致難以意料的行為。

**瀏覽器支援 (舊版環境之替代方案)：**

`.toSorted()` 在所有現代瀏覽器中均已可用。針對舊環境，請搭配展開運算子：

```typescript
// 舊版瀏覽器的替代方案
const sorted = [...items].sort((a, b) => a.value - b.value)
```

**其他不可變陣列方法：**

- `.toSorted()` - 不可變排序
- `.toReversed()` - 不可變反轉
- `.toSpliced()` - 不可變拼接
- `.with()` - 不可變元素替換
