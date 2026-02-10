---
name: web-design-guidelines
description: 審查 UI 程式碼是否符合 Web Interface Guidelines。用於「審查我的 UI」、「檢查無障礙」、「稽核設計」、「審查 UX」或「檢查最佳實踐」。
metadata:
  author: vercel
  version: "1.0.0"
  argument-hint: <file-or-pattern>
---

# Web Interface Guidelines

審查檔案是否符合 Web Interface Guidelines。

## 運作方式

1. 從下方來源 URL 抓取最新指南
2. 閱讀指定檔案（或提示使用者提供檔案/模式）
3. 檢查抓取的指南中的所有規則
4. 以簡潔的 `file:line` 格式輸出結果

## 指南來源

每次審查前抓取最新指南：

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

使用 WebFetch 擷取最新規則。抓取的內容包含所有規則和輸出格式說明。

## 使用方式

當使用者提供檔案或模式參數時：
1. 從上方來源 URL 抓取指南
2. 閱讀指定檔案
3. 應用抓取指南中的所有規則
4. 使用指南中指定的格式輸出結果

如果未指定檔案，詢問使用者要審查哪些檔案。

---

## 相關技能

| 技能 | 適用時機 |
|------|----------|
| **[frontend-design](../frontend-design/SKILL.md)** | 編碼前 — 學習設計原則（色彩、排版、UX 心理）|
| **web-design-guidelines**（本技能）| 編碼後 — 無障礙、效能和最佳實踐稽核 |

## 設計工作流

```
1. 設計   → 閱讀 frontend-design 原則
2. 編碼   → 實作設計
3. 稽核   → 執行 web-design-guidelines 審查 ← 你在這裡
4. 修復   → 處理稽核發現的問題
```
