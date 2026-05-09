---
name: docx
description: "當使用者想要建立、閱讀、編輯或操作 Word 文件（.docx 檔案）時使用此技能。觸發條件包括：任何提及 'Word doc'、'word 文件'、'.docx'，或是要求製作帶有目錄、標題、頁碼或信頭等格式的專業文件。另外，當從 .docx 檔案中萃取或重組內容、在文件中插入或取代圖片、在 Word 檔案中執行尋找與取代、處理追蹤修訂或註解，或將內容轉換為精美的 Word 文件時，也請使用此技能。如果是要求將 '報告'、'備忘錄'、'信件'、'範本' 或類似的可交付成果作為 Word 或 .docx 檔案，請使用此技能。請勿將此技能用於 PDF、試算表、Google 文件，或與文件生成無關的一般編碼任務。"
license: Proprietary. 完整條款請見 LICENSE.txt
---

# DOCX 建立、編輯與分析

## 概覽

.docx 檔案是包含 XML 檔案的 ZIP 壓縮檔。

## 快速參考

| 任務 | 處理方式 |
|------|----------|
| 讀取/分析內容 | `pandoc` 或解壓縮以取得原始 XML |
| 建立新文件 | 使用 `docx-js` - 請參閱下方「建立新文件」段落 |
| 編輯現有文件 | 解壓縮 → 編輯 XML → 重新打包 - 請參閱下方「編輯現有文件」段落 |

### 將 .doc 轉換為 .docx

傳統的 `.doc` 檔案在編輯前必須先進行轉換：

```bash
python scripts/office/soffice.py --headless --convert-to docx document.doc
```

### 讀取內容

```bash
# 保留追蹤修訂的文字萃取
pandoc --track-changes=all document.docx -o output.md

# 原始 XML 存取
python scripts/office/unpack.py document.docx unpacked/
```

### 轉換為圖片

```bash
python scripts/office/soffice.py --headless --convert-to pdf document.docx
pdftoppm -jpeg -r 150 document.pdf page
```

### 接受追蹤修訂

若要產生已接受所有追蹤修訂的乾淨文件（需要 LibreOffice）：

```bash
python scripts/accept_changes.py input.docx output.docx
```

---

## 建立新文件

使用 JavaScript 產生 .docx 檔案，然後進行驗證。安裝：`npm install -g docx`

### 設定
```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
        Header, Footer, AlignmentType, PageOrientation, LevelFormat, ExternalHyperlink,
        InternalHyperlink, Bookmark, FootnoteReferenceRun, PositionalTab,
        PositionalTabAlignment, PositionalTabRelativeTo, PositionalTabLeader,
        TabStopType, TabStopPosition, Column, SectionType,
        TableOfContents, HeadingLevel, BorderStyle, WidthType, ShadingType,
        VerticalAlign, PageNumber, PageBreak } = require('docx');

const doc = new Document({ sections: [{ children: [/* 內容 */] }] });
Packer.toBuffer(doc).then(buffer => fs.writeFileSync("doc.docx", buffer));
```

### 驗證
建立檔案後，對其進行驗證。如果驗證失敗，請解壓縮、修正 XML，然後重新打包。
```bash
python scripts/office/validate.py doc.docx
```

### 頁面大小

```javascript
// 注意 (CRITICAL): docx-js 預設為 A4，而非 US Letter
// 始終明確設定頁面大小以獲取一致的結果
sections: [{
  properties: {
    page: {
      size: {
        width: 12240,   // 8.5 英吋的 DXA 單位
        height: 15840   // 11 英吋的 DXA 單位
      },
      margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } // 1 英吋邊距
    }
  },
  children: [/* 內容 */]
}]
```

**常見的頁面大小 (DXA 單位，1440 DXA = 1 英吋):**

| 紙張 | 寬度 | 高度 | 內容寬度 (1 英吋邊距) |
|-------|-------|--------|---------------------------|
| US Letter | 12,240 | 15,840 | 9,360 |
| A4 (預設) | 11,906 | 16,838 | 9,026 |

**橫向方向 (Landscape orientation):** docx-js 在內部會對調寬度/高度，因此請傳入直向的尺寸，讓它處理對調：
```javascript
size: {
  width: 12240,   // 將短邊作為寬度傳入
  height: 15840,  // 將長邊作為高度傳入
  orientation: PageOrientation.LANDSCAPE  // docx-js 會在 XML 中將它們對調
},
// 內容寬度 = 15840 - 左邊距 - 右邊距 (使用長邊)
```

### 樣式 (覆寫內建標題)

使用 Arial 作為預設字型（普遍支援）。保持標題為黑色以便於閱讀。

```javascript
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } }, // 12pt 預設值
    paragraphStyles: [
      // 重要 (IMPORTANT): 使用完全相同的 ID 來覆寫內建樣式
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } }, // 目錄 (TOC) 需要 outlineLevel
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, font: "Arial" },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 } },
    ]
  },
  sections: [{
    children: [
      new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Title")] }),
    ]
  }]
});
```

### 清單 (絕對不要使用 Unicode 項目符號)

```javascript
// ❌ 錯誤做法 - 絕對不要手動插入項目符號字元
new Paragraph({ children: [new TextRun("• Item")] })  // 錯誤
new Paragraph({ children: [new TextRun("\u2022 Item")] })  // 錯誤

// ✅ 正確做法 - 使用帶有 LevelFormat.BULLET 的編號設定
const doc = new Document({
  numbering: {
    config: [
      { reference: "bullets",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "numbers",
        levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
    ]
  },
  sections: [{
    children: [
      new Paragraph({ numbering: { reference: "bullets", level: 0 },
        children: [new TextRun("Bullet item")] }),
      new Paragraph({ numbering: { reference: "numbers", level: 0 },
        children: [new TextRun("Numbered item")] }),
    ]
  }]
});

// ⚠️ 每個 reference 會建立獨立的編號系統
// 相同的 reference = 延續 (1,2,3 然後 4,5,6)
// 不同的 reference = 重新開始 (1,2,3 然後 1,2,3)
```

### 表格

**注意 (CRITICAL): 表格需要雙重寬度設定** - 在表格上設定 `columnWidths`，**並且**在每個儲存格設定 `width`。如果沒有兩者都設定，表格在某些平台上會呈現錯誤。

```javascript
// 注意 (CRITICAL): 始終設定表格寬度以獲得一致的渲染結果
// 注意 (CRITICAL): 使用 ShadingType.CLEAR (非 SOLID) 來防止黑色背景
const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const borders = { top: border, bottom: border, left: border, right: border };

new Table({
  width: { size: 9360, type: WidthType.DXA }, // 始終使用 DXA (百分比設定在 Google Docs 中會損壞)
  columnWidths: [4680, 4680], // 必須加總為表格寬度 (DXA: 1440 = 1 英吋)
  rows: [
    new TableRow({
      children: [
        new TableCell({
          borders,
          width: { size: 4680, type: WidthType.DXA }, // 同時也設定在每個儲存格上
          shading: { fill: "D5E8F0", type: ShadingType.CLEAR }, // 是 CLEAR 而非 SOLID
          margins: { top: 80, bottom: 80, left: 120, right: 120 }, // 儲存格內邊距 (內部的，不會增加到寬度)
          children: [new Paragraph({ children: [new TextRun("Cell")] })]
        })
      ]
    })
  ]
})
```

**表格寬度計算:**

始終使用 `WidthType.DXA` — `WidthType.PERCENTAGE` 在 Google Docs 中會損壞。

```javascript
// 表格寬度 = columnWidths 的總和 = 內容寬度
// US Letter 搭配 1 英吋邊距: 12240 - 2880 = 9360 DXA
width: { size: 9360, type: WidthType.DXA },
columnWidths: [7000, 2360]  // 必須加總為表格寬度
```

**寬度規則:**
- **始終使用 `WidthType.DXA`** — 絕對不要用 `WidthType.PERCENTAGE`（與 Google Docs 不相容）
- 表格寬度必須等於 `columnWidths` 的總和
- 儲存格的 `width` 必須與對應的 `columnWidth` 相符
- 儲存格的 `margins` 是內部邊距 - 它們會減少內容區域，而不會增加到儲存格寬度
- 對於全寬表格：使用內容寬度 (頁面寬度減去左邊與右邊距)

### 圖片

```javascript
// 注意 (CRITICAL): type 參數是必須的
new Paragraph({
  children: [new ImageRun({
    type: "png", // 必須是: png, jpg, jpeg, gif, bmp, svg
    data: fs.readFileSync("image.png"),
    transformation: { width: 200, height: 150 },
    altText: { title: "Title", description: "Desc", name: "Name" } // 這三個都是必須的
  })]
})
```

### 分頁符號

```javascript
// 注意 (CRITICAL): PageBreak 必須在一個 Paragraph 內
new Paragraph({ children: [new PageBreak()] })

// 或使用 pageBreakBefore
new Paragraph({ pageBreakBefore: true, children: [new TextRun("New page")] })
```

### 超連結

```javascript
// 外部連結
new Paragraph({
  children: [new ExternalHyperlink({
    children: [new TextRun({ text: "Click here", style: "Hyperlink" })],
    link: "https://example.com",
  })]
})

// 內部連結 (書籤 + 參考)
// 1. 在目標位置建立書籤
new Paragraph({ heading: HeadingLevel.HEADING_1, children: [
  new Bookmark({ id: "chapter1", children: [new TextRun("Chapter 1")] }),
]})
// 2. 連結到它
new Paragraph({ children: [new InternalHyperlink({
  children: [new TextRun({ text: "See Chapter 1", style: "Hyperlink" })],
  anchor: "chapter1",
})]})
```

### 註腳

```javascript
const doc = new Document({
  footnotes: {
    1: { children: [new Paragraph("Source: Annual Report 2024")] },
    2: { children: [new Paragraph("See appendix for methodology")] },
  },
  sections: [{
    children: [new Paragraph({
      children: [
        new TextRun("Revenue grew 15%"),
        new FootnoteReferenceRun(1),
        new TextRun(" using adjusted metrics"),
        new FootnoteReferenceRun(2),
      ],
    })]
  }]
});
```

### 定位點 (Tab Stops)

```javascript
// 在同一行上靠右對齊文字 (例如，標題對面的日期)
new Paragraph({
  children: [
    new TextRun("Company Name"),
    new TextRun("\tJanuary 2025"),
  ],
  tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }],
})

// 點狀前導字元 (例如，目錄樣式)
new Paragraph({
  children: [
    new TextRun("Introduction"),
    new TextRun({ children: [
      new PositionalTab({
        alignment: PositionalTabAlignment.RIGHT,
        relativeTo: PositionalTabRelativeTo.MARGIN,
        leader: PositionalTabLeader.DOT,
      }),
      "3",
    ]}),
  ],
})
```

### 多欄版面配置

```javascript
// 等寬的欄位
sections: [{
  properties: {
    column: {
      count: 2,          // 欄數
      space: 720,        // 欄與欄之間的間距，以 DXA 為單位 (720 = 0.5 英吋)
      equalWidth: true,
      separate: true,    // 欄之間的分隔線
    },
  },
  children: [/* 內容會自然地跨欄流動 */]
}]

// 自訂寬度的欄位 (equalWidth 必須是 false)
sections: [{
  properties: {
    column: {
      equalWidth: false,
      children: [
        new Column({ width: 5400, space: 720 }),
        new Column({ width: 3240 }),
      ],
    },
  },
  children: [/* 內容 */]
}]
```

強制使用新節 (`type: SectionType.NEXT_COLUMN`) 進行分欄。

### 目錄

```javascript
// 注意 (CRITICAL): 標題必須只使用 HeadingLevel - 標題段落上不得有自訂樣式
new TableOfContents("Table of Contents", { hyperlink: true, headingStyleRange: "1-3" })
```

### 頁首/頁尾

```javascript
sections: [{
  properties: {
    page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } // 1440 = 1 英吋
  },
  headers: {
    default: new Header({ children: [new Paragraph({ children: [new TextRun("Header")] })] })
  },
  footers: {
    default: new Footer({ children: [new Paragraph({
      children: [new TextRun("Page "), new TextRun({ children: [PageNumber.CURRENT] })]
    })] })
  },
  children: [/* 內容 */]
}]
```

### docx-js 的關鍵規則

- **明確設定頁面大小** - docx-js 預設為 A4；對於 US 文件，請使用 US Letter (12240 x 15840 DXA)
- **橫向方向：傳遞直向尺寸** - docx-js 在內部會調換寬度和高度；傳遞短邊作為 `width`，長邊作為 `height`，並設定 `orientation: PageOrientation.LANDSCAPE`
- **絕對不要使用 `\n`** - 使用個別的 Paragraph 元素
- **絕對不要使用 Unicode 項目符號字元** - 使用帶有 numbering config 的 `LevelFormat.BULLET`
- **PageBreak 必須在 Paragraph 中** - 單獨使用建立的 XML 將無效
- **ImageRun 需要 `type` 屬性** - 一定要指定 png/jpg/等
- **始終以 DXA 設定表格 `width`** - 絕對不要使用 `WidthType.PERCENTAGE` (在 Google Docs 會毀損)
- **表格需要雙重寬度** - `columnWidths` 陣列 AND 儲存格的 `width`，兩者必須匹配
- **表格寬度 = columnWidths 之和** - 對於 DXA，請確保它們完全相加
- **務必加入儲存格 margins** - 使用 `margins: { top: 80, bottom: 80, left: 120, right: 120 }`，提供可讀的留白
- **使用 `ShadingType.CLEAR`** - 不要為表格陰影使用 SOLID
- **絕不要使用表格作為分隔線/規則** - 儲存格有最小高度，而且將被渲染成空盒子（即便是頁首/頁尾也是這樣）；在 Paragraph 上使用 `border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "2E75B6", space: 1 } }` 。如果兩欄頁尾，使用 tab stops（請見上述介紹），別使用表格。
- **TOC 僅需 HeadingLevel** - 不要自訂標題圖形段落樣式。
- **複寫內建樣式** - 使用確切的 IDs："Heading1"、"Heading2" 等。
- **包含 `outlineLevel`** - 為 TOC 需要 (H1 為 0, H2 為 1, 等。)

---

## 編輯現有文件

**請依序執行這 3 個步驟。**

### 步驟 1：解壓縮
```bash
python scripts/office/unpack.py document.docx unpacked/
```
擷取 XML，進行排版美化 (pretty-print)，合併相鄰片段 (runs)，並將智慧引號轉換為 XML 實體 (`&#x201C;` 等)，這樣它們就能在編輯過程存留下來。使用 `--merge-runs false` 可跳過合併 fragment 過程。

### 步驟 2：編輯 XML

直接編輯在 `unpacked/word/` 的檔案。在以下可找到 XML 參考模式。

**追蹤修訂與註解的作者預設使用 "Claude"**，除非使用者明確要求使用不同的名稱。

**請直接使用 Edit 工具進行字串置換，不要寫 Python 腳本。** 腳本會帶來不必要的複雜度；Edit 工具會明確顯示替換的內容。

**關鍵（CRITICAL）：新增內容請使用 smart quotes。** 加入帶有撇號或引號的文字時，請以 XML 實體產生 smart quotes：
```xml
<!-- 使用以下實體以呈現專業排版 -->
<w:t>Here&#x2019;s a quote: &#x201C;Hello&#x201D;</w:t>
```
| 實體 | 字元 |
|--------|-----------|
| `&#x2018;` | ‘（左單引號）|
| `&#x2019;` | ’（右單引號／撇號）|
| `&#x201C;` | “（左雙引號）|
| `&#x201D;` | ”（右雙引號）|

**加入註解（Comments）：** 使用 `comment.py` 處理多個 XML 檔案的樣板程式碼（傳入的文字必須先做 XML 跳脫）：
```bash
python scripts/comment.py unpacked/ 0 "Comment text with &amp; and &#x2019;"
python scripts/comment.py unpacked/ 1 "Reply text" --parent 0  # 回覆編號 0 的註解
python scripts/comment.py unpacked/ 0 "Text" --author "Custom Author"  # 自訂作者名稱
```
然後在 `document.xml` 中加入標記（請見下方「XML 參考資料」中的「註解」一節）。

### 步驟 3：打包
```bash
python scripts/office/pack.py unpacked/ output.docx --original document.docx
```
透過自動修復進行驗證、壓縮 XML 並產生 DOCX。加上 `--validate false` 可略過驗證。

**自動修復會處理：**
- `durableId` >= 0x7FFFFFFF（重新產生合法的 ID）
- 含有空白的 `<w:t>` 缺少 `xml:space="preserve"` 屬性

**自動修復不會處理：**
- 格式錯誤的 XML、不合法的元素巢狀、缺少的 relationships、違反 schema 的內容。

### 常見陷阱

- **整個替換 `<w:r>` 元素**：加入追蹤修訂時，請以 `<w:del>...<w:ins>...` 作為兄弟節點，整個取代原本的 `<w:r>...</w:r>` 區塊。不要把追蹤修訂標籤塞在 run 內部。
- **保留 `<w:rPr>` 的格式設定**：將原始 run 的 `<w:rPr>` 區塊複製到你的追蹤修訂 run 內，以維持粗體、字型大小等格式。

---

## XML 參考資料

### Schema 合規

- **`<w:pPr>` 內元素的順序**：`<w:pStyle>`、`<w:numPr>`、`<w:spacing>`、`<w:ind>`、`<w:jc>`，最後才是 `<w:rPr>`。
- **空白處理**：含有前導／尾隨空白的 `<w:t>` 必須加上 `xml:space="preserve"`。
- **RSIDs**：必須是 8 位元的十六進位（例如 `00AB1234`）。

### 追蹤修訂

**插入：**
```xml
<w:ins w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:t>inserted text</w:t></w:r>
</w:ins>
```

**刪除：**
```xml
<w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>deleted text</w:delText></w:r>
</w:del>
```

**`<w:del>` 內部**：使用 `<w:delText>` 而非 `<w:t>`，使用 `<w:delInstrText>` 而非 `<w:instrText>`。

**最小幅度編輯** —— 只標記真正改動的部分：
```xml
<!-- 將 "30 days" 改為 "60 days" -->
<w:r><w:t>The term is </w:t></w:r>
<w:del w:id="1" w:author="Claude" w:date="...">
  <w:r><w:delText>30</w:delText></w:r>
</w:del>
<w:ins w:id="2" w:author="Claude" w:date="...">
  <w:r><w:t>60</w:t></w:r>
</w:ins>
<w:r><w:t> days.</w:t></w:r>
```

**刪除整個段落／清單項目** —— 移除一段（或一個項目）的所有內容時，連同段落標記也要標記為已刪除，這樣接受變更後該段才會與下一段合併。請在 `<w:pPr><w:rPr>` 中加入 `<w:del/>`：
```xml
<w:p>
  <w:pPr>
    <w:numPr>...</w:numPr>  <!-- 若是清單項目，保留編號設定 -->
    <w:rPr>
      <w:del w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z"/>
    </w:rPr>
  </w:pPr>
  <w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
    <w:r><w:delText>Entire paragraph content being deleted...</w:delText></w:r>
  </w:del>
</w:p>
```
若 `<w:pPr><w:rPr>` 內未加上 `<w:del/>`，接受變更後會留下一個空段落／空清單項目。

**拒絕其他作者的插入** —— 將刪除巢狀放在他人的插入之內：
```xml
<w:ins w:author="Jane" w:id="5">
  <w:del w:author="Claude" w:id="10">
    <w:r><w:delText>their inserted text</w:delText></w:r>
  </w:del>
</w:ins>
```

**還原其他作者的刪除** —— 在他人的刪除之後新增插入（不要修改他人原本的刪除）：
```xml
<w:del w:author="Jane" w:id="5">
  <w:r><w:delText>deleted text</w:delText></w:r>
</w:del>
<w:ins w:author="Claude" w:id="10">
  <w:r><w:t>deleted text</w:t></w:r>
</w:ins>
```

### 註解

執行完 `comment.py`（見「步驟 2」）之後，在 `document.xml` 中加入標記。要回覆某則註解時，請使用 `--parent` 旗標，並把回覆的標記巢狀放在父註解的標記之內。

**CRITICAL：`<w:commentRangeStart>` 與 `<w:commentRangeEnd>` 是 `<w:r>` 的兄弟節點，絕對不能放在 `<w:r>` 內部。**

```xml
<!-- 註解標記是 <w:p> 的直接子節點，絕不放在 <w:r> 內部 -->
<w:commentRangeStart w:id="0"/>
<w:del w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>deleted</w:delText></w:r>
</w:del>
<w:r><w:t> more text</w:t></w:r>
<w:commentRangeEnd w:id="0"/>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>

<!-- 註解 0，內部巢狀放入回覆 1 -->
<w:commentRangeStart w:id="0"/>
  <w:commentRangeStart w:id="1"/>
  <w:r><w:t>text</w:t></w:r>
  <w:commentRangeEnd w:id="1"/>
<w:commentRangeEnd w:id="0"/>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="1"/></w:r>
```

### 圖片

1. 將圖片檔案放到 `word/media/`。
2. 在 `word/_rels/document.xml.rels` 加入 relationship：
```xml
<Relationship Id="rId5" Type=".../image" Target="media/image1.png"/>
```
3. 在 `[Content_Types].xml` 加入 content type：
```xml
<Default Extension="png" ContentType="image/png"/>
```
4. 在 `document.xml` 中引用圖片：
```xml
<w:drawing>
  <wp:inline>
    <wp:extent cx="914400" cy="914400"/>  <!-- EMU 單位：914400 = 1 英吋 -->
    <a:graphic>
      <a:graphicData uri=".../picture">
        <pic:pic>
          <pic:blipFill><a:blip r:embed="rId5"/></pic:blipFill>
        </pic:pic>
      </a:graphicData>
    </a:graphic>
  </wp:inline>
</w:drawing>
```

---

## 相依套件

- **pandoc**：文字擷取。
- **docx**：`npm install -g docx`（用於建立新文件）。
- **LibreOffice**：PDF 轉換（透過 `scripts/office/soffice.py` 自動配置沙盒環境）。
- **Poppler**：以 `pdftoppm` 將 PDF 轉為圖片。
