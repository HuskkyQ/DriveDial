# v6 → SwiftUI 映射

坐标原点是画板左上，单位 pt。画板 874×402。数值来自 v6 HTML 与 `design-baseline`，实现集中在 `DesignSpec`，由 `DesignSpecTests` 锁定。

| 稿 | Swift |
| --- | --- |
| `.cluster` 底 `#05070C`，线性渐变 `#070B12` → 55% `#05070C` → `#04060A` | `ClusterFace.boardBackground` |
| 唯一中心椭圆 cx 437 cy 210 rx 390 ry 165，径向 0% `#15283C` 0.55 / 40% `#163056` 0.22 / 100% 透明 | 同一 Canvas，无额外模糊、无左右两团 |
| `.ready` 文案 READY，left 58.89 top 22，Outfit 500 / 11px / 0.22em，`#3EE0A4` | `LinkState.readyLabel`，演示胶囊另放 |
| `.telltale-row` left 128 top 16 height 20 gap 14，5 个 16×16 图标，灯为 `.on` | `TelltaleRow`，路径按 v6 `d` 属性 |
| `.demo-badge`「演示模式」top 14，水平居中 | 顶栏胶囊 |
| `.hero-clean` Outfit 200 / 134.24 / tracking -2.8，x 149.37 与 721.22，基线 y 244.62 | `SvgText` 把 `firstTextBaseline` 放到该 y |
| 功率文案 `12`，无 `+` | `DesignSpec.wholeHero` |
| 速度、功率下方不再画横线。单位仍在基线 262.17 | `CleanHero.drawsUnderline = false` |
| 标签基线 74.91，单位基线 262.17 / 12px | 同 `SvgText` |
| 车道框上移 12pt：350.79,137.81 172.41×213.90。只描左右斜边和虚线中线，路径不闭合 | `RoadOutline`，`RoadTrapezoid` 只填充不描顶底 |
| `.car-img.rear` 上移 12pt：406.37,216.05 60.41×83.23，630×868 contain | `BitmapCar("CarRear")` |
| 圆点随中间组上移 12pt，`bottom: 64` | 底边 y = 402−64 |
| `.bottombar` 59,364 756×22 | 底栏 frame |
| 安全区 59/59/21 已含在画板内 | `PlacedBoard`：inset 不超过这块留白时不二次缩小 |

未把 HTML 卡片的 55pt 圆角和预览页灰底画进全屏，避免再做出截图里红框那条额外黑边。
