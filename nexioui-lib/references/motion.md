# NexioUI 动效与反馈（源码实测）

来源：`anim/FolmeSpring.kt`、`indication/NexioIndication.kt`、`pressfeedback/SinkFeedback.kt`、`interaction/InteractiveHighlight.kt`、`cardexpand/CardExpand.kt`、`switch/CouiSpring.kt`、`overscroll/*`（`main` @ `3fa6c2f`）。

## 1. 弹簧的两种写法

### 1.1 `folmeSpring(damping, response)`

`anim/FolmeSpring.kt`：用「阻尼比 + 响应时长」描述弹簧，比直接给 `stiffness` 直观。

```kotlin
val stiffness = ((2 * PI / response) * (2 * PI / response)).toFloat()
spring(dampingRatio = damping, stiffness = stiffness)
```

- `damping = 1.0` 临界阻尼（不过冲），`< 1.0` 振荡，`> 1.0` 过阻尼。
- `response` 是秒，越小越快。

**新增动效优先用它**，而不是手算 stiffness —— 参数含义可读，跨组件一致。

### 1.2 `CardDefaults.SizeAnimation`

```kotlin
spring(dampingRatio = 0.9f, stiffness = Spring.StiffnessMediumLow, visibilityThreshold = IntSize.VisibilityThreshold)
```

用于卡片高度变化（行数增减、文字换行）。`0.9` 只有极轻微回弹，常见行高变化约 260~320ms，**首帧不播**，首次测量直接定高。

## 2. 按压反馈（不用水波纹）

这是全库最容易被破坏的约定。

| 组件 | 作用 |
| --- | --- |
| `indication/NexioIndication` | 整块淡色覆盖，替代 Material ripple |
| `interaction/InteractiveHighlight` | AGSL `RuntimeShader` 按压高光 |
| `pressfeedback/SinkFeedback` | 按压缩放：默认 `sinkAmount = 0.94f`，`spring(0.8f, 600f)` |

`NexioTheme` 内部把 `LocalIndication` 全局替换为 `NexioIndication(colorScheme.onBackground)`：

```kotlin
val indication = remember(colorScheme.onBackground) { NexioIndication(color = colorScheme.onBackground) }
CompositionLocalProvider(LocalIndication provides indication, ...)
```

`NexioIndication` 的透明度档位：

| 交互 | delta |
| --- | --- |
| hover | 0.06 |
| focus | 0.08 |
| press | 0.10 |
| hold down | 0.10 |

`SinkFeedback` 同时响应 `HoldDownInteraction`：长按时手指滑出边界仍算按住，与普通按下共用同一份缩放。

**推论**：任何 `clickable(indication = ripple())`、`Modifier.indication(ripple())` 都会打破全局一致性；`SinkFeedback` 与水波纹互斥。

## 3. 卡内展开：`CardExpand`

参数集中在 `CardExpandDefaults`：

| 参数 | 值 | 含义 |
| --- | --- | --- |
| `HeightSpring` | `CardDefaults.SizeAnimation` | 与卡片高度同一条 spring |
| `FadeMillis` | **180** | 内容淡入淡出，比高度短，避免「先亮后长」 |
| `BlurDp` | **12f** | 最大模糊半径 |
| `BlurInMillis` | **420** | 展开时模糊散尽，比高度长，高度先到位再收尾变清晰 |
| `BlurOutMillis` | **160** | 收起时模糊铺满，比高度短，先糊住再缩回 |

**进慢出快是刻意的**。实现要点（自己写类似动效时必须遵守）：

- 高度用 `AnimatedVisibility(expandVertically/shrinkVertically, animationSpec = HeightSpring)`，**不要**用 `animateContentSize` 包 Card（它补间占位尺寸，内容按最终尺寸绘制，「收不回去」）。
- 模糊用 `BlurEffect(px, px, TileMode.Decal)`，先判 `isRenderEffectSupported()`；绘制期读动画值，组合期不读 → 零重组。
- `AnimatedVisibility` 内必须再包一层 `Column`：它按单子内容设计，多子项会被全部 place 到 (0,0) 叠成一行。
- 同一段内容只用一种机制；`CardExpand` 套 `animateContentSize` = 「动画的动画」。

## 4. 开关的连续弹簧：`CouiSpring`

`switch/CouiSpring.kt` 是 KMP 版 `SpringAnimation` 等价物：

- 持续运行的物理弹簧，`animateToFinalPosition` **只改目标不重启**。
- `velocity` 可读写，高频拖动不打断跟手。
- 默认收敛阈值 `minimumChange = 1f`。

开关的四个参数（`SwitchDefaults`）：`toggleResponse 0.4` / `toggleBounce 0.3` / `dragResponse 0.3` / `dragBounce 0`；位移阈值 `transformDistancePx = 4f`、`transformVelocityPx = 1000f`。

**不要**用 `animateFloatAsState(checked)` 重写开关：会丢失甩动惯性。

## 5. 滚动与触感

| 包 | 内容 |
| --- | --- |
| `overscroll/` | `NexioOverscrollFactory`（弹簧回弹）、`OverscrollMath`、`SpringMotion`；无 `overScroll*` 修饰符的滚动容器经 `LocalOverscrollFactory` 自动继承 |
| `scrollhaptic/` | `ScrollEndHaptic`，滚到底的触感 |
| `slider/` | `SliderHapticEffect.Edge`（默认） |

## 6. 其它动效

| 包 | 内容 |
| --- | --- |
| `motion/` | `ArcBend`（弧形弯折）、共享元素转场 |
| `ripple/` | 自定义水波纹（用于少数需要强调扩散的场景，非常规按压反馈） |
| `interaction/` | `DampedDragAnimation`（派生自 AndroidLiquidGlass-kmp）、`DragGestureInspector`、`HoldDownInteraction`、`SpotlightShader` |
| `window/` | 窗口圆角、`TabletWidth` 判定 |
| `colorpalette/` | `ColorPalette` + `HsvAlphaSlider`（HSV 调色） |

## 7. 降级路径（必须保留）

- 玻璃：无 shader / 无壁纸 → 纯色表面。
- 渐进模糊：渐变遮罩 → AGSL 两趟 → 假渐进 → 渐变遮罩兜底，**不退化纯色**。
- `isRenderEffectSupported()` 为假时不要跳过内容，只跳过模糊。