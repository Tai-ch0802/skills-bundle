# 記憶檔案格式參考

`~/.agent-brain/` 中所有記憶檔案的範本與慣例。

## 記憶本體論速查表

決定新資訊該儲存在哪裡時，請參考此表：

| 問題 | 如果是 → | 對應檔案 |
|------|----------|---------|
| 這是關於使用者個人的偏好或習慣？ | **身分 IDENTITY** | `USER.md` |
| 這個事實 30 天後仍然有用？ | **知識 KNOWLEDGE** | `MEMORY.md` |
| 這是「我現在正在處理什麼」？ | **狀態 STATE** | `STATE.md` |
| 值得記錄但以上皆非？ | **經驗 EXPERIENCE** | `sessions/*.md` |

## MEMORY.md 格式

```markdown
# Agent Brain — 長期記憶

> Last updated: YYYY-MM-DD

## Technical Knowledge
- {持久的技術事實、架構決策}
- {API 金鑰位置、伺服器設定、部署模式}

## Projects Overview
| Project | Repo | Status | Key Tech |
|---------|------|--------|----------|
| {name} | {path/url} | Active/Archived | {stack} |

## Cross-Project Patterns
- {跨專案觀察到的模式}

## Environment
- {機器設定、工具版本、路徑}
- {服務帳號、部署目標}

## Important Decisions
- YYYY-MM-DD: {決策及其理由}
```

## USER.md 格式

```markdown
# 使用者檔案

## Identity
- Name: {名稱}
- Timezone: {時區}

## Coding Preferences
- Primary languages: {語言}
- Preferred frameworks: {框架}
- Code style: {慣例}

## Communication Style
- Preferred language: {溝通語言}
- Level of detail: {簡潔/詳細}

## Workflow Habits
- {觀察到的工作流程模式}
- {工具偏好}

## Pet Peeves
- {使用者不喜歡或想避免的事}
```

## STATE.md 格式

STATE.md 是一個**短期便條簿**，用於記錄當前的工作上下文。在 session 期間可自由覆寫，過期（來自前一天的）時會自動歸檔。

**關鍵規則**：
- STATE **永不同步**至 pCloud（臨時性，僅本地）
- STATE **不被索引**到 brain.db
- 持久事實**必須**提升至 MEMORY.md，不可遺留在 STATE 中

```markdown
# Active State

> Updated: YYYY-MM-DD HH:MM

## Current Focus
- {正在處理的主要任務或目標}

## Working Context
- {關鍵變數：活躍分支、目標檔案、PR 編號、錯誤碼}
- {相關專案：[[projects/{name}]]}

## Scratch Pad
- {臨時筆記、中間結論、待確認事項}
- {快速參考：URL、指令片段、設定值}
```

**歸檔格式**（當過期 STATE 被追加到 session 日誌時）：

```markdown
### Archived State
> 從 STATE.md 帶入 (YYYY-MM-DD HH:MM)
- {歸檔的 STATE 內容摘要}
```

## sessions/YYYY-MM-DD.md 格式

```markdown
# Sessions — YYYY-MM-DD

## Session HH:MM:SS — {簡要上下文}
**專案**：[[projects/{name}]]
**工作區**：{repo 路徑或目錄}

### 摘要
{1-3 句話說明完成了什麼}

### 關鍵決策
- {決策及其簡要理由}

### 學習心得
- {新的技術知識或洞察}

### 問題解決
- {問題 → 解決方案}

### 後續步驟
- [ ] {未完成的任務或追蹤事項}

---

## Session HH:MM:SS — {下一個 session}
...
```

## projects/{name}.md 格式

```markdown
# Project: {名稱}

**Repo**: {路徑或 URL}
**Tech Stack**: {語言、框架}
**Status**: Active | Archived

## Context
{專案的簡要描述、用途、架構}

## Key Architecture Decisions
- {決策及其理由}

## Timeline
- YYYY-MM-DD: {發生了什麼} [[sessions/YYYY-MM-DD#session-hhmmss]]
- YYYY-MM-DD: {發生了什麼} [[sessions/YYYY-MM-DD#session-hhmmss]]

## Current State
{專案目前的狀態、活躍分支、待處理工作}

## Known Issues
- {持續性問題或技術債}
```

## 交叉連結語法

使用 `[[path]]` wiki-link 風格進行交叉引用：
- `[[projects/skills-bundle]]` — 連結到專案檔案
- `[[sessions/2026-03-03]]` — 連結到 session 日期
- `[[sessions/2026-03-03#session-143022]]` — 連結到特定 session 條目

這些是人類可讀的參考；代理人透過讀取被引用的檔案來解析它們。
