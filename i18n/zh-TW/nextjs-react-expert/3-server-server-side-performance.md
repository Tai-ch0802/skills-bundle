# 3. 伺服器端效能 (Server-Side Performance)

> **影響力：** 高 (HIGH)
> **焦點：** 優化伺服器端渲染 (SSR) 與資料抓取，消除伺服器端瀑布流並減少回應時間。

---

## 概述

本章節包含 **7 個規則**，專注於伺服器端效能。

---

## 規則 3.1：像 API 路由一樣驗證 Server Action (Authenticate Server Actions Like API Routes)

**影響力：** 關鍵 (CRITICAL)  
**標籤：** server, server-actions, authentication, security, authorization  

## 像 API 路由一樣驗證 Server Action

**影響力：關鍵 (防止未經授權存取伺服器狀態變更)**

Server Action（標有 `"use server"` 的函式）就像 API 路由一樣，是被公開暴露的端點。務必在**每個** Server Action 內部驗證驗證 (Authentication) 與授權 (Authorization) — 不要僅依賴中間件 (Middleware)、佈局守衛 (Layout Guards) 或頁面層級的檢查，因為 Server Action 可以被直接調用。

Next.js 官方文件明確指出：「將 Server Action 視為與面向大眾的 API 端點相同的安全考量，並驗證使用者是否被允許執行該變更。」

**錯誤範例 (無驗證檢查)：**

```typescript
'use server'

export async function deleteUser(userId: string) {
  // 任何人都可以調用！無驗證檢查
  await db.user.delete({ where: { id: userId } })
  return { success: true }
}
```

**正確範例 (Action 內建驗證)：**

```typescript
'use server'

import { verifySession } from '@/lib/auth'
import { unauthorized } from '@/lib/errors'

export async function deleteUser(userId: string) {
  // 務必在 Action 內部檢查驗證
  const session = await verifySession()
  
  if (!session) {
    throw unauthorized('Must be logged in')
  }
  
  // 同時檢查授權
  if (session.user.role !== 'admin' && session.user.id !== userId) {
    throw unauthorized('Cannot delete other users')
  }
  
  await db.user.delete({ where: { id: userId } })
  return { success: true }
}
```

**包含輸入驗證：**

```typescript
'use server'

import { verifySession } from '@/lib/auth'
import { z } from 'zod'

const updateProfileSchema = z.object({
  userId: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email()
})

export async function updateProfile(data: unknown) {
  // 先驗證輸入
  const validated = updateProfileSchema.parse(data)
  
  // 接著檢查驗證
  const session = await verifySession()
  if (!session) {
    throw new Error('Unauthorized')
  }
  
  // 最後檢查授權
  if (session.user.id !== validated.userId) {
    throw new Error('Can only update own profile')
  }
  
  // 最後才執行變更
  await db.user.update({
    where: { id: validated.userId },
    data: {
      name: validated.name,
      email: validated.email
    }
  })
  
  return { success: true }
}
```

參考資料：[https://nextjs.org/docs/app/guides/authentication](https://nextjs.org/docs/app/guides/authentication)

---

## 規則 3.2：避免 RSC Props 中的重複序列化 (Avoid Duplicate Serialization in RSC Props)

**影響力：** 低 (LOW)  
**標籤：** server, rsc, serialization, props, client-components  

## 避免 RSC Props 中的重複序列化

**影響力：低（透過避免重複序列化減少網路負載）**

RSC→Client 的序列化是基於物件引用 (Object Reference) 進行去重 (Deduplication)，而非基於值。相同的引用 = 序列化一次；新的引用 = 再次序列化。資料轉換（如 `.toSorted()`, `.filter()`, `.map()`）請在客戶端處理，而非伺服器端。

**錯誤範例 (陣列重複)：**

```tsx
// RSC：傳送了 6 個字串 (2 個陣列 × 3 個項目)
<ClientList usernames={usernames} usernamesOrdered={usernames.toSorted()} />
```

**正確範例 (傳送 3 個字串)：**

```tsx
// RSC：傳送一次
<ClientList usernames={usernames} />

// Client：在客戶端進行轉換
'use client'
const sorted = useMemo(() => [...usernames].sort(), [usernames])
```

**巢狀去重行為：**

去重是遞迴進行的。影響程度取決於資料類型：

- `string[]`, `number[]`, `boolean[]`: **影響大** - 陣列及其所有原始值會被完全重複。
- `object[]`: **影響小** - 陣列結構會重複，但巢狀物件會根據引用進行去重。

```tsx
// string[] - 全部重複
usernames={['a','b']} sorted={usernames.toSorted()} // 傳送 4 個字串

// object[] - 僅重複陣列結構
users={[{id:1},{id:2}]} sorted={users.toSorted()} // 傳送 2 個陣列 + 2 個唯一物件 (非 4 個)
```

**會破壞去重的操作（創造新引用）：**

- 陣列：`.toSorted()`, `.filter()`, `.map()`, `.slice()`, `[...arr]`
- 物件：`{...obj}`, `Object.assign()`, `structuredClone()`, `JSON.parse(JSON.stringify())`

**更多範例：**

```tsx
// ❌ 錯誤
<C users={users} active={users.filter(u => u.active)} />
<C product={product} productName={product.name} />

// ✅ 正確
<C users={users} />
<C product={product} />
// 在客戶端進行過濾/解構
```

**例外情況：** 當轉換操作極其昂貴，或是客戶端根本不需要原始資料時，才傳遞衍生資料。

---

## 規則 3.3：跨請求 LRU 快取 (Cross-Request LRU Caching)

**影響力：** 高 (HIGH)  
**標籤：** server, cache, lru, cross-request  

## 跨請求 LRU 快取

`React.cache()` 僅在單一請求內有效。對於跨多個連續請求共享的資料（例如使用者點擊按鈕 A 隨後點擊按鈕 B），請使用 LRU 快取。

**實作範例：**

```typescript
import { LRUCache } from 'lru-cache'

const cache = new LRUCache<string, any>({
  max: 1000,
  ttl: 5 * 60 * 1000  // 5 分鐘
})

export async function getUser(id: string) {
  const cached = cache.get(id)
  if (cached) return cached

  const user = await db.user.findUnique({ where: { id } })
  cache.set(id, user)
  return user
}

// 請求 1: 執行資料庫查詢，結果被快取
// 請求 2: 快取命中，不執行資料庫查詢
```

適用於使用者行為會在數秒內觸發多個需要相同資料的端點之情景。

**搭配 Vercel 的 [Fluid Compute](https://vercel.com/docs/fluid-compute)：** LRU 快取特別有效，因為多個並發請求可以共享同一個函式實例與快取。這意味著快取可以在請求之間存留，而無需 Redis 等外部儲存。

**傳統 Serverless 環境：** 每次調用都是隔離執行的，因此建議考慮使用 Redis 進行跨進程快取。

參考資料：[https://github.com/isaacs/node-lru-cache](https://github.com/isaacs/node-lru-cache)

---

## 規則 3.4：最小化 RSC 邊界的序列化 (Minimize Serialization at RSC Boundaries)

**影響力：** 高 (HIGH)  
**標籤：** server, rsc, serialization, props  

## 最小化 RSC 邊界的序列化

React Server/Client 邊界會將所有物件屬性轉化為字串，並嵌入到 HTML 回應及隨後的 RSC 請求中。這些序列化資料直接影響頁面大小與載入時間，因此**體積非常重要**。請僅傳遞客戶端真正會使用的欄位。

**錯誤範例 (序列化全數 50 個欄位)：**

```tsx
async function Page() {
  const user = await fetchUser()  // 50 個欄位
  return <Profile user={user} />
}

'use client'
function Profile({ user }: { user: User }) {
  return <div>{user.name}</div>  // 只使用 1 個欄位
}
```

**正確範例 (僅序列化 1 個欄位)：**

```tsx
async function Page() {
  const user = await fetchUser()
  return <Profile name={user.name} />
}

'use client'
function Profile({ name }: { name: string }) {
  return <div>{name}</div>
}
```

---

## 規則 3.5：利用組件組合實現並行資料抓取 (Parallel Data Fetching with Component Composition)

**影響力：** 關鍵 (CRITICAL)  
**標籤：** server, rsc, parallel-fetching, composition  

## 利用組件組合實現並行資料抓取

React Server Components 在渲染樹中是順序執行的。透過組件組合 (Composition) 重構以並行化資料抓取。

**錯誤範例 (Sidebar 等待 Page 的抓取完成)：**

```tsx
export default async function Page() {
  const header = await fetchHeader()
  return (
    <div>
      <div>{header}</div>
      <Sidebar />
    </div>
  )
}

async function Sidebar() {
  const items = await fetchSidebarItems()
  return <nav>{items.map(renderItem)}</nav>
}
```

**正確範例 (兩者同時抓取)：**

```tsx
async function Header() {
  const data = await fetchHeader()
  return <div>{data}</div>
}

async function Sidebar() {
  const items = await fetchSidebarItems()
  return <nav>{items.map(renderItem)}</nav>
}

export default function Page() {
  return (
    <div>
      <Header />
      <Sidebar />
    </div>
  )
}
```

**使用 children prop 的替代方案：**

```tsx
async function Header() {
  const data = await fetchHeader()
  return <div>{data}</div>
}

async function Sidebar() {
  const items = await fetchSidebarItems()
  return <nav>{items.map(renderItem)}</nav>
}

function Layout({ children }: { children: ReactNode }) {
  return (
    <div>
      <Header />
      {children}
    </div>
  )
}

export default function Page() {
  return (
    <Layout>
      <Sidebar />
    </Layout>
  )
}
```

---

## 規則 3.6：使用 React.cache() 進行單次請求去重 (Per-Request Deduplication with React.cache())

**影響力：** 中 (MEDIUM)  
**標籤：** server, cache, react-cache, deduplication  

## 使用 React.cache() 進行單次請求去重

使用 `React.cache()` 實現伺服器端請求去重。身份驗證與資料庫查詢受益最深。

**用法：**

```typescript
import { cache } from 'react'

export const getCurrentUser = cache(async () => {
  const session = await auth()
  if (!session?.user?.id) return null
  return await db.user.findUnique({
    where: { id: session.user.id }
  })
})
```

在單一請求中，多次調用 `getCurrentUser()` 僅會執行一次資料庫查詢。

**避免使用內連物件作為參數：**

`React.cache()` 使用淺比較 (`Object.is`) 來判斷快取命中。內連物件在每次調用時都會產生新引用，導致快取失效。

**錯誤範例 (總是快取失效)：**

```typescript
const getUser = cache(async (params: { uid: number }) => {
  return await db.user.findUnique({ where: { id: params.uid } })
})

// 每次調用都產生新物件，永不命中快取
getUser({ uid: 1 })
getUser({ uid: 1 })  // 快取失效，再次運行查詢
```

**正確範例 (快取命中)：**

```typescript
const getUser = cache(async (uid: number) => {
  return await db.user.findUnique({ where: { id: uid } })
})

// 原始型別參數使用值比較
getUser(1)
getUser(1)  // 快取命中，回傳快取結果
```

如果你必須傳遞物件，請傳遞同一個引用：

```typescript
const params = { uid: 1 }
getUser(params)  // 執行查詢
getUser(params)  // 快取命中 (相同引用)
```

**Next.js 特定說明：**

在 Next.js 中，`fetch` API 已被自動擴充了請求記憶化 (Request Memoization)。具有相同 URL 與選項的請求會在單一請求中自動去重，因此你不需要為 `fetch` 調用使用 `React.cache()`。然而，對於其他非同步任務，`React.cache()` 仍然至關重要：

- 資料庫查詢 (Prisma, Drizzle 等)
- 重度計算
- 身份驗證檢查
- 檔案系統操作
- 任何非 fetch 的非同步工作

使用 `React.cache()` 在你的組件樹中去重這些操作。

參考資料：[React.cache documentation](https://react.dev/reference/react/cache)

---

## 規則 3.7：為非阻塞操作使用 after() (Use after() for Non-Blocking Operations)

**影響力：** 中 (MEDIUM)  
**標籤：** server, async, logging, analytics, side-effects  

## 為非阻塞操作使用 after()

使用 Next.js 的 `after()` 安排那些應該在回應送出後執行的任務。這可以防止日誌記錄、數據分析與其他副作用阻塞回應時間。

**錯誤範例 (阻塞回應)：**

```tsx
import { logUserAction } from '@/app/utils'

export async function POST(request: Request) {
  // 執行變更
  await updateDatabase(request)
  
  // 日誌記錄阻塞了回應
  const userAgent = request.headers.get('user-agent') || 'unknown'
  await logUserAction({ userAgent })
  
  return new Response(JSON.stringify({ status: 'success' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

**正確範例 (非阻塞)：**

```tsx
import { after } from 'next/server'
import { headers, cookies } from 'next/headers'
import { logUserAction } from '@/app/utils'

export async function POST(request: Request) {
  // 執行變更
  await updateDatabase(request)
  
  // 在回應送出後記錄日誌
  after(async () => {
    const userAgent = (await headers()).get('user-agent') || 'unknown'
    const sessionCookie = (await cookies()).get('session-id')?.value || 'anonymous'
    
    logUserAction({ sessionCookie, userAgent })
  })
  
  return new Response(JSON.stringify({ status: 'success' }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  })
}
```

回應會立即送出，而日誌記錄則在背景進行。

**常見使用場景：**

- 數據分析追蹤
- 稽核日誌 (Audit logging)
- 傳送通知
- 快取失效 (Cache invalidation)
- 清理任務

**重要筆記：**

- `after()` 即使回應失敗或重新導向也會執行
- 可在 Server Action, Route Handlers, 與 Server Components 中工作

參考資料：[https://nextjs.org/docs/app/api-reference/functions/after](https://nextjs.org/docs/app/api-reference/functions/after)
