# SukiSU-Ultra 管理器 UI 规范

来源：`SukiSU-Ultra/SukiSU-Ultra` main 分支 manager 目录源码实测。包名 `com.sukisu.ultra`，路径相对 `manager/app/src/main/java/com/sukisu/ultra/`。

## 技术栈

- Kotlin 2.4.20 / AGP 9.4.1，Compose BOM 2026.09.00，**Material 3 Expressive（material3 1.5.0-alpha28）** + **Miuix 0.9.4** + **materialKolor 5.0.1**——与官方 KernelSU 依赖版本完全相同
- **双 UI 引擎**：`ui/UiMode.kt` `enum UiMode { Miuix, Material }`，**默认 Material**（官方默认 Miuix）；页面三件套 `XxxScreen.kt` + `XxxMaterial.kt` + `XxxMiuix.kt`，按 `LocalUiMode` 分发
- 其他：navigationevent-compose（预测性返回）、HorizontalPager 主导航、reorderable 3.1.0（列表拖拽排序）、commonmark、libsu 6.0.0

## 颜色体系

- **无固定品牌蓝；非动态色时的基调是绿 + 粉**：
  - `Colors.kt` `FallbackSeedColor = 0xFFFF9CA8`（粉，A12 以下/无动态色兜底）
  - 15 个预设 keyColor（与官方同一套 Material 经典色）
  - **首页状态卡绿**（HomeMiuix）：非动态时 accent `0xFF36D167`，暗卡底 `0xFF1A3825` / 亮卡底 `0xFFDFFAE4`，tag 底暗 `0xFF315D3E` / 亮 `0xFFB8E8C5`，tag 文字 `0xFF164A29`
- 7 种 ColorMode（SYSTEM/LIGHT/DARK/MONET_SYSTEM/MONET_LIGHT/MONET_DARK/DARK_AMOLED）；Monet 用系统 dynamic scheme primary 作 seed；PaletteStyle TonalSpot（默认）/Neutral/Vibrant/Expressive + SPEC_2025
- **AMOLED**：`amoledBackground()` 把 background/surface/surfaceDim/surfaceContainer* 全压 Black
- **主题色切换动画**：ColorScheme 全部 36 个 role 逐项 `animateColorAsState(spring())`（ThemeExt.kt）——换主题整屏弹性过渡
- Material 版状态卡：大色块 `colorScheme.primary` 实底 + onPrimary 文字 + `drawStatusRings(contentColor alpha 0.18f)` 装饰圆环
- 警告卡（WarningCard）：Error 暗 `0xFF310808`/亮 `0xFFF8E2E2` 文字 `0xFFF72727`；Notice 暗 `0xFF3E2F1B`/亮 `0xFFFFF0DB` 文字 `0xFFF5A623`
- **背景图模式**：`LocalCardBackgroundAlpha = 0.6f`，设背景图后卡片/表面 token 统一降透明（`backgroundAwareCardColors`），禁用文字 alpha 从 0.38 提到 0.85 保对比
- AppearanceOverlay：用户/主题包可覆盖任意 token，色板生成后统一 `withAppearance(overlayTokens)` 应用

## 字体排版

- `Type.kt` 只覆写 bodyLarge（16sp/24sp/0.5sp），无自定义字体文件
- 局部约定：**首页状态大字 36sp Bold**、StatsRow 数字 **26sp Bold**、模块名 17sp、KPM 名称 18sp SemiBold、**版本号/日志/args 用 Monospace 13-14sp**、StatusTag **9sp / FontWeight(750)**、底栏标签 11sp
- CustomTextScreen：自定义文案模板（替换界面固定文案）

## 形状与圆角（比 M3 默认更圆）

`ui/theme/Shape.kt`（注释：「比 Material 默认更圆，让卡片和对话框轮廓更柔和」）：

```
extraSmall 8dp / small 12dp / medium 18dp / large 24dp / extraLarge 32dp
```

- Material 状态卡 `HeroShape = 28dp`；沉浸 banner `BannerCorner = 20dp`
- KPM FAB 20dp 圆角；模块 FAB CircleShape；args 代码块 12dp；模块标签与 StatusTag 6dp；应用图标 `AppIconShape = 14dp`

## 组件签名

- **TopAppBar**：Miuix `TopAppBar` + `MiuixScrollBehavior`（标题距随 collapsedFraction 动画），透明底套 **`BlurredBar` + `TopBarVeil`（`ProgressiveBlur.Top` + 垂直渐变 tint 0.28→0.12→0）**；首页导航位放主题商店入口（Storefront 图标），actions 是重启菜单
- **底栏两形态**（BottomBarMiuix.kt）：① 标准 Miuix NavigationBar（透明底 + BlurredBar 模糊）；② **FloatingBottomBar 液态玻璃胶囊**：高 64dp、内边距 4dp、水平 28dp 边距、item 最小宽 76dp、label 11sp；blur 4dp + **折射 refractionHeight/refractionAmount 24dp**、底部渐进模糊 22dp、**重力感应旋转高光**（rememberGravityRotulatedHighlight）、按压橡皮筋 4dp、阴影 10dp（暗 0.2/亮 0.1）、白色 12% 内高光。宽屏 NavigationRail。带 NavigationBadgeState 徽章；非 fullFeatured 隐藏底栏
- **卡片**：Miuix `AppCard`（无 elevation 靠填充分层，**按压反馈 `PressFeedbackType.Tilt` 倾斜 / `Sink` 下沉**——标志性微交互）；Material `TonalCard`：`surfaceBright` + shapes.large(24dp) + **按压缩放 0.97f + 触觉**
- **FAB 一律 shadowElevation = 0**（扁平化）；模块页 CircleShape + border(0.05dp, outline 50%) + 40dp 图标
- 超级用户列表项：左侧 **6×24dp 竖条（16dp 圆角）授权状态指示** + 40dp 图标 + Chip 过滤器（14×7dp padding）
- 模块项：卡片 insideMargin 0 + 可选 banner 全宽背景 + 内部 16dp padding + 名称 17sp + 标签胶囊（12sp、6dp 圆角）+ 0.5dp 底分隔线 + 35dp 最小操作按钮
- 对话框三套并存：DialogMiuix/DialogMaterial、ExpressiveDialog、ScaleDialog，另有 FullscreenPagerDialog、DownloadDialog、SendLogBottomSheet
- M3 Expressive 家族封装在 `ui/component/material/`（ExpressiveSwitch/ToggleButton/TabRow/Slider/Menu/SnackBar）
- 液态特效：`ui/component/liquid/`（CombinedBackdrop、InnerShadow、Lens、Vibrancy）+ `miuix/effect/BgEffect*`（OS3 风格背景虚化碎片）

## 页面结构

- 主导航：HorizontalPager + 四 tab（Home/Superuser/Module/Settings）；KPM、KernelModules、SUSFS、ThemeStore、安装、刷入为二级页
- **首页**（HomeMiuix，LazyColumn 水平 12dp、块间 12dp）：
  1. **StatusCard**：Active 版最小高 188dp、内边距 22dp、右下 **150dp 大图标 offset(27dp,31dp)**、顶部 FlowRow StatusTag（工作模式/LKM/安全模式/越狱）、中部 36sp Bold "Working" + 14sp Monospace 版本号 `ksuVersion-kernelUAPIVersion`
  2. WarningCard 组（版本不匹配/PR 构建/需新内核/LKM 更新/Root 失败/预览模式/CI 更新，均可点击）
  3. AI 助手卡（MD3 卡嵌套 AiAssistantMaterialTheme）
  4. **StatsRow 三个等宽 88dp 高小卡**：Superuser 数/模块数/KPM 数（26sp Bold，Sink 反馈）
  5. InfoCard + SpecSheet 系统信息（内边距 16dp、行高最小 48dp）
  6. SupportLinks
- **沉浸模式首页**（HomeLayout.IMMERSIVE，常量集中在 `ui/util/HomeStatusStyle.kt`）：状态改「胶囊 pill」（min 高 46dp、状态圆点 8dp、label 15sp/meta 11.5sp）+ 可选图片 banner（高 88dp、圆角 20dp）+ sticker 贴纸系统
- **安装页**：SelectInstallMethod 单选卡组（选中态 2dp 描边）→ LKM 上传区（一键安装 LKM）→ boot 分区下拉（含 slot）→ **内核版本伪装（spoof）开关** + 展开输入框 → 主按钮 textButtonColorsPrimary；非 GKI 走 KernelFlashScreen（A/B Slot 对话框）
- **设置页**：AppCard 分组 + Switch/ArrowPreference；内含外观（UiMode/keyColor/PaletteStyle/背景图/模糊开关/悬浮底栏）、SUSFS 入口、主题导入导出

## SukiSU 独有页面（官方对应路径 404）

- **KPM 页**（screen/kpm/）：总览卡（18dp 圆角 primaryContainer 图标容器 + 28dp Extension 图标、20sp SemiBold 标题）→ KPM 模块卡（14dp 圆角 secondaryContainer 图标容器、18sp SemiBold 名称、**参数块 12dp 圆角 surfaceContainerHigh 底 + Monospace 13sp**、FlowRow 操作按钮）；空态 56dp 主色图标
- **SUSFS 页**（screen/susfs/）：FeatureStatusCard + BasicSettings/Kstat/SusPaths/SusMaps/SusLoopPaths/PriorityUidFilter 六分区 + 备份恢复
- **主题商店**（screen/themestore/）：Browse/Detail/Comments/Messages/Upload/Author 全套社区系统、主题包加密导出导入、试用、ThemePreviewSamples 实时预览
- 其他：AI 主题生成、AppIcon 图标包、Extensions（CPU/版本伪装胶囊入口）、DynamicManagers、Sulog、Account 页

## 与官方 KernelSU 的对比

- **高度趋同**：Theme.kt/Colors.kt/UiMode.kt/FloatingBottomBar.kt/BgEffectBackground.kt/ColorPaletteScreen.kt 两仓库几乎逐字一致（互相回流），不能算 SukiSU 独有
- **默认引擎不同**：官方 Miuix 默认，SukiSU Material 默认
- **SukiSU 独有**：主题商店、沉浸首页 + sticker、KPM 页；AppearanceOverlay、AI 主题、AppIcon 包、Extensions、SUSFS 完整管理页、DynamicManagers、Sulog、Account

## 一句话总结

**「M3 Expressive 与 Miuix 双引擎 + 全量 Monet 动态色（SPEC_2025、AMOLED、主题色 spring 动画）+ 比默认更圆的 8/12/18/24/32dp 形状 + 无阴影扁平卡片（按压 Tilt/Sink/0.97 缩放）+ 液态玻璃悬浮底栏（blur+折射+重力高光）+ 绿色 0xFF36D167 品牌基调」，其上叠主题商店、沉浸首页、KPM/SUSFS 管理页等分支特性。**
