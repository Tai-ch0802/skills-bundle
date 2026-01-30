# Skills Bundle

A curated collection of AI agent skills for coding assistants.

## Overview

This repository contains reusable skill packs that enhance AI coding assistants with structured methodologies and best practices.

## Available Skills

| Skill Pack | Description |
|------------|-------------|
| **[SDD](/sdd/)** | Spec-Driven Development — A "No Spec, No Code" workflow with PRD → SA → Implementation |
| **[Refactoring](/refactoring/)** | Code smell identification and refactoring techniques based on Refactoring.guru |

### SDD (Spec-Driven Development)

A structured development workflow that enforces explicit documentation before coding. Includes three interconnected skills:

| Skill | Description | Key Artifacts |
|-------|-------------|---------------|
| **[prd](./prd/SKILL.md)** | Product Requirement Documents — Define *what* to build and *why* | `PRD_spec.md` |
| **[sa](./sa/SKILL.md)** | System Analysis — Define *how* to build it (technical design) | `SA_spec.md` |
| **[sdd](./sdd/SKILL.md)** | Orchestrating workflow — Coordinates PRD → SA → Implementation | - |

> **Core Principle**: "No Spec, No Code" — Every feature requires complete documentation before implementation.

## Installation

### Interactive Installer (Recommended)

Run the interactive installer directly from GitHub:

```bash
npx github:Tai-ch0802/skills-bundle
```

The installer will guide you through:
1. 🌐 **Language selection** — English or 繁體中文
2. 📦 **Skill selection** — Choose which skills to install (with auto-dependency resolution)
3. 📁 **Path selection** — Preset paths for popular AI agents or custom path

### Manual Installation

Copy the skill folders directly to your AI agent's skills directory:

```bash
# Example for Antigravity / Gemini CLI
cp -r prd sa sdd /your-project/.agent/skills/

# Example for Traditional Chinese version
cp -r i18n/zh-TW/* /your-project/.agent/skills/
```

## Internationalization (i18n)

This repository supports multiple languages. The default language is English, with additional languages under `i18n/`.

| Language | Directory | Status |
|----------|-----------|--------|
| English (default) | Root directories | ✅ Complete |
| 繁體中文 (Traditional Chinese) | `i18n/zh-TW/` | ✅ Complete |

### Contributing Translations

1. Create a new directory under `i18n/` (e.g., `i18n/ja/` for Japanese)
2. Copy the English skill structure and translate all files
3. Ensure all relative links within files are correct
4. Update the language table in this README

## Project Structure

```
skills-bundle/
├── prd/                 # PRD skill (English)
├── sa/                  # SA skill (English)
├── sdd/                 # SDD orchestration skill (English)
├── i18n/
│   └── zh-TW/           # Traditional Chinese translations
├── bin/
│   └── install.mjs      # Interactive CLI installer
└── package.json
```

## License

[MIT](./LICENSE)
