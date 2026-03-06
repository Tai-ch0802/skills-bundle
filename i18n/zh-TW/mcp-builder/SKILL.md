---
name: mcp-builder
description: 建立高質量 MCP (Model Context Protocol) 伺服器的指南，使 LLM 能透過精心設計的工具與外部服務互動。當需要建構 MCP 伺服器以整合外部 API 或服務時使用，無論是使用 Python (FastMCP) 或 Node/TypeScript (MCP SDK)。
license: 完整條款請見 LICENSE.txt
---

# MCP 伺服器開發指南

## 概覽

建立 MCP (Model Context Protocol) 伺服器，使 LLM 能透過精心設計的工具與外部服務互動。MCP 伺服器的品質取決於它如何良好地幫助 LLM 完成真實世界的任務。

---

# 流程

## 🚀 高階工作流程

建立高質量的 MCP 伺服器包含四個主要階段：

### 階段 1：深入研究與規劃

#### 1.1 了解現代 MCP 設計

**API 覆蓋率 vs. 工作流程工具：**
在全面的 API 端點覆蓋率和專門的工作流程工具之間取得平衡。工作流程工具對於特定任務可能更方便，而全面的覆蓋則讓代理程式有靈活性來組合操作。不同客戶端的效能各異 — 有些客戶端受益於結合基本工具的程式碼執行，而其他則在更高階的工作流程中表現更好。若不確定，請優先考慮全面的 API 覆蓋率。

**工具命名與可發現性：**
清晰、具描述性的工具名稱有助於代理程式快速找到正確的工具。使用一致的前綴（例如：`github_create_issue`、`github_list_repos`）和任務導向的命名。

**上下文管理：**
代理程式受益於簡潔的工具描述以及過濾/分頁結果的能力。設計能返回聚焦、相關資料的工具。有些客戶端支援程式碼執行，這可幫助代理程式有效率地過濾和處理資料。

**可執行的錯誤訊息：**
錯誤訊息應透過具體的建議和後續步驟引導代理程式解決問題。

#### 1.2 研讀 MCP 協定文件

**瀏覽 MCP 規格：**

從網站地圖開始尋找相關頁面：`https://modelcontextprotocol.io/sitemap.xml`

然後透過 `.md` 後綴取得特定頁面的 markdown 格式（例如：`https://modelcontextprotocol.io/specification/draft.md`）。

需要審閱的關鍵頁面：
- 規格概覽與架構
- 傳輸機制（streamable HTTP, stdio）
- 工具、資源和提示定義

#### 1.3 研讀框架文件

**建議的技術堆疊：**
- **語言**: TypeScript（高品質的 SDK 支援且在多數執行環境中具備良好相容性，例如 MCPB。此外 AI 模型擅長生成 TypeScript 程式碼，受益於其廣泛的使用率、靜態型別和良好的 linting 工具）
- **傳輸**: 對於遠端伺服器使用 Streamable HTTP，採用無狀態 JSON（比起有狀態的會話和串流回應更易於擴展與維護）。對於本地伺服器使用 stdio。

**載入框架文件：**

- **MCP 最佳實踐**: [📋 檢視最佳實踐](./reference/mcp_best_practices.md) - 核心指南

**對於 TypeScript（建議）：**
- **TypeScript SDK**: 使用 WebFetch 載入 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`
- [⚡ TypeScript 指南](./reference/node_mcp_server.md) - TypeScript 模式與範例

**對於 Python：**
- **Python SDK**: 使用 WebFetch 載入 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`
- [🐍 Python 指南](./reference/python_mcp_server.md) - Python 模式與範例

#### 1.4 規劃實作

**了解 API：**
審閱服務的 API 文件，識別關鍵端點、驗證需求和資料模型。視需要使用網頁搜尋和 WebFetch。

**工具選擇：**
優先考慮全面的 API 覆蓋率。列出要實作的端點，從最常見的操作開始。

---

### 階段 2：實作

#### 2.1 建立專案結構

請參閱特定語言的專案設定指南：
- [⚡ TypeScript 指南](./reference/node_mcp_server.md) - 專案結構、package.json、tsconfig.json
- [🐍 Python 指南](./reference/python_mcp_server.md) - 模組組織、相依套件

#### 2.2 實作核心基礎設施

建立共用工具程式：
- 具備驗證功能的 API 客戶端
- 錯誤處理輔助函數
- 回應格式化（JSON/Markdown）
- 分頁支援

#### 2.3 實作工具

針對每個工具：

**輸入 Schema:**
- 使用 Zod (TypeScript) 或 Pydantic (Python)
- 包含限制條件與清晰的描述
- 在欄位描述中加入範例

**輸出 Schema:**
- 盡可能為結構化資料定義 `outputSchema`
- 在工具回應中使用 `structuredContent` (TypeScript SDK 功能)
- 幫助客戶端理解與處理工具輸出

**工具描述:**
- 功能的簡潔摘要
- 參數描述
- 返回型別 schema

**實作:**
- 針對 I/O 操作使用 async/await
- 適當的錯誤處理與可執行的訊息
- 支援適用的分頁
- 當使用現代 SDK 時，返回文字內容和結構化資料

**註解:**
- `readOnlyHint`: true/false
- `destructiveHint`: true/false
- `idempotentHint`: true/false
- `openWorldHint`: true/false

---

### 階段 3：審核與測試

#### 3.1 程式碼品質

審核以下項目：
- 無重複程式碼（DRY 原則）
- 一致的錯誤處理
- 完整的型別覆蓋
- 清晰的工具描述

#### 3.2 建置與測試

**TypeScript:**
- 執行 `npm run build` 以驗證編譯
- 使用 MCP Inspector 測試: `npx @modelcontextprotocol/inspector`

**Python:**
- 驗證語法: `python -m py_compile your_server.py`
- 使用 MCP Inspector 測試

請參閱特定語言指南以獲取詳細的測試方法和品質檢查清單。

---

### 階段 4：建立評估

在實作 MCP 伺服器之後，建立全面性的評估來測試其有效性。

**載入 [✅ 評估指南](./reference/evaluation.md) 獲取完整的評估準則。**

#### 4.1 了解評估目的

使用評估來測試 LLM 是否能有效使用您的 MCP 伺服器回答真實且複雜的問題。

#### 4.2 建立 10 個評估問題

要建立有效的評估，請遵循評估指南中列出的流程：

1. **工具檢查**: 列出可用工具並了解其能力
2. **內容探索**: 使用 READ-ONLY (唯讀) 操作探索可用資料
3. **問題生成**: 建立 10 個複雜、真實的問題
4. **答案驗證**: 自行解決每個問題以驗證答案

#### 4.3 評估要求

確保每個問題符合：
- **獨立性**: 不依賴其他問題
- **唯讀**: 只需要非破壞性操作
- **複雜性**: 需要多次呼叫工具和深度探索
- **真實性**: 基於人類關心的真實用例
- **可驗證性**: 單一、明確的答案，可透過字串比對進行驗證
- **穩定性**: 答案不會隨時間改變

#### 4.4 輸出格式

建立具有此結構的 XML 檔案：

```xml
<evaluation>
  <qa_pair>
    <question>Find discussions about AI model launches with animal codenames. One model needed a specific safety designation that uses the format ASL-X. What number X was being determined for the model named after a spotted wild cat?</question>
    <answer>3</answer>
  </qa_pair>
<!-- 更多 qa_pairs... -->
</evaluation>
```

---

# 參考檔案

## 📚 文件庫

開發期間視需要載入這些資源：

### 核心 MCP 文件 (優先載入)
- **MCP Protocol**: 從網站地圖 `https://modelcontextprotocol.io/sitemap.xml` 開始，然後取得具 `.md` 後綴的特定頁面
- [📋 MCP 最佳實踐](./reference/mcp_best_practices.md) - 包含以下內容的通用 MCP 指南：
  - 伺服器與工具命名約定
  - 回應格式準則 (JSON vs Markdown)
  - 分頁最佳實踐
  - 傳輸選擇 (streamable HTTP vs stdio)
  - 安全性與錯誤處理標準

### SDK 文件 (階段 1/2 載入)
- **Python SDK**: 從 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md` 獲取
- **TypeScript SDK**: 從 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md` 獲取

### 特定語言實作指南 (階段 2 載入)
- [🐍 Python 實作指南](./reference/python_mcp_server.md) - 完整的 Python/FastMCP 指南，包含：
  - 伺服器初始化模式
  - Pydantic 模型範例
  - 使用 `@mcp.tool` 註冊工具
  - 完整可用範例
  - 品質檢查清單

- [⚡ TypeScript 實作指南](./reference/node_mcp_server.md) - 完整的 TypeScript 指南，包含：
  - 專案結構
  - Zod schema 模式
  - 使用 `server.registerTool` 註冊工具
  - 完整可用範例
  - 品質檢查清單

### 評估指南 (階段 4 載入)
- [✅ 評估指南](./reference/evaluation.md) - 完整的評估建立指南，包含：
  - 問題建立準則
  - 答案驗證策略
  - XML 格式規格
  - 問題與答案範例
  - 使用提供的腳本執行評估
