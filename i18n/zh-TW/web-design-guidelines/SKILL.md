---
name: web-design-guidelines
description: 審查 UI 程式碼是否符合 Web 介面指南。當被要求「審查我的 UI」、「檢查無障礙功能」、「審核設計」、「審查 UX」或「檢查我的網站是否符合最佳實踐」時使用。
when_to_use: "當審核 Web UI 的最佳實踐、檢查無障礙功能或根據 Web 介面指南審查設計時。"
metadata:
  author: vercel
  version: "1.0.0"
  argument-hint: <file-or-pattern>
---

# Web 介面指南

審查檔案是否符合 Web 介面指南。

## 工作原理

1. 從下方來源 URL 獲取最新的指南
2. 讀取指定的檔案（或提示使用者輸入檔案/模式）
3. 根據獲取的指南中的所有規則進行檢查
4. 以簡潔的 `file:line` 格式輸出發現的問題

## 指南來源

在每次審查之前獲取最新的指南：

```
https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
```

使用 WebFetch 獲取最新規則。獲取的內容包含所有規則和輸出格式說明。

## 使用方式

當使用者提供檔案或模式參數時：

1. 從上方來源 URL 獲取指南
2. 讀取指定的檔案
3. 應用獲取指南中的所有規則
4. 使用指南中指定的格式輸出發現的問題

如果沒有指定檔案，詢問使用者要審查哪些檔案。

## 相關技能

| 技能 | 使用時機 |
|-------|-------------|
| **[frontend-design](../frontend-design/SKILL.md)** | 編碼前 - 學習設計原則（色彩、排版、UX 心理學） |
| **web-design-guidelines** (此技能) | 編碼後 - 審核無障礙功能、效能和最佳實踐 |

## 設計工作流程

```
1. 設計   → 閱讀 frontend-design 原則
2. 編碼   → 實作設計
3. 審核   → 執行 web-design-guidelines 審查 ← 你在這裡
4. 修復   → 解決審查中發現的問題
```
