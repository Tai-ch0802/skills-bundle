# 專案類型偵測

> 分析使用者請求以判定專案類型和範本。

## 關鍵字矩陣

| 關鍵字 | 專案類型 | 範本 |
|--------|----------|------|
| blog、post、article | 部落格 | astro-static |
| e-commerce、product、cart、payment | 電商 | nextjs-saas |
| dashboard、panel、management | 管理儀表板 | nextjs-fullstack |
| api、backend、service、rest | API 服務 | express-api |
| python、fastapi、django | Python API | python-fastapi |
| mobile、android、ios、react native | 行動應用（RN）| react-native-app |
| flutter、dart | 行動應用（Flutter）| flutter-app |
| portfolio、personal、cv | 作品集 | nextjs-static |
| crm、customer、sales | CRM | nextjs-fullstack |
| saas、subscription、stripe | SaaS | nextjs-saas |
| landing、promotional、marketing | 著陸頁 | nextjs-static |
| docs、documentation | 文件 | astro-static |
| extension、plugin、chrome | 瀏覽器擴充 | chrome-extension |
| desktop、electron | 桌面應用 | electron-desktop |
| cli、command line、terminal | CLI 工具 | cli-tool |
| monorepo、workspace | Monorepo | monorepo-turborepo |

## 偵測流程

```
1. 對使用者請求分詞
2. 提取關鍵字
3. 判定專案類型
4. 偵測缺少的資訊 → 轉發至 conversation-manager
5. 建議技術堆疊
```
