# 視覺特效參考指南

> 現代 CSS 特效原則與技術 — 學習概念，創造變體。
> **不要複製固定值 — 理解背後的模式。**

---

## 1. 玻璃擬態原則 (Glassmorphism)

### 玻璃擬態生效的關鍵

```
關鍵屬性：
├── 半透明背景 (非實色)
├── 背景模糊 (Backdrop blur - 毛玻璃效果)
├── 細微邊框 (用於定義輪廓)
└── 通常：配合輕微陰影以增加深度
```

### 模式 (可自訂數值)

```css
.glass {
  /* 透明度：根據內容易讀性調整不透明度 */
  background: rgba(R, G, B, OPACITY);
  /* OPACITY：深色背景使用 0.1-0.3，淺色背景使用 0.5-0.8 */
  
  /* 模糊：越高 = 越像毛玻璃 */
  backdrop-filter: blur(AMOUNT);
  /* AMOUNT：8-12px 為細微，16-24px 為強效 */
  
  /* 邊框：定義邊緣 */
  border: 1px solid rgba(255, 255, 255, OPACITY);
  /* OPACITY：通常為 0.1-0.3 */
  
  /* 圓角：匹配你的設計系統 */
  border-radius: YOUR_RADIUS;
}
```

### 何時使用玻璃擬態
- ✅ 位於鮮艷/圖片背景之上
- ✅ 彈窗、覆蓋層、卡片
- ✅ 背景內容會捲動的導航列
- ❌ 文字密集的內容 (易讀性問題)
- ❌ 單純的實色背景 (毫無意義)

### 何時「不」使用
- 低對比度的情況
- 對無障礙性要求極高的內容
- 效能受限的裝置

---

## 2. 擬物化原則 (Neomorphism)

### 擬物化生效的關鍵

```
關鍵概念：使用雙重陰影營造柔軟的擠壓感
├── 淺色陰影 (來自光源方向)
├── 深色陰影 (相反方向)
└── 背景與周圍環境匹配 (相同顏色)
```

### 模式

```css
.neo-raised {
  /* 背景必須與父元素相同 */
  background: SAME_AS_PARENT;
  
  /* 雙重陰影：淺色方向 + 深色方向 */
  box-shadow: 
    OFFSET OFFSET BLUR rgba(light-color),
    -OFFSET -OFFSET BLUR rgba(dark-color);
  
  /* OFFSET：通常為 6-12px */
  /* BLUR：通常為 12-20px */
}

.neo-pressed {
  /* Inset 建立「推入」效果 */
  box-shadow: 
    inset OFFSET OFFSET BLUR rgba(dark-color),
    inset -OFFSET -OFFSET BLUR rgba(light-color);
}
```

### 無障礙警告
⚠️ **低對比度** — 請節制使用，並確保有清晰的邊界。

### 何時使用
- 裝飾性元素
- 細微的互動狀態
- 使用平鋪色彩的簡約 UI

---

## 3. 陰影層級原則 (Shadow Hierarchy)

### 概念：陰影指示高度 (Elevation)

```
高度越高 = 陰影越大
├── 第 0 級：無陰影 (平貼表面)
├── 第 1 級：細微陰影 (略微抬起)
├── 第 2 級：中等陰影 (卡片、按鈕)
├── 第 3 級：大型陰影 (彈窗、下拉選單)
└── 第 4 級：深陰影 (懸浮元素)
```

### 可調整的陰影屬性

```css
box-shadow: OFFSET-X OFFSET-Y BLUR SPREAD COLOR;

/* Offset：陰影方向 */
/* Blur：柔軟度 (越大 = 越柔軟) */
/* Spread：尺寸擴增 */
/* Color：通常為低不透明度的黑色 */
```

### 自然陰影的原則

1. **Y 偏移大於 X** (光源來自上方)
2. **低不透明度** (5-15% 為細微，15-25% 為顯著)
3. **多層陰影** 以增加真實感 (環境光 + 直射光)
4. **模糊隨偏移縮放** (偏移越大 = 模糊越大)

### 深色模式陰影
- 陰影在深色背景上較不明顯
- 可能需要增加不透明度
- 或改用光暈/高亮 (Glow/Highlight) 代替

---

## 4. 漸層原則 (Gradients)

### 類型與使用時機

| 類型 | 模式 | 使用案例 |
|------|---------|----------|
| **線性 (Linear)** | 顏色 A → 顏色 B 沿直線變化 | 背景、按鈕、標頭 |
| **放射 (Radial)** | 中心 → 向外變化 | 聚光燈、焦點 |
| **圓錐 (Conic)**| 繞中心旋轉變化 | 圓餅圖、創意特效 |

### 創造和諧的漸層

```
好的漸層規則：
├── 使用色輪上相鄰的顏色 (相似色)
├── 或使用同一種色相但明度不同
├── 避免使用互補色 (顯得突兀)
└── 增加中間停駐點 (Middle stops) 使過渡更平滑
```

### 漸層語法模式

```css
.gradient {
  background: linear-gradient(
    DIRECTION,           /* 角度或 to-關鍵字 */
    COLOR-STOP-1,        /* 顏色 + 選填位置 */
    COLOR-STOP-2,
    /* ... 更多停駐點 */
  );
}

/* 方向範例： */
/* 90deg, 135deg, to right, to bottom right */
```

### 網格漸層 (Mesh Gradients)

```
多個放射漸層重疊：
├── 每個都位於不同位置
├── 每個都有透明衰減
├── **Hero 區域營造「哇」效果的必備技術**
└── 創造有機、色彩豐富的效果 (搜尋：「Aurora Gradient CSS」)
```

---

## 5. 邊框特效原則

### 漸層邊框

```
技術：使用偽元素 (Pseudo-element) 配合漸層背景
├── 元素具有 padding = 邊框寬度
├── 偽元素填充漸層
└── 使用 Mask 或 Clip 建立邊框效果
```

### 動態邊框

```
技術：旋轉漸層或圓錐掃描
├── 偽元素大於內容
├── 動畫旋轉漸層
└── overflow: hidden 裁剪形狀
```

### 光暈邊框 (Glow Borders)

```css
/* 多重 box-shadow 建立光暈 */
box-shadow:
  0 0 SMALL-BLUR COLOR,
  0 0 MEDIUM-BLUR COLOR,
  0 0 LARGE-BLUR COLOR;

/* 每一層都增加光暈強度 */
```

---

## 6. 光暈特效原則 (Glow Effects)

### 文字光暈

```css
text-shadow: 
  0 0 BLUR-1 COLOR,
  0 0 BLUR-2 COLOR,
  0 0 BLUR-3 COLOR;

/* 多層 = 更強的光暈 */
/* 更大的模糊值 = 更柔軟的擴散 */
```

### 元素光暈

```css
box-shadow:
  0 0 BLUR-1 COLOR,
  0 0 BLUR-2 COLOR;

/* 使用與元素匹配的顏色以獲得逼真的光暈 */
/* 低不透明度適合細微效果，高不透明度適合霓虹效果 */
```

### 脈動光暈動畫 (Pulsing Glow)

```css
@keyframes glow-pulse {
  0%, 100% { box-shadow: 0 0 SMALL-BLUR COLOR; }
  50% { box-shadow: 0 0 LARGE-BLUR COLOR; }
}

/* 緩和曲線 (Easing) 和持續時間會影響手感 */
```

---

## 7. 覆蓋技術 (Overlay Techniques)

### 圖片上的漸層覆蓋

```
目的：提高圖片上文字的易讀性
模式：從透明到不透明的漸層
位置：文字出現的地方
```

```css
.overlay::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(
    DIRECTION,
    transparent PERCENTAGE,
    rgba(0,0,0,OPACITY) 100%
  );
}
```

### 有色覆蓋 (Colored Overlay)

```css
/* 混合模式或分層漸層 */
background: 
  linear-gradient(YOUR-COLOR-WITH-OPACITY),
  url('image.jpg');
```

---

## 8. 現代 CSS 技術

### 容器查詢 (Container Queries - 概念)

```
取代視窗斷點 (Viewport breakpoints)：
├── 元件根據「其容器」作出反應
├── 真正的模組化、可重複使用元件
└── 語法：@container (condition) { }
```

### :has() 選擇器 (概念)

```
根據子元素設定父元素樣式：
├── 「具有 X 子元素的父元素」
├── 實現以往不可能實現的模式
└── 漸進式增強 (Progressive enhancement) 的方法
```

### 捲動驅動動畫 (Scroll-Driven Animations - 概念)

```
動畫進度與捲動連結：
├── 捲動時的進入/退出動畫
├── 視差效果 (Parallax)
├── 進度指示器
└── 基於視圖 (View-based) 或捲動 (Scroll-based) 的時間軸
```

---

## 9. 效能原則

### GPU 加速屬性

```
動畫開銷低 (GPU)：
├── transform (translate, scale, rotate)
└── opacity

動畫開銷高 (CPU)：
├── width, height
├── top, left, right, bottom
├── margin, padding
└── box-shadow (需要重新計算)
```

### will-change 使用

```css
/* 請節制使用，僅用於重型動畫 */
.heavy-animation {
  will-change: transform;
}

/* 如果可能，在動畫結束後移除 */
```

### 減弱動態 (Reduced Motion)

```css
@media (prefers-reduced-motion: reduce) {
  /* 停用或最小化動畫 */
  /* 尊重使用者偏好 */
}
```

---

## 10. 特效選擇檢查清單

在應用任何特效之前：

- [ ] **它有目的嗎？** (而不僅僅是裝飾)
- [ ] **它是否適合情境？** (品牌、受眾)
- [ ] **是否與以往的專案不同？** (避免重複)
- [ ] **是否具有無障礙性？** (對比度、動態敏感度)
- [ ] **效能是否優良？** (特別是在行動裝置上)
- [ ] **詢問過使用者偏好嗎？** (如果風格是開放性的)

### 應避免的錯誤模式

- ❌ 在每個元素上都用玻璃擬態 (顯得俗氣)
- ❌ 將深色 + 霓虹色作為預設 (懶散的 AI 風格)
- ❌ **沒有深度的靜態/扁平設計 (失敗)**
- ❌ 損害易讀性的特效
- ❌ 沒有目的的動畫

---

> **記住**：特效應強化含義。根據目的和情境進行選擇，而非僅僅因為它「看起來很酷」。
