---
description: 從其他 GitHub repo 引入 skills 至 skills-bundle，包含翻譯建立、安裝器設定更新、文件更新、及建立自動同步 GitHub Action (遠端下載架構)
---

# 從其他 Repo 引入 Skills

本工作流程描述如何將外部 GitHub repository 中的 skills 整合至 `skills-bundle` 專案。因本專案採用 **遠端下載架構**，我們不再將完整的 skill 目錄複製到本地，而是更新安裝器配置讓用戶安裝時動態下載，本地僅需維護繁體中文翻譯與 Action workflow。

## 前置準備

- [ ] 確認上游 repo 的 URL（例如 `https://github.com/org/repo`）
- [ ] 確認上游 repo 的授權相容性（MIT / Apache-2.0 等）
- [ ] 確認本地 repo 工作區乾淨（`git status` 無未提交變更）

## 步驟

### 1. 研究上游 Repo 結構

Clone 上游 repo 至暫存目錄並分析其結構：

// turbo
```bash
rm -rf /tmp/upstream-skills && git clone --depth 1 <UPSTREAM_URL> /tmp/upstream-skills
```

分析重點：
- [ ] 列出所有 skill 目錄及其內容（`ls -la /tmp/upstream-skills/`）
- [ ] 確認 skill 目錄的位置（是在根目錄還是子目錄如 `skills/`？）
- [ ] 閱讀每個 skill 的 `SKILL.md`，理解其用途
- [ ] 確認是否有 skill 衝突（同名）

> [!IMPORTANT]
> 記錄 skill 的路徑映射關係（例如 `vudovn/antigravity-kit` 是根目錄，而 `anthropics/skills` 是在 `skills/` 底下）。後續設定 `install.mjs` 以及 GitHub Action 都會用到這條路徑。

### 2. 建立 zh-TW 翻譯

> [!WARNING]
> 本專案為遠端下載架構：來自 GitHub 的 skills **不** 放入本地根目錄。僅需在本地保留 `i18n/zh-TW/` 的翻譯檔與安裝器的 metadata。

為每個新 skill 建立繁體中文翻譯目錄，並複製原版的 `SKILL.md` 來進行翻譯：

```bash
mkdir -p i18n/zh-TW/<skill-name>
cp /tmp/upstream-skills/<path-to-skill>/<skill-name>/SKILL.md i18n/zh-TW/<skill-name>/
```

若上游有多個 skills，可批次處理：

```bash
for skill in skill-a skill-b skill-c; do
  mkdir -p i18n/zh-TW/${skill}
  cp /tmp/upstream-skills/skills/${skill}/SKILL.md i18n/zh-TW/${skill}/
done
```

翻譯規則：
- 保留 YAML frontmatter 結構（`name` 不翻譯，`description` 翻譯為中文）
- 保留所有程式碼範例與指令（僅翻譯註解與字串）
- 保留所有 URL 連結與 Markdown 格式不變
- 使用繁體中文的開發術語（如：函式呼叫、結構化輸出、多模態等）

### 3. 更新 `bin/install.mjs`

需要在安裝器中修改 5 個區塊：

#### 3a. `SKILLS` 陣列
在 `SKILLS` 陣列中按字母順序加入新 skill 的識別名：
```javascript
const SKILLS = [
  // ...existing...
  '<new-skill>',
];
```

#### 3b. `DEPENDENCIES` 物件
加入新 skill 的相依性（無相依則為空陣列）：
```javascript
const DEPENDENCIES = {
  // ...existing...
  '<new-skill>': [],
};
```

#### 3c. `REMOTE_SKILLS` 配置
在對應的 upstream repo 區塊下（或新增一個註解區塊）加入：
```javascript
const REMOTE_SKILLS = {
  // ...
  '<new-skill>': { repo: '<org>/<repo>', path: '<path-to-skill>/<new-skill>', branch: 'main' },
};
```

#### 3d. 英文 `skillDescriptions`
在 `LANGUAGES.en.messages.skillDescriptions` 加入英文描述：
```javascript
'<new-skill>': 'Brief English description of the skill',
```

#### 3e. 繁中 `skillDescriptions`
在 `LANGUAGES['zh-TW'].messages.skillDescriptions` 加入繁中描述：
```javascript
'<new-skill>': '技能的簡短繁體中文描述',
```

### 4. 更新 `README.md`

需要修改 4 個區塊：

#### 4a. Skill Sources 表格
新增一行來源（若為全新來源）：
```markdown
| **[repo-name](https://github.com/org/repo)** | `skill-a`, `skill-b` | [@author](https://github.com/author) |
```

#### 4b. Available Skills 數量
更新標題中的技能總數。

#### 4c. 技能列表區塊
新增對應區塊或在既有區塊中加入條目（遠端載入需使用 ⚡ 標記、並且不用建立 local file 連結）：
```markdown
### <Source Name> Skills ⚡ (from [org/repo](https://github.com/org/repo))

<details>
<summary>Click to expand skills (remote-downloaded at install time)</summary>

| Skill | Description |
|-------|-------------|
| **skill-name** | Description text goes here |

</details>
```

#### 4d. Credits 區塊
新增致謝：
```markdown
- **<Source Name> Skills** — From [org/repo](https://github.com/org/repo) by [@author](https://github.com/author)
```

### 5. 更新 `GEMINI.md`

更新技能總數，並在 "Skill Categories" 清單中加入新來源或更新 count/examples。

### 6. 建立 GitHub Action 同步 Workflow

在 `.github/workflows/` 建立新的 workflow 檔案：

**命名規則**: `sync-upstream-for-<org>-<repo>.yml`

參考既有的 `sync-upstream-for-vudovn-antigravity-kit.yml`，建立新 workflow。

> [!IMPORTANT]
> 必須在 Jules prompt 內明確給出指示：
> **此專案採遠端下載架構，不可把上游 skill 目錄複製到本地！**
> Jules 只需要負責：更新 metadata（`install.mjs` 中的描述與 `REMOTE_SKILLS` 等）、維護 `i18n/zh-TW/` 下的翻譯、更新 `README.md`。
> 並且記得放入「只處理該上游技能，不可修改其他來源技能的保護性聲明」。

### 7. 驗證

// turbo
```bash
# 確認新翻譯檔案存在
ls -la i18n/zh-TW/<skill-name>/SKILL.md

# 確認 install.mjs 包含新 skill 的 metadata
grep '<skill-name>' bin/install.mjs

# 確認 README.md 包含新 skill
grep '<skill-name>' README.md
```

### 8. Commit 並推送

```bash
git add -A
git commit -m "feat: integrate <skill-names> from <org>/<repo>

- Add translation for <skill-names>
- Update remote download configurations in install.mjs
- Add GitHub Action workflow for upstream metadata sync
- Update README.md and GEMINI.md"
```

## 清單速覽

| # | 項目 | 涉及檔案 |
|---|------|----------|
| 1 | 研究上游結構 | (讀取) |
| 2 | 建立 zh-TW 翻譯 | `i18n/zh-TW/<skill>/SKILL.md` |
| 3 | 更新安裝器與設定 | `bin/install.mjs` |
| 4 | 更新 README | `README.md` |
| 5 | 更新 GEMINI.md | `GEMINI.md` |
| 6 | 建立同步 Action | `.github/workflows/sync-upstream-for-*.yml` |
| 7 | 驗證 | (指令) |
| 8 | Commit | (git) |
