---
name: app-builder
description: "主要應用程式建構協調器。從自然語言請求建立全端應用。判定專案類型、選擇技術堆疊、協調代理。"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

# App Builder — 應用程式建構協調器

> 分析使用者的請求、決定技術堆疊、規劃結構並協調代理。

## 🎯 選擇性閱讀規則

**僅閱讀與請求相關的檔案！** 查看內容地圖，找到你需要的。

| 檔案 | 描述 | 何時閱讀 |
|------|------|----------|
| `project-detection.md` | 關鍵字矩陣、專案類型偵測 | 開始新專案 |
| `tech-stack.md` | 2026 預設堆疊、替代方案 | 選擇技術 |
| `agent-coordination.md` | 代理管線、執行順序 | 協調多代理工作 |
| `scaffolding.md` | 目錄結構、核心檔案 | 建立專案結構 |
| `feature-building.md` | 功能分析、錯誤處理 | 為現有專案新增功能 |
| `templates/SKILL.md` | **專案範本** | 搭建新專案骨架 |

---

## 📦 範本（13 個）

新專案的快速啟動骨架。**僅閱讀匹配的範本！**

| 範本 | 技術堆疊 | 適用時機 |
|------|----------|----------|
| [nextjs-fullstack](templates/nextjs-fullstack/TEMPLATE.md) | Next.js + Prisma | 全端 Web 應用 |
| [nextjs-saas](templates/nextjs-saas/TEMPLATE.md) | Next.js + Stripe | SaaS 產品 |
| [nextjs-static](templates/nextjs-static/TEMPLATE.md) | Next.js + Framer | 著陸頁 |
| [nuxt-app](templates/nuxt-app/TEMPLATE.md) | Nuxt 3 + Pinia | Vue 全端應用 |
| [express-api](templates/express-api/TEMPLATE.md) | Express + JWT | REST API |
| [python-fastapi](templates/python-fastapi/TEMPLATE.md) | FastAPI | Python API |
| [react-native-app](templates/react-native-app/TEMPLATE.md) | Expo + Zustand | 行動應用 |
| [flutter-app](templates/flutter-app/TEMPLATE.md) | Flutter + Riverpod | 跨平台行動 |
| [electron-desktop](templates/electron-desktop/TEMPLATE.md) | Electron + React | 桌面應用 |
| [chrome-extension](templates/chrome-extension/TEMPLATE.md) | Chrome MV3 | 瀏覽器擴充 |
| [cli-tool](templates/cli-tool/TEMPLATE.md) | Node.js + Commander | CLI 應用 |
| [monorepo-turborepo](templates/monorepo-turborepo/TEMPLATE.md) | Turborepo + pnpm | Monorepo |

---

## 🔗 相關代理

| 代理 | 角色 |
|------|------|
| `project-planner` | 任務分解、依賴圖 |
| `frontend-specialist` | UI 元件、頁面 |
| `backend-specialist` | API、業務邏輯 |
| `database-architect` | Schema、遷移 |
| `devops-engineer` | 部署、預覽 |

---

## 使用範例

```
使用者：「做一個有照片分享和按讚的 Instagram 複製品」

App Builder 流程：
1. 專案類型：社群媒體應用
2. 技術堆疊：Next.js + Prisma + Cloudinary + Clerk
3. 建立計畫：
   ├─ 資料庫 schema（users、posts、likes、follows）
   ├─ API 路由（12 個端點）
   ├─ 頁面（feed、profile、upload）
   └─ 元件（PostCard、Feed、LikeButton）
4. 協調代理
5. 報告進度
6. 啟動預覽
```
