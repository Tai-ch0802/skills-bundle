# 快取元件：`use cache` 和 `cacheLife`

> [!IMPORTANT]
> 這是 Next.js 16+ 特定的技能。在未明確檢查相容性的情況下，**請勿**將這些模式應用於 Next.js 15 或更早版本。

## 核心理念
Next.js 16 標誌著從「區段級快取 (Segment-level caching)」過渡到「元件級快取 (Component-level caching)」。我們不再依賴 `export const revalidate = 3600`。相反地，我們使用更細微的指令和設定檔。

## 1. `use cache` 指令
`use cache` 指令可應用於 **Server Components (伺服器元件)** 或 **函式**。

### 規則：細粒度應用
僅包裹需要快取的資料擷取邏輯或特定元件。

```tsx
// 佳：細粒度的函式快取
async function getProduct(id: string) {
  'use cache'
  return await db.product.findUnique({ where: { id } })
}

// 佳：元件級快取
export default async function ProductCard({ id }: { id: string }) {
  'use cache'
  const product = await getProduct(id)
  return <div>{product.name}</div>
}
```

## 2. 使用 `cacheLife`
`cacheLife` 透過預先定義或自訂的設定檔，來定義快取項目的「新鮮度 (Freshness)」和「過期時間 (Staleness)」。

### 使用模式
```tsx
import { cacheLife } from 'next/cache'

async function getStockInfo() {
  'use cache'
  cacheLife('minutes') // 使用預先定義的設定檔
  return await fetchStocks()
}
```

### 設定檔參考
- `default`：基礎設定檔（1 年過期時間）。
- `seconds`：高頻率更新。
- `minutes`：標準動態內容。
- `hours`：穩定的內容（例如，部落格文章）。
- `days`：半靜態內容。
- `weeks`：類靜態內容。
- `max`：永久快取直到被失效。

## 3. 使用 `cacheTag` 隨需失效
`cacheTag` 允許你為快取資料加上標籤，以便進行選擇性清除。

### 實作
```tsx
import { cacheTag } from 'next/cache'

async function getProfile(user: string) {
  'use cache'
  cacheTag(`profile-${user}`)
  return await db.user.findUnique(...)
}
```

### 重新驗證
在 Server Action 內：
```tsx
import { revalidateTag, updateTag } from 'next/cache'

export async function updateProfile(user: string, data: any) {
  await db.user.update(...)

  // 選擇 A：背景重新驗證 (Stale-While-Revalidate)
  revalidateTag(`profile-${user}`)

  // 選擇 B：立即的 "Read-Your-Writes" 更新
  updateTag(`profile-${user}`)
}
```

## 4. 部分預先渲染 (PPR)
Next.js 16 透過 `next.config.ts` 中的 `cacheComponents` 標籤，使 PPR (Partial Pre-Rendering) 變得穩定。

### 模式：Suspense 邊界
務必將動態的「快取元件」包裹在 `<Suspense>` 中以啟用 PPR。

```tsx
import { Suspense } from 'react'
import { Skeleton } from '@/components/ui/skeleton'

export default function Page() {
  return (
    <main>
      <h1>Static Header</h1>
      <Suspense fallback={<Skeleton />}>
        <DynamicCacheComponent />
      </Suspense>
    </main>
  )
}
```
