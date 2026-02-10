---
name: bash-linux
description: Bash/Linux 終端模式。關鍵指令、管道、錯誤處理、腳本撰寫。用於 macOS 或 Linux 系統。
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Bash Linux 模式

> Bash 在 Linux/macOS 上的基本模式。

---

## 1. 運算子語法

### 串連指令

| 運算子 | 意義 | 範例 |
|--------|------|------|
| `;` | 依序執行 | `cmd1; cmd2` |
| `&&` | 前一個成功才執行 | `npm install && npm run dev` |
| `\|\|` | 前一個失敗才執行 | `npm test \|\| echo "Tests failed"` |
| `\|` | 管道輸出 | `ls \| grep ".js"` |

---

## 2. 檔案操作

### 基本指令

| 任務 | 指令 |
|------|------|
| 列出全部 | `ls -la` |
| 尋找檔案 | `find . -name "*.js" -type f` |
| 檔案內容 | `cat file.txt` |
| 前 N 行 | `head -n 20 file.txt` |
| 後 N 行 | `tail -n 20 file.txt` |
| 跟蹤日誌 | `tail -f log.txt` |
| 搜尋檔案內容 | `grep -r "pattern" --include="*.js"` |
| 檔案大小 | `du -sh *` |
| 磁碟用量 | `df -h` |

---

## 3. 程序管理

| 任務 | 指令 |
|------|------|
| 列出程序 | `ps aux` |
| 依名稱尋找 | `ps aux \| grep node` |
| 依 PID 終止 | `kill -9 <PID>` |
| 查詢使用埠口的程序 | `lsof -i :3000` |
| 終止佔用埠口的程序 | `kill -9 $(lsof -t -i :3000)` |
| 背景執行 | `npm run dev &` |
| 工作列表 | `jobs -l` |
| 帶到前景 | `fg %1` |

---

## 4. 文字處理

### 核心工具

| 工具 | 用途 | 範例 |
|------|------|------|
| `grep` | 搜尋 | `grep -rn "TODO" src/` |
| `sed` | 取代 | `sed -i 's/old/new/g' file.txt` |
| `awk` | 擷取欄位 | `awk '{print $1}' file.txt` |
| `cut` | 切割欄位 | `cut -d',' -f1 data.csv` |
| `sort` | 排序行 | `sort -u file.txt` |
| `uniq` | 唯一行 | `sort file.txt \| uniq -c` |
| `wc` | 計數 | `wc -l file.txt` |

---

## 5. 環境變數

| 任務 | 指令 |
|------|------|
| 查看全部 | `env` 或 `printenv` |
| 查看單一 | `echo $PATH` |
| 設定臨時 | `export VAR="value"` |
| 在腳本中設定 | `VAR="value" command` |
| 加入 PATH | `export PATH="$PATH:/new/path"` |

---

## 6. 網路

| 任務 | 指令 |
|------|------|
| 下載 | `curl -O https://example.com/file` |
| API 請求 | `curl -X GET https://api.example.com` |
| POST JSON | `curl -X POST -H "Content-Type: application/json" -d '{"key":"value"}' URL` |
| 檢查埠口 | `nc -zv localhost 3000` |
| 網路資訊 | `ifconfig` 或 `ip addr` |

---

## 7. 腳本範本

```bash
#!/bin/bash
set -euo pipefail  # 遇錯退出、未定義變數退出、管道失敗退出

# 顏色（選用）
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# 腳本目錄
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 函式
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# 主程式
main() {
    log_info "開始..."
    # 你的邏輯放這裡
    log_info "完成！"
}

main "$@"
```

---

## 8. 常見模式

### 檢查指令是否存在

```bash
if command -v node &> /dev/null; then
    echo "Node 已安裝"
fi
```

### 預設變數值

```bash
NAME=${1:-"default_value"}
```

### 逐行讀取檔案

```bash
while IFS= read -r line; do
    echo "$line"
done < file.txt
```

### 迴圈處理檔案

```bash
for file in *.js; do
    echo "處理 $file"
done
```

---

## 9. 與 PowerShell 的差異

| 任務 | PowerShell | Bash |
|------|------------|------|
| 列出檔案 | `Get-ChildItem` | `ls -la` |
| 尋找檔案 | `Get-ChildItem -Recurse` | `find . -type f` |
| 環境變數 | `$env:VAR` | `$VAR` |
| 字串串接 | `"$a$b"` | `"$a$b"`（相同）|
| 空值檢查 | `if ($x)` | `if [ -n "$x" ]` |
| 管道 | 基於物件 | 基於文字 |

---

## 10. 錯誤處理

### 設定選項

```bash
set -e          # 遇錯退出
set -u          # 未定義變數時退出
set -o pipefail # 管道失敗時退出
set -x          # 除錯：印出指令
```

### Trap 清理

```bash
cleanup() {
    echo "清理中..."
    rm -f /tmp/tempfile
}
trap cleanup EXIT
```

---

> **記住：** Bash 是基於文字的。使用 `&&` 串連成功指令，`set -e` 確保安全，並且記得引用你的變數！
