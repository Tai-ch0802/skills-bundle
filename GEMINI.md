# Skills Bundle

## Overview

This repository is a **curated collection of AI agent skills** for coding assistants.

Currently available skill packs:
- **SDD (Spec-Driven Development)**: `prd/`, `sa/`, `sdd/`
- **Refactoring**: `refactoring/`

## For AI Agents

### Using This Skill Pack

Copy the skill folders to your project's `.agent/skills/` directory:

```bash
# English (default)
cp -r prd sa sdd refactoring /your-project/.agent/skills/

# Traditional Chinese (繁體中文)
cp -r i18n/zh-TW/* /your-project/.agent/skills/
```

Or use the interactive installer:
```bash
npx github:Tai-ch0802/skills-bundle
```

### Key Principles

- **SDD**: "No Spec, No Code" — Every feature requires complete documentation before implementation.
- **Refactoring**: Identify code smells and apply refactoring techniques based on Refactoring.guru.

## Project Structure

```
skills-bundle/
├── prd/               # PRD skill (English)
├── sa/                # SA skill (English)
├── sdd/               # SDD orchestration skill (English)
├── refactoring/       # Refactoring skill (English)
├── i18n/
│   └── zh-TW/         # Traditional Chinese translations
├── bin/
│   └── install.mjs    # Interactive CLI installer
└── README.md
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
