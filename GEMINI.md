# SDD Skills Bundle

## Overview

This repository is a **skill pack** for AI coding assistants implementing **Spec-Driven Development (SDD)**.

It contains three interconnected skills:
- `prd/` - Product Requirement Document guidelines
- `sa/` - System Analysis methodology
- `sdd/` - Orchestrating workflow (PRD → SA → Implementation)

## For AI Agents

### Using This Skill Pack

Copy the skill folders to your project's `.agent/skills/` directory:

```bash
# English (default)
cp -r prd sa sdd /your-project/.agent/skills/

# Traditional Chinese (繁體中文)
cp -r i18n/zh-TW/* /your-project/.agent/skills/
```

Then invoke by referencing the skill name (e.g., `/sdd` for full workflow).

### Key Principle

> **"No Spec, No Code"** — Every feature requires complete documentation before implementation.

## Project Structure

```
skills-bundle/
├── prd/               # PRD skill (English)
│   ├── SKILL.md
│   └── references/
├── sa/                # SA skill (English)
│   ├── SKILL.md
│   └── references/
├── sdd/               # Main orchestration skill (English)
│   ├── SKILL.md
│   └── references/
├── i18n/              # Internationalized versions
│   └── zh-TW/         # Traditional Chinese
│       ├── prd/
│       ├── sa/
│       └── sdd/
└── README.md
```

## Available Languages

| Language | Directory | Status |
|----------|-----------|--------|
| English | `prd/`, `sa/`, `sdd/` | ✅ Default |
| 繁體中文 | `i18n/zh-TW/` | ✅ Complete |

## Contributing

When modifying skills:
1. Follow the YAML frontmatter format in `SKILL.md` files
2. Test skill invocation with a sample project
3. Update templates in `references/` as needed
4. When adding translations, mirror the English structure under `i18n/{locale}/`
