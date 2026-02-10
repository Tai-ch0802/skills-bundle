# API 風格選擇（2025）

> REST vs GraphQL vs tRPC — 什麼情況用什麼？

## 決策樹

```
API 的消費者是誰？
│
├── 公開 API / 多平台
│   └── REST + OpenAPI（最廣泛的相容性）
│
├── 複雜資料需求 / 多個前端
│   └── GraphQL（彈性查詢）
│
├── TypeScript 前後端（monorepo）
│   └── tRPC（端到端型別安全）
│
├── 即時 / 事件驅動
│   └── WebSocket + AsyncAPI
│
└── 內部微服務
    └── gRPC（效能）或 REST（簡單性）
```

## 比較

| 因素 | REST | GraphQL | tRPC |
|------|------|---------|------|
| **最適合** | 公開 API | 複雜應用 | TS monorepo |
| **學習曲線** | 低 | 中 | 低（若用 TS）|
| **過度/不足取得** | 常見 | 已解決 | 已解決 |
| **型別安全** | 手動（OpenAPI）| 基於 Schema | 自動 |
| **快取** | HTTP 原生 | 複雜 | 基於客戶端 |

## 選擇問題

1. API 的消費者是誰？
2. 前端是否使用 TypeScript？
3. 資料關係有多複雜？
4. 快取是否至關重要？
5. 公開或內部 API？
