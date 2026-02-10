# 專案骨架搭建

> 新專案的目錄結構和核心檔案。

---

## Next.js 全端結構（2025 最佳化）

```
project-name/
├── src/
│   ├── app/                        # 僅路由（薄層）
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── globals.css
│   │   ├── (auth)/                 # 路由群組 — 驗證頁面
│   │   │   ├── login/page.tsx
│   │   │   └── register/page.tsx
│   │   ├── (dashboard)/            # 路由群組 — 儀表板佈局
│   │   │   ├── layout.tsx
│   │   │   └── page.tsx
│   │   └── api/
│   │       └── [resource]/route.ts
│   │
│   ├── features/                   # 基於功能的模組
│   │   ├── auth/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── actions.ts          # Server Actions
│   │   │   ├── queries.ts          # 資料抓取
│   │   │   └── types.ts
│   │   ├── products/
│   │   │   ├── components/
│   │   │   ├── actions.ts
│   │   │   └── queries.ts
│   │   └── cart/
│   │       └── ...
│   │
│   ├── shared/                     # 共享工具
│   │   ├── components/ui/          # 可重用 UI 元件
│   │   ├── lib/                    # 工具、輔助函式
│   │   └── hooks/                  # 全域 hooks
│   │
│   └── server/                     # 僅伺服器端程式碼
│       ├── db/                     # 資料庫客戶端（Prisma）
│       ├── auth/                   # 驗證配置
│       └── services/               # 外部 API 整合
│
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
│
├── public/
├── .env.example
├── .env.local
├── package.json
├── tailwind.config.ts
├── tsconfig.json
└── README.md
```

---

## 結構原則

| 原則 | 實作 |
|------|------|
| **功能隔離** | 每個功能在 `features/` 中有自己的元件、hooks、actions |
| **伺服器/客戶端分離** | 僅伺服器端程式碼在 `server/`，防止意外客戶端引入 |
| **薄路由** | `app/` 僅用於路由，邏輯放在 `features/` |
| **路由群組** | `(groupName)/` 用於共享佈局而不影響 URL |
| **共享程式碼** | `shared/` 用於真正可重用的 UI 和工具 |

---

## 核心檔案

| 檔案 | 用途 |
|------|------|
| `package.json` | 依賴 |
| `tsconfig.json` | TypeScript + 路徑別名（`@/features/*`）|
| `tailwind.config.ts` | Tailwind 配置 |
| `.env.example` | 環境變數範本 |
| `README.md` | 專案文件 |
| `.gitignore` | Git 忽略規則 |
| `prisma/schema.prisma` | 資料庫 schema |

---

## 路徑別名（tsconfig.json）

```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@/features/*": ["./src/features/*"],
      "@/shared/*": ["./src/shared/*"],
      "@/server/*": ["./src/server/*"]
    }
  }
}
```

---

## 何時用什麼

| 需求 | 位置 |
|------|------|
| 新頁面/路由 | `app/(group)/page.tsx` |
| 功能元件 | `features/[name]/components/` |
| Server action | `features/[name]/actions.ts` |
| 資料抓取 | `features/[name]/queries.ts` |
| 可重用按鈕/輸入 | `shared/components/ui/` |
| 資料庫查詢 | `server/db/` |
| 外部 API 呼叫 | `server/services/` |
