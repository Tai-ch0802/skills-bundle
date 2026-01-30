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
      selectSkills: 'Select skills to install:',
      selectAgent: 'Select your AI agent type:',
      inputPath: 'Enter custom installation path:',
      confirmInstall: 'Install to {path}?',
      installing: 'Installing skills...',
      installed: '✅ Installed: {skill}',
      complete: '🎉 Installation complete!',
      cancelled: '❌ Installation cancelled.',
      skillDescriptions: {
        prd: 'Product Requirements Document guidelines',
        sa: 'System Analysis methodology',
        sdd: 'Spec-Driven Development workflow (includes prd, sa)',
        refactoring: 'Code smell identification and refactoring techniques',
      },
    },
  },
  'zh-TW': {
    name: '繁體中文',
    path: 'i18n/zh-TW',
    messages: {
      welcome: '🚀 技能包安裝程式',
      selectLanguage: '請選擇您偏好的語言：',
      selectSkills: '請選擇要安裝的技能：',
      selectAgent: '請選擇您的 AI 代理類型：',
      inputPath: '請輸入自訂安裝路徑：',
      confirmInstall: '確認安裝至 {path}？',
      installing: '正在安裝技能...',
      installed: '✅ 已安裝：{skill}',
      complete: '🎉 安裝完成！',
      cancelled: '❌ 已取消安裝。',
      skillDescriptions: {
        prd: '產品需求文件指南',
        sa: '系統分析方法論',
        sdd: '規格驅動開發工作流程（包含 prd, sa）',
        refactoring: '程式碼異味識別與重構技術',
      },
    },
  },
};

const SKILLS = ['prd', 'sa', 'sdd', 'refactoring'];

const DEPENDENCIES = {
  prd: [],
  sa: [],
  sdd: ['prd', 'sa'],
  refactoring: [],
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

  // Step 2: Select Skills
  const selectedSkills = await checkbox({
    message: msg.selectSkills,
    choices: SKILLS.map((skill) => ({
      name: `${skill} - ${msg.skillDescriptions[skill]}`,
      value: skill,
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
