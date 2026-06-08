---
name: database-design
description: 資料庫設計原則與決策。Schema 設計、索引策略、ORM 選擇、無伺服器資料庫。
allowed-tools: Read, Write, Edit, Glob, Grep
---

# 資料庫設計

> **學習思考方式，而非複製 SQL 模式。**

## 🎯 選擇性閱讀規則

**僅閱讀與請求相關的檔案！** 查看內容地圖，找到你需要的。

| 檔案 | 描述 | 何時閱讀 |
|------|------|----------|
| `database-selection.md` | PostgreSQL vs Neon vs Turso vs SQLite | 選擇資料庫 |
| `orm-selection.md` | Drizzle vs Prisma vs Kysely | 選擇 ORM |
| `schema-design.md` | 正規化、PK、關聯 | 設計 schema |
| `indexing.md` | 索引類型、複合索引 | 效能調優 |
| `optimization.md` | N+1、EXPLAIN ANALYZE | 查詢最佳化 |
| `migrations.md` | 安全遷移、無伺服器 DB | Schema 變更 |

---

## ⚠️ 核心原則

- 不明確時詢問使用者資料庫偏好
- 根據情境選擇資料庫/ORM
- 不要什麼都預設 PostgreSQL

---

## 決策檢查清單

設計 schema 前：

- [ ] 詢問使用者資料庫偏好了嗎？
- [ ] 為此情境選擇了資料庫？
- [ ] 考慮了部署環境？
- [ ] 規劃了索引策略？
- [ ] 定義了關聯類型？

---

## 反模式

❌ 簡單應用預設 PostgreSQL（SQLite 可能就夠了）
❌ 跳過索引
❌ 生產環境使用 SELECT *
❌ 結構化資料更好時卻儲存 JSON
❌ 忽略 N+1 查詢
