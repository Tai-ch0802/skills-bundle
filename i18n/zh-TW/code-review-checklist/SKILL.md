---
name: code-review-checklist
description: 程式碼審查指南，涵蓋品質、安全性與最佳實踐。
allowed-tools: Read, Glob, Grep
---

# 程式碼審查檢查清單

## 快速審查檢查清單

### 正確性
- [ ] 程式碼做了它應該做的事
- [ ] 邊界情況已處理
- [ ] 錯誤處理已就位
- [ ] 沒有明顯的 bug

### 安全性
- [ ] 輸入已驗證和清理
- [ ] 沒有 SQL/NoSQL 注入弱點
- [ ] 沒有 XSS 或 CSRF 弱點
- [ ] 沒有寫死的密鑰或敏感憑證
- [ ] **AI 特定：** 防禦 Prompt 注入（如適用）
- [ ] **AI 特定：** 輸出在用於關鍵接收端前已清理

### 效能
- [ ] 沒有 N+1 查詢
- [ ] 沒有不必要的迴圈
- [ ] 適當的快取
- [ ] 已考慮打包大小影響

### 程式碼品質
- [ ] 清楚的命名
- [ ] DRY — 沒有重複程式碼
- [ ] 遵循 SOLID 原則
- [ ] 適當的抽象層次

### 測試
- [ ] 新程式碼有單元測試
- [ ] 邊界情況已測試
- [ ] 測試可讀且易維護

### 文件
- [ ] 複雜邏輯已加註解
- [ ] 公開 API 已文件化
- [ ] 如需要已更新 README

## AI & LLM 審查模式（2025）

### 邏輯 & 幻覺
- [ ] **思維鏈：** 邏輯是否遵循可驗證的路徑？
- [ ] **邊界情況：** AI 是否考慮了空狀態、逾時和部分失敗？
- [ ] **外部狀態：** 程式碼對檔案系統或網路的假設是否安全？

### Prompt 工程審查
```markdown
// ❌ 程式碼中模糊的 prompt
const response = await ai.generate(userInput);

// ✅ 結構化且安全的 prompt
const response = await ai.generate({
  system: "You are a specialized parser...",
  input: sanitize(userInput),
  schema: ResponseSchema
});
```

## 要標記的反模式

```typescript
// ❌ 魔法數字
if (status === 3) { ... }

// ✅ 命名常數
if (status === Status.ACTIVE) { ... }

// ❌ 深層巢狀
if (a) { if (b) { if (c) { ... } } }

// ✅ 提前返回
if (!a) return;
if (!b) return;
if (!c) return;
// 執行工作

// ❌ 長函式（100+ 行）
// ✅ 小巧、專注的函式

// ❌ any 型別
const data: any = ...

// ✅ 正確的型別
const data: UserData = ...
```

## 審查評論指南

```
// 阻塞問題使用 🔴
🔴 阻塞：此處有 SQL 注入弱點

// 重要建議使用 🟡
🟡 建議：考慮使用 useMemo 提升效能

// 小問題使用 🟢
🟢 小問題：不可變變數偏好使用 const 而非 let

// 問題使用 ❓
❓ 問題：如果 user 為 null，這裡會怎樣？
```
