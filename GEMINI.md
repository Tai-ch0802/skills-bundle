# Skills Bundle

## Overview

This repository is a **curated collection of 43 AI agent skills** for coding assistants, bundled from multiple sources with an interactive installer and Traditional Chinese translations.

## Skill Categories

| Category | Count | Examples |
|----------|-------|---------|
| **SDD Pack** (original) | 4 | `prd`, `sa`, `sdd`, `refactoring` |
| **Antigravity Kit** (from vudovn) | 31 | `api-patterns`, `architecture`, `frontend-design`, `database-design`, … |
| **Gemini API** (from google-gemini) | 3 | `gemini-api-dev`, `gemini-interactions-api`, `gemini-live-api-dev` |
| **Composite** (merged & curated) | 2 | `testing-mastery`, `code-quality` |
| **Cloud & Memory** (original) | 3 | `pcloud`, `agent-brain` |

> **Core Principle (SDD)**: "No Spec, No Code" — Every feature requires complete documentation before implementation.

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
├── pcloud/                # pCloud cloud storage API
├── agent-brain/           # Persistent cross-session memory
├── gemini-api-dev/        # Gemini API development
├── gemini-interactions-api/ # Gemini Interactions API development
├── gemini-live-api-dev/   # Gemini Live API development
├── api-patterns/          # ┐
├── architecture/          # │ Antigravity Kit skills
├── frontend-design/       # │ (31 skills from vudovn)
├── ...                    # ┘
├── i18n/
│   └── zh-TW/             # Traditional Chinese translations
├── bin/
│   └── install.mjs        # Interactive CLI installer
├── .github/workflows/     # Upstream sync GitHub Actions
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
2. Test skill invocation with a sample project
3. Update templates in `references/` as needed
4. When adding translations, mirror the English structure under `i18n/{locale}/`
5. Run the installer to verify new skills are correctly listed
