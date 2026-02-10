#!/usr/bin/env node

import { select, checkbox, input, confirm } from '@inquirer/prompts';
import chalk from 'chalk';
import { existsSync, mkdirSync, cpSync, readdirSync } from 'fs';
import { join, dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const PACKAGE_ROOT = resolve(__dirname, '..');

// ============================================================================
// Configuration
// ============================================================================

const LANGUAGES = {
  en: {
    name: 'English',
    path: '',
    messages: {
      welcome: '🚀 Skills Bundle Installer',
      selectLanguage: 'Select your preferred language:',
      selectPreset: 'Start with a preset or choose custom:',
      selectSkills: 'Select skills to install:',
      selectAgent: 'Select your AI agent type:',
      inputPath: 'Enter custom installation path:',
      confirmInstall: 'Install to {path}?',
      installing: 'Installing skills...',
      installed: '✅ Installed: {skill}',
      complete: '🎉 Installation complete!',
      cancelled: '❌ Installation cancelled.',
      presetNames: {
        'fullstack-web': '🌐 - Full-Stack Web Development',
        'mobile-fullstack': '📱 - Mobile Full-Stack',
        'security-expert': '🛡️ - Security Expert',
        architect: '🏗️ - Architect',
        'sdd-pack': '📝 - Spec-Driven Development',
        custom: '🎯 - Custom Selection...',
      },
      skillDescriptions: {
        // SDD Pack
        prd: 'Product Requirements Document guidelines',
        sa: 'System Analysis methodology',
        sdd: 'Spec-Driven Development workflow (includes prd, sa)',
        refactoring: 'Code smell identification and refactoring techniques',
        // Antigravity Kit Skills
        'api-patterns': 'API design principles — REST vs GraphQL vs tRPC, response formats, versioning',
        'app-builder': 'Full-stack app building orchestrator from natural language requests',
        architecture: 'Architectural decision-making framework with ADR documentation',
        'bash-linux': 'Bash/Linux terminal patterns, commands, piping, error handling',
        'behavioral-modes': 'AI operational modes (brainstorm, implement, debug, review, teach, ship)',
        brainstorming: 'Socratic questioning protocol for complex requests and new features',
        'code-quality': 'Pragmatic coding standards, code review guidelines, anti-patterns (merged from clean-code + code-review-checklist)',
        'database-design': 'Database design — schema, indexing, ORM selection, serverless databases',
        'deployment-procedures': 'Production deployment workflows, rollback strategies, verification',
        'documentation-templates': 'Documentation templates — README, API docs, code comments',
        'frontend-design': 'Design thinking for web UI — components, layouts, color, typography',
        'game-development': 'Game development orchestrator for multiple platforms',
        'geo-fundamentals': 'Generative Engine Optimization for AI search engines',
        'i18n-localization': 'Internationalization — translations, locale files, RTL support',
        'intelligent-routing': 'Automatic agent selection and intelligent task routing',
        'lint-and-validate': 'Automatic quality control, linting, and static analysis',
        'mcp-builder': 'MCP server building — tool design, resource patterns, best practices',
        'mobile-design': 'Mobile-first design for iOS/Android — touch, performance, platform conventions',
        'nextjs-react-expert': 'React/Next.js performance optimization from Vercel Engineering',
        'nodejs-best-practices': 'Node.js development — framework selection, async, security, architecture',
        'parallel-agents': 'Multi-agent orchestration for independent parallel tasks',
        'performance-profiling': 'Performance profiling — measurement, analysis, optimization',
        'plan-writing': 'Structured task planning with breakdowns, dependencies, verification',
        'powershell-windows': 'PowerShell Windows patterns, operator syntax, error handling',
        'python-patterns': 'Python development — framework selection, async, type hints, structure',
        'red-team-tactics': 'Red team tactics based on MITRE ATT&CK — attack phases, detection evasion',
        'rust-pro': 'Rust 1.75+ with modern async patterns and advanced type system',
        'seo-fundamentals': 'SEO fundamentals — E-E-A-T, Core Web Vitals, Google algorithms',
        'server-management': 'Server management — process management, monitoring, scaling',
        'systematic-debugging': '4-phase systematic debugging with root cause analysis',
        'tailwind-patterns': 'Tailwind CSS v4 — CSS-first config, container queries, design tokens',
        'testing-mastery': 'Unified testing — TDD, unit/integration patterns, E2E/Playwright (merged from tdd-workflow + testing-patterns + webapp-testing)',
        'vulnerability-scanner': 'Vulnerability analysis — OWASP 2025, supply chain security',
        'web-design-guidelines': 'UI code review for Web Interface Guidelines compliance',
      },
    },
  },
  'zh-TW': {
    name: '繁體中文',
    path: 'i18n/zh-TW',
    messages: {
      welcome: '🚀 技能包安裝程式',
      selectLanguage: '請選擇您偏好的語言：',
      selectPreset: '選擇預設組合或自訂：',
      selectSkills: '請選擇要安裝的技能：',
      selectAgent: '請選擇您的 AI 代理類型：',
      inputPath: '請輸入自訂安裝路徑：',
      confirmInstall: '確認安裝至 {path}？',
      installing: '正在安裝技能...',
      installed: '✅ 已安裝：{skill}',
      complete: '🎉 安裝完成！',
      cancelled: '❌ 已取消安裝。',
      presetNames: {
        'fullstack-web': '🌐 - 全端 Web 開發',
        'mobile-fullstack': '📱 - 行動端全端開發',
        'security-expert': '🛡️ - 安全專家',
        architect: '🏗️ - 架構師',
        'sdd-pack': '📝 - 規格驅動開發',
        custom: '🎯 - 自訂選擇...',
      },
      skillDescriptions: {
        // SDD 技能包
        prd: '產品需求文件指南',
        sa: '系統分析方法論',
        sdd: '規格驅動開發工作流程（包含 prd, sa）',
        refactoring: '程式碼異味識別與重構技術',
        // Antigravity Kit 技能
        'api-patterns': 'API 設計原則 — REST vs GraphQL vs tRPC、回應格式、版本控制',
        'app-builder': '全端應用程式建構協調器，從自然語言需求建立應用',
        architecture: '架構決策框架與 ADR 文件',
        'bash-linux': 'Bash/Linux 終端模式、指令、管道、錯誤處理',
        'behavioral-modes': 'AI 操作模式（腦力激盪、實作、除錯、審查、教學、發布）',
        brainstorming: '蘇格拉底式提問協議，用於複雜需求與新功能',
        'code-quality': '務實的編碼標準與程式碼審查指南（合併自 clean-code + code-review-checklist）',
        'database-design': '資料庫設計 — Schema、索引策略、ORM 選擇、無伺服器資料庫',
        'deployment-procedures': '生產環境部署流程、回滾策略、驗證',
        'documentation-templates': '文件範本 — README、API 文件、程式碼註解',
        'frontend-design': 'Web UI 設計思維 — 元件、佈局、配色、排版',
        'game-development': '遊戲開發協調器，支援多平台',
        'geo-fundamentals': '生成式引擎最佳化（GEO），針對 AI 搜尋引擎',
        'i18n-localization': '國際化 — 翻譯管理、本地化檔案、RTL 支援',
        'intelligent-routing': '自動代理選擇與智慧任務路由',
        'lint-and-validate': '自動品質控制、程式碼檢查與靜態分析',
        'mcp-builder': 'MCP 伺服器建構 — 工具設計、資源模式、最佳實踐',
        'mobile-design': '行動優先設計（iOS/Android）— 觸控互動、效能、平台慣例',
        'nextjs-react-expert': 'React/Next.js 效能最佳化（來自 Vercel 工程團隊）',
        'nodejs-best-practices': 'Node.js 開發 — 框架選擇、非同步模式、安全性、架構',
        'parallel-agents': '多代理協調，用於獨立的平行任務',
        'performance-profiling': '效能分析 — 量測、分析、最佳化技術',
        'plan-writing': '結構化任務規劃，含分解、相依性、驗證準則',
        'powershell-windows': 'PowerShell Windows 模式、運算子語法、錯誤處理',
        'python-patterns': 'Python 開發 — 框架選擇、非同步、型別提示、專案結構',
        'red-team-tactics': '紅隊戰術（基於 MITRE ATT&CK）— 攻擊階段、規避偵測',
        'rust-pro': 'Rust 1.75+ 現代非同步模式與進階型別系統',
        'seo-fundamentals': 'SEO 基礎 — E-E-A-T、Core Web Vitals、Google 演算法',
        'server-management': '伺服器管理 — 程序管理、監控策略、擴展決策',
        'systematic-debugging': '四階段系統化除錯與根因分析',
        'tailwind-patterns': 'Tailwind CSS v4 — CSS 優先配置、容器查詢、設計代幣',
        'testing-mastery': '統一測試技能 — TDD、單元/整合模式、E2E/Playwright（合併自 tdd-workflow + testing-patterns + webapp-testing）',
        'vulnerability-scanner': '弱點分析 — OWASP 2025、供應鏈安全',
        'web-design-guidelines': 'UI 程式碼審查，符合 Web 介面指南',
      },
    },
  },
};

const SKILLS = [
  // SDD Pack
  'prd', 'sa', 'sdd', 'refactoring',
  // Antigravity Kit Skills (alphabetical)
  'api-patterns', 'app-builder', 'architecture', 'bash-linux',
  'behavioral-modes', 'brainstorming', 'code-quality',
  'database-design', 'deployment-procedures', 'documentation-templates',
  'frontend-design', 'game-development', 'geo-fundamentals', 'i18n-localization',
  'intelligent-routing', 'lint-and-validate', 'mcp-builder', 'mobile-design',
  'nextjs-react-expert', 'nodejs-best-practices', 'parallel-agents',
  'performance-profiling', 'plan-writing', 'powershell-windows', 'python-patterns',
  'red-team-tactics', 'rust-pro', 'seo-fundamentals', 'server-management',
  'systematic-debugging', 'tailwind-patterns', 'testing-mastery',
  'vulnerability-scanner', 'web-design-guidelines',
];

const DEPENDENCIES = {
  // --- SDD Pack ---
  prd: [],
  sa: [],
  sdd: ['prd', 'sa'],

  // --- Quality Chain ---
  'code-quality': [],
  refactoring: ['code-quality'],
  'lint-and-validate': ['code-quality'],

  // --- Testing ---
  'testing-mastery': ['code-quality'],

  // --- Design Chain ---
  'frontend-design': [],
  'web-design-guidelines': ['frontend-design'],
  'mobile-design': ['frontend-design'],
  'tailwind-patterns': ['frontend-design'],

  // --- Security Chain ---
  'vulnerability-scanner': [],
  'red-team-tactics': ['vulnerability-scanner'],

  // --- SEO Chain ---
  'seo-fundamentals': [],
  'geo-fundamentals': ['seo-fundamentals'],

  // --- Orchestration ---
  'app-builder': ['plan-writing', 'architecture'],

  // --- Independent Skills ---
  'api-patterns': [],
  architecture: [],
  'bash-linux': [],
  'behavioral-modes': [],
  brainstorming: [],
  'database-design': [],
  'deployment-procedures': [],
  'documentation-templates': [],
  'game-development': [],
  'i18n-localization': [],
  'intelligent-routing': [],
  'mcp-builder': [],
  'nextjs-react-expert': [],
  'nodejs-best-practices': [],
  'parallel-agents': [],
  'performance-profiling': [],
  'plan-writing': [],
  'powershell-windows': [],
  'python-patterns': [],
  'rust-pro': [],
  'server-management': [],
  'systematic-debugging': [],
};

const SKILL_PRESETS = {
  'fullstack-web': {
    skills: [
      'frontend-design', 'tailwind-patterns', 'nextjs-react-expert',
      'api-patterns', 'database-design', 'nodejs-best-practices',
      'testing-mastery', 'deployment-procedures', 'seo-fundamentals',
      'code-quality', 'lint-and-validate',
    ],
  },
  'mobile-fullstack': {
    skills: [
      'mobile-design', 'api-patterns', 'database-design',
      'testing-mastery', 'deployment-procedures', 'code-quality',
      'lint-and-validate', 'performance-profiling',
    ],
  },
  'security-expert': {
    skills: [
      'vulnerability-scanner', 'red-team-tactics', 'code-quality',
    ],
  },
  architect: {
    skills: [
      'architecture', 'api-patterns', 'database-design',
      'plan-writing', 'code-quality', 'performance-profiling',
    ],
  },
  'sdd-pack': {
    skills: ['sdd', 'refactoring'],
  },
};

const AGENT_PRESETS = {
  antigravity: {
    name: 'Antigravity / Gemini CLI',
    path: '.agent/skills',
  },
  cursor: {
    name: 'Cursor',
    path: '.cursor/skills',
  },
  custom: {
    name: 'Custom / Other',
    path: null,
  },
};

// ============================================================================
// Helper Functions
// ============================================================================

function resolveDependencies(selectedSkills) {
  const resolved = new Set();

  function addWithDeps(skill) {
    if (resolved.has(skill)) return;
    for (const dep of DEPENDENCIES[skill]) {
      addWithDeps(dep);
    }
    resolved.add(skill);
  }

  for (const skill of selectedSkills) {
    addWithDeps(skill);
  }

  return Array.from(resolved);
}

function getSkillSourcePath(skill, langPath) {
  if (langPath) {
    return join(PACKAGE_ROOT, langPath, skill);
  }
  return join(PACKAGE_ROOT, skill);
}

function copySkill(skill, langPath, destBase) {
  const srcPath = getSkillSourcePath(skill, langPath);
  const destPath = join(destBase, skill);

  if (!existsSync(srcPath)) {
    console.error(chalk.red(`Source not found: ${srcPath}`));
    return false;
  }

  mkdirSync(destPath, { recursive: true });
  cpSync(srcPath, destPath, { recursive: true });
  return true;
}

// ============================================================================
// Main Installer
// ============================================================================

async function main() {
  console.log('\n' + chalk.bold.cyan('═'.repeat(50)));
  console.log(chalk.bold.cyan('  🚀 Skills Bundle Installer'));
  console.log(chalk.bold.cyan('═'.repeat(50)) + '\n');

  // Step 1: Select Language
  const langCode = await select({
    message: 'Select your preferred language / 請選擇您偏好的語言：',
    choices: Object.entries(LANGUAGES).map(([code, lang]) => ({
      name: lang.name,
      value: code,
    })),
  });

  const lang = LANGUAGES[langCode];
  const msg = lang.messages;

  // Step 2: Select Preset or Custom
  const presetChoices = [
    ...Object.entries(SKILL_PRESETS).map(([key]) => ({
      name: msg.presetNames[key] || key,
      value: key,
    })),
    { name: msg.presetNames.custom || '🎯 Custom...', value: 'custom' },
  ];

  const presetChoice = await select({
    message: msg.selectPreset,
    choices: presetChoices,
  });

  const preChecked = presetChoice !== 'custom'
    ? new Set(SKILL_PRESETS[presetChoice].skills)
    : new Set();

  // Step 3: Select Skills (with preset pre-checked)
  const selectedSkills = await checkbox({
    message: msg.selectSkills,
    choices: SKILLS.map((skill) => ({
      name: `${skill} - ${msg.skillDescriptions[skill]}`,
      value: skill,
      checked: preChecked.has(skill),
    })),
    required: true,
  });

  if (selectedSkills.length === 0) {
    console.log(chalk.yellow('\n⚠️  No skills selected. Exiting.'));
    process.exit(0);
  }

  // Resolve dependencies
  const allSkills = resolveDependencies(selectedSkills);
  const addedDeps = allSkills.filter((s) => !selectedSkills.includes(s));

  if (addedDeps.length > 0) {
    console.log(
      chalk.cyan(`\n📦 Auto-including dependencies: ${addedDeps.join(', ')}`)
    );
  }

  // Step 3: Select Installation Path
  const agentType = await select({
    message: msg.selectAgent,
    choices: Object.entries(AGENT_PRESETS).map(([key, preset]) => ({
      name: preset.name + (preset.path ? ` (${preset.path})` : ''),
      value: key,
    })),
  });

  let installPath;
  if (agentType === 'custom') {
    installPath = await input({
      message: msg.inputPath,
      default: '.agent/skills',
    });
  } else {
    installPath = AGENT_PRESETS[agentType].path;
  }

  // Resolve to absolute path from cwd
  const absolutePath = resolve(process.cwd(), installPath);

  // Step 4: Confirm Installation
  console.log(chalk.dim(`\n📁 Installation path: ${absolutePath}`));
  console.log(chalk.dim(`📦 Skills to install: ${allSkills.join(', ')}`));
  console.log(chalk.dim(`🌐 Language: ${lang.name}\n`));

  const confirmed = await confirm({
    message: msg.confirmInstall.replace('{path}', installPath),
    default: true,
  });

  if (!confirmed) {
    console.log(chalk.yellow(`\n${msg.cancelled}`));
    process.exit(0);
  }

  // Step 5: Install Skills
  console.log(chalk.cyan(`\n${msg.installing}\n`));

  mkdirSync(absolutePath, { recursive: true });

  for (const skill of allSkills) {
    const success = copySkill(skill, lang.path, absolutePath);
    if (success) {
      console.log(chalk.green(msg.installed.replace('{skill}', skill)));
    }
  }

  // Step 6: Complete
  console.log(chalk.bold.green(`\n${msg.complete}`));
  console.log(chalk.dim(`\nInstalled to: ${absolutePath}\n`));
}

main().catch((err) => {
  if (err.name === 'ExitPromptError') {
    console.log(chalk.yellow('\n❌ Installation cancelled.'));
    process.exit(0);
  }
  console.error(chalk.red('Error:'), err.message);
  process.exit(1);
});
