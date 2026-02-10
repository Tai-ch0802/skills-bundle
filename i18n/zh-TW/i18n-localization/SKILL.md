---
name: i18n-localization
description: 國際化與在地化模式。偵測寫死字串、管理翻譯、語系檔案、RTL 支援。
allowed-tools: Read, Glob, Grep
---

# i18n 與在地化

> 國際化（i18n）與在地化（L10n）最佳實踐。

---

## 1. 核心概念

| 術語 | 意義 |
|------|------|
| **i18n** | 國際化 — 讓應用程式可翻譯 |
| **L10n** | 在地化 — 實際翻譯 |
| **Locale** | 語言 + 地區（en-US、zh-TW）|
| **RTL** | 右至左語言（阿拉伯語、希伯來語）|

---

## 2. 何時使用 i18n

| 專案類型 | 需要 i18n？ |
|----------|-------------|
| 公開 Web 應用 | ✅ 是 |
| SaaS 產品 | ✅ 是 |
| 內部工具 | ⚠️ 可能 |
| 單一地區應用 | ⚠️ 考慮未來 |
| 個人專案 | ❌ 選擇性 |

---

## 3. 實作模式

### React (react-i18next)

```tsx
import { useTranslation } from 'react-i18next';

function Welcome() {
  const { t } = useTranslation();
  return <h1>{t('welcome.title')}</h1>;
}
```

### Next.js (next-intl)

```tsx
import { useTranslations } from 'next-intl';

export default function Page() {
  const t = useTranslations('Home');
  return <h1>{t('title')}</h1>;
}
```

### Python (gettext)

```python
from gettext import gettext as _

print(_("Welcome to our app"))
```

---

## 4. 檔案結構

```
locales/
├── en/
│   ├── common.json
│   ├── auth.json
│   └── errors.json
├── zh-TW/
│   ├── common.json
│   ├── auth.json
│   └── errors.json
└── ar/          # RTL
    └── ...
```

---

## 5. 最佳實踐

### 要做 ✅

- 使用翻譯鍵，而非原始文字
- 按功能命名空間翻譯
- 支援複數形
- 按語系處理日期/數字格式
- 從一開始就規劃 RTL
- 使用 ICU 訊息格式處理複雜字串

### 不要做 ❌

- 在元件中寫死字串
- 串接已翻譯的字串
- 假設文字長度（德文長 30%）
- 忘記 RTL 佈局
- 在同一檔案中混合語言

---

## 6. 常見問題

| 問題 | 解決方案 |
|------|----------|
| 缺少翻譯 | 備援到預設語言 |
| 寫死字串 | 使用 linter/檢查腳本 |
| 日期格式 | 使用 Intl.DateTimeFormat |
| 數字格式 | 使用 Intl.NumberFormat |
| 複數形 | 使用 ICU 訊息格式 |

---

## 7. RTL 支援

```css
/* CSS 邏輯屬性 */
.container {
  margin-inline-start: 1rem;  /* 不是 margin-left */
  padding-inline-end: 1rem;   /* 不是 padding-right */
}

[dir="rtl"] .icon {
  transform: scaleX(-1);
}
```

---

## 8. 檢查清單

發布前：

- [ ] 所有使用者面對的字串使用翻譯鍵
- [ ] 所有支援語言都有語系檔案
- [ ] 日期/數字格式使用 Intl API
- [ ] RTL 佈局已測試（如適用）
- [ ] 備援語言已設定
- [ ] 元件中沒有寫死字串

---

## 腳本

| 腳本 | 用途 | 指令 |
|------|------|------|
| `scripts/i18n_checker.py` | 偵測寫死字串和缺少的翻譯 | `python scripts/i18n_checker.py <project_path>` |
