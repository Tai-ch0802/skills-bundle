---
name: python-patterns
description: Python 開發原則與決策。框架選擇、非同步模式、型別提示、專案結構。教你思考而非複製。
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Python 模式

> 2025 年 Python 開發的原則與決策。
> **學習思考方式，而非記憶模式。**

---

## ⚠️ 如何使用此技能

此技能教導**決策原則**，而非固定的程式碼複製。

- 不明確時詢問使用者框架偏好
- 根據情境選擇 async vs sync
- 不要每次都預設相同的框架

---

## 1. 框架選擇（2025）

### 決策樹

```
你要建構什麼？
│
├── API 優先 / 微服務
│   └── FastAPI（非同步、現代、快速）
│
├── 全端 Web / CMS / 管理後台
│   └── Django（電池已含）
│
├── 簡單 / 腳本 / 學習
│   └── Flask（最小、彈性）
│
├── AI/ML API 服務
│   └── FastAPI（Pydantic、async、uvicorn）
│
└── 背景工作
    └── Celery + 任何框架
```

### 比較原則

| 因素 | FastAPI | Django | Flask |
|------|---------|--------|-------|
| **最適合** | API、微服務 | 全端、CMS | 簡單、學習 |
| **非同步** | 原生 | Django 5.0+ | 透過擴充 |
| **管理後台** | 手動 | 內建 | 透過擴充 |
| **ORM** | 自選 | Django ORM | 自選 |
| **學習曲線** | 低 | 中 | 低 |

### 選擇時要問的問題：
1. 這是僅 API 還是全端？
2. 需要管理介面嗎？
3. 團隊熟悉 async 嗎？
4. 現有基礎設施？

---

## 2. Async vs Sync 決策

### 何時使用 Async

```
async def 更好的情況：
├── I/O 密集操作（資料庫、HTTP、檔案）
├── 大量併發連線
├── 即時功能
├── 微服務通訊
└── FastAPI/Starlette/Django ASGI

def（sync）更好的情況：
├── CPU 密集操作
├── 簡單腳本
├── 遺留程式碼庫
├── 團隊不熟悉 async
└── 阻塞函式庫（沒有 async 版本）
```

### 黃金法則

```
I/O 密集 → async（等待外部）
CPU 密集 → sync + multiprocessing（計算）

不要：
├── 粗心混合 sync 和 async
├── 在 async 程式碼中使用 sync 函式庫
└── 強制 async 用於 CPU 工作
```

### Async 函式庫選擇

| 需求 | Async 函式庫 |
|------|-------------|
| HTTP 客戶端 | httpx |
| PostgreSQL | asyncpg |
| Redis | aioredis / redis-py async |
| 檔案 I/O | aiofiles |
| 資料庫 ORM | SQLAlchemy 2.0 async、Tortoise |

---

## 3. 型別提示策略

### 何時加型別

```
始終加型別：
├── 函式參數
├── 回傳型別
├── 類別屬性
├── 公開 API

可以跳過：
├── 區域變數（讓推斷運作）
├── 一次性腳本
├── 測試（通常）
```

### 常見型別模式

```python
# 理解這些模式：

# Optional → 可能是 None
from typing import Optional
def find_user(id: int) -> Optional[User]: ...

# Union → 多個型別之一
def process(data: str | dict) -> None: ...

# 泛型集合
def get_items() -> list[Item]: ...
def get_mapping() -> dict[str, int]: ...

# Callable
from typing import Callable
def apply(fn: Callable[[int], str]) -> str: ...
```

### Pydantic 用於驗證

```
何時使用 Pydantic：
├── API 請求/回應模型
├── 設定/配置
├── 資料驗證
├── 序列化

好處：
├── 執行期驗證
├── 自動生成 JSON schema
├── 與 FastAPI 原生整合
└── 清晰的錯誤訊息
```

---

## 4. 專案結構原則

### 結構選擇

```
小專案 / 腳本：
├── main.py
├── utils.py
└── requirements.txt

中型 API：
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── models/
│   ├── routes/
│   ├── services/
│   └── schemas/
├── tests/
└── pyproject.toml

大型應用：
├── src/
│   └── myapp/
│       ├── core/
│       ├── api/
│       ├── services/
│       ├── models/
│       └── ...
├── tests/
└── pyproject.toml
```

### FastAPI 結構原則

```
依功能或依層次組織：

依層次：
├── routes/（API 端點）
├── services/（業務邏輯）
├── models/（資料庫模型）
├── schemas/（Pydantic 模型）
└── dependencies/（共用相依）

依功能：
├── users/
│   ├── routes.py
│   ├── service.py
│   └── schemas.py
└── products/
    └── ...
```

---

## 5. Django 原則（2025）

### Django Async（Django 5.0+）

```
Django 支援 async：
├── Async views
├── Async middleware
├── Async ORM（有限）
└── ASGI 部署

Django 中何時使用 async：
├── 外部 API 呼叫
├── WebSocket（Channels）
├── 高併發 view
└── 觸發背景任務
```

### Django 最佳實踐

```
模型設計：
├── 胖模型、瘦視圖
├── 使用 managers 處理常用查詢
├── 用抽象基礎類別共享欄位

Views：
├── 複雜 CRUD 用 Class-based view
├── 簡單端點用 Function-based view
├── 配合 DRF 使用 viewsets

查詢：
├── select_related() 用於 FK
├── prefetch_related() 用於 M2M
├── 避免 N+1 查詢
└── 使用 .only() 選取特定欄位
```

---

## 6. FastAPI 原則

### async def vs def

```
使用 async def 當：
├── 使用 async 資料庫驅動
├── 進行 async HTTP 呼叫
├── I/O 密集操作
└── 想要處理併發

使用 def 當：
├── 阻塞操作
├── Sync 資料庫驅動
├── CPU 密集工作
└── FastAPI 自動在 threadpool 中執行
```

### 依賴注入

```
使用依賴用於：
├── 資料庫 session
├── 當前使用者 / 驗證
├── 設定
├── 共享資源

好處：
├── 可測試性（模擬依賴）
├── 乾淨分離
├── 自動清理（yield）
```

### Pydantic v2 整合

```python
# FastAPI 與 Pydantic 緊密整合：

# 請求驗證
@app.post("/users")
async def create(user: UserCreate) -> UserResponse:
    # user 已經完成驗證
    ...

# 回應序列化
# 回傳型別即為回應 schema
```

---

## 7. 背景任務

### 選擇指南

| 方案 | 最適合 |
|------|--------|
| **BackgroundTasks** | 簡單、程序內任務 |
| **Celery** | 分散式、複雜工作流 |
| **ARQ** | Async、基於 Redis |
| **RQ** | 簡單 Redis 佇列 |
| **Dramatiq** | Actor 基礎、比 Celery 簡單 |

### 何時使用各項方案

```
FastAPI BackgroundTasks：
├── 快速操作
├── 不需要持久化
├── Fire-and-forget
└── 同一個 process

Celery／ARQ：
├── 長時間運作的任務
├── 需要重試邏輯
├── 分散式 worker
├── 持久化佇列
└── 複雜工作流
```

---

## 8. 錯誤處理原則

### 例外策略

```
在 FastAPI：
├── 建立自訂例外類別
├── 註冊例外處理器
├── 回傳一致的錯誤格式
└── 記錄日誌但不洩漏內部細節

模式：
├── 在 service 層丟出 domain 例外
├── 在 handler 層攔截並轉換
└── 客戶端拿到乾淨的錯誤回應
```

### 錯誤回應理念

```
應包含：
├── 錯誤代碼（程式可解析）
├── 訊息（人類可讀）
├── 細節（適用時逐欄位）
└── 不要 stack traces（資安考量）
```

---

## 9. 測試原則

### 測試策略

| 類型 | 用途 | 工具 |
|------|------|------|
| **單元** | 業務邏輯 | pytest |
| **整合** | API 端點 | pytest + httpx/TestClient |
| **E2E** | 完整工作流 | pytest + DB |

### Async 測試

```python
# 使用 pytest-asyncio 撰寫 async 測試

import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_endpoint():
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/users")
        assert response.status_code == 200
```

### Fixtures 策略

```
常見 fixtures：
├── db_session → 資料庫連線
├── client → 測試 client
├── authenticated_user → 帶 token 的使用者
└── sample_data → 測試資料準備
```

---

## 10. 決策檢查清單

實作前：

- [ ] **詢問使用者框架偏好了嗎？**
- [ ] **為此情境選擇了框架？**
- [ ] **決定了 async vs sync？**
- [ ] **規劃了型別提示策略？**
- [ ] **定義了專案結構？**
- [ ] **規劃了錯誤處理？**
- [ ] **考慮了背景任務？**

---

## 11. 應避免的反模式

### ❌ 不要：
- 簡單 API 預設用 Django（FastAPI 可能更適合）
- 在 async 程式碼中使用 sync 函式庫
- 公開 API 略過型別提示
- 把業務邏輯放在 routes/views
- 忽略 N+1 查詢
- 粗心混合 async 與 sync

### ✅ 要：
- 依情境選擇框架
- 詢問 async 需求
- 使用 Pydantic 做驗證
- 分離關注點（routes → services → repos）
- 測試關鍵路徑

---

> **記住**：Python 模式是關於你特定情境的決策。不要複製程式碼 — 思考什麼最適合你的應用。
