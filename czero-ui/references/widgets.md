# gdust 九款小部件视觉规范（CZeroX 语言延伸）

> **实证边界**：CZeroX 官方没有发布任何 widget 截图。本章是 **[推导]**——把 tokens.md 的实底卡语言延伸到桌面小部件环境，并结合 gdust 现有 `WidgetStyle.kt` 的落地约束写成。视觉会话产出规范、主线会话落地时，本章为基准；有冲突时用户裁决。
>
> 现状（2026-11-14 快照）：九款 widget 走的是 **Nexio/SoftGlass 玻璃卡风**（`WidgetStyle.glassCard`：半透明白渐变底 + 顶部扫光 + 细描边，透壁纸）。CZeroX 是**实底卡**语言，两套不能混。
> **注意**：widget 目录正被其他会话持续改动，本章「现状」列可能过时——落地前先读最新的 `WidgetStyle.kt`，映射表以「目标」列为准。

## 一、九款清单与信息构成

| 类别 | 尺寸 | 卡面构成 |
|---|---|---|
| 课表 Schedule | Wide / Medium / Tall | 今日课程块列表；Medium/Tall 含「下一节倒计时」高亮行；课程块用 accentSoft 胶囊 + sectionLabel |
| 电量 Power | Wide / Medium / Tall | 当前电量大数字（powerValue，`%.1f`）+ 走势线图（trend）+ Wide 含量程切换（RangeSwitch） |
| 待办 Todo | Wide / Medium / Tall | 分组计数（逾期/今天/本周/以后/无期，pending）+ 待办行（KindBadge + 标题 + dueText 到期文本） |

实现：Glance（`GdustGlanceWidget` 基类 + `GdustWidgets.kt`），样式集中在 `WidgetStyle.kt`。**改样式只动 WidgetStyle 与相关 composable，不改数据层。**

## 二、总原则：从玻璃卡到 CZeroX 实底卡

CZeroX 分层哲学 = **底色分层，不用线**。落到桌面环境：

1. **卡面实底化**：浅色 = `#FFFFFF` 实底（或 `#F7F7F7` 当 widget 需要与浅色壁纸区隔时），深色 = `#1C1C1E` 实底。**移除半透明渐变、顶部扫光、细描边**（`glassCard` 的三件套全部退役；若确需保留透壁纸质感，透明度不得低于 92%，且描边与扫光仍必须移除）。
2. **圆角对齐 App**：`WidgetStyle.radius` 22dp → **24dp**，与 App 内卡片同一档。
3. **文字对比度对齐 tokens.md**：大数字/主文字 = 纯黑（浅）/ `#F2F2F7`（深）；标签/说明 = `#666666`（浅）/ 白 62%（深）。现有 `text()`/`sub()` 基本对齐，仅浅色 sub 从黑 55% 换成 `#666666` 实色。
4. **强调色**：沿用 `ACCENT_LIGHT #3482FF`（与 CZeroX UI 蓝实测一致）/ `ACCENT_DARK #7AB0FF`。课程胶囊、类型徽章、激活态继续用 accentSoft（14%/24% alpha）。
5. **状态色语义**：电量低、待办逾期用 `danger #EE4444` **小面积**点缀（数字或徽章前景色），不做大面积红 tint 卡——widget 空间小，大面积 tint 只留给「整卡即状态」的场景（如全逾期）。
6. **无阴影无描边**：Glance 也画不了真阴影；层与层之间靠 bg 与卡面明度差。widget 内部不再嵌套卡片框。

## 三、逐项映射（WidgetStyle 落地清单）

| 现状（玻璃卡风） | 目标（CZeroX 风） |
|---|---|
| `glassCard()` 半透明渐变 + 扫光 + 描边 | 实底圆角矩形：浅 `#FFFFFF` / 深 `#1C1C1E`，radius 24dp，可保留 `Bitmap` 方案（纯色填充即可，代码更短） |
| `sub(dark)` 浅色 = 黑 55% alpha | `#666666` 实色（深色不变：白 62%） |
| `trend()` 线图（accent 线 + 渐变面积 + 末点白圈） | 保留，底衬基线与面积渐变随实底底色重算对比度；末点白圈在白底上改为深色描边（浅）/ 白描边（深） |
| `Badge` 胶囊 | 保留 accentSoft 底 + accent 前景；危险态 `danger` 12% 底 + `#EE4444` 前景 |
| 空态/禁用 | 数值区显示「—」，不整卡置灰；与 components.md 状态清单一致 |

## 四、平台注意（Glance）

- 无实时模糊/阴影：一切「玻璃感」手段都不符合本规范，不要试图替代实现。
- 文字最小 11sp，大数字按 Medium/Tall 分别 22–28sp / 32–40sp。
- 深浅色由 `WidgetStyle.isDark` 跟随系统；**两套色都要过对比度自查**（黑字白卡、白字深灰卡）。
- 布局密度：Wide ≥ 4 列信息密度，Medium 2 列，Tall 纵向堆叠——信息排布沿用现有 `provideGlance` 结构，本规范只管视觉，不动机制。
