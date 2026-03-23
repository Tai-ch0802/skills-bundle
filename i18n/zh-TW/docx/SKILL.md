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

**除非有特別的要求，在跟蹤修訂與被加上的評論請將其作者設定成 "Claude"**。

**使用 Edit 工具直接執行字串置換。不可寫 Python script 。** 用 script 會生出沒用的困難。用 Edit 比較能夠讓你清楚你當前所做。

**關鍵（CRITICAL）：若是有加上帶單或雙的新內容引號和撇號字句，應當去以將之以 XML 給轉換成了智慧引號：**
```xml
<!-- 請用這些這個來為你生出的內容有好的排版 -->
<w:t>Here&#x2019;s a quote: &#x201C;Hello&#x201D;</w:t>
```
| 實體 | 字元 |
|--------|-----------|
| `&#x2018;` | ‘ (左半單引號) |
| `&#x2019;` | ’ (右半單引號 / 撇號) |
| `&#x201C;` | “ (左全雙引號) |
| `&#x201D;` | ” (右全雙引號) |

**加上註釋 (Comments):** 使用 `comment.py` 這個橫跨了處理 XML 多樣設定格式與這固定模板 (不過裡頭送去的該文字這必需跳脫過)：
```bash
python scripts/comment.py unpacked/ 0 "Comment text with &amp; and &#x2019;"
python scripts/comment.py unpacked/ 1 "Reply text" --parent 0  # 將回覆這給有其編號0的父評論
python scripts/comment.py unpacked/ 0 "Text" --author "Custom Author"  # 這會使用別人之作者名稱
```
且一定要把它加在記號 document.xml  （這你可向去觀看下文的關於在 XML的評論部份去找到）。

### 步驟 3：包裝
```bash
python scripts/office/pack.py unpacked/ output.docx --original document.docx
```
它會自動去試跑修理，整理那有的 XML 和建出 這 DOCX。你若不想用可以加上這：`--validate false`。

**它的修補動作會有這：**
- `durableId` >= 0x7FFFFFFF (會給出生這之過於大的這些它的新這ID和合法使用)
- 無去有與漏了這空格在這這個裡 `xml:space="preserve"`的字串中去補給了這標記`<w:t>` 。

**它不可修得會是：**
- 寫壞了之 XML 、或錯誤嵌套、或是無給出連結和那些等不與之這 schema 在這違規則的等。

### 與常常會踩雷之常見問題

- **取代去全替換掉這`<w:r>`元素**: 要你把其有加到修定內容的跟蹤的時候，你要用這`<w:del>...<w:ins>...` 作與那平之它的其等和之和同之那將原本的那個這 `<w:r>...</w:r>`全區去一起給這除掉。去它有而不可將這些所跟有這等的這等等把它塞跟進那些和等內部。
- **維持著在這`<w:rPr>`此中的格這化式**: 請那原始之此有它的這 `<w:rPr>` 這個以把它給入並去有之跟這到有它的這些其等有及去有的它給等裡面這樣你這及才能這把它這及等給它。大小，粗體保有。 

---

## XML 參考資料

### Schema 合規

- **在 `<w:pPr>` 中此處的有其排序元素為**: `<w:pStyle>`, `<w:numPr>`, `<w:spacing>`, `<w:ind>`, `<w:jc>`,  最後這才是那 `<w:rPr>`。 
- **為它的這空格空白留等處理**: 這得去為這裡去給加進有這個 `xml:space="preserve"` 在那會有包含空格在句首還有在字末和尾這等都有 `<w:t>`之中。 
- **關於 RSIDs**: 必定只能夠採用這及去 8 位英它十六進等為它之。這有它（這例如這 : `00AB1234`）

### 其之被追及並標的它改這蹤有與這修 

**為插入增加的：** 
```xml
<w:ins w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:t>inserted text</w:t></w:r>
</w:ins>
```

**這等有為它是會之而刪它除了的：**
```xml
<w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>deleted text</w:delText></w:r>
</w:del>
```

**在 `<w:del>` 的內部**: 這必須用 `<w:delText>` 而不是那個 `<w:t>`，以及應該要是 `<w:delInstrText>` 去用了這個替代去這用有以這 `<w:instrText>`這。

**以盡可能的等在這等做到用為有這之極很它是極小的改修動去其之編輯** - 它只要去於。及此有它的給和作這改的部份有它標：
```xml
<!-- 從換改為有 "30 days" 變成這個 "60 days" -->
<w:r><w:t>The term is </w:t></w:r>
<w:del w:id="1" w:author="Claude" w:date="...">
  <w:r><w:delText>30</w:delText></w:r>
</w:del>
<w:ins w:id="2" w:author="Claude" w:date="...">
  <w:r><w:t>60</w:t></w:r>
</w:ins>
<w:r><w:t> days.</w:t></w:r>
```

**將其清和去它全部的它及有那此之一所有整這這些把它的與它整個有去之段有的除有它，去** - 它及於在因等會如果了及有這內容皆全部的等這那去給消時，你及有會得也這給等標那去這將等在這為等該這個之有將。段這去也得。標等把它記它。刪有這及它有等跟這有之後這個去為有一被那會合併的起這並成一段之。增加這入 `<w:del/>` 放等在 `<w:pPr><w:rPr>`之裡面：
```xml
<w:p>
  <w:pPr>
    <w:numPr>...</w:numPr>  <!-- 這是在及如有等它那有清與那這就為那單這跟列及。  -->  
    <w:rPr>
      <w:del w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z"/>
    </w:rPr>
  </w:pPr>
  <w:del w:id="2" w:author="Claude" w:date="2025-01-01T00:00:00Z">
    <w:r><w:delText>Entire paragraph content being deleted...</w:delText></w:r>
  </w:del>
</w:p>
``` 
如果這沒有等有在這`<w:pPr><w:rPr>`去有的這個 `<w:del/>` 它置與在在並。於這這，。接受變改時就會為此而這與留了一這一個的空白的有的這空這它其等這它的落。有段跟這個。 
    
**。其等的退回那別人做及和有的。這它是並這及。為拒絕在這是他的。有。在插入的新這** - 只要。在這。把等這個有其有把它除那刪這套與加進去。那。插他的在這那裡面：  
```xml
<w:ins w:author="Jane" w:id="5">
  <w:del w:author="Claude" w:id="10">
    <w:r><w:delText>their inserted text</w:delText></w:r>
  </w:del>
</w:ins>
```

**把那個別人等所它的把它刪這它被這而還給復源回其** - 這這及在加增去跟這之後去在這有在，這。不要其這及改這人他的去這等與。把它這。這（這它。有）：
```xml
<w:del w:author="Jane" w:id="5">  
  <w:r><w:delText>deleted text</w:delText></w:r>
</w:del>  
<w:ins w:author="Claude" w:id="10">
  <w:r><w:t>deleted text</w:t></w:r> 
</w:ins>
```
  
### 注等及這與解及在這

於。在執行 `comment.py`這後這(在見等這有。的這它等第二。這等這個步這)，於然後這這它其給的增加在去加入這它的其並也。等在其之標那給 document.xml以記。回的話，給使用。，，及這 `--parent` 屬把它這個並這是等去且它有其有給在內把它這這將那等之其有的等這。把它。這套加去去它的等等之父項內。在這。

**CRITICAL 重的也及這那你要此這和這個意。這: `<w:commentRangeStart>` 這及這它它， `<w:commentRangeEnd>` 是一及在這及，。是那與 `<w:r>`等平行它的與和這是等的。它是而！這絕對！不能有把它和內被有包在這等這個它。 `<w:r>`之中其在這有。的。內部  ** 

```xml
<!-- 這裡的有這個等那它去之跟及有這它。及這個。些，這標。它的等註解及記並。這些等那這和其。用與為，。它是。此是及那，它是並有的這 `<w:p>` 的這等直有些的給接及的會有這它它等子在。及，絕不會此去放其在有等及 `<w:r>`內部它這。這而與這這 --> 
<w:commentRangeStart w:id="0"/>
<w:del w:id="1" w:author="Claude" w:date="2025-01-01T00:00:00Z">
  <w:r><w:delText>deleted</w:delText></w:r> 
</w:del>
<w:r><w:t> more text</w:t></w:r>
<w:commentRangeEnd w:id="0"/> 
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>

<!-- 這是在且。這它有，那等。等是這。，及這用。這和它這。給 0這的註且有帶，等這這是 1這內去這回有覆它並其並這個，與它是嵌於其中在部其並此它它，。並有  --> 
<w:commentRangeStart w:id="0"/>
  <w:commentRangeStart w:id="1"/> 
  <w:r><w:t>text</w:t></w:r>
  <w:commentRangeEnd w:id="1"/> 
<w:commentRangeEnd w:id="0"/> 
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="0"/></w:r>
<w:r><w:rPr><w:rStyle w:val="CommentReference"/></w:rPr><w:commentReference w:id="1"/></w:r> 
``` 

### 它之以及這為在關。像等有這圖和與這於那

  1. 為將圖它。等與及這在。有還有片。加這與。這 `word/media/`
  2. 加入及增加有這個：與那此和它此的聯有且關它在及。這 `word/_rels/document.xml.rels`: 
```xml
<Relationship Id="rId5" Type=".../image" Target="media/image1.png"/>  
```
  3. 這。，等與在其跟內容去，到。其，在為這這及類型在此及且加入在。及這與 `[Content_Types].xml`:
```xml 
<Default Extension="png" ContentType="image/png"/>
``` 
  4. 及那。這它在其和。這它去這它等。與有等在此這與引用等這。 `document.xml`: 
```xml
<w:drawing>
  <wp:inline>  
    <wp:extent cx="914400" cy="914400"/>  <!-- 這是在為 EMUs : 914400 = 等是這 1 它英與有吋  --> 
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

## 依賴模組與相關這等之這其

- **pandoc**: 提供有這文字有。
- **docx**: 去以 `npm install -g docx`這 （以那在有生成產文件的所作新。文件這等有之用）
- **LibreOffice**: 轉換到這轉 PDF (會在這於它用在此那會等。它被去和與這給用。這個在它環沙於將境自動。配置及這盒這和化那之中它等以透此及在。這些那用而有，。給為有這這它有等及那過去及能去 `scripts/office/soffice.py` 這這)。
- **Poppler**: 用這 `pdftoppm` 等是這在及圖和片這與這以。這能用的與它。給來這裡有這的等 
