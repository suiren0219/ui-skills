# KernelSU 官方管理器（tiann/KernelSU）UI 规范

来源：`tiann/KernelSU` main 分支 `manager/` 目录 Compose 源码实测。包名 `me.weishu.kernelsu`，以下路径相对 `manager/app/src/main/java/me/weishu/kernelsu/`。

## 技术栈

- Jetpack Compose BOM 2026.09.00 + **Material 3 Expressive（material3 1.5.0-alpha28）**
- **Miuix 0.9.4**（`top.yukonga.miuix.kmp`）+ **materialKolor 5.0.1**（动态取色）
- **双 UI 引擎**：`ui/UiMode.kt` 定义 `enum UiMode { Miuix, Material }`，**默认 Miuix**，每个页面三件套 `XxxScreen.kt`（逻辑）+ `XxxMaterial.kt` + `XxxMiuix.kt`（两套视觉），按 `LocalUiMode` 分发
- 自研 `ui/navigation3/` 导航，渲染用 miuix `NavDisplay`：predictive back、侧滑返回（可关）、页面裁剪圆角跟随系统圆角（`rememberNavSystemCornerRadius()`）
- `MaterialExpressiveTheme(colorScheme, motionScheme = MotionScheme.expressive(), typography)`（`ui/theme/MaterialTheme.kt`）

## 颜色体系

- `ColorMode` 7 档（`ui/theme/Theme.kt`）：SYSTEM / LIGHT / DARK / MONET_SYSTEM / MONET_LIGHT / MONET_DARK / DARK_AMOLED
- 取色：Monet 时取系统 `dynamicDark/LightColorScheme().primary` 作 seed；自选 seed 时 materialkolor `rememberDynamicColorScheme(seed, isDark, isAmoled, style, spec)`；`paletteStyle` 默认 TonalSpot，`colorSpec` 默认 SPEC_2025（仅 TonalSpot/Neutral/Vibrant/Expressive 支持 2025 规范）
- **预设 15 色 keyColor**（`ui/theme/Colors.kt`）：`0xFFF44336 / 0xFFE91E63 / 0xFF9C27B0 / 0xFF673AB7 / 0xFF3F51B5 / 0xFF2196F3 / 0xFF00BCD4 / 0xFF009688 / 0xFF4FAF50 / 0xFFFFEB3B / 0xFFFFC107 / 0xFFFF9800 / 0xFF795548 / 0xFF607D8F / 0xFFFF9CA8`
- **AMOLED**（`ThemeExt.kt amoledBackground()`）：`background/surface/surfaceDim/surfaceContainerLowest~Highest` 全部 `Color.Black`
- **主题切换动画**：整个 ColorScheme 47 色逐项 `animateColorAsState(spring())`
- 容器层级：Scaffold / TopAppBar / 底栏统一 `surfaceContainer`（无滚动变色分层）；卡片与分段列表用 `surfaceBright`
- 状态语义（`ui/screen/home/HomeMaterial.kt`）：工作正常 = `secondaryContainer` + `Icons.Rounded.CheckCircle`；未安装/不支持 = `errorContainer`（Warning/Block 图标）；警告卡 Error=`errorContainer`、Notice=`tertiaryContainer`
- 徽章（SuperUserMaterial / BottomBarMaterial）：ROOT=`primary/onPrimary`、UMOUNT=`tertiaryContainer`、CUSTOM=`secondaryContainer`、USER N=`tertiary/onTertiary`；更新提醒 Badge=error 色、普通计数=primary
- **Miuix 首页硬编码绿色**（`HomeMiuix.kt`）：正常卡亮 `0xFFDFFAE4` / 暗 `0xFF1A3825`，装饰图标 `0xFF36D167`；StatusTag 绿文字 `0xFFB8E8C5`、底亮 `0xFF164A29` / 暗 `0xFF315D3E`；动态色开启时改用 secondaryContainer/tertiaryContainer

## 字体排版

- 无自定义字体；`ui/theme/Type.kt` 仅覆写 `bodyLarge = 16sp / lineHeight 24sp / letterSpacing 0.5sp`
- 大量用 M3 Expressive emphasized 变体：`titleMediumEmphasized`（状态卡标题）、`titleSmallEmphasized`（分段组标题，primary 色）、`labelSmallEmphasized`（StatusTag）
- Miuix 版硬编码：状态卡标题 22sp SemiBold、版本行 15sp、LKM/GKI 角标 16sp Medium
- 模块卡：名称 `titleMedium + SemiBold`、版本/作者 `bodySmall + onSurfaceVariant`

## 形状与圆角

无自定义 Shape.kt，Material 侧 `shapes.large`（Expressive 16dp）：

- 卡片 `TonalCard shape = MaterialTheme.shapes.large`
- **分段列表**（`ui/component/material/SegmentedList.kt`）：外圆角 16dp、内圆角 4dp、条目间距 2dp；圆角随条目显隐用 `spring(stiffness = 800f, damping = 0.9f)` 动画（iOS 分组列表行为）
- StatusTag：`RoundedCornerShape(4.dp)`，padding 2×4dp
- 浮动底栏：胶囊 CircleShape，容器高 64dp、指示器 56dp、内边距 4dp
- 安装页图标预览 100dp + 25dp 圆角

## 组件签名

| 组件 | 要点 |
|---|---|
| TopAppBar | `LargeFlexibleTopAppBar` + `exitUntilCollapsedScrollBehavior`，全 App 统一大标题，与页面同色 surfaceContainer |
| Scaffold | `ExpressiveScaffold`：`containerColor = surfaceContainer`，insets `safeDrawing.only(Top+Horizontal)` |
| 主导航 | Material：`ShortNavigationBar`；Miuix：液态玻璃胶囊底栏；宽屏 `NavigationRail`。4 tab：Home/Shield/Extension/Settings，`Filled/Outlined` 双态图标 |
| 主内容 | `HorizontalPager` 4 页（`beyondViewportPageCount = 3`）+ spring 切页；predictive back 先回第 0 页 |
| 卡片 | `TonalCard`：填充式无 elevation 无描边，`surfaceBright`，combinedClickable |
| 分组列表 | `SegmentedColumn + SegmentedListItem/SwitchItem/DropdownItem/CheckboxItem/RadioItem`；组标题 `titleSmallEmphasized` primary 色 |
| 开关 | `ExpressiveSwitch`：thumb 恒显 Check/Close 图标；disabled thumb alpha 0.38 / track 0.12 |
| FAB | `SmallExtendedFloatingActionButton`（模块页「安装」），随滚动展开/收起 |
| 小按钮 | `filledTonalShape`、52×32dp、图标 20dp、labelMedium |
| 菜单 | `DropdownMenuGroup` + Expressive 分组形状 `MenuDefaults.groupShapes()/itemShape(index, count)` |
| 下拉刷新 | `PullToRefreshBox` + VirtualKey 触觉 |

## 页面结构

- **首页**（HomeMaterial）：更新卡 → WarningCard 组 → **StatusCard**（整宽 Surface，secondaryContainer/errorContainer，leading 状态图标 + titleMediumEmphasized + trailing LKM/GKI StatusTag）→ InfoCard（两个 SegmentedColumn：管理器/内核版本、设备/fingerprint + SELinux/Seccomp）→ SupportLinks。纵向 `padding(horizontal = 16.dp)` + `spacedBy(13.dp)`
- **Miuix 首页**：绿色大卡 + **110dp 背景装饰大图标**（右下溢出裁切 offset(27dp,31dp)）+ 左上 22sp 标题 + 左下 LKM/GKI 角标；`padding(horizontal = 12.dp)` 间距 12dp
- **模块页**：LazyColumn `spacedBy(13.dp)`；TonalCard 内边距 16/14/16/10；头部三行文本 + 右侧 ExpressiveSwitch；卸载待重启文字 LineThrough；META 徽章；Hairline 分隔线；底部 Action/WebUI/更新/卸载 按钮排；描述默认 4 行可展开
- **超级用户页**：按 uid 分组分段列表；组项图标 48dp + trailing 垂直 StatusTag 列；多 app 可展开（子项图标 40dp，搜索命中 secondaryContainer 高亮）
- **设置页**：LargeFlexibleTopAppBar + 多组 SegmentedColumn（组间距 bottom 13dp）
- **安装页**：SegmentedRadioItem 单选安装方式 → 分区 SegmentedDropdownItem + 强制备份 Checkbox → 高级选项折叠（ExpandMore rotate 0→180° 动画）→ 底部全宽「下一步」Button
- **主题定制页**：15 色 ColorButton + PaletteStyle/ColorSpec 下拉 + 实时预览卡

## 液态玻璃底栏（招牌，`ui/component/FloatingBottomBar.kt`）

- 胶囊 CircleShape 64dp；效果链 `vibrancy() + blur(4.dp) + lens(refractionHeight 24dp, refractionAmount 24dp)` + innerShadow
- 高光：双光源 BloomStroke（主光 (0.5,-0.3,-0.05) intensity 1f，次光 (0.5,0.8,-0.5) 0.4f，dualPeak，1dp 白 alpha 0.12）
- **重力传感器驱动高光方位**（`rememberDeviceTilt`，|g_xy|>0.1 阈值、3° 步进量化）
- 选中指示器 `DampedDragAnimation`：按压缩放 lerp(1f, 1f+16dp/width)、rubber band 4dp、dropShadow 10dp
- 页面级 `layerBackdrop`/`rememberBlurBackdrop` 供给底栏/顶栏实时模糊（LocalEnableBlur 等三开关，仅 Miuix 模式）

## 关键数值速查

- 页面水平 padding：Material 16dp / Miuix 12dp；卡片纵向间距 13dp / 12dp
- 分段列表：间距 2dp、外角 16dp、内角 4dp、组标题 bottom 8dp
- StatusTag：4dp 圆角、2×4dp padding；应用图标 48/40dp
- 圆角动画 spring(0.9f, 800f)；splash 500ms 强制时长
- WebUI 联动：`MonetColorsProvider.UpdateCss(colorScheme)` 把色板注入模块 WebView CSS 变量
