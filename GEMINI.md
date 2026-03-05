# Skills Bundle

## Overview

This repository is a **curated collection of 62 AI agent skills** for coding assistants, bundled from multiple sources with an interactive installer and Traditional Chinese translations.

## Skill Categories

| Category | Count | Examples |
|----------|-------|---------|
| **SDD Pack** (original) | 4 | `prd`, `sa`, `sdd`, `refactoring` |
| **Antigravity Kit** (from vudovn) | 28 | `api-patterns`, `architecture`, `database-design`, … |
| **Anthropic Official** (from anthropics) | 17 | `claude-api`, `frontend-design`, `mcp-builder`, `docx`, `pdf`, `pptx`, `xlsx`, … |
| **Gemini API** (from google-gemini) | 3 | `gemini-api-dev`, `gemini-interactions-api`, `gemini-live-api-dev` |
| **ClawHub** (from biostartechnology, spclaudehome) | 2 | `humanizer`, `skill-vetter` |
| **Composite** (merged & curated) | 2 | `testing-mastery`, `code-quality` |
| **Cloud & Memory** (original) | 3 | `pcloud`, `agent-brain` |

> **Core Principle (SDD)**: "No Spec, No Code" — Every feature requires complete documentation before implementation.

> **Remote Download Architecture**: Skills from GitHub repos (Antigravity Kit, Anthropic, Gemini) are **not stored locally** — they are downloaded at install time. Only original skills, composites, ClawHub skills, and zh-TW translations are stored in this repo.

## For AI Agents

### Using This Skill Pack

Use the interactive installer:
```bash
npx github:Tai-ch0802/skills-bundle
```

Or copy skill folders directly:
```bash
# English (default)
cp -r prd sa sdd refactoring /your-project/.agent/skills/

# Traditional Chinese (繁體中文)
cp -r i18n/zh-TW/prd i18n/zh-TW/sa i18n/zh-TW/sdd /your-project/.agent/skills/
```

### Dependency Chains

Skills are linked by dependencies — installing one auto-includes prerequisites:
- `sdd` → `prd`, `sa`
- `refactoring` → `code-quality`
- `testing-mastery` → `code-quality`
- `agent-brain` → `pcloud`
- `app-builder` → `plan-writing`, `architecture`

## Project Structure

```
skills-bundle/
├── prd/                   # SDD: Product Requirements
├── sa/                    # SDD: System Analysis
├── sdd/                   # SDD: Orchestration
├── refactoring/           # Refactoring skill
├── testing-mastery/       # Composite: unified testing
├── code-quality/          # Composite: standards + review
├── humanizer/             # ClawHub: Remove AI writing patterns
├── skill-vetter/          # ClawHub: Security-first skill vetting
├── pcloud/                # pCloud cloud storage API
├── agent-brain/           # Persistent cross-session memory
├── i18n/
│   └── zh-TW/             # Traditional Chinese translations (all 62 skills)
├── bin/
│   └── install.mjs        # Interactive installer (⚡ downloads 48 skills at runtime)
├── .github/workflows/     # Upstream sync GitHub Actions (metadata & i18n only)
└── package.json
```

## Available Languages

| Language | Directory | Status |
|----------|-----------|--------|
| English | Root directories | ✅ Default |
| 繁體中文 | `i18n/zh-TW/` | ✅ Complete |

## Contributing

When modifying skills:
1. Follow the YAML frontmatter format in `SKILL.md` files
2. Only locally-stored skills can be edited directly; remote skills require upstream PRs
3. Update templates in `references/` as needed
4. When adding translations, mirror the English structure under `i18n/{locale}/`
5. Run the installer to verify new skills are correctly listed
6. To add new remote skills, update `REMOTE_SKILLS` in `bin/install.mjs`
