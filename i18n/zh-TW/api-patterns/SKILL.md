---
name: api-patterns
description: API 設計原則與決策。REST vs GraphQL vs tRPC 選擇、回應格式、版本控制、分頁。
allowed-tools: Read, Write, Edit, Glob, Grep
---

# API 模式

> API 設計原則與 2025 年最佳決策。
> **學習思考方式，而非複製固定模式。**

## 🎯 選擇性閱讀規則

**僅閱讀與需求相關的檔案！** 查看內容地圖，找到你需要的。

---

## 📑 內容地圖

| 檔案 | 描述 | 何時閱讀 |
|------|------|----------|
| `api-style.md` | REST vs GraphQL vs tRPC 決策樹 | 選擇 API 類型 |
| `rest.md` | 資源命名、HTTP 方法、狀態碼 | 設計 REST API |
| `response.md` | 封裝模式、錯誤格式、分頁 | 回應結構 |
| `graphql.md` | Schema 設計、使用時機、安全性 | 考慮 GraphQL |
| `trpc.md` | TypeScript monorepo、型別安全 | TS 全端專案 |
| `versioning.md` | URI/Header/Query 版本控制 | API 演進規劃 |
| `auth.md` | JWT、OAuth、Passkey、API Keys | 驗證模式選擇 |
| `rate-limiting.md` | Token bucket、滑動視窗 | API 保護 |
| `documentation.md` | OpenAPI/Swagger 最佳實踐 | 文件撰寫 |
| `security-testing.md` | OWASP API Top 10、驗證/授權測試 | 安全稽核 |

---

## 🔗 相關技能

| 需求 | 技能 |
|------|------|
| API 實作 | `@[skills/backend-development]` |
| 資料結構 | `@[skills/database-design]` |
| 安全細節 | `@[skills/security-hardening]` |

---

## ✅ 決策檢查清單

設計 API 前：

- [ ] **是否詢問過使用者 API 的消費者？**
- [ ] **是否根據此情境選擇了 API 風格？**（REST/GraphQL/tRPC）
- [ ] **是否定義了一致的回應格式？**
- [ ] **是否規劃了版本控制策略？**
- [ ] **是否考慮了驗證需求？**
- [ ] **是否規劃了速率限制？**
- [ ] **是否定義了文件方法？**

---

## ❌ 反模式

**不要：**
- 所有情況預設使用 REST
- 在 REST 端點中使用動詞（/getUsers）
- 回傳不一致的回應格式
- 將內部錯誤暴露給客戶端
- 跳過速率限制

**要：**
- 根據情境選擇 API 風格
- 詢問客戶端需求
- 撰寫完整文件
- 使用適當的狀態碼

---

## 腳本

| 腳本 | 用途 | 指令 |
|------|------|------|
| `scripts/api_validator.py` | API 端點驗證 | `python scripts/api_validator.py <project_path>` |
