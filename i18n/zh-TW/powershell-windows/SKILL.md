---
name: powershell-windows
description: PowerShell Windows 模式。關鍵陷阱、運算子語法、錯誤處理。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# PowerShell Windows 模式

> Windows PowerShell 的關鍵模式與陷阱。

---

## 1. 運算子語法規則

### 關鍵：需要括號

| ❌ 錯誤 | ✅ 正確 |
|---------|---------|
| `if (Test-Path "a" -or Test-Path "b")` | `if ((Test-Path "a") -or (Test-Path "b"))` |
| `if (Get-Item $x -and $y -eq 5)` | `if ((Get-Item $x) -and ($y -eq 5))` |

**規則：** 使用邏輯運算子時，每個 cmdlet 呼叫都必須在括號中。

---

## 2. Unicode/Emoji 限制

### 關鍵：腳本中不用 Unicode

| 用途 | ❌ 不要用 | ✅ 要用 |
|------|-----------|---------|
| 成功 | ✅ ✓ | [OK] [+] |
| 錯誤 | ❌ ✗ 🔴 | [!] [X] |
| 警告 | ⚠️ 🟡 | [*] [WARN] |
| 資訊 | ℹ️ 🔵 | [i] [INFO] |
| 進度 | ⏳ | [...] |

**規則：** PowerShell 腳本中僅使用 ASCII 字元。

---

## 3. Null 檢查模式

### 存取前始終檢查

| ❌ 錯誤 | ✅ 正確 |
|---------|---------|
| `$array.Count -gt 0` | `$array -and $array.Count -gt 0` |
| `$text.Length` | `if ($text) { $text.Length }` |

---

## 4. 字串插值

### 複雜表達式

| ❌ 錯誤 | ✅ 正確 |
|---------|---------|
| `"Value: $($obj.prop.sub)"` | 先存入變數 |

**模式：**
```
$value = $obj.prop.sub
Write-Output "Value: $value"
```

---

## 5. 錯誤處理

### ErrorActionPreference

| 值 | 用途 |
|----|------|
| Stop | 開發（快速失敗）|
| Continue | 生產腳本 |
| SilentlyContinue | 預期會有錯誤時 |

### Try/Catch 模式

- 不要在 try 區塊內 return
- 使用 finally 進行清理
- 在 try/catch 之後 return

---

## 6. 檔案路徑

### Windows 路徑規則

| 模式 | 用途 |
|------|------|
| 字面路徑 | `C:\Users\User\file.txt` |
| 變數路徑 | `Join-Path $env:USERPROFILE "file.txt"` |
| 相對路徑 | `Join-Path $ScriptDir "data"` |

**規則：** 使用 Join-Path 確保跨平台安全性。

---

## 7. 陣列操作

### 正確模式

| 操作 | 語法 |
|------|------|
| 空陣列 | `$array = @()` |
| 新增項目 | `$array += $item` |
| ArrayList 新增 | `$list.Add($item) | Out-Null` |

---

## 8. JSON 操作

### 關鍵：Depth 參數

| ❌ 錯誤 | ✅ 正確 |
|---------|---------|
| `ConvertTo-Json` | `ConvertTo-Json -Depth 10` |

**規則：** 巢狀物件始終指定 `-Depth`。

### 檔案操作

| 操作 | 模式 |
|------|------|
| 讀取 | `Get-Content "file.json" -Raw | ConvertFrom-Json` |
| 寫入 | `$data | ConvertTo-Json -Depth 10 | Out-File "file.json" -Encoding UTF8` |

---

## 9. 常見錯誤

| 錯誤訊息 | 原因 | 修復 |
|----------|------|------|
| "parameter 'or'" | 缺少括號 | 用 () 包裹 cmdlet |
| "Unexpected token" | Unicode 字元 | 僅使用 ASCII |
| "Cannot find property" | Null 物件 | 先檢查 null |
| "Cannot convert" | 型別不匹配 | 使用 .ToString() |

---

## 10. 腳本範本

```powershell
# 嚴格模式
Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# 路徑
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 主程式
try {
    # 邏輯放這裡
    Write-Output "[OK] 完成"
    exit 0
}
catch {
    Write-Warning "錯誤：$_"
    exit 1
}
```

---

> **記住：** PowerShell 有獨特的語法規則。括號、僅 ASCII 和 null 檢查是不可妥協的。
