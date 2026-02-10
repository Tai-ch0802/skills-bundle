# 資料庫選擇（2025）

> 根據情境選擇資料庫，而非預設。

## 決策樹

```
你的需求是什麼？
│
├── 需要完整關聯功能
│   ├── 自架 → PostgreSQL
│   └── 無伺服器 → Neon、Supabase
│
├── Edge 部署 / 超低延遲
│   └── Turso（edge SQLite）
│
├── AI / 向量搜尋
│   └── PostgreSQL + pgvector
│
├── 簡單 / 嵌入式 / 本地
│   └── SQLite
│
└── 全球分佈
    └── PlanetScale、CockroachDB、Turso
```

## 比較

| 資料庫 | 最適合 | 權衡 |
|--------|--------|------|
| **PostgreSQL** | 完整功能、複雜查詢 | 需要託管 |
| **Neon** | 無伺服器 PG、分支 | PG 複雜度 |
| **Turso** | Edge、低延遲 | SQLite 限制 |
| **SQLite** | 簡單、嵌入式、本地 | 單寫入者 |
| **PlanetScale** | MySQL、全球規模 | 無外鍵 |

## 要問的問題

1. 部署環境是什麼？
2. 查詢多複雜？
3. Edge/無伺服器重要嗎？
4. 需要向量搜尋嗎？
5. 需要全球分佈嗎？
