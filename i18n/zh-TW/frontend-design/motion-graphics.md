# 動態圖形參考指南

> 進階網頁體驗的動效技術 — Lottie, GSAP, SVG, 3D, 粒子效果。
> **學習原則，創造令人驚嘆 (WOW) 的效果。**

---

## 1. Lottie 動畫

### 什麼是 Lottie？

```
基於 JSON 的向量動畫：
├── 透過 Bodymovin 從 After Effects 導出
├── 輕量級 (比 GIF/影片更小)
├── 可縮放 (向量式，無像素糊化)
├── 具互動性 (控制播放、分段)
└── 跨平台 (Web, iOS, Android, React Native)
```

### 何時使用 Lottie

| 使用案例 | 為何選擇 Lottie？ |
|----------|-------------|
| **載入動畫** | 具備品牌感、流暢且輕量 |
| **空白狀態 (Empty states)** | 引人入勝的插圖 |
| **引導流程 (Onboarding)** | 複雜的多步驟動畫 |
| **成功/錯誤回饋** | 令人愉悅的微交互 |
| **動態圖示** | 跨平台一致性 |

### 原則

- 檔案大小保持在 100KB 以下以維持效能
- 節制使用循環動畫 (避免分心)
- 為「減弱動態」偏好提供靜態備案
- 儘可能對動畫檔案進行懶加載 (Lazy load)

### 資源

- LottieFiles.com (免費庫)
- After Effects + Bodymovin (自定義)
- Figma 外掛 (從設計導出)

---

## 2. GSAP (GreenSock)

### GSAP 有何不同

```
專業的基於時間軸的動畫庫：
├── 對序列有精確控制
├── ScrollTrigger 用於捲動驅動動畫
├── MorphSVG 用於形狀轉換
├── 基於物理的緩動
└── 適用於任何 DOM 元素
```

### 核心概念

| 概念 | 目的 |
|---------|---------|
| **Tween** | 單個 A→B 動畫 |
| **Timeline** | 序列化/重疊的動畫組 |
| **ScrollTrigger** | 捲動位置控制播放進度 |
| **Stagger** | 跨元素的階梯式效果 |

### 何時使用 GSAP

- ✅ 複雜的序列化動畫
- ✅ 捲動觸發的揭露效果
- ✅ 需要精確的時間控制
- ✅ SVG 形狀變換 (Morphing) 特效
- ❌ 簡單的懸停/焦點效果 (使用 CSS)
- ❌ 對效能極度要求且資源受限的行動裝置 (庫較重)

### 原則

- 使用時間軸 (Timeline) 進行協調 (而非單個 tween)
- 階梯式 (Stagger) 延遲：項目之間 0.05-0.15s
- ScrollTrigger：在視窗進入 70-80% 時開始
- 組件卸載時清除動畫 (防止記憶體洩漏)

---

## 3. SVG 動畫

### SVG 動畫類型

| 類型 | 技術 | 使用案例 |
|------|-----------|----------|
| **線條繪製** | stroke-dashoffset | 標誌揭露、手寫簽名 |
| **形狀變換 (Morph)** | 路徑插值 (Path interpolation) | 圖示轉換 |
| **變換 (Transform)** | rotate, scale, translate | 互動式圖示 |
| **顏色** | fill/stroke 轉換 | 狀態變更 |

### 線條繪製原則

```
stroke-dashoffset 繪製原理：
├── 將 dasharray 設置為編道路徑長度
├── 將 dashoffset 設置為等於 dasharray (隱藏)
├── 將 dashoffset 動畫至 0 (揭露)
└── 建立「繪製中」的效果
```

### 何時使用 SVG 動畫

- ✅ 標誌揭露、品牌時刻
- ✅ 圖示狀態轉換 (漢堡選單 ↔ X)
- ✅ 資訊圖表、數據視覺化
- ✅ 互動式插圖
- ❌ 寫實的照片內容 (使用影片)
- ❌ 極度複雜的場景 (影響效能)

### 原則

- 動態獲取路徑長度以確保準確性
- 持續時間：完整繪製為 1-3s
- 緩動：使用「緩出 (ease-out)」獲得自然感
- 簡單的填充 (Fills) 起輔助作用，不要喧賓奪主

---

## 4. 3D CSS 變換 (Transforms)

### 核心屬性

```
CSS 3D 空間：
├── perspective：3D 視場深度 (典型值 500-1500px)
├── transform-style：preserve-3d (啟用子元素 3D 效果)
├── rotateX/Y/Z：各軸旋轉
├── translateZ：向觀察者靠近/遠離
└── backface-visibility：顯示/隱藏背面
```

### 常見 3D 模式

| 模式 | 使用案例 |
|---------|----------|
| **卡片翻轉 (Card flip)** | 揭露、閃示卡、產品檢視 |
| **懸停傾斜 (Tilt)** | 互動式卡片、3D 深度感 |
| **視差圖層 (Parallax)** | Hero 區域、沉浸式捲動 |
| **3D 輪播** | 圖片藝廊、選取器 |

### 原則

- 透視度 (Perspective)：細微效果使用 800-1200px，戲劇化效果使用 400-600px
- 保持變換簡單 (旋轉 + 位移)
- 翻轉時確保 `backface-visibility: hidden`
- 在 Safari 上進行測試 (渲染方式不同)

---

## 5. 粒子效果 (Particle Effects)

### 粒子系統類型

| 類型 | 感覺 | 使用案例 |
|------|------|----------|
| **幾何型** | 科技感、網絡 | SaaS、科技網站 |
| **紙屑型 (Confetti)** | 慶祝 | 成功時刻 |
| **雨雪型** | 大氣感 | 季節性、氛圍營造 |
| **光塵/散景 (Bokeh)** | 夢幻、唯美 | 攝影、奢華品牌 |
| **螢火蟲** | 魔幻感 | 遊戲、幻想風格 |

### 常用庫

| 庫名稱 | 最適合於 |
|---------|----------|
| **tsParticles** | 高度可配置、輕量 |
| **particles.js** | 簡單的背景 |
| **Canvas API** | 自定義、最大控制權 |
| **Three.js** | 複雜的 3D 粒子 |

### 原則

- 預設值：30-50 個粒子 (避免眼花繚亂)
- 運動：緩慢、有機 (速度 0.5-2)
- 不透明度：0.3-0.6 (不要爭奪內容注意力)
- 連接：用於「網絡」感的細微連線
- ⚠️ 在行動裝置上停用或減少數量

### 何時使用

- ✅ Hero 背景 (營造氛圍)
- ✅ 成功慶祝 (紙屑噴發)
- ✅ 科技視覺化 (連接節點)
- ❌ 內容密集的頁面 (造成分心)
- ❌ 低功耗裝置 (消耗電池)

---

## 6. 捲動驅動動畫 (Scroll-Driven Animations)

### 原生 CSS (現代)

```
CSS Scroll Timelines：
├── animation-timeline: scroll() - 文件捲動
├── animation-timeline: view() - 元素在視窗中
├── animation-range: 進入/退出閾值
└── 不需要 JavaScript 即可實現
```

### 原則

| 觸發點 | 使用案例 |
|---------------|----------|
| **Entry 0%** | 元素剛開始進入時 |
| **Entry 50%** | 一半可見時 |
| **Cover 50%** | 在視窗中心時 |
| **Exit 100%** | 完全退出時 |

### 最佳實踐

- 揭露動畫：在約 25% 進入時開始
- 視差效果：持續的捲動進度
- 固定 (Sticky) 元素：使用封面範圍 (Cover range)
- 始終測試捲動效能

---

## 7. 效能原則

### GPU vs CPU 動畫

```
開銷低 (GPU 加速)：
├── transform (translate, scale, rotate)
├── opacity
└── filter (謹慎使用)

開銷高 (觸发布局重排)：
├── width, height
├── top, left, right, bottom
├── padding, margin
└── 複雜的 box-shadow
```

### 優化檢查清單

- [ ] 僅對 transform/opacity 進行動畫處理
- [ ] 在重型動畫前使用 `will-change` (結束後移除)
- [ ] 在低階裝置上進行測試
- [ ] 實作 `prefers-reduced-motion` 支援
- [ ] 延遲加載動畫庫
- [ ] 節流 (Throttle) 基於捲動的計算

---

## 8. 動態圖形決策樹

```
你需要什麼樣的動畫？
│
├── 複雜的品牌動畫？
│   └── Lottie (After Effects 導出)
│
├── 序列化的捲動觸發動畫？
│   └── GSAP + ScrollTrigger
│
├── 標誌/圖示動畫？
│   └── SVG 動畫 (描邊或形狀變換)
│
├── 互動式 3D 效果？
│   └── CSS 3D 變換 (簡單) 或 Three.js (複雜)
│
├── 氛圍背景？
│   └── tsParticles 或 Canvas
│
└── 簡單的入場/懸停？
    └── CSS @keyframes 或 Framer Motion
```

---

## 9. 應避免的錯誤模式 (Anti-Patterns)

| ❌ 不要 | ✅ 要 |
|----------|-------|
| 同時讓所有東西都在動 | 階梯式順序呈現 |
| 為簡單效果使用重型庫 | 從 CSS 開始嘗試 |
| 忽略減弱動態偏好 | 始終提供備案 |
| 阻塞主線程 | 為 60fps 進行優化 |
| 每個專案都用同樣的粒子 | 匹配品牌/情境 |
| 在行動端使用複雜效果 | 進行功能檢測 (Feature detection) |

---

## 10. 快速參考表

| 效果 | 工具 | 效能開銷 |
|--------|------|-------------|
| 載入旋轉圖示 | CSS/Lottie | 輕量 |
| 階梯式揭露 | GSAP/Framer | 中等 |
| SVG 路徑繪製 | CSS stroke | 輕量 |
| 3D 卡片翻轉 | CSS transforms | 輕量 |
| 粒子背景 | tsParticles | 重型 |
| 捲動視差 | GSAP ScrollTrigger | 中等 |
| 形狀變換 (Morph) | GSAP MorphSVG | 中等 |

---

> **記住**：動態圖形應強化體驗，而非分散注意力。每個動畫都必須服務於一個目的 — 回饋、引導、愉悅或傳遞故事。
