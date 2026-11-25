# NexioUI 组件默认值（源码实测）

来源：`nexioui/src/commonMain/kotlin/com/haooz/nexioui/` 下各 `*Defaults.kt` / 组件首参数（`main` @ `3fa6c2f`，v0.1.2）。
下表只记**默认值与签名**，不抄实现。控件清单见文末。

## 容器与布局

| 组件 | 关键默认值 | 文件 |
| --- | --- | --- |
| `Card` | 圆角 20dp；`insideMargin = PaddingValues(0.dp)`（**卡片内自己控 padding**） | `card/Card.kt` |
| `Card`（可点） | `PressFeedbackType.None` / `Sink` 两档；默认关闭系统涟漪 | `card/Card.kt` |
| `CardExpand` | 见 `motion.md` 的「卡内展开」 | `cardexpand/CardExpand.kt` |
| `Divider` | 0.75dp | `divider/Divider.kt` |
| `SmallTitle` | `InsideMargin = (horizontal 12dp, vertical 8dp)`；样式 `subtitle + Medium` | `smalltitle/SmallTitle.kt` |
| `Scaffold` | 自带弹层宿主 `NexioPopupHost`；`FabPosition` 四档（Start/Center/End/EndOverlay） | `scaffold/Scaffold.kt` |

> `SmallTitle` 的 12dp 是**有意**的：与调用方的 16dp / 20dp `contentPadding` 叠加后接近 MIUI 小标题起始位置。单独给到 16dp 会偏右。

## 按钮

| 组件 | MinWidth | MinHeight | 圆角 | InsideMargin |
| --- | --- | --- | --- | --- |
| `Button` / `FlatTextButton` | 58dp | 40dp | 16dp | 16dp / 13dp |

配色工厂：`buttonColors()`（次级）、`buttonColorsPrimary()`（主色）、`textButtonColors()`（透明覆盖，alpha 0.06，见 tokens.md §4）。
按钮默认文字 17sp；放进设置行要压 `minWidth/minHeight` 与 `insideMargin` 的垂直值，**不要改字号**。

## 输入

| 组件 | 默认值 |
| --- | --- |
| `TextField` | `insideMargin = DpSize(16.dp, 16.dp)`，`cornerRadius = 20.dp` |
| `SearchBar` | 圆角 20dp；`actionIconSize = 23.dp`；内部 `InsideMargin = DpSize(10.dp, 0.dp)` |
| `NativeTextField` | 平台原生输入（`androidMain` / 其他平台各一份实现） |

v0.1.2 起 TextField 底色改 `secondaryContainer`，对话框内用半透明叠加。

## 导航与栏

| 组件 | 默认值 |
| --- | --- |
| `BottomBar` | 高 56dp，`ActionGap = 10dp`，`TabWidthFraction = 0.21f`，图标 24dp，标签 11sp |
| `CollapsibleTopAppBar` | 收起高 52dp，`TitlePadding = 28dp`，`TitleWidthFraction = 0.9f`，大/小标题最大模糊 6dp |
| `ProgressiveBlurTopBar` | `BlurMaxRadius = 12dp`；无状态栏时额外收窄 `NoStatusBarBlurReduction = 8dp` |
| `TabletNav` | 展开最小宽 200dp，Rail 宽 84dp，侧/底内边距 12dp，面板 padding 8dp，项高 52dp，项间距 0，图标 26dp，图标中心 X 42dp |

渐进模糊的渲染路径按能力降级：渐变遮罩 → AGSL 两趟（抖动 + 环形去噪）→ 假渐进（单次 blur + 淡出；API 31–32 / 鸿蒙走 `Offscreen + DstIn`）→ 无 RenderEffect 时渐变遮罩兜底，**不退化纯色**。

## 选择与开关

| 组件 | 默认值 |
| --- | --- |
| `Switch` | 48×26dp，滑块 20dp，内距 3dp，`ContinuousCapsule`；`toggleResponse 0.4 / toggleBounce 0.3`，`dragResponse 0.3 / dragBounce 0` |
| `Checkbox` | 自定义绘制，不使用 M3 图标 |
| `Slider` | `MinHeight = 48dp`，默认触感 `SliderHapticEffect.Edge` |
| `CapsuleSlider` | 胶囊形态，含 `CapsuleFlingTracker`（甩动惯性）、`CapsuleSelector` |
| `SegmentedControl` | 容器高 42dp |

开关的弹簧是自实现的 `CouiSpring`：与 AndroidX `SpringAnimation` 同语义，运行中 `animateTo` 只改目标与速度、不重启协程，高频拖动不打断跟手。**不要换成 `animateFloatAsState`**，会丢跟手感。

## 弹层

| 组件 | 默认值 |
| --- | --- |
| `OverlayDialog` | `MaxWidth = 420dp`，圆角 42dp；采样层统一走 `overlayDialogBackdrop` |
| `OverlayPopup` / `Dropdown` | 预测性返回手势；`ListPopupLayout` 负责布局 |
| `BlurBottomSheet` | detent 分级（`BlurBottomSheetDetent`）；平板另走 `BlurBottomSheetTablet` |
| 底部弹窗底色 | 非莫奈时用中性底色（v0.1.1 修复项，别改回动态色） |

## 偏好设置项

`ArrowPreference`、`CheckboxPreference`、`SwitchPreference` 三件套；`BasicComponent` 承载只读行，`PreferenceFlash` 提供刷亮反馈。行内标题用 `headline1`（17sp），摘要用 `body2`（14sp）。

## 玻璃与背景

| 组件/工具 | 用法 |
| --- | --- |
| `GlassBackdrop`（SoftGlass） | `rememberLayerBackdrop()` + `Modifier.layerBackdrop()` 录采样源，传给玻璃组件 |
| `BgEffectBackground` / `BgEffectModifier` | OS3 风格背景特效，配置在 `BgEffectConfig` |
| `LocalMaterialNoneEnabled` | 无材质档：关玻璃，渐进模糊降渐变遮罩 |
| `LocalUseFakeProgressiveBlur` | 假渐进模糊（单次 blur + alpha 淡出） |

## 图标

`icon/basic/`（箭头、勾、关、搜索等）与 `icon/extended/`（大量业务图标，体积约 5.1MB）。**用库内图标**，不要混 `material-icons`；混入会破坏线性粗细一致性。

## 完整组件清单

`anim` `arrowpreference` `background` `basiccomponent` `blurbottomsheet` `bottombar` `button` `capsuleslider` `card` `cardexpand` `checkbox` `checkboxpreference` `color` `colorpalette` `daterangecalendar` `divider` `dropdown` `icon` `iconbutton` `indication` `interaction` `internal` `material` `motion` `nativetextfield` `navigationback` `numberpicker` `overlaydialog` `overlaypopup` `overscroll` `pressfeedback` `progressbar` `progressindicator` `progressiveblurtopbar` `ripple` `scaffold` `scrollhaptic` `searchbar` `segmentedcontrol` `slider` `smalltitle` `surface` `switch` `switchpreference` `tabletnav` `text` `textbutton` `textfield` `theme` `topappbar` `topbarmaterial` `window`

## 未覆盖

- 具体组件内部绘制逻辑与 shader 代码：本 skill 不复制，需要时到上游读。
- iOS 制品：JitPack 只出 Android / JVM，iOS 需 macOS 本地发布（`publishToMavenLocal` 验证）。