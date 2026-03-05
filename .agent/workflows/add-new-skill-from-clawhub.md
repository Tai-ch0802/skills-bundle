---
description: 從 ClawHub 引入 skill 至 skills-bundle，包含技能下載、翻譯、安裝器更新、文件更新、及建立自動同步 GitHub Action
---

# 從 ClawHub 引入 Skill

本工作流程描述如何將 [ClawHub](https://clawhub.ai) 上的 skill 整合至 `skills-bundle` 專案。

> [!IMPORTANT]
> ClawHub 不是 Git repo，無法用 `git clone` 或 GitHub API。
> 必須透過 ClawHub REST API 下載技能檔案與偵測更新。

## 前置準備

- [ ] 確認 ClawHub skill 的 URL（例如 `https://clawhub.ai/<owner>/<skill-slug>`）
- [ ] 確認授權相容性（通常是 MIT）
- [ ] 確認本地 repo 工作區乾淨（`git status` 無未提交變更）

## ClawHub API 端點

所有 ClawHub skill 都可透過以下 API 存取：

| 用途 | URL |
|------|-----|
| 技能 metadata | `https://wry-manatee-359.convex.site/api/v1/skills/<slug>` |
| 技能下載 (zip) | `https://wry-manatee-359.convex.site/api/v1/download?slug=<slug>` |

Metadata 回應範例：
```json
{
  "skill": { "slug": "humanizer", "updatedAt": 1772065840450 },
  "latestVersion": { "version": "1.0.0", "changelog": "..." },
  "owner": { "handle": "biostartechnology" }
}
```

## 步驟

### 1. 研究 ClawHub Skill 內容

先在瀏覽器或 API 查看技能頁面：

```
https://clawhub.ai/<owner>/<slug>
```

然後用 API 下載技能至暫存目錄：

// turbo
```bash
SKILL_SLUG="<slug>"
curl -L -o /tmp/clawhub-skill.zip "https://wry-manatee-359.convex.site/api/v1/download?slug=${SKILL_SLUG}"
mkdir -p /tmp/clawhub-skill && cd /tmp/clawhub-skill && unzip -o /tmp/clawhub-skill.zip
```

分析重點：
- [ ] 確認 zip 內包含的檔案（通常有 `SKILL.md`、`README.md`、`_meta.json`）
- [ ] 閱讀 `SKILL.md`，理解其用途與 description
- [ ] 用 metadata API 確認版本號與更新時間
- [ ] 確認 skill 名稱（slug）在本地是否已存在（避免衝突）

// turbo
```bash
curl -sf "https://wry-manatee-359.convex.site/api/v1/skills/${SKILL_SLUG}" | jq '.skill.slug, .latestVersion.version, .owner.handle'
```

### 2. 複製 Skill 檔案至本地

將 `SKILL.md` 複製到本地 repo 的根目錄（只取 `SKILL.md`，不取 `README.md` 和 `_meta.json`）：

```bash
mkdir -p ./<slug>
cp /tmp/clawhub-skill/SKILL.md ./<slug>/SKILL.md
```

驗證複製結果：

// turbo
```bash
ls -la <slug>/SKILL.md
```

### 3. 建立 zh-TW 翻譯

為新 skill 建立繁體中文翻譯：

```
i18n/zh-TW/<slug>/SKILL.md
```

翻譯規則：
- 保留 YAML frontmatter 結構（`name` 不翻譯，`description` 翻譯為中文）
- 保留所有程式碼範例（僅翻譯註解與字串值中的 prompt 文字）
- 保留所有 URL 連結不變
- 保留所有英文範例句（Before/After 區塊中的範例維持原文）
- 使用繁體中文專業術語

### 4. 更新 `bin/install.mjs`

需要修改 4 個區塊（皆依字母順序插入）：

#### 4a. `SKILLS` 陣列

```javascript
const SKILLS = [
  // ...existing...
  '<slug>',
  // ...existing...
];
```

#### 4b. `DEPENDENCIES` 物件

```javascript
const DEPENDENCIES = {
  // ...existing...
  '<slug>': [],
  // ...existing...
};
```

#### 4c. 英文 `skillDescriptions`

```javascript
'<slug>': 'Brief English description from SKILL.md frontmatter',
```

#### 4d. 繁中 `skillDescriptions`

```javascript
'<slug>': '技能的簡短繁體中文描述',
```

### 5. 更新 `package.json`

在 `files` 陣列中按字母順序加入新 skill 目錄：

```json
{
  "files": [
    "...",
    "<slug>/",
    "..."
  ]
}
```

### 6. 更新 `README.md`

需要修改 4 個區塊：

#### 6a. Skill Sources 表格

若為全新 ClawHub 作者，新增一行來源：
```markdown
| **[<slug>](https://clawhub.ai/<owner>/<slug>)** | `<slug>` | [@<owner>](https://clawhub.ai/<owner>/<slug>) |
```

若 ClawHub 來源已存在，在對應行追加 skill。

#### 6b. Available Skills 數量

更新標題中的技能總數：
```markdown
## Available Skills (N)  <!-- 原數 + 1 -->
```

#### 6c. 技能列表區塊

在 **ClawHub Skills** 區塊中加入條目（若區塊不存在則建立）：
```markdown
### ClawHub Skills (from [...](https://clawhub.ai/...))

| Skill | Description |
|-------|-------------|
| **[<slug>](./<slug>/SKILL.md)** | Description |
```

#### 6d. Credits 區塊

新增或追加致謝：
```markdown
- **<Skill Name>** — From [<owner>/<slug>](https://clawhub.ai/<owner>/<slug>) on ClawHub
```

### 7. 更新 `GEMINI.md`

- 更新技能總數
- 若 ClawHub 分類列已存在，追加 skill；否則新增一行
- 在 Project Structure 中加入新目錄

### 8. 建立 GitHub Action 同步 Workflow

在 `.github/workflows/` 建立新的 workflow 檔案。

**命名規則**: `sync-upstream-for-clawhub-skills.yml`（所有 ClawHub skills 共用一個 workflow）

> [!IMPORTANT]
> 若 workflow 已存在（表示已有其他 ClawHub skill），則修改既有 workflow 新增偵測邏輯，
> 而非建立新檔案。

#### 關鍵設計差異（與 GitHub 型 workflow 不同）

| 設定項 | GitHub 型 | ClawHub 型 |
|--------|----------|------------|
| 變更偵測 | `gh api repos/org/repo/commits` | `curl` ClawHub REST API |
| 狀態追蹤 | 時間回溯（lookback hours） | `.github/.clawhub-<slug>-version.txt` 版本號比對 |
| 下載方式 | `git clone` | `curl` zip 下載 |
| 變更摘要 | commit/PR 清單 | changelog 文字 |

#### Phase 1: Detect（偵測更新）

```yaml
- name: 🔍 Detect upstream changes
  id: detect
  run: |
    CLAWHUB_API="https://wry-manatee-359.convex.site/api/v1/skills/<slug>"
    RESPONSE=$(curl -sf "${CLAWHUB_API}")
    UPSTREAM_VERSION=$(echo "${RESPONSE}" | jq -r '.latestVersion.version')

    LOCAL_VERSION_FILE=".github/.clawhub-<slug>-version.txt"
    LOCAL_VERSION=$(head -1 "${LOCAL_VERSION_FILE}" 2>/dev/null | tr -d '[:space:]')

    if [ "${UPSTREAM_VERSION}" = "${LOCAL_VERSION}" ]; then
      echo "has_changes=false" >> "$GITHUB_OUTPUT"
      exit 0
    fi

    echo "has_changes=true" >> "$GITHUB_OUTPUT"
    echo "upstream_version=${UPSTREAM_VERSION}" >> "$GITHUB_OUTPUT"
```

#### Phase 2: Jules（同步）

Jules prompt 中須包含：
- ClawHub 下載指令（`curl` zip）
- 只同步 ClawHub 來源的 skill，不修改其他 skill
- **保護清單**：所有非此 ClawHub skill 的技能名稱
- 更新版本追蹤檔
- 更新 zh-TW 翻譯

參考既有的 `.github/workflows/sync-upstream-for-clawhub-skills.yml`。

### 9. 建立版本追蹤檔

```bash
echo "<version>" > .github/.clawhub-<slug>-version.txt
```

此檔案用於 workflow 比對版本變化。

### 10. 驗證

// turbo
```bash
SKILL_SLUG="<slug>"

# 確認新 skill 檔案存在
ls -la ${SKILL_SLUG}/SKILL.md i18n/zh-TW/${SKILL_SLUG}/SKILL.md

# 確認 install.mjs 包含新 skill
grep "'${SKILL_SLUG}'" bin/install.mjs

# 確認 package.json 包含新 skill
grep "\"${SKILL_SLUG}/\"" package.json

# 確認 README.md 包含新 skill
grep "${SKILL_SLUG}" README.md

# 確認 GEMINI.md 包含新 skill
grep "${SKILL_SLUG}" GEMINI.md

# 確認版本追蹤檔存在
cat .github/.clawhub-${SKILL_SLUG}-version.txt

# 確認 workflow YAML 語法有效
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/sync-upstream-for-clawhub-skills.yml')); print('✅ YAML valid')"
```

### 11. Commit 並推送

```bash
git add -A
git commit -m "feat: integrate ${SKILL_SLUG} from ClawHub

- Add ${SKILL_SLUG} skill from ClawHub
- Add zh-TW translation
- Add/update GitHub Action workflow for ClawHub sync
- Update bin/install.mjs, package.json, README.md, GEMINI.md"
```

## 清單速覽

| # | 項目 | 涉及檔案 |
|---|------|----------|
| 1 | 研究 ClawHub Skill | (API 查詢 + 下載) |
| 2 | 複製 SKILL.md | `<slug>/SKILL.md` |
| 3 | 建立 zh-TW 翻譯 | `i18n/zh-TW/<slug>/SKILL.md` |
| 4 | 更新安裝器 | `bin/install.mjs` |
| 5 | 更新套件設定 | `package.json` |
| 6 | 更新 README | `README.md` |
| 7 | 更新 GEMINI.md | `GEMINI.md` |
| 8 | 建立/更新同步 Action | `.github/workflows/sync-upstream-for-clawhub-skills.yml` |
| 9 | 建立版本追蹤檔 | `.github/.clawhub-<slug>-version.txt` |
| 10 | 驗證 | (指令) |
| 11 | Commit | (git) |
