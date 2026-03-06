---
name: slack-gif-creator
description: 建立針對 Slack 最佳化的動畫 GIF 的知識和工具。提供限制條件、驗證工具和動畫概念。當使用者要求為 Slack 建立動畫 GIF 時使用，例如「幫我做一個 X 做 Y 的 Slack GIF」。
license: 完整條款請見 LICENSE.txt
---

# Slack GIF 創作器

提供用於建立針對 Slack 最佳化的動畫 GIF 的工具和知識。

## Slack 需求

**尺寸：**
- Emoji GIF：128x128（建議）
- 訊息 GIF：480x480

**參數：**
- FPS：10-30（較低 = 較小檔案大小）
- 色彩數：48-128（較少 = 較小檔案大小）
- 持續時間：Emoji GIF 保持在 3 秒以內

## 核心工作流程

```python
from core.gif_builder import GIFBuilder
from PIL import Image, ImageDraw

# 1. 建立建構器
builder = GIFBuilder(width=128, height=128, fps=10)

# 2. 生成影格
for i in range(12):
    frame = Image.new('RGB', (128, 128), (240, 248, 255))
    draw = ImageDraw.Draw(frame)

    # 使用 PIL 繪圖基本元素繪製你的動畫
    # （圓形、多邊形、線條等）

    builder.add_frame(frame)

# 3. 儲存並最佳化
builder.save('output.gif', num_colors=48, optimize_for_emoji=True)
```

## 繪製圖形

### 處理使用者上傳的圖片
如果使用者上傳圖片，考慮他們是否想要：
- **直接使用**（例如：「將這個做成動畫」、「將這個拆成影格」）
- **作為靈感**（例如：「做一個類似這個的東西」）

使用 PIL 載入並處理圖片：
```python
from PIL import Image

uploaded = Image.open('file.png')
# 直接使用，或僅作為色彩/風格的參考
```

### 從頭繪製
從頭繪製圖形時，使用 PIL ImageDraw 基本元素：

```python
from PIL import ImageDraw

draw = ImageDraw.Draw(frame)

# 圓形/橢圓
draw.ellipse([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)

# 星形、三角形、任何多邊形
points = [(x1, y1), (x2, y2), (x3, y3), ...]
draw.polygon(points, fill=(r, g, b), outline=(r, g, b), width=3)

# 線條
draw.line([(x1, y1), (x2, y2)], fill=(r, g, b), width=5)

# 矩形
draw.rectangle([x1, y1, x2, y2], fill=(r, g, b), outline=(r, g, b), width=3)
```

**不要使用：** Emoji 字體（跨平台不可靠）或假設此技能中存在預製圖形。

### 讓圖形看起來更好

圖形應該看起來精緻且有創意，而非基本。方法如下：

**使用較粗的線條** - 輪廓和線條始終設定 `width=2` 或更高。細線（width=1）看起來粗糙且業餘。

**添加視覺深度**：
- 使用漸層背景（`create_gradient_background`）
- 分層多個形狀以增加複雜性（例如一個星星裡面有更小的星星）

**讓形狀更有趣**：
- 不要只畫一個普通的圓 — 添加高光、環或圖案
- 星星可以有光暈（在後方繪製更大的半透明版本）
- 組合多個形狀（星星 + 閃爍、圓圈 + 環）

**注意色彩**：
- 使用鮮豔、互補的色彩
- 添加對比（淺色形狀上的深色輪廓，深色形狀上的淺色輪廓）
- 考慮整體構圖

**複雜形狀**（愛心、雪花等）：
- 使用多邊形和橢圓的組合
- 仔細計算點以確保對稱
- 添加細節（愛心可以有高光曲線，雪花有精緻的分支）

要有創意和細節！好的 Slack GIF 應該看起來精緻，而非像佔位符圖形。

## 可用工具

### GIFBuilder (`core.gif_builder`)
組裝影格並針對 Slack 最佳化：
```python
builder = GIFBuilder(width=128, height=128, fps=10)
builder.add_frame(frame)  # 添加 PIL Image
builder.add_frames(frames)  # 添加影格清單
builder.save('out.gif', num_colors=48, optimize_for_emoji=True, remove_duplicates=True)
```

### 驗證器 (`core.validators`)
檢查 GIF 是否符合 Slack 需求：
```python
from core.validators import validate_gif, is_slack_ready

# 詳細驗證
passes, info = validate_gif('my.gif', is_emoji=True, verbose=True)

# 快速檢查
if is_slack_ready('my.gif'):
    print("Ready!")
```

### 緩動函數 (`core.easing`)
平滑動作而非線性：
```python
from core.easing import interpolate

# 從 0.0 到 1.0 的進度
t = i / (num_frames - 1)

# 套用緩動
y = interpolate(start=0, end=400, t=t, easing='ease_out')

# 可用：linear, ease_in, ease_out, ease_in_out,
#       bounce_out, elastic_out, back_out
```

### 影格輔助工具 (`core.frame_composer`)
常見需求的便利函數：
```python
from core.frame_composer import (
    create_blank_frame,         # 純色背景
    create_gradient_background,  # 垂直漸層
    draw_circle,                # 圓形輔助
    draw_text,                  # 簡單文字渲染
    draw_star                   # 五角星
)
```

## 動畫概念

### 搖晃/震動
用振盪偏移物件位置：
- 使用 `math.sin()` 或 `math.cos()` 搭配影格索引
- 添加小隨機變化以獲得自然感
- 套用於 x 和/或 y 位置

### 脈動/心跳
有節奏地縮放物件大小：
- 使用 `math.sin(t * frequency * 2 * math.pi)` 進行平滑脈動
- 心跳效果：兩次快速脈動後暫停（調整正弦波）
- 在基礎大小的 0.8 到 1.2 之間縮放

### 彈跳
物件墜落並彈跳：
- 使用 `interpolate()` 搭配 `easing='bounce_out'` 進行著陸
- 使用 `easing='ease_in'` 進行墜落（加速）
- 透過每影格增加 y 速度來套用重力

### 旋轉/轉動
物件繞中心旋轉：
- PIL：`image.rotate(angle, resample=Image.BICUBIC)`
- 擺動效果：使用正弦波代替線性角度

### 淡入/淡出
逐漸出現或消失：
- 建立 RGBA 圖片，調整 alpha 通道
- 或使用 `Image.blend(image1, image2, alpha)`
- 淡入：alpha 從 0 到 1
- 淡出：alpha 從 1 到 0

### 滑動
物件從螢幕外移動到位置：
- 起始位置：在影格邊界外
- 結束位置：目標位置
- 使用 `interpolate()` 搭配 `easing='ease_out'` 進行平滑停止
- 超越效果：使用 `easing='back_out'`

### 縮放
縮放和定位以產生縮放效果：
- 放大：從 0.1 縮放到 2.0，裁切中心
- 縮小：從 2.0 縮放到 1.0
- 可添加動態模糊以增加戲劇效果（PIL 濾鏡）

### 爆炸/粒子迸發
建立向外輻射的粒子：
- 以隨機角度和速度生成粒子
- 更新每個粒子：`x += vx`、`y += vy`
- 添加重力：`vy += gravity_constant`
- 粒子隨時間淡出（減少 alpha）

## 最佳化策略

僅在被要求使檔案大小更小時，實施以下幾種方法：

1. **更少影格** - 降低 FPS（10 而非 20）或更短持續時間
2. **更少色彩** - `num_colors=48` 而非 128
3. **更小尺寸** - 128x128 而非 480x480
4. **移除重複** - 在 save() 中設 `remove_duplicates=True`
5. **Emoji 模式** - `optimize_for_emoji=True` 自動最佳化

```python
# Emoji 的最大最佳化
builder.save(
    'emoji.gif',
    num_colors=48,
    optimize_for_emoji=True,
    remove_duplicates=True
)
```

## 理念

此技能提供：
- **知識**：Slack 的需求和動畫概念
- **工具**：GIFBuilder、驗證器、緩動函數
- **彈性**：使用 PIL 基本元素建立動畫邏輯

此技能**不**提供：
- 固定的動畫範本或預製函數
- Emoji 字體渲染（跨平台不可靠）
- 內建於技能中的預製圖形庫

**關於使用者上傳的注意事項**：此技能不包含預製圖形，但如果使用者上傳圖片，使用 PIL 載入並處理 — 根據他們的請求判斷是要直接使用還是僅作為靈感。

發揮創意！組合多種概念（彈跳 + 旋轉、脈動 + 滑動等）並充分利用 PIL 的全部功能。

## 相依套件

```bash
pip install pillow imageio numpy
```
