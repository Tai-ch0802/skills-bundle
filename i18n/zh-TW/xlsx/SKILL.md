---
name: xlsx
description: "當試算表檔案是主要的輸入或輸出時，使用此技能。涵蓋以下任務：開啟、讀取、編輯或修復現有的 .xlsx、.xlsm、.csv 或 .tsv 檔案（例如新增欄位、計算公式、套用格式、製作圖表、清理雜亂資料）；從零或從其他資料來源建立新的試算表；或在不同表格檔案格式之間轉換。當使用者以檔名或路徑提及試算表（即使只是隨口提到「我下載夾裡那個 xlsx」）並希望對它做點什麼或從中產出結果時，特別應觸發此技能；將格式錯亂的表格資料（行列錯位、表頭擺錯、夾雜雜訊）整理成正規試算表的需求也適用。最終交付物必須是試算表檔案。若主要交付物是 Word 文件、HTML 報告、獨立 Python 腳本、資料庫管線，或 Google Sheets API 整合（即使過程涉及表格資料），請勿觸發此技能。"
license: Proprietary. 完整條款請見 LICENSE.txt
---

# 輸出要求

## 所有 Excel 檔案

### 專業字型
- 除非使用者另有指示，否則所有交付成果皆應使用一致且專業的字型（例如 Arial、Times New Roman）。

### 零公式錯誤
- 每個 Excel 模型在交付時必須保證**零**公式錯誤（#REF!、#DIV/0!、#VALUE!、#N/A、#NAME?）。

### 保留現有範本（更新範本時）
- 修改檔案時，務必研究並**完全符合**其現有格式、樣式與慣例。
- 絕對不要將標準化格式強加到已有既定模式的檔案上。
- 現有範本的慣例**永遠**優先於這些指南。

## 財務模型

### 顏色編碼標準
除非使用者或現有範本另有說明：

#### 業界標準的顏色慣例
- **藍色文字 (RGB: 0,0,255)**：寫死的輸入值（Hardcoded inputs），以及使用者為了情境而會更改的數字。
- **黑色文字 (RGB: 0,0,0)**：所有的公式與計算。
- **綠色文字 (RGB: 0,128,0)**：從相同活頁簿內的其他工作表提取資料的連結。
- **紅色文字 (RGB: 255,0,0)**：連結至其他檔案的外部連結。
- **黃色背景 (RGB: 255,255,0)**：需要注意的關鍵假設，或需要被更新的儲存格。

### 數字格式化標準

#### 必須遵守的格式規則
- **年份**：格式化為文字字串（例如 "2024" 而非 "2,024"）。
- **貨幣**：使用 `$#,##0` 格式；務必在標題中指定單位（如 "營收 ($mm)"）。
- **零值 (Zeros)**：使用數字格式使所有零顯示為 "-"，包括百分比（例如 `"$#,##0;($#,##0);-"`）。
- **百分比**：預設為 0.0% 格式（小數點後一位）。
- **乘數/倍數 (Multiples)**：估值倍數（EV/EBITDA、P/E）格式化為 0.0x。
- **負數**：使用括號 (123) 而不是減號 -123。

### 公式建構規則

#### 假設位置
- 將所有假設（增長率、利潤率、倍數等）放在獨立的假設儲存格中。
- 在公式中使用儲存格參照，而不是寫死的數值。
- 範例：使用 `=B5*(1+$B$6)` 而不是 `=B5*1.05`。

#### 防止公式錯誤
- 驗證所有儲存格參照是否正確。
- 檢查範圍是否發生差一錯誤（off-by-one errors）。
- 確保所有預測期間的公式保持一致。
- 使用邊緣情況（零值、負數）進行測試。
- 驗證沒有意外的循環參照。

#### 寫死數值的文件要求
- 在儲存格內加上註解，或在旁邊儲存格說明（如果在表格末端）。格式：「來源: [系統/文件], [日期], [具體參考], [URL 如適用]」
- 範例：
  - "來源: 公司 10-K, FY2024, 頁 45, 營收備註, [SEC EDGAR URL]"
  - "來源: 公司 10-Q, Q2 2025, 附件 99.1, [SEC EDGAR URL]"
  - "來源: 彭博終端機, 8/15/2025, AAPL US Equity"
  - "來源: FactSet, 8/20/2025, 預估共識篩選"

# XLSX 建立、編輯與分析

## 概覽

使用者可能會要求你建立、編輯或分析 .xlsx 檔案的內容。針對不同的任務，你有不同的工具與工作流程可供使用。

## 重要要求

**重新計算公式需要 LibreOffice**：你可以假設已安裝 LibreOffice，並使用 `scripts/recalc.py` 腳本來重新計算公式值。該腳本會在首次執行時自動配置 LibreOffice，包括在 Unix sockets 受到限制的沙盒環境中（由 `scripts/office/soffice.py` 處理）。

## 讀取與分析資料

### 使用 pandas 進行資料分析
對於資料分析、視覺化與基本操作，請使用提供強大資料操作功能的 **pandas**：

```python
import pandas as pd

# 讀取 Excel
df = pd.read_excel('file.xlsx')                          # 預設：第一個工作表
all_sheets = pd.read_excel('file.xlsx', sheet_name=None) # 所有工作表以 dict 呈現

# 分析
df.head()      # 預覽資料
df.info()      # 欄位資訊
df.describe()  # 統計數據

# 寫入 Excel
df.to_excel('output.xlsx', index=False)
```

## Excel 檔案工作流程

## 關鍵 (CRITICAL)：使用公式，而非寫死數值

**請一律使用 Excel 公式，不要在 Python 中先計算好再把結果寫死到儲存格。** 這能確保試算表保持動態且可隨資料更新。

### ❌ 錯誤做法 — 將計算後的值寫死
```python
# 不良示範：在 Python 中計算並將結果寫死
total = df['Sales'].sum()
sheet['B10'] = total  # 寫死了 5000

# 不良示範：在 Python 中計算成長率
growth = (df.iloc[-1]['Revenue'] - df.iloc[0]['Revenue']) / df.iloc[0]['Revenue']
sheet['C5'] = growth  # 寫死了 0.15

# 不良示範：在 Python 計算平均數
avg = sum(values) / len(values)
sheet['D20'] = avg  # 寫死了 42.5
```

### ✅ 正確做法 — 使用 Excel 公式
```python
# 良好示範：讓 Excel 計算總和
sheet['B10'] = '=SUM(B2:B9)'

# 良好示範：成長率作為 Excel 公式
sheet['C5'] = '=(C4-C2)/C2'

# 良好示範：使用 Excel 公式計算平均數
sheet['D20'] = '=AVERAGE(D2:D19)'
```

此原則適用於**所有**計算 — 總計、百分比、比率、差值等等。當來源資料改變時，試算表必須能夠重新計算。

## 常見工作流程
1. **選擇工具**：用 pandas 處理資料，用 openpyxl 處理公式/格式
2. **建立／載入**：建立新活頁簿或載入現有檔案
3. **修改**：新增／編輯資料、公式與格式
4. **儲存**：寫入檔案
5. **重新計算公式（若使用了公式則為強制步驟）**：使用 `scripts/recalc.py` 腳本
   ```bash
   python scripts/recalc.py output.xlsx
   ```
6. **驗證並修復任何錯誤**：
   - 腳本會回傳含錯誤詳情的 JSON
   - 若 `status` 為 `errors_found`，請查看 `error_summary` 以瞭解錯誤類型與位置
   - 修復識別出的錯誤，然後再次重新計算
   - 常見的待修錯誤：
     - `#REF!`：無效的儲存格參照
     - `#DIV/0!`：除以零
     - `#VALUE!`：公式中的資料型別錯誤
     - `#NAME?`：無法識別的公式名稱

### 建立新的 Excel 檔案

```python
# 使用 openpyxl 設定公式與格式
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment

wb = Workbook()
sheet = wb.active

# 加入資料
sheet['A1'] = 'Hello'
sheet['B1'] = 'World'
sheet.append(['Row', 'of', 'data'])

# 加入公式
sheet['B2'] = '=SUM(A1:A10)'

# 套用格式
sheet['A1'].font = Font(bold=True, color='FF0000')
sheet['A1'].fill = PatternFill('solid', start_color='FFFF00')
sheet['A1'].alignment = Alignment(horizontal='center')

# 欄寬
sheet.column_dimensions['A'].width = 20

wb.save('output.xlsx')
```

### 編輯現有的 Excel 檔案

```python
# 使用 openpyxl 以保留公式與既有格式
from openpyxl import load_workbook

# 載入現有檔案
wb = load_workbook('existing.xlsx')
sheet = wb.active  # 或使用 wb['SheetName'] 開啟指定工作表

# 處理多個工作表
for sheet_name in wb.sheetnames:
    sheet = wb[sheet_name]
    print(f"Sheet: {sheet_name}")

# 修改儲存格
sheet['A1'] = 'New Value'
sheet.insert_rows(2)  # 在第 2 列插入新列
sheet.delete_cols(3)  # 刪除第 3 欄

# 在活頁簿中建立新工作表
new_sheet = wb.create_sheet('NewSheet')
new_sheet['A1'] = 'Data'

wb.save('modified.xlsx')
```

## 公式重新計算

由 openpyxl 建立或修改的 Excel 檔案會以字串形式保留公式，但不包含計算後的數值。請使用內附的 `scripts/recalc.py` 腳本重新計算公式：

```bash
python scripts/recalc.py <excel_file> [timeout_seconds]
```

範例：
```bash
python scripts/recalc.py output.xlsx 30
```

此腳本會：
- 首次執行時自動設定 LibreOffice 巨集
- 重算所有工作表中的所有公式
- 掃描所有儲存格，偵測 Excel 錯誤（#REF!、#DIV/0! 等）
- 回傳 JSON，含詳細錯誤位置與計數
- 同時支援 Linux 與 macOS

## 公式驗證檢查清單

確保公式正確運作的快速檢查項目：

### 基本驗證
- [ ] **測試 2–3 個取樣參照**：在建立完整模型前，先確認這些參照取出的值正確。
- [ ] **欄位對應**：確認 Excel 欄位代碼正確（例如第 64 欄 = BL，不是 BK）。
- [ ] **列序偏移**：謹記 Excel 列由 1 開始（DataFrame 第 5 列 ≡ Excel 第 6 列）。

### 常見陷阱
- [ ] **NaN 處理**：使用 `pd.notna()` 檢查空值。
- [ ] **最右側欄位**：年度（FY）資料常落在第 50 欄之後。
- [ ] **多筆匹配**：搜尋全部相符項，而非只取第一個。
- [ ] **除以零**：在公式中使用 `/` 之前先檢查分母（#DIV/0!）。
- [ ] **參照錯誤**：確認所有儲存格參照指向正確位置（#REF!）。
- [ ] **跨工作表參照**：以正確格式（如 `Sheet1!A1`）連結不同工作表。

### 公式測試策略
- [ ] **小規模起手**：先在 2–3 個儲存格上測試公式，再擴展套用。
- [ ] **驗證相依性**：確認公式所參照的儲存格皆存在。
- [ ] **涵蓋邊界情境**：測試零值、負數與極大值。

### 解讀 `scripts/recalc.py` 的輸出
腳本會回傳含錯誤資訊的 JSON：
```json
{
  "status": "success",           // 或 "errors_found"
  "total_errors": 0,              // 錯誤總數
  "total_formulas": 42,           // 檔案內公式數量
  "error_summary": {              // 僅在發現錯誤時出現
    "#REF!": {
      "count": 2,
      "locations": ["Sheet1!B5", "Sheet1!C10"]
    }
  }
}
```

## 最佳實踐

### 函式庫選擇
- **pandas**：適合資料分析、批次操作與簡易匯出。
- **openpyxl**：適合複雜格式、公式以及 Excel 特有功能。

### 使用 openpyxl 的注意事項
- 儲存格索引以 1 為起點（row=1、column=1 即儲存格 A1）。
- 以 `data_only=True` 讀取計算後的數值：`load_workbook('file.xlsx', data_only=True)`。
- **警告**：若以 `data_only=True` 開啟後再存檔，公式會被替換成數值並永久遺失。
- 大型檔案：讀取時使用 `read_only=True`；寫入時使用 `write_only=True`。
- 公式會被保留但不會被自動求值——請以 `scripts/recalc.py` 更新計算結果。

### 使用 pandas 的注意事項
- 明確指定資料型別，避免型別推斷問題：`pd.read_excel('file.xlsx', dtype={'id': str})`。
- 大型檔案僅讀取需要的欄位：`pd.read_excel('file.xlsx', usecols=['A', 'C', 'E'])`。
- 妥善處理日期：`pd.read_excel('file.xlsx', parse_dates=['date_column'])`。

## 程式碼風格指南

**重要**：在為 Excel 操作產生 Python 程式碼時：
- 撰寫精簡、扼要的 Python 程式碼，避免不必要的註解。
- 避免冗長的變數名稱與多餘的操作。
- 避免不必要的 `print` 敘述。

**對 Excel 檔案本身**：
- 為含有複雜公式或重要假設的儲存格加上註解。
- 為寫死的數值記錄資料來源。
- 為關鍵計算與模型段落加上說明。
