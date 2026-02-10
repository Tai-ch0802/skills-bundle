---
name: architecture
description: 架構決策框架。需求分析、權衡評估、ADR 文件。用於做架構決策或分析系統設計。
allowed-tools: Read, Glob, Grep
---

# 架構決策框架

> 「需求驅動架構。權衡決定決策。ADR 捕捉理由。」

## 🎯 選擇性閱讀規則

**僅閱讀與需求相關的檔案！** 查看內容地圖，找到你需要的。

| 檔案 | 描述 | 何時閱讀 |
|------|------|----------|
| `context-discovery.md` | 要問的問題、專案分類 | 開始架構設計 |
| `trade-off-analysis.md` | ADR 範本、權衡框架 | 記錄決策 |
| `pattern-selection.md` | 決策樹、反模式 | 選擇模式 |
| `examples.md` | MVP、SaaS、企業範例 | 參考實作 |
| `patterns-reference.md` | 模式快速查詢 | 模式比較 |

---

## 🔗 相關技能

| 技能 | 用途 |
|------|------|
| `@[skills/database-design]` | 資料庫 Schema 設計 |
| `@[skills/api-patterns]` | API 設計模式 |
| `@[skills/deployment-procedures]` | 部署架構 |

---

## 核心原則

**「簡約是終極的優雅。」**

- 從簡單開始
- 僅在證明必要時才增加複雜度
- 你隨時可以稍後加入模式
- 移除複雜度比加入複雜度困難得多

---

## 驗證檢查清單

在確定架構前：

- [ ] 需求已清楚理解
- [ ] 已識別限制條件
- [ ] 每個決策都有權衡分析
- [ ] 已考慮更簡單的替代方案
- [ ] 已為重大決策撰寫 ADR
- [ ] 團隊專長與所選模式匹配
