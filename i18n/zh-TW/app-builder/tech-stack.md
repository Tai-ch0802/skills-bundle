# 技術堆疊選擇（2026）

> Web 應用的預設和替代技術選擇。

## 預設堆疊（Web App — 2026）

```yaml
前端:
  框架: Next.js 16 (Stable)
  語言: TypeScript 5.7+
  樣式: Tailwind CSS v4
  狀態: React 19 Actions / Server Components
  打包器: Turbopack (Stable for Dev)

後端:
  執行期: Node.js 23
  框架: Next.js API Routes / Hono (for Edge)
  驗證: Zod / TypeBox

資料庫:
  主要: PostgreSQL
  ORM: Prisma / Drizzle
  託管: Supabase / Neon

驗證:
  提供者: Auth.js (v5) / Clerk

Monorepo:
  工具: Turborepo 2.0
```

## 替代選項

| 需求 | 預設 | 替代 |
|------|------|------|
| 即時通訊 | — | Supabase Realtime、Socket.io |
| 檔案儲存 | — | Cloudinary、S3 |
| 支付 | Stripe | LemonSqueezy、Paddle |
| Email | — | Resend、SendGrid |
| 搜尋 | — | Algolia、Typesense |
