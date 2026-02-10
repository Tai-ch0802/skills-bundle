# ORM 選擇（2025）

> 根據部署和開發體驗需求選擇 ORM。

## 決策樹

```
情境是什麼？
│
├── Edge 部署 / 打包大小很重要
│   └── Drizzle（最小、類 SQL）
│
├── 最佳 DX / Schema 優先
│   └── Prisma（遷移、studio）
│
├── 最大控制
│   └── 原始 SQL 搭配查詢建構器
│
└── Python 生態系
    └── SQLAlchemy 2.0（async 支援）
```

## 比較

| ORM | 最適合 | 權衡 |
|-----|--------|------|
| **Drizzle** | Edge、TypeScript | 較新、範例較少 |
| **Prisma** | DX、schema 管理 | 較重、非 edge-ready |
| **Kysely** | 型別安全 SQL 建構器 | 手動遷移 |
| **原始 SQL** | 複雜查詢、控制 | 手動型別安全 |
