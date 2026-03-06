#!/usr/bin/env node

import { select, checkbox, input, confirm } from '@inquirer/prompts';
import { homedir } from 'os';
import chalk from 'chalk';
import { existsSync, mkdirSync, cpSync, readdirSync, createWriteStream, rmSync } from 'fs';
import { join, dirname, resolve } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';
import { get } from 'https';

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
      selectScope: 'Where do you want to install skills?',
      scopeProject: '📁 Project directory (for project-specific skills)',
      scopeGlobal: '🌐 Global directory (for cross-project skills like agent-brain)',
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
        'ai-builder': '🤖 - AI & API Builder',
        'content-creator': '✍️ - Content & Docs Creator',
        'devops-infra': '⚙️ - DevOps & Infrastructure',
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
        'game-development': 'Game development orchestrator for multiple platforms',
        'gemini-api-dev': 'Gemini API development — SDK usage, multimodal, function calling, structured output',
        'gemini-interactions-api': 'Gemini Interactions API — agentic applications, server-side state, tool orchestration, deep research',
        'gemini-live-api-dev': 'Gemini Live API development — real-time audio/video streaming, WebSockets, native audio',
        'geo-fundamentals': 'Generative Engine Optimization for AI search engines',
        humanizer: 'Remove AI writing patterns — inflated symbolism, AI vocabulary, em dash overuse, vague attributions',
        'i18n-localization': 'Internationalization — translations, locale files, RTL support',
        'intelligent-routing': 'Automatic agent selection and intelligent task routing',
        'lint-and-validate': 'Automatic quality control, linting, and static analysis',
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
        'skill-vetter': 'Security-first skill vetting — red flags, permission scope, suspicious patterns',
        'systematic-debugging': '4-phase systematic debugging with root cause analysis',
        'tailwind-patterns': 'Tailwind CSS v4 — CSS-first config, container queries, design tokens',
        'testing-mastery': 'Unified testing — TDD, unit/integration patterns, E2E/Playwright (merged from tdd-workflow + testing-patterns + webapp-testing)',
        'vulnerability-scanner': 'Vulnerability analysis — OWASP 2025, supply chain security',
        'web-design-guidelines': 'UI code review for Web Interface Guidelines compliance',
        pcloud: 'pCloud cloud storage API integration — file management, sharing, streaming, OAuth 2.0',
        'agent-brain': 'Persistent cross-session memory system — digital twin brain with pCloud sync',
        // Anthropic Official Skills
        'algorithmic-art': 'Algorithmic art with p5.js — seeded randomness, flow fields, particle systems',
        'brand-guidelines': 'Apply Anthropic brand colors and typography to artifacts',
        'canvas-design': 'Visual art creation in .png/.pdf — posters, designs, static graphics',
        'claude-api': 'Build apps with Claude API / Anthropic SDK / Agent SDK',
        'doc-coauthoring': 'Structured co-authoring workflow for docs, proposals, and specs',
        docx: 'Create, read, edit Word documents (.docx) — formatting, tables, images, tracked changes',
        'frontend-design': 'Production-grade frontend interfaces — creative, polished UI code',
        'internal-comms': 'Internal communications — status reports, newsletters, incident reports',
        'mcp-builder': 'MCP server building guide — FastMCP (Python) and MCP SDK (Node/TS)',
        pdf: 'PDF manipulation — read, merge, split, fill forms, OCR, watermarks',
        pptx: 'PowerPoint manipulation — create, read, edit, parse .pptx presentations',
        'skill-creator': 'Create, improve, and evaluate AI skills with benchmarking',
        'slack-gif-creator': 'Create animated GIFs optimized for Slack',
        'theme-factory': 'Apply visual themes to slides, docs, reports, landing pages (10 presets)',
        'web-artifacts-builder': 'Multi-component HTML artifacts with React, Tailwind, shadcn/ui',
        'webapp-testing': 'Web app testing toolkit with Playwright — screenshots, logs, debugging',
        xlsx: 'Spreadsheet manipulation — read, write, format .xlsx/.csv files',
      },
    },
  },
  'zh-TW': {
    name: '繁體中文',
    path: 'i18n/zh-TW',
    messages: {
      welcome: '🚀 技能包安裝程式',
      selectLanguage: '請選擇您偏好的語言：',
      selectScope: '您想將技能安裝到哪裡？',
      scopeProject: '📁 專案目錄（適合專案特定技能）',
      scopeGlobal: '🌐 全域目錄（適合跨專案技能，如 agent-brain）',
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
        'ai-builder': '🤖 - AI 與 API 建構師',
        'content-creator': '✍️ - 內容與文件創建',
        'devops-infra': '⚙️ - DevOps 與基礎設施',
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
        'game-development': '遊戲開發協調器，支援多平台',
        'gemini-api-dev': 'Gemini API 開發 — SDK 使用、多模態、函式呼叫、結構化輸出',
        'gemini-interactions-api': 'Gemini Interactions API — 代理應用程式、伺服器端狀態、工具協調、深度研究',
        'gemini-live-api-dev': 'Gemini Live API 開發 — 即時音訊/視訊串流、WebSockets、原生音訊',
        'geo-fundamentals': '生成式引擎最佳化（GEO），針對 AI 搜尋引擎',
        humanizer: '移除 AI 寫作模式 — 膨脹象徵主義、AI 詞彙、破折號濫用、模糊歸因',
        'i18n-localization': '國際化 — 翻譯管理、本地化檔案、RTL 支援',
        'intelligent-routing': '自動代理選擇與智慧任務路由',
        'lint-and-validate': '自動品質控制、程式碼檢查與靜態分析',
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
        'skill-vetter': '安全優先的技能審查 — 紅色旗標、權限範圍、可疑模式偵測',
        'systematic-debugging': '四階段系統化除錯與根因分析',
        'tailwind-patterns': 'Tailwind CSS v4 — CSS 優先配置、容器查詢、設計代幣',
        'testing-mastery': '統一測試技能 — TDD、單元/整合模式、E2E/Playwright（合併自 tdd-workflow + testing-patterns + webapp-testing）',
        'vulnerability-scanner': '弱點分析 — OWASP 2025、供應鏈安全',
        'web-design-guidelines': 'UI 程式碼審查，符合 Web 介面指南',
        pcloud: 'pCloud 雲端儲存 API 整合 — 檔案管理、分享、串流、OAuth 2.0',
        'agent-brain': '持久化跨 Session 記憶系統 — 數位孿生大腦，搭配 pCloud 同步',
        // Anthropic 官方技能
        'algorithmic-art': '使用 p5.js 的演算法藝術 — 種子隨機性、流場、粒子系統',
        'brand-guidelines': '套用 Anthropic 品牌色彩與排版至產出物',
        'canvas-design': '視覺藝術創作（.png/.pdf）— 海報、設計、靜態圖像',
        'claude-api': '使用 Claude API / Anthropic SDK / Agent SDK 建構應用',
        'doc-coauthoring': '結構化文件共同撰寫工作流程 — 提案、技術規格',
        docx: 'Word 文件操作 — 建立、讀取、編輯 .docx，格式化、表格、追蹤修訂',
        'frontend-design': '生產等級前端介面 — 創意且精緻的 UI 程式碼',
        'internal-comms': '內部通訊 — 狀態報告、電子報、事件報告',
        'mcp-builder': 'MCP 伺服器建構指南 — FastMCP (Python) 與 MCP SDK (Node/TS)',
        pdf: 'PDF 操作 — 讀取、合併、分割、填表、OCR、浮水印',
        pptx: 'PowerPoint 操作 — 建立、讀取、編輯、解析 .pptx 簡報',
        'skill-creator': 'AI 技能建立、改善與評估（含效能基準測試）',
        'slack-gif-creator': '建立針對 Slack 最佳化的動態 GIF',
        'theme-factory': '為投影片、文件、報告、登陸頁套用視覺主題（10 種預設）',
        'web-artifacts-builder': '多元件 HTML 產出物 — React、Tailwind、shadcn/ui',
        'webapp-testing': 'Web 應用測試工具包 — Playwright 截圖、日誌、除錯',
        xlsx: '試算表操作 — 讀取、寫入、格式化 .xlsx/.csv 檔案',
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
  'game-development', 'gemini-api-dev', 'gemini-interactions-api', 'gemini-live-api-dev', 'geo-fundamentals', 'humanizer', 'i18n-localization',
  'intelligent-routing', 'lint-and-validate', 'mobile-design',
  'nextjs-react-expert', 'nodejs-best-practices', 'parallel-agents',
  'performance-profiling', 'plan-writing', 'powershell-windows', 'python-patterns',
  'red-team-tactics', 'rust-pro', 'seo-fundamentals', 'server-management',
  'skill-vetter', 'systematic-debugging', 'tailwind-patterns', 'testing-mastery',
  'vulnerability-scanner', 'web-design-guidelines',
  // Anthropic Official Skills (alphabetical)
  'algorithmic-art', 'brand-guidelines', 'canvas-design', 'claude-api',
  'doc-coauthoring', 'docx', 'frontend-design', 'internal-comms',
  'mcp-builder', 'pdf', 'pptx', 'skill-creator', 'slack-gif-creator',
  'theme-factory', 'web-artifacts-builder', 'webapp-testing', 'xlsx',
  // Cloud & Memory Skills
  'pcloud', 'agent-brain',
];

// Remote skills — not stored in this repo; downloaded at install time from upstream
const REMOTE_SKILLS = {
  // --- anthropics/skills (upstream path: skills/<name>) ---
  'algorithmic-art': { repo: 'anthropics/skills', path: 'skills/algorithmic-art', branch: 'main' },
  'brand-guidelines': { repo: 'anthropics/skills', path: 'skills/brand-guidelines', branch: 'main' },
  'canvas-design': { repo: 'anthropics/skills', path: 'skills/canvas-design', branch: 'main' },
  'claude-api': { repo: 'anthropics/skills', path: 'skills/claude-api', branch: 'main' },
  'doc-coauthoring': { repo: 'anthropics/skills', path: 'skills/doc-coauthoring', branch: 'main' },
  docx: { repo: 'anthropics/skills', path: 'skills/docx', branch: 'main' },
  'frontend-design': { repo: 'anthropics/skills', path: 'skills/frontend-design', branch: 'main' },
  'internal-comms': { repo: 'anthropics/skills', path: 'skills/internal-comms', branch: 'main' },
  'mcp-builder': { repo: 'anthropics/skills', path: 'skills/mcp-builder', branch: 'main' },
  pdf: { repo: 'anthropics/skills', path: 'skills/pdf', branch: 'main' },
  pptx: { repo: 'anthropics/skills', path: 'skills/pptx', branch: 'main' },
  'skill-creator': { repo: 'anthropics/skills', path: 'skills/skill-creator', branch: 'main' },
  'slack-gif-creator': { repo: 'anthropics/skills', path: 'skills/slack-gif-creator', branch: 'main' },
  'theme-factory': { repo: 'anthropics/skills', path: 'skills/theme-factory', branch: 'main' },
  'web-artifacts-builder': { repo: 'anthropics/skills', path: 'skills/web-artifacts-builder', branch: 'main' },
  'webapp-testing': { repo: 'anthropics/skills', path: 'skills/webapp-testing', branch: 'main' },
  xlsx: { repo: 'anthropics/skills', path: 'skills/xlsx', branch: 'main' },

  // --- vudovn/antigravity-kit (upstream path: <name>, root-level) ---
  'api-patterns': { repo: 'vudovn/antigravity-kit', path: 'api-patterns', branch: 'main' },
  'app-builder': { repo: 'vudovn/antigravity-kit', path: 'app-builder', branch: 'main' },
  architecture: { repo: 'vudovn/antigravity-kit', path: 'architecture', branch: 'main' },
  'bash-linux': { repo: 'vudovn/antigravity-kit', path: 'bash-linux', branch: 'main' },
  'behavioral-modes': { repo: 'vudovn/antigravity-kit', path: 'behavioral-modes', branch: 'main' },
  brainstorming: { repo: 'vudovn/antigravity-kit', path: 'brainstorming', branch: 'main' },
  'database-design': { repo: 'vudovn/antigravity-kit', path: 'database-design', branch: 'main' },
  'deployment-procedures': { repo: 'vudovn/antigravity-kit', path: 'deployment-procedures', branch: 'main' },
  'documentation-templates': { repo: 'vudovn/antigravity-kit', path: 'documentation-templates', branch: 'main' },
  'game-development': { repo: 'vudovn/antigravity-kit', path: 'game-development', branch: 'main' },
  'geo-fundamentals': { repo: 'vudovn/antigravity-kit', path: 'geo-fundamentals', branch: 'main' },
  'i18n-localization': { repo: 'vudovn/antigravity-kit', path: 'i18n-localization', branch: 'main' },
  'intelligent-routing': { repo: 'vudovn/antigravity-kit', path: 'intelligent-routing', branch: 'main' },
  'lint-and-validate': { repo: 'vudovn/antigravity-kit', path: 'lint-and-validate', branch: 'main' },
  'mobile-design': { repo: 'vudovn/antigravity-kit', path: 'mobile-design', branch: 'main' },
  'nextjs-react-expert': { repo: 'vudovn/antigravity-kit', path: 'nextjs-react-expert', branch: 'main' },
  'nodejs-best-practices': { repo: 'vudovn/antigravity-kit', path: 'nodejs-best-practices', branch: 'main' },
  'parallel-agents': { repo: 'vudovn/antigravity-kit', path: 'parallel-agents', branch: 'main' },
  'performance-profiling': { repo: 'vudovn/antigravity-kit', path: 'performance-profiling', branch: 'main' },
  'plan-writing': { repo: 'vudovn/antigravity-kit', path: 'plan-writing', branch: 'main' },
  'powershell-windows': { repo: 'vudovn/antigravity-kit', path: 'powershell-windows', branch: 'main' },
  'python-patterns': { repo: 'vudovn/antigravity-kit', path: 'python-patterns', branch: 'main' },
  'red-team-tactics': { repo: 'vudovn/antigravity-kit', path: 'red-team-tactics', branch: 'main' },
  'rust-pro': { repo: 'vudovn/antigravity-kit', path: 'rust-pro', branch: 'main' },
  'seo-fundamentals': { repo: 'vudovn/antigravity-kit', path: 'seo-fundamentals', branch: 'main' },
  'server-management': { repo: 'vudovn/antigravity-kit', path: 'server-management', branch: 'main' },
  'systematic-debugging': { repo: 'vudovn/antigravity-kit', path: 'systematic-debugging', branch: 'main' },
  'tailwind-patterns': { repo: 'vudovn/antigravity-kit', path: 'tailwind-patterns', branch: 'main' },
  'vulnerability-scanner': { repo: 'vudovn/antigravity-kit', path: 'vulnerability-scanner', branch: 'main' },
  'web-design-guidelines': { repo: 'vudovn/antigravity-kit', path: 'web-design-guidelines', branch: 'main' },

  // --- google-gemini/gemini-skills (upstream path: skills/<name>) ---
  'gemini-api-dev': { repo: 'google-gemini/gemini-skills', path: 'skills/gemini-api-dev', branch: 'main' },
  'gemini-interactions-api': { repo: 'google-gemini/gemini-skills', path: 'skills/gemini-interactions-api', branch: 'main' },
  'gemini-live-api-dev': { repo: 'google-gemini/gemini-skills', path: 'skills/gemini-live-api-dev', branch: 'main' },
};

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
  'gemini-api-dev': [],
  humanizer: [],
  'gemini-interactions-api': ['gemini-api-dev'],
  'gemini-live-api-dev': [],
  'i18n-localization': [],
  'intelligent-routing': [],
  'nextjs-react-expert': [],
  'nodejs-best-practices': [],
  'parallel-agents': [],
  'performance-profiling': [],
  'plan-writing': [],
  'powershell-windows': [],
  'python-patterns': [],
  'rust-pro': [],
  'server-management': [],
  'skill-vetter': [],
  'systematic-debugging': [],

  // --- Anthropic Official Skills ---
  'algorithmic-art': [],
  'brand-guidelines': [],
  'canvas-design': [],
  'claude-api': [],
  'doc-coauthoring': [],
  docx: [],
  'internal-comms': [],
  'mcp-builder': [],
  pdf: [],
  pptx: [],
  'skill-creator': [],
  'slack-gif-creator': [],
  'theme-factory': [],
  'web-artifacts-builder': [],
  'webapp-testing': [],
  xlsx: [],

  // --- Cloud & Memory ---
  pcloud: [],
  'agent-brain': ['pcloud'],
};

const SKILL_PRESETS = {
  'fullstack-web': {
    skills: [
      'frontend-design', 'tailwind-patterns', 'nextjs-react-expert',
      'api-patterns', 'database-design', 'nodejs-best-practices',
      'testing-mastery', 'deployment-procedures', 'seo-fundamentals',
      'code-quality', 'lint-and-validate',
      'web-design-guidelines', 'documentation-templates', 'systematic-debugging',
    ],
  },
  'mobile-fullstack': {
    skills: [
      'mobile-design', 'api-patterns', 'database-design',
      'testing-mastery', 'deployment-procedures', 'code-quality',
      'lint-and-validate', 'performance-profiling',
      'systematic-debugging', 'documentation-templates',
    ],
  },
  'security-expert': {
    skills: [
      'vulnerability-scanner', 'red-team-tactics', 'code-quality',
      'systematic-debugging', 'server-management', 'bash-linux',
    ],
  },
  architect: {
    skills: [
      'architecture', 'api-patterns', 'database-design',
      'plan-writing', 'code-quality', 'performance-profiling',
      'deployment-procedures', 'documentation-templates', 'systematic-debugging',
    ],
  },
  'ai-builder': {
    skills: [
      'claude-api', 'gemini-api-dev', 'mcp-builder',
      'app-builder', 'api-patterns', 'plan-writing',
      'testing-mastery', 'code-quality',
    ],
  },
  'content-creator': {
    skills: [
      'docx', 'pdf', 'pptx', 'xlsx',
      'frontend-design', 'canvas-design', 'brand-guidelines',
      'theme-factory', 'doc-coauthoring', 'humanizer',
      'internal-comms', 'skill-creator',
    ],
  },
  'devops-infra': {
    skills: [
      'bash-linux', 'server-management', 'deployment-procedures',
      'performance-profiling', 'systematic-debugging',
      'lint-and-validate', 'powershell-windows',
    ],
  },
  'sdd-pack': {
    skills: ['sdd', 'refactoring', 'plan-writing', 'documentation-templates'],
  },
};

const AGENT_PRESETS = {
  project: {
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
  },
  global: {
    antigravity: {
      name: 'Antigravity (Global)',
      path: join(homedir(), '.gemini', 'antigravity', 'skills'),
    },
    custom: {
      name: 'Custom / Other',
      path: null,
    },
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

/**
 * Download a remote skill from GitHub using tarball API + tar extraction.
 * @returns {boolean} true if download succeeded
 */
function downloadRemoteSkill(skill, destBase) {
  const config = REMOTE_SKILLS[skill];
  if (!config) return false;

  const destPath = join(destBase, skill);
  const tarballUrl = `https://github.com/${config.repo}/archive/refs/heads/${config.branch}.tar.gz`;
  const tmpTar = join(destBase, `.tmp-${skill}.tar.gz`);

  try {
    console.log(chalk.dim(`   ⏬ Downloading ${skill} from ${config.repo}...`));

    // Download tarball using curl (available on all platforms)
    execSync(`curl -sL "${tarballUrl}" -o "${tmpTar}"`, { stdio: 'pipe' });

    // Extract only the target skill directory
    mkdirSync(destPath, { recursive: true });
    // The tarball contains a root dir like "skills-main/", so we strip 2 components
    // and match only the target path
    const stripComponents = config.path.split('/').length + 1; // +1 for the archive root dir
    execSync(
      `tar -xzf "${tmpTar}" -C "${destPath}" --strip-components=${stripComponents} "*/${config.path}/"`,
      { stdio: 'pipe' }
    );

    return true;
  } catch (err) {
    console.error(chalk.red(`   ❌ Failed to download ${skill}: ${err.message}`));
    return false;
  } finally {
    // Clean up temp tarball
    try { rmSync(tmpTar, { force: true }); } catch { /* ignore */ }
  }
}

function copySkill(skill, langPath, destBase) {
  // Check if this is a remote skill (and not a zh-TW translation request)
  if (REMOTE_SKILLS[skill] && !langPath) {
    return downloadRemoteSkill(skill, destBase);
  }

  const srcPath = getSkillSourcePath(skill, langPath);
  const destPath = join(destBase, skill);

  if (!existsSync(srcPath)) {
    // For remote skills with langPath, the zh-TW translation may not exist
    if (REMOTE_SKILLS[skill]) {
      console.log(chalk.dim(`   ℹ️  No ${langPath} translation for ${skill}, using English`));
      return downloadRemoteSkill(skill, destBase);
    }
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

  // Step 3: Select Installation Scope (global vs project)
  const installScope = await select({
    message: msg.selectScope,
    choices: [
      { name: msg.scopeProject, value: 'project' },
      { name: msg.scopeGlobal, value: 'global' },
    ],
  });

  const scopePresets = AGENT_PRESETS[installScope];

  // Step 4: Select Agent / Path
  const agentType = await select({
    message: msg.selectAgent,
    choices: Object.entries(scopePresets).map(([key, preset]) => ({
      name: preset.name + (preset.path ? ` (${preset.path})` : ''),
      value: key,
    })),
  });

  let installPath;
  if (agentType === 'custom') {
    const defaultPath = installScope === 'global'
      ? join(homedir(), '.gemini', 'antigravity', 'skills')
      : '.agent/skills';
    installPath = await input({
      message: msg.inputPath,
      default: defaultPath,
    });
  } else {
    installPath = scopePresets[agentType].path;
  }

  // Resolve to absolute path
  const absolutePath = installScope === 'global'
    ? resolve(installPath)
    : resolve(process.cwd(), installPath);

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
