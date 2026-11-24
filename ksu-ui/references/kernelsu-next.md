# KernelSU-Next 管理器 UI 规范

来源：`KernelSU-Next/KernelSU-Next` dev 分支（默认分支）manager 目录源码实测。包名 `com.rifsxd.ksunext`。

## 技术栈

- Kotlin 2.2.0 + Jetpack Compose + **标准 Material 3**（compose-bom 2025.07.00）——**无 Miuix，无 Expressive**，是三家中最传统的 M3 路线
- 导航：`com.ramcosta.composed-destinations`（注解式路由）
- 第三方 UI：`com.github.MMRLApp.MMRL:ui`（`LabelItem`/`TextRow` 标签组件贯穿全部列表）、`maxkeppeler sheets-compose-dialogs`（列表/输入弹窗）、markwon（Markdown 对话框）、coil
- dynamic color：A12+ 直接 `dynamicDark/LightColorScheme`（`ui/theme/Theme.kt` `dynamicColor = true`）
- **AMOLED**：动态暗色方案上 `background/surface` 置 `0xFF000000`，`surfaceVariant` 与 5 个 `surfaceContainer*` 按 `blend(AMOLED_BLACK, 0.6f)` 混黑；非动态时 0.8f
- edge-to-edge 全透明系统栏 + `isNavigationBarContrastEnforced = false`

## 颜色体系（Catppuccin 品牌色）

`ui/theme/Color.kt`（Catppuccin 调色板，三家唯一有固定品牌色板的）：

```kotlin
PRIMARY        = 0xFF8AADF4  // Catppuccin Blue——品牌主色
PRIMARY_LIGHT  = 0xFFB7BDF8  // Lavender
SECONDARY_LIGHT= 0xFFA6DA95  // Green
PRIMARY_DARK   = 0xFF7DC4E4  // Sky
SECONDARY_DARK = 0xFFF5BDE6  // Pink
DARK_PURPLE    = 0xFF6E6CB6  // Mauve
DARK_GREY      = 0xFF363A4F  // Surface
GREEN 0xFF4CAF50 / RED 0xFFF44336 / YELLOW 0xFFFFEB3B / ORANGE 0xFFFF9800
```

- 暗色策略：跟随系统 → Monet 动态色优先（A12+）→ fallback Catppuccin 固定板；darkColorScheme(primary = PRIMARY, secondary = PRIMARY_DARK, tertiary = SECONDARY_DARK)
- 语义色全走 M3 容器色：错误=errorContainer、中性标签=secondaryContainer、正向/更新=tertiaryContainer、**强调卡=primary 实底 + onPrimary 文字**（StatusCard、UpdateCard）
- 模块页 banner 渐变遮罩（Module.kt）：暗色 AMOLED→Black / 动态→surface / 普通暗→`0xFF222222` / 亮→White；判动态色的技巧是 `colorScheme.primary != colorScheme.secondary`
- WebUI 桥接：`ui/webui/MonetColorsProvider.kt` 导出 CSS 变量（与官方同名文件）

## 字体排版

- `Type.kt` 仅覆写 `bodyLarge`（16sp/24sp/0.5sp），无自定义字体
- 页面标题：`titleLarge + FontWeight.Black`（Settings/Module/SuperUser/Customization/Home 顶栏统一）
- 卡片标题：`titleMedium + SemiBold`（个别 Bold）；hero 数字 `titleMedium + SemiBold`；辅文 bodySmall/bodyMedium；标签 labelMedium/labelSmall
- 局部硬编码：LKM 小标签 10sp、About 卡 18sp/14sp

## 形状与圆角（24→8dp 梯度）

无 Shape.kt，M3 默认 medium/large + 硬编码：

| 元素 | 圆角 |
|---|---|
| 悬浮底栏容器 | 24dp |
| 底栏选中 pill | 16dp |
| 设置页 ListItem / LoadingDialog / AboutCard | 8dp |
| 更新分段选择器容器 / 段 | 12dp / 10dp |
| 模块操作按钮胶囊 | 20dp |
| LKM 小标签 | 4dp |
| 头像/图标底 | CircleShape |

## 组件签名

- **TopAppBar**：M3 `TopAppBar` + `pinnedScrollBehavior`，标题 `titleLarge + Black`；Home logo 彩蛋：点击旋转 `360f × 6`、tween(1400ms, FastOutSlowInEasing)
- **SearchAppBar**（`ui/component/SearchBar.kt`）：点搜索图标在标题位 AnimatedVisibility 淡入 `OutlinedTextField`（非 M3 SearchBar），带 actionsContent/dropdownContent 插槽
- **底部导航（核心特色，MainActivity.kt L701-914）**：完全自绘，不用 NavigationBar：
  - 悬浮胶囊 Surface：24dp 圆角、tonalElevation 3dp、shadowElevation 8dp、垂直外边距 14dp、水平 padding 响应式（>600dp→32 / >400dp→24 / 否则 16）
  - 容器高 72dp、item 56dp、间距 4dp、内边距 7dp；图标 Filled/Outlined 双态，选中 primary
  - 选中指示器滑动 pill（secondaryContainer、16dp 圆角）：`spring(DampingRatioMediumBouncy, StiffnessLow)`；**可拖拽 pill 切页**（拖拽中 scale 1.1f + NoBouncy）
  - 滚动下隐上显（threshold 50f slide+fade）；**左右横滑切 tab**（threshold 150f + GestureEnd 触觉）；页面方向性转场 tween(300)
- **卡片**：三容器——`ElevatedCard`（首页状态/计数/警告/更新卡，实底填充、内边距 24dp）；filled `Card`（模块项、设置分组、InfoCard、对话框容器）；描边只出现在小按钮 `BorderStroke(0.5.dp, outlineVariant)`
- **列表项**：`Card + ListItem(containerColor = Transparent)`；图标 48dp；副标题下 `FlowRow + LabelItem` 标签（spacedBy 4-6dp）
- **对话框**：ConfirmDialog（titleLarge + SemiBold，Markwon 渲染 Markdown）；LoadingDialog = 100dp Surface + spinner 禁外关；SUSFS/语言用 ModalBottomSheet（24dp 内边距）
- **开关**：`SwitchItem` 整行 toggleable 透明 ListItem，禁用整体 alpha 0.5f
- **FAB：无**（显式 `floatingActionButton = {}`），主操作走 TopAppBar 图标
- 下拉菜单：M3 DropdownMenu，排序 7 项均带 trailing Checkbox

## 页面结构

- 统一 Scaffold：内容列 `padding(top 16, horizontal 16)` + `spacedBy(16.dp)`；底部留白 `navigationBars + 112dp`
- **首页**：TopBar（logo+名称 | 设置/Archive 安装/重启下拉 6 项）→ **StatusCard**（ElevatedCard primary 实底，Mood 图标，LabelItem 标 LKM/BUILT-IN、SafeMode、sucompat_disabled(tertiary)、jailbreak_mode(errorContainer)；版本行 `vTag (versionCode-UAPI)`）→ **双计数卡**并排（Row spacedBy 14dp、weight 1:1、secondaryContainer、8dp 内边距；更新数 AnimatedContent 滑动动画）→ WarningCard×N（error 实底）→ **UpdateCard**（primary 实底 + **Main/Spoofed 分段选择器**：容器高 48dp、`surfaceVariant.copy(alpha=0.12f)`、12dp 圆角；段内 FilledTonalButton 10dp 圆角，选中 primaryContainer/未选 secondaryContainer alpha 0.69）→ **InfoCard**（filled Card 24dp 内边距；条目=图标+titleMedium SemiBold 标签+bodySmall 值、条目间 16dp；常显 Manager Version/Hook Mode/MetaModule/SUSFS 版本/Zygisk 状态；底部 36dp IconButton 箭头 tween(300) 旋转 180° 展开内核/Android 版本/ABI/SELinux/Seccomp）→ IssueReportCard → ContributorsCard（头像 38dp CircleShape + 0.5dp 描边）
- **模块页**：SearchAppBar（Cloud/Add/MoreVert 排序 7 项）→ PullToRefreshBox（LongPress 触觉）→ LazyColumn spacedBy 16dp → `ModuleItem`：filled Card + **banner 平铺背景 alpha 0.18f + Brush.verticalGradient 遮罩（0→0.8）**，内容 padding(22,18,22,12)；名称 titleMedium SemiBold（待卸载 LineThrough）；右上 Switch；描述 bodySmall 3 行；**LabelItem 标签行**：size、uninstalled/zygisk_required/preinit(errorContainer)、meta_module/zygisk/webui/action(secondaryContainer)、update available/updated(tertiaryContainer)；**单击展开操作行**（fadeIn+expandVertically）：Action/WebUI/Donate/Restore/Uninstall 为 FilledTonalButton 52×32dp，Update 为 Button(textShape)；长按弹自绘 Dialog+Card 菜单
- **超级用户页**：AppItem = Card + 透明 ListItem，48dp 图标，titleMedium SemiBold + bodySmall 包名，FlowRow 标签 ROOT/UMOUNT/CUSTOM/DEFAULT
- **设置页**：按功能分 **3 张 filled Card**（KernelFeatures 8 项 Umount/SU/Sulog/ADB root/SELinux Hide/AVC Spoof 等，summary 按 supported/managed/forced/unsupported 四态文案；Security：SELinux Permissive + **SUSFS Guard LKM 加载入口**；AppSettings）；组内 `Column(padding 12, spacedBy 6)`，条目 clip 8dp
- **MetaModule 仓库页**：卡片与模块卡同风格（banner 渐变、LabelItem：License/Installed(secondaryContainer+Check)/Stars(tertiaryContainer+Star，≥1000 显示 x.xk)）；底部 Latest version + 下载 Button（下载中换 18dp spinner）
- **启动动画**：Logo 120dp 旋转 6 圈 1400ms（可关）+ AnimatedContent fade 180ms 进主界面
- 开发者选项：InfoCard UAPI/UID 明细、模块卡 3 行技术信息、ROOT UID 标签、默认展开 InfoCard
- AppLock：生物识别全屏遮罩（独立 Theme 包裹）

## 与官方管理器的差异（fork 后自演进）

1. 品牌色 Catppuccin 蓝紫系（官方无固定色板，走 Monet/自选）
2. AMOLED 手工混黑（官方走 Miuix ColorSchemeMode）
3. 独有：自绘悬浮可拖拽底栏、横滑切页与方向性转场、启动/logo 旋转彩蛋、模块 banner 渐变背景、MMRL LabelItem 标签体系、MetaModule 仓库页、SUSFS 加载 UI、Main/Spoofed 分段选择、模块卡展开式操作行、贡献者卡
4. 一致处：edge-to-edge、pinnedScrollBehavior TopAppBar、Markdown 对话框、WebUI Monet 导出

## 一句话总结

**「Catppuccin 底色 + Monet 动态优先、M3 实底卡片 + LabelItem 标签化列表、悬浮胶囊可拖拽底栏、24/16/12/10/8dp 圆角梯度、titleLarge-Black 页面标题」的高密度工具型 M3 设计语言，特色全围绕 SUSFS/MetaModule/开发者诊断信息展开。**
