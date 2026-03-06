---
name: web-artifacts-builder
description: 使用現代前端 Web 技術（React、Tailwind CSS、shadcn/ui）建立精緻的多元件 claude.ai HTML 產出物的工具套件。用於需要狀態管理、路由或 shadcn/ui 元件的複雜產出物 — 不適用於簡單的單檔 HTML/JSX 產出物。
license: 完整條款請見 LICENSE.txt
---

# Web 產出物建構器

要建構強大的前端 claude.ai 產出物，請依照以下步驟：
1. 使用 `scripts/init-artifact.sh` 初始化前端專案
2. 編輯生成的程式碼來開發你的產出物
3. 使用 `scripts/bundle-artifact.sh` 將所有程式碼打包為單一 HTML 檔案
4. 向使用者展示產出物
5. （可選）測試產出物

**技術堆疊**：React 18 + TypeScript + Vite + Parcel（打包）+ Tailwind CSS + shadcn/ui

## 設計與風格指南

**非常重要**：為避免所謂的「AI 廉價感」，避免使用過多置中佈局、紫色漸層、統一的圓角和 Inter 字體。

## 快速入門

### 步驟 1：初始化專案

執行初始化腳本以建立新的 React 專案：
```bash
bash scripts/init-artifact.sh <project-name>
cd <project-name>
```

這會建立一個完整配置的專案，包含：
- ✅ React + TypeScript（透過 Vite）
- ✅ Tailwind CSS 3.4.1 搭配 shadcn/ui 主題系統
- ✅ 路徑別名（`@/`）已配置
- ✅ 40+ 個 shadcn/ui 元件已預裝
- ✅ 所有 Radix UI 相依套件已包含
- ✅ Parcel 打包已配置（透過 .parcelrc）
- ✅ Node 18+ 相容（自動偵測並鎖定 Vite 版本）

### 步驟 2：開發你的產出物

要建構產出物，編輯生成的檔案。參見下方**常見開發任務**以獲得指引。

### 步驟 3：打包為單一 HTML 檔案

要將 React 應用程式打包為單一 HTML 產出物：
```bash
bash scripts/bundle-artifact.sh
```

這會建立 `bundle.html` — 一個自包含的產出物，所有 JavaScript、CSS 和相依套件皆已內嵌。此檔案可直接在 Claude 對話中作為產出物分享。

**需求**：你的專案必須在根目錄有 `index.html`。

**腳本行為**：
- 安裝打包相依套件（parcel、@parcel/config-default、parcel-resolver-tspaths、html-inline）
- 建立 `.parcelrc` 配置，支援路徑別名
- 使用 Parcel 建置（無 source maps）
- 使用 html-inline 將所有資源內嵌至單一 HTML

### 步驟 4：與使用者分享產出物

最後，在對話中分享打包的 HTML 檔案，讓使用者可以作為產出物檢視。

### 步驟 5：測試/視覺化產出物（可選）

注意：這是完全可選的步驟。僅在必要或被要求時執行。

要測試/視覺化產出物，使用可用工具（包括其他技能或內建工具如 Playwright 或 Puppeteer）。一般來說，避免事先測試產出物，因為這會增加請求到完成產出物之間的延遲。如果有需要或出現問題，在展示產出物後再測試。

## 參考資料

- **shadcn/ui 元件**：https://ui.shadcn.com/docs/components
