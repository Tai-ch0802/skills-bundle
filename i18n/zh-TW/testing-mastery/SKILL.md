---
name: testing-mastery
description: 統一測試技能 — TDD 工作流程、單元/整合測試模式、E2E/Playwright 策略。取代 tdd-workflow + testing-patterns + webapp-testing。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
version: 1.0
priority: HIGH
---

# 測試精通 — 統一測試技能

> 撰寫能**記錄意圖**、捕捉回歸錯誤且快速執行的測試。針對不同情境選擇正確的策略。

---

## 決策樹：該用哪種測試策略？

```
這是新功能嗎？
├─ 是 → 使用 TDD（參見 references/tdd-cycle.md）
│        撰寫失敗測試 → 最小化程式碼 → 重構
└─ 否
   ├─ 這是 Bug 修復嗎？
   │  └─ 是 → 先撰寫回歸測試，再修復
   ├─ 這是關鍵使用者流程（登入、結帳）嗎？
   │  └─ 是 → E2E 測試（參見 references/e2e-playwright.md）
   └─ 這是商業邏輯 / 資料轉換嗎？
      └─ 是 → 單元 + 整合測試（參見 references/unit-integration.md）
```

---

## 測試金字塔

```
        /\          E2E（少量，~10%）
       /  \         僅限關鍵使用者流程
      /----\
     /      \       整合測試（適量，~20%）
    /--------\      API、資料庫、服務契約
   /          \
  /------------\    單元測試（大量，~70%）
                    函式、類別、工具
```

---

## 核心原則

| 原則 | 規則 |
|------|------|
| **AAA** | 佈置（Arrange）→ 執行（Act）→ 斷言（Assert） |
| **快速** | 單元測試 < 100ms，整合測試 < 1s |
| **隔離** | 測試之間沒有相依性 |
| **行為** | 測試「做什麼」，而非「怎麼做」 |
| **最小化** | 每個測試一個斷言（理想情況） |

---

## 快速參考

| 我需要... | 使用 | 參考 |
|-----------|------|------|
| 以測試優先的方式建構功能 | TDD（RED-GREEN-REFACTOR） | [tdd-cycle.md](references/tdd-cycle.md) |
| 撰寫單元/整合測試 | Mocking、資料策略、模式 | [unit-integration.md](references/unit-integration.md) |
| 在瀏覽器中測試關鍵使用者流程 | E2E + Playwright | [e2e-playwright.md](references/e2e-playwright.md) |

---

## 反模式（通用）

| ❌ 不要 | ✅ 應該 |
|---------|---------|
| 測試實作細節 | 測試可觀察的行為 |
| 出貨後才寫測試 | 在開發前/中撰寫測試 |
| 複製測試程式碼 | 使用工廠與固定資料 |
| 複雜的測試設定 | 簡化或拆分 |
| 忽略不穩定測試 | 修復根本原因 |
| 跳過清理 | 在 teardown 中重設狀態 |
| 每個測試多個斷言 | 每個測試一個行為 |

---

## 🔧 執行腳本

| 腳本 | 用途 | 指令 |
|------|------|------|
| `scripts/test_runner.py` | 統一測試執行 | `python scripts/test_runner.py <project_path>` |
| `scripts/playwright_runner.py` | 瀏覽器 E2E 測試 | `python scripts/playwright_runner.py <url>` |
| | 附帶截圖 | `python scripts/playwright_runner.py <url> --screenshot` |
| | 無障礙檢查 | `python scripts/playwright_runner.py <url> --a11y` |

---

> **記住：** 測試就是規格。如果你寫不出測試，那代表你不了解需求。
