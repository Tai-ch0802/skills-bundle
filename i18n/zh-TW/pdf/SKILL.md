---
name: pdf
description: 當使用者想要對 PDF 檔案做任何操作時使用此技能。包括讀取或擷取 PDF 中的文字/表格、合併或合併多個 PDF 為一個、拆分 PDF、旋轉頁面、添加浮水印、建立新 PDF、填寫 PDF 表單、加密/解密 PDF、擷取圖片，以及對掃描的 PDF 進行 OCR 使其可搜尋。如果使用者提到 .pdf 檔案或要求產生 PDF，使用此技能。
license: 專有。LICENSE.txt 包含完整條款
---

# PDF 處理指南

## 概覽

本指南涵蓋使用 Python 函式庫和命令列工具進行的基本 PDF 處理操作。進階功能、JavaScript 函式庫和詳細範例，請參見 REFERENCE.md。如果需要填寫 PDF 表單，請閱讀 FORMS.md 並遵循其說明。

## 快速入門

```python
from pypdf import PdfReader, PdfWriter

# 讀取 PDF
reader = PdfReader("document.pdf")
print(f"Pages: {len(reader.pages)}")

# 擷取文字
text = ""
for page in reader.pages:
    text += page.extract_text()
```

## Python 函式庫

### pypdf - 基本操作

#### 合併 PDF
```python
from pypdf import PdfWriter, PdfReader

writer = PdfWriter()
for pdf_file in ["doc1.pdf", "doc2.pdf", "doc3.pdf"]:
    reader = PdfReader(pdf_file)
    for page in reader.pages:
        writer.add_page(page)

with open("merged.pdf", "wb") as output:
    writer.write(output)
```

#### 拆分 PDF
```python
reader = PdfReader("input.pdf")
for i, page in enumerate(reader.pages):
    writer = PdfWriter()
    writer.add_page(page)
    with open(f"page_{i+1}.pdf", "wb") as output:
        writer.write(output)
```

#### 擷取中繼資料
```python
reader = PdfReader("document.pdf")
meta = reader.metadata
print(f"Title: {meta.title}")
print(f"Author: {meta.author}")
print(f"Subject: {meta.subject}")
print(f"Creator: {meta.creator}")
```

#### 旋轉頁面
```python
reader = PdfReader("input.pdf")
writer = PdfWriter()

page = reader.pages[0]
page.rotate(90)  # 順時針旋轉 90 度
writer.add_page(page)

with open("rotated.pdf", "wb") as output:
    writer.write(output)
```

### pdfplumber - 文字和表格擷取

#### 擷取帶佈局的文字
```python
import pdfplumber

with pdfplumber.open("document.pdf") as pdf:
    for page in pdf.pages:
        text = page.extract_text()
        print(text)
```

#### 擷取表格
```python
with pdfplumber.open("document.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        for j, table in enumerate(tables):
            print(f"Table {j+1} on page {i+1}:")
            for row in table:
                print(row)
```

#### 進階表格擷取
```python
import pandas as pd

with pdfplumber.open("document.pdf") as pdf:
    all_tables = []
    for page in pdf.pages:
        tables = page.extract_tables()
        for table in tables:
            if table:  # 檢查表格是否非空
                df = pd.DataFrame(table[1:], columns=table[0])
                all_tables.append(df)

# 合併所有表格
if all_tables:
    combined_df = pd.concat(all_tables, ignore_index=True)
    combined_df.to_excel("extracted_tables.xlsx", index=False)
```

### reportlab - 建立 PDF

#### 基本 PDF 建立
```python
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

c = canvas.Canvas("hello.pdf", pagesize=letter)
width, height = letter

# 添加文字
c.drawString(100, height - 100, "Hello World!")
c.drawString(100, height - 120, "This is a PDF created with reportlab")

# 添加線條
c.line(100, height - 140, 400, height - 140)

# 儲存
c.save()
```

#### 建立多頁 PDF
```python
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.styles import getSampleStyleSheet

doc = SimpleDocTemplate("report.pdf", pagesize=letter)
styles = getSampleStyleSheet()
story = []

# 添加內容
title = Paragraph("Report Title", styles['Title'])
story.append(title)
story.append(Spacer(1, 12))

body = Paragraph("This is the body of the report. " * 20, styles['Normal'])
story.append(body)
story.append(PageBreak())

# 第 2 頁
story.append(Paragraph("Page 2", styles['Heading1']))
story.append(Paragraph("Content for page 2", styles['Normal']))

# 建置 PDF
doc.build(story)
```

#### 下標與上標

**重要**：絕不在 ReportLab PDF 中使用 Unicode 下標/上標字元（₀₁₂₃₄₅₆₇₈₉, ⁰¹²³⁴⁵⁶⁷⁸⁹）。內建字體不包含這些字型，會導致它們渲染為黑色實心方塊。

改用 ReportLab 的 XML 標記標籤在 Paragraph 物件中：
```python
from reportlab.platypus import Paragraph
from reportlab.lib.styles import getSampleStyleSheet

styles = getSampleStyleSheet()

# 下標：使用 <sub> 標籤
chemical = Paragraph("H<sub>2</sub>O", styles['Normal'])

# 上標：使用 <super> 標籤
squared = Paragraph("x<super>2</super> + y<super>2</super>", styles['Normal'])
```

對於 canvas 繪製的文字（非 Paragraph 物件），手動調整字體大小和位置，而非使用 Unicode 下標/上標。

## 命令列工具

### pdftotext (poppler-utils)
```bash
# 擷取文字
pdftotext input.pdf output.txt

# 保留佈局擷取文字
pdftotext -layout input.pdf output.txt

# 擷取特定頁面
pdftotext -f 1 -l 5 input.pdf output.txt  # 第 1-5 頁
```

### qpdf
```bash
# 合併 PDF
qpdf --empty --pages file1.pdf file2.pdf -- merged.pdf

# 拆分頁面
qpdf input.pdf --pages . 1-5 -- pages1-5.pdf
qpdf input.pdf --pages . 6-10 -- pages6-10.pdf

# 旋轉頁面
qpdf input.pdf output.pdf --rotate=+90:1  # 將第 1 頁旋轉 90 度

# 移除密碼
qpdf --password=mypassword --decrypt encrypted.pdf decrypted.pdf
```

### pdftk（如果可用）
```bash
# 合併
pdftk file1.pdf file2.pdf cat output merged.pdf

# 拆分
pdftk input.pdf burst

# 旋轉
pdftk input.pdf rotate 1east output rotated.pdf
```

## 常見任務

### 從掃描的 PDF 擷取文字
```python
# 需要：pip install pytesseract pdf2image
import pytesseract
from pdf2image import convert_from_path

# 將 PDF 轉換為圖片
images = convert_from_path('scanned.pdf')

# 對每頁進行 OCR
text = ""
for i, image in enumerate(images):
    text += f"Page {i+1}:\n"
    text += pytesseract.image_to_string(image)
    text += "\n\n"

print(text)
```

### 添加浮水印
```python
from pypdf import PdfReader, PdfWriter

# 建立浮水印（或載入現有的）
watermark = PdfReader("watermark.pdf").pages[0]

# 套用至所有頁面
reader = PdfReader("document.pdf")
writer = PdfWriter()

for page in reader.pages:
    page.merge_page(watermark)
    writer.add_page(page)

with open("watermarked.pdf", "wb") as output:
    writer.write(output)
```

### 擷取圖片
```bash
# 使用 pdfimages (poppler-utils)
pdfimages -j input.pdf output_prefix

# 這會擷取所有圖片為 output_prefix-000.jpg、output_prefix-001.jpg 等
```

### 密碼保護
```python
from pypdf import PdfReader, PdfWriter

reader = PdfReader("input.pdf")
writer = PdfWriter()

for page in reader.pages:
    writer.add_page(page)

# 添加密碼
writer.encrypt("userpassword", "ownerpassword")

with open("encrypted.pdf", "wb") as output:
    writer.write(output)
```

## 快速參考

| 任務 | 最佳工具 | 命令/程式碼 |
|------|----------|------------|
| 合併 PDF | pypdf | `writer.add_page(page)` |
| 拆分 PDF | pypdf | 每頁一個檔案 |
| 擷取文字 | pdfplumber | `page.extract_text()` |
| 擷取表格 | pdfplumber | `page.extract_tables()` |
| 建立 PDF | reportlab | Canvas 或 Platypus |
| 命令列合併 | qpdf | `qpdf --empty --pages ...` |
| OCR 掃描 PDF | pytesseract | 先轉換為圖片 |
| 填寫 PDF 表單 | pdf-lib 或 pypdf（見 FORMS.md）| 見 FORMS.md |

## 下一步

- 進階 pypdfium2 用法，請參見 REFERENCE.md
- JavaScript 函式庫（pdf-lib），請參見 REFERENCE.md
- 如果需要填寫 PDF 表單，請遵循 FORMS.md 中的說明
- 疑難排解指南，請參見 REFERENCE.md
