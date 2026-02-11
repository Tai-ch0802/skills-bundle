---
description: 從其他 GitHub repo 引入 skills 至 skills-bundle，包含技能複製、翻譯、安裝器更新、文件更新、及建立自動同步 GitHub Action
---

# 從其他 Repo 引入 Skills

本工作流程描述如何將外部 GitHub repository 中的 skills 整合至 `skills-bundle` 專案。

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
- [ ] 確認 skill 目錄的位置（根目錄 or 子目錄如 `skills/`）
- [ ] 閱讀每個 skill 的 `SKILL.md`，理解其用途
- [ ] 確認是否有 skill 已存在於本地（避免重複或衝突）

> [!IMPORTANT]
> 不同 repo 的目錄結構可能不同。例如：
> - `vudovn/antigravity-kit`：skill 在根目錄 `<name>/`
> - `google-gemini/gemini-skills`：skill 在 `skills/<name>/`
>
> 記錄此路徑映射關係，後續 GitHub Action 會用到。

### 2. 複製 Skill 檔案至本地

將 skill 目錄複製到本地 repo 的根目錄：

```bash
cp -r /tmp/upstream-skills/<path-to-skill>/<skill-name> ./<skill-name>
```

若上游有多個 skills，重複執行或批次複製：

```bash
for skill in skill-a skill-b skill-c; do
  cp -r /tmp/upstream-skills/skills/${skill} ./${skill}
done
```

驗證複製結果：

// turbo
```bash
diff -r /tmp/upstream-skills/<path-to-skill>/<skill-name> ./<skill-name>
```

### 3. 建立 zh-TW 翻譯

為每個新 skill 建立繁體中文翻譯：

```
i18n/zh-TW/<skill-name>/SKILL.md
```

翻譯規則：
- 保留 YAML frontmatter 結構（`name` 不翻譯，`description` 翻譯為中文）
- 保留所有程式碼範例（僅翻譯註解與字串值中的 prompt 文字）
- 保留所有 URL 連結不變
- 使用繁體中文專業術語（如 函式呼叫、結構化輸出、多模態 等）

### 4. 更新 `bin/install.mjs`

需要修改 4 個區塊（皆依字母順序插入）：

#### 4a. `SKILLS` 陣列

在 `SKILLS` 陣列中按字母順序加入新 skill：

```javascript
const SKILLS = [
  // ...existing...
  '<new-skill>',
  // ...existing...
];
```

#### 4b. `DEPENDENCIES` 物件

加入新 skill 的相依性（無相依則為空陣列）：

```javascript
const DEPENDENCIES = {
  // ...existing...
  '<new-skill>': [],
  // ...existing...
};
```

#### 4c. 英文 `skillDescriptions`

在 `LANGUAGES.en.messages.skillDescriptions` 加入英文描述：

```javascript
'<new-skill>': 'Brief English description of the skill',
```

#### 4d. 繁中 `skillDescriptions`

在 `LANGUAGES['zh-TW'].messages.skillDescriptions` 加入繁中描述：

```javascript
'<new-skill>': '技能的簡短繁體中文描述',
```

### 5. 更新 `package.json`

在 `files` 陣列中按字母順序加入新 skill 目錄：

```json
{
  "files": [
    "...",
    "<new-skill>/",
    "..."
  ]
}
```

### 6. 更新 `README.md`

需要修改 4 個區塊：

#### 6a. Skill Sources 表格

新增一行來源（若為全新來源）：

```markdown
| **[repo-name](https://github.com/org/repo)** | `skill-a`, `skill-b` | [@author](https://github.com/author) |
```

#### 6b. Available Skills 數量

更新標題中的技能總數：

```markdown
## Available Skills (N)  <!-- 原數 + 新增數 -->
```

#### 6c. 技能列表區塊

新增對應區塊或在既有區塊中加入條目：

```markdown
### <Source Name> Skills (from [org/repo](https://github.com/org/repo))

| Skill | Description |
|-------|-------------|
| **[skill-name](./skill-name/SKILL.md)** | Description |
```

#### 6d. Credits 區塊

新增致謝：

```markdown
- **<Source Name> Skills** — From [org/repo](https://github.com/org/repo) by [@author](https://github.com/author)
```

### 7. 更新 `GEMINI.md`

在 "Currently available skill packs" 清單中加入新來源：

```markdown
- **<Pack Name>**: `skill-a/`, `skill-b/`
```

### 8. 建立 GitHub Action 同步 Workflow

在 `.github/workflows/` 建立新的 workflow 檔案：

**命名規則**: `sync-upstream-for-<org>-<repo>.yml`

參考既有的 `sync-upstream-for-vudovn-antigravity-kit.yml`，建立新的 workflow，關鍵差異點：

| 設定項 | 說明 |
|--------|------|
| `UPSTREAM_REPO` | 設定為上游的 `org/repo` |
| **路徑映射** | 在 Jules prompt 中明確說明上游 skill 路徑與本地路徑的映射 |
| **Skills 清單** | 列出所有來自此上游的 skill 名稱 |
| **保護清單** | 列出所有 **不來自** 此上游的 skill（包含其他上游的 skills） |

> [!IMPORTANT]
> Jules prompt 中的「保護清單」必須包含所有非此上游來源的 skills，
> 避免 Jules 意外修改到其他來源的技能。可從 `bin/install.mjs` 的 `SKILLS` 陣列推導。

Workflow 結構（兩階段）：
1. **Phase 1: Detect** — 用 GitHub API 偵測上游近 24 小時的 commits 和 merged PRs
2. **Phase 2: Jules** — 若有變更，呼叫 `google-labs-code/jules-action@v1.0.0` 同步

### 9. 驗證

// turbo
```bash
# 確認新 skill 檔案存在
ls -la <skill-name>/SKILL.md i18n/zh-TW/<skill-name>/SKILL.md

# 確認 install.mjs 包含新 skill
grep '<skill-name>' bin/install.mjs

# 確認 package.json 包含新 skill
grep '<skill-name>' package.json

# 確認 README.md 包含新 skill
grep '<skill-name>' README.md

# 確認 workflow YAML 語法有效
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/sync-upstream-for-<org>-<repo>.yml')); print('✅ YAML valid')" \
  || node -e "require('yaml').parse(require('fs').readFileSync('.github/workflows/sync-upstream-for-<org>-<repo>.yml','utf8')); console.log('✅ YAML valid')"
```

### 10. Commit 並推送

```bash
git add -A
git commit -m "feat: integrate <skill-names> from <org>/<repo>

- Add <skill-name> skill(s)
- Add zh-TW translation(s)
- Add GitHub Action workflow for upstream sync
- Update bin/install.mjs, package.json, README.md, GEMINI.md"
```

## 清單速覽

| # | 項目 | 涉及檔案 |
|---|------|----------|
| 1 | 研究上游結構 | (讀取) |
| 2 | 複製 skill 檔案 | `<skill>/SKILL.md` |
| 3 | 建立 zh-TW 翻譯 | `i18n/zh-TW/<skill>/SKILL.md` |
| 4 | 更新安裝器 | `bin/install.mjs` |
| 5 | 更新套件設定 | `package.json` |
| 6 | 更新 README | `README.md` |
| 7 | 更新 GEMINI.md | `GEMINI.md` |
| 8 | 建立同步 Action | `.github/workflows/sync-upstream-for-*.yml` |
| 9 | 驗證 | (指令) |
| 10 | Commit | (git) |
