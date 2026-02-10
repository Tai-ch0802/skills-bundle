---
name: parallel-agents
description: 多代理協調模式。當多個獨立任務可使用不同領域專長並行執行，或全面分析需要多角度觀點時使用。
allowed-tools: Read, Glob, Grep
---

# 原生平行代理

> 透過 Antigravity 內建代理工具進行協調

## 概覽

此技能透過 Antigravity 的原生代理系統協調多個專家代理。不同於外部腳本，此方法將所有協調保持在 Antigravity 的控制範圍內。

## 何時使用協調

✅ **適合：**
- 需要多個專長領域的複雜任務
- 從安全、效能和品質角度分析程式碼
- 全面審查（架構 + 安全 + 測試）
- 需要後端 + 前端 + 資料庫工作的功能實作

❌ **不適合：**
- 簡單的單一領域任務
- 快速修復或小變更
- 一個代理就足夠的任務

---

## 原生代理調用

### 單一代理
```
使用 security-auditor 代理審查驗證
```

### 循序鏈
```
首先，使用 explorer-agent 發現專案結構。
然後，使用 backend-specialist 審查 API 端點。
最後，使用 test-engineer 識別測試缺口。
```

### 帶情境傳遞
```
使用 frontend-specialist 分析 React 元件。
根據這些發現，讓 test-engineer 生成元件測試。
```

### 恢復先前工作
```
恢復代理 [agentId] 並繼續附加需求。
```

---

## 協調模式

### 模式 1：全面分析
```
代理：explorer-agent → [領域代理] → 綜合
1. explorer-agent：對應程式碼庫結構
2. security-auditor：安全態勢
3. backend-specialist：API 品質
4. frontend-specialist：UI/UX 模式
5. test-engineer：測試覆蓋率
6. 綜合所有發現
```

### 模式 2：功能審查
```
代理：受影響領域代理 → test-engineer
1. 識別受影響的領域（後端？前端？兩者？）
2. 調用相關領域代理
3. test-engineer 驗證變更
4. 綜合建議
```

### 模式 3：安全稽核
```
代理：security-auditor → penetration-tester → 綜合
1. security-auditor：設定和程式碼審查
2. penetration-tester：主動弱點測試
3. 以優先順序的修復建議進行綜合
```

---

## 可用代理

| 代理 | 專長 | 觸發片語 |
|------|------|----------|
| `orchestrator` | 協調 | 「全面」、「多角度」 |
| `security-auditor` | 安全 | 「安全」、「驗證」、「弱點」 |
| `penetration-tester` | 安全測試 | 「滲透測試」、「紅隊」、「利用」 |
| `backend-specialist` | 後端 | 「API」、「伺服器」、「Node.js」、「Express」 |
| `frontend-specialist` | 前端 | 「React」、「UI」、「元件」、「Next.js」 |
| `test-engineer` | 測試 | 「測試」、「覆蓋率」、「TDD」 |
| `devops-engineer` | DevOps | 「部署」、「CI/CD」、「基礎設施」 |
| `database-architect` | 資料庫 | 「schema」、「Prisma」、「遷移」 |
| `mobile-developer` | 行動 | 「React Native」、「Flutter」、「行動」 |
| `api-designer` | API 設計 | 「REST」、「GraphQL」、「OpenAPI」 |
| `debugger` | 除錯 | 「bug」、「錯誤」、「無法運作」 |
| `explorer-agent` | 發現 | 「探索」、「對應」、「結構」 |
| `documentation-writer` | 文件 | 「寫文件」、「建立 README」、「生成 API 文件」 |
| `performance-optimizer` | 效能 | 「慢」、「最佳化」、「分析」 |
| `project-planner` | 規劃 | 「計畫」、「路線圖」、「里程碑」 |
| `seo-specialist` | SEO | 「SEO」、「meta 標籤」、「搜尋排名」 |
| `game-developer` | 遊戲開發 | 「遊戲」、「Unity」、「Godot」、「Phaser」 |

---

## Antigravity 內建代理

這些與自訂代理並行運作：

| 代理 | 模型 | 用途 |
|------|------|------|
| **Explore** | Haiku | 快速唯讀程式碼庫搜尋 |
| **Plan** | Sonnet | 計畫模式中的研究 |
| **General-purpose** | Sonnet | 複雜多步驟修改 |

使用 **Explore** 進行快速搜尋，**自訂代理** 提供領域專長。

---

## 綜合協議

所有代理完成後，進行綜合：

```markdown
## 協調綜合

### 任務摘要
[完成了什麼]

### 代理貢獻
| 代理 | 發現 |
|------|------|
| security-auditor | 發現 X |
| backend-specialist | 識別 Y |

### 合併建議
1. **關鍵**：[來自代理 A 的問題]
2. **重要**：[來自代理 B 的問題]
3. **錦上添花**：[來自代理 C 的增強]

### 行動項目
- [ ] 修復關鍵安全問題
- [ ] 重構 API 端點
- [ ] 新增缺少的測試
```

---

## 最佳實踐

1. **可用代理** — 17 個專家代理可供協調
2. **邏輯順序** — 發現 → 分析 → 實作 → 測試
3. **分享情境** — 將相關發現傳遞給後續代理
4. **單一綜合** — 一份統一報告，而非分散的輸出
5. **驗證變更** — 程式碼修改時始終包含 test-engineer

---

## 主要好處

- ✅ **單一會話** — 所有代理共享情境
- ✅ **AI 控制** — Claude 自主協調
- ✅ **原生整合** — 與內建 Explore、Plan 代理配合
- ✅ **恢復支援** — 可以繼續先前的代理工作
- ✅ **情境傳遞** — 發現在代理間流動
