# 1. 消除瀑布流 (Eliminating Waterfalls)

> **影響力：** 關鍵 (CRITICAL)
> **焦點：** 瀑布流是效能的第一大殺手。每一次順序執行的 `await` 都會增加完整的網路延遲。消除它們能獲得最顯著的收益。

---

## 概述

本章節包含 **5 個規則**，專注於消除非必要的非同步順序執行（瀑布流）。

---

## 規則 1.1：延遲等待直到必要 (Defer Await Until Needed)

**影響力：** 高 (HIGH)  
**標籤：** async, await, conditional, optimization  

## 延遲等待直到必要

將 `await` 操作移入真正使用資料的分支中，以避免阻塞那些不需要該資料的程式碼路徑。

**錯誤範例 (兩個分支都會被阻塞)：**

```typescript
async function handleRequest(userId: string, skipProcessing: boolean) {
  const userData = await fetchUserData(userId)
  
  if (skipProcessing) {
    // 雖然直接回傳，但仍然等待了 userData 的取回
    return { skipped: true }
  }
  
  // 只有這個分支需要使用 userData
  return processUserData(userData)
}
```

**正確範例 (只在需要時才阻塞)：**

```typescript
async function handleRequest(userId: string, skipProcessing: boolean) {
  if (skipProcessing) {
    // 直接回傳且無需等待
    return { skipped: true }
  }
  
  // 僅在必要時發起請求
  const userData = await fetchUserData(userId)
  return processUserData(userData)
}
```

**另一個範例 (早期回傳優化)：**

```typescript
// 錯誤：總是會先抓取權限
async function updateResource(resourceId: string, userId: string) {
  const permissions = await fetchPermissions(userId)
  const resource = await getResource(resourceId)
  
  if (!resource) {
    return { error: 'Not found' }
  }
  
  if (!permissions.canEdit) {
    return { error: 'Forbidden' }
  }
  
  return await updateResourceData(resource, permissions)
}

// 正確：僅在必要時抓取
async function updateResource(resourceId: string, userId: string) {
  const resource = await getResource(resourceId)
  
  if (!resource) {
    return { error: 'Not found' }
  }
  
  const permissions = await fetchPermissions(userId)
  
  if (!permissions.canEdit) {
    return { error: 'Forbidden' }
  }
  
  return await updateResourceData(resource, permissions)
}
```

當可以跳過的分支經常被觸發，或者延遲的操作非常昂貴時，這項優化特別有價值。

---

## 規則 1.2：基於依賴的並行化 (Dependency-Based Parallelization)

**影響力：** 關鍵 (CRITICAL)  
**標籤：** async, parallelization, dependencies, better-all  

## 基於依賴的並行化

對於具備部分依賴關係的操作，使用 `better-all` 來最大化並行度。它會自動在最早可能的時刻啟動每個任務。

**錯誤範例 (設定資訊在非必要的情況下等待使用者資訊)：**

```typescript
const [user, config] = await Promise.all([
  fetchUser(),
  fetchConfig()
])
const profile = await fetchProfile(user.id)
```

**正確範例 (config 與 profile 同時開發並行)：**

```typescript
import { all } from 'better-all'

const { user, config, profile } = await all({
  async user() { return fetchUser() },
  async config() { return fetchConfig() },
  async profile() {
    return fetchProfile((await this.$.user).id)
  }
})
```

**不使用額外依賴庫的替代方案：**

我們可以先創建所有的 Promise，最後再執行 `Promise.all()`。

```typescript
const userPromise = fetchUser()
const profilePromise = userPromise.then(user => fetchProfile(user.id))

const [user, config, profile] = await Promise.all([
  userPromise,
  fetchConfig(),
  profilePromise
])
```

參考資料：[https://github.com/shuding/better-all](https://github.com/shuding/better-all)

---

## 規則 1.3：防止 API 路由中的瀑布鏈 (Prevent Waterfall Chains in API Routes)

**影響力：** 關鍵 (CRITICAL)  
**標籤：** api-routes, server-actions, waterfalls, parallelization  

## 防止 API 路由中的瀑布鏈

在 API 路由和 Server Actions 中，立即啟動獨立的操作，即使你還不需要 `await` 它們。

**錯誤範例 (config 等待 auth，data 等待兩者)：**

```typescript
export async function GET(request: Request) {
  const session = await auth()
  const config = await fetchConfig()
  const data = await fetchData(session.user.id)
  return Response.json({ data, config })
}
```

**正確範例 (auth 與 config 同時啟動)：**

```typescript
export async function GET(request: Request) {
  const sessionPromise = auth()
  const configPromise = fetchConfig()
  const session = await sessionPromise
  const [config, data] = await Promise.all([
    configPromise,
    fetchData(session.user.id)
  ])
  return Response.json({ data, config })
}
```

對於具有更複雜依賴鏈的操作，請使用 `better-all` 自動最大化並行度。

---

## 規則 1.4：針對獨立操作使用 Promise.all()

**影響力：** 關鍵 (CRITICAL)  
**標籤：** async, parallelization, promises, waterfalls  

## 針對獨立操作使用 Promise.all()

當非同步操作之間沒有相互依賴關係時，使用 `Promise.all()` 同步執行它們。

**錯誤範例 (順序執行，需 3 次往返時間)：**

```typescript
const user = await fetchUser()
const posts = await fetchPosts()
const comments = await fetchComments()
```

**正確範例 (並行執行，只需 1 次往返時間)：**

```typescript
const [user, posts, comments] = await Promise.all([
  fetchUser(),
  fetchPosts(),
  fetchComments()
])
```

---

## 規則 1.5：策略性的 Suspense 邊界 (Strategic Suspense Boundaries)

**影響力：** 高 (HIGH)  
**標籤：** async, suspense, streaming, layout-shift  

## 策略性的 Suspense 邊界

與其在非同步組件中 `await` 資料後才回傳 JSX，不如使用 Suspense 邊界，在資料載入時先顯示包裝層 UI (Wrapper UI)。

**錯誤範例 (包裝層被資料抓取阻塞)：**

```tsx
async function Page() {
  const data = await fetchData() // 阻塞整頁
  
  return (
    <div>
      <div>Sidebar</div>
      <div>Header</div>
      <div>
        <DataDisplay data={data} />
      </div>
      <div>Footer</div>
    </div>
  )
}
```

即始只有中間區塊需要資料，整個佈局仍然需要等待資料。

**正確範例 (立即顯示佈局，資料串流傳入)：**

```tsx
function Page() {
  return (
    <div>
      <div>Sidebar</div>
      <div>Header</div>
      <div>
        <Suspense fallback={<Skeleton />}>
          <DataDisplay />
        </Suspense>
      </div>
      <div>Footer</div>
    </div>
  )
}

async function DataDisplay() {
  const data = await fetchData() // 僅阻塞此組件
  return <div>{data.content}</div>
}
```

Sidebar, Header, 與 Footer 會立即渲染。只有 DataDisplay 會等待資料。

**替代方案 (跨組件共享 Promise)：**

```tsx
function Page() {
  // 立即開始抓取，但不等待 (don't await)
  const dataPromise = fetchData()
  
  return (
    <div>
      <div>Sidebar</div>
      <div>Header</div>
      <Suspense fallback={<Skeleton />}>
        <DataDisplay dataPromise={dataPromise} />
        <DataSummary dataPromise={dataPromise} />
      </Suspense>
      <div>Footer</div>
    </div>
  )
}

function DataDisplay({ dataPromise }: { dataPromise: Promise<Data> }) {
  const data = use(dataPromise) // 解開 Promise
  return <div>{data.content}</div>
}

function DataSummary({ dataPromise }: { dataPromise: Promise<Data> }) {
  const data = use(dataPromise) // 重用同一個 Promise
  return <div>{data.summary}</div>
}
```

兩個組件共享同一個 Promise，因此只會發生一次抓取。佈局會立即渲染，而兩個組件會一起等待。

**何時「不」該使用此模式：**

- 佈局決策需要關鍵資料（影響定位）。
- 首屏 (Above the fold) 關鍵的 SEO 內容。
- 資料量極小、極快的查詢，Suspense 的開銷不值得。
- 當你想要避免佈局偏移 (Layout Shift, 載入中 → 內容跳動)。

**權衡：** 追求更快的初始繪製 (Initial Paint) vs. 潛在的佈局偏移。根據你的 UX 優先順序進行選擇。
