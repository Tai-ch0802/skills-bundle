---
name: lint-and-validate
description: 自動品質控制、Lint 與靜態分析程序。每次程式碼修改後使用，確保語法正確性和專案標準。觸發關鍵字：lint、format、check、validate、types、static analysis。
allowed-tools: Read, Glob, Grep, Bash
---

# Lint 與驗證技能

> **必要：** 每次程式碼變更後執行適當的驗證工具。在程式碼無錯誤之前不要完成任務。

### 各生態系程序

#### Node.js / TypeScript
1. **Lint/修復：** `npm run lint` 或 `npx eslint "path" --fix`
2. **型別：** `npx tsc --noEmit`
3. **安全：** `npm audit --audit-level=high`

#### Python
1. **Linter (Ruff)：** `ruff check "path" --fix`（快速且現代）
2. **安全 (Bandit)：** `bandit -r "path" -ll`
3. **型別 (MyPy)：** `mypy "path"`

## 品質迴圈
1. **撰寫/編輯程式碼**
2. **執行稽核：** `npm run lint && npx tsc --noEmit`
3. **分析報告：** 檢查「最終稽核報告」區塊。
4. **修復並重複：** 提交帶有「最終稽核」失敗的程式碼是不允許的。

## 錯誤處理
- 如果 `lint` 失敗：立即修復樣式或語法問題。
- 如果 `tsc` 失敗：在繼續之前修正型別不匹配。
- 如果沒有工具配置：檢查專案根目錄是否有 `.eslintrc`、`tsconfig.json`、`pyproject.toml` 並建議建立一個。

---
**嚴格規則：** 未通過這些檢查的程式碼不應被提交或報告為「完成」。

---

## 腳本

| 腳本 | 用途 | 指令 |
|------|------|------|
| `scripts/lint_runner.py` | 統一 lint 檢查 | `python scripts/lint_runner.py <project_path>` |
| `scripts/type_coverage.py` | 型別覆蓋率分析 | `python scripts/type_coverage.py <project_path>` |
