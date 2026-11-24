---
name: ksu-ui
description: KSU 系 root 管理器 UI 设计语言——以 KernelSU 官方、KernelSU-Next、SukiSU-Ultra 三家管理器的 Compose 源码实测为基准的规范：Monet 动态色 + AMOLED、实底状态卡流、StatusTag 徽章体系、液态玻璃悬浮底栏、扁平无阴影卡片。凡涉及还原/模仿这三家管理器界面、用户说「KSU 风格」「SukiSU 风格」「KernelSU 风格」「root 管理器风格」「照 KSU 改」时使用。与 fruit-flavor-design（HIG）/czero-ui（CZeroX）共用时，用户点名 KSU 系风格则以本 skill 视觉基准为准。
---

# KSU 系管理器 UI 设计语言

来源：三家仓库 manager 目录 **Compose 源码实测**（非截图目测），详细数值与文件路径证据在 `references/` 下：
- 改官方 KernelSU 风格 → `references/kernelsu-official.md`
- 改 KernelSU-Next 风格 → `references/kernelsu-next.md`
- 改 SukiSU-Ultra 风格 → `references/sukisu-ultra.md`
- 跨家共用/只需基底 → 本页「共性规范」即可

## 工作流（动手前按序执行）

1. **先定基准家**：用户点名哪家就用哪家；没点名时默认 **SukiSU-Ultra**（社区当前主流、特性最全）。
2. 按基准家读对应 references 文件拿到色值/圆角/组件签名，再写代码。
3. 套用下方「迁移映射」，写完过一遍「红线」自检。

## 设计气质（先读懂再动手）

root 工具型管理器的「**状态优先卡流**」：首页以一张全宽实底状态卡为锚（工作正常 = 正向色实底，异常 = errorContainer），工作模式（LKM/GKI）与安全模式用小徽章标注；其余信息卡按 警告 → 计数 → 版本/系统信息 顺序铺开。信息密集但**扁平**：分层靠填充色明度差，无描边、无阴影（SukiSU 连 FAB 阴影都压成 0）。Monet 动态取色优先 + AMOLED 纯黑独立开关。**液态玻璃悬浮胶囊底栏（blur + 折射 + 重力高光）是 KSU 系招牌交互**；spring 动画贯穿全局（换主题逐色弹性过渡、分段列表圆角动画、按压缩放）。

## 三家身份速览

| | KernelSU 官方 | KernelSU-Next | SukiSU-Ultra |
|---|---|---|---|
| 引擎 | Miuix 默认，可切 Material | 纯标准 M3 | Material 默认，可切 Miuix |
| 品牌色 | 无固定板，Monet + 15 色自选 | **Catppuccin 蓝 `0xFF8AADF4`** | **绿 `0xFF36D167`** 状态基调，粉 `0xFFFF9CA8` 兜底 seed |
| 形状 | large 16dp，分段列表 16/4dp | 24/16/12/10/8dp 梯度 | **8/12/18/24/32dp（比 M3 更圆）**，状态卡 Hero 28dp |
| 顶栏 | LargeFlexibleTopAppBar 大标题 | pinned TopAppBar + titleLarge-Black 标题 | Miuix TopAppBar + 渐进模糊 veil |
| 底栏 | 液态玻璃胶囊 / ShortNavigationBar | 自绘悬浮胶囊 + **可拖拽 pill + 横滑切页** | 液态玻璃胶囊 / 标准 Miuix |
| 卡片 | TonalCard（surfaceBright，无阴影） | ElevatedCard 实底 + filled Card | 无阴影扁平卡 + **按压 Tilt/Sink/缩放 0.97** |
| 招牌 | 分段列表设置页、ColorPalette 调色页 | 模块 banner 渐变、LabelItem 标签行、MetaModule 仓库、双计数卡 | 主题商店、沉浸首页 + sticker、KPM/SUSFS 页、36sp 大数字 |

## 共性规范（三家共享的基底）

- **颜色语义**：错误=`errorContainer/onErrorContainer`；中性标签=`secondaryContainer`；正向/更新=`tertiaryContainer`；强调卡=`primary` 实底 + `onPrimary` 文字。工作正常状态卡=正向容器色（Miuix 风用绿色系实底，Material 风用 primary/secondaryContainer）
- **StatusTag 徽章体系**：小圆角色块（4~6dp 圆角、9~12sp、Emphasized 字重）标注 LKM/GKI、SafeMode、越狱模式、ROOT/UMOUNT、META 等，贯穿状态卡/模块卡/超级用户页/底栏 badge
- **字排**：无自定义字体，只覆写 `bodyLarge = 16sp / lineHeight 24sp / letterSpacing 0.5sp`；页面标题 titleLarge（Next 用 FontWeight.Black）；卡名 titleMedium+SemiBold；辅文 bodySmall + onSurfaceVariant；**版本号/日志/内核参数用 Monospace**
- **edge-to-edge**：全透明系统栏 + `isNavigationBarContrastEnforced = false`；Scaffold insets 用 `safeDrawing.only(Top + Horizontal)`
- **AMOLED**：暗色下把 background/surface/surfaceContainer* 压成纯黑（Next 用 blend 混黑保留层次）
- **换主题动画**：ColorScheme 逐 role `animateColorAsState(spring())`
- 页面水平 padding 12~16dp，卡片纵向间距 12~13dp；设置页 = 分组卡 + Switch/Arrow 行
- WebUI 联动：把 colorScheme 导出为模块 WebView 的 CSS 变量

## 迁移映射（Miuix 项目落地）

- 主题层用 miuix `MiuixTheme` + `ThemeController(ColorSchemeMode, keyColor, isDark, paletteStyle)`（与官方 `ui/theme/MiuixTheme.kt` 同款），Monet 取系统 dynamic scheme 的 primary 当 keyColor；AMOLED 走 ColorSchemeMode
- 状态卡：Miuix 风直接抄官方 HomeMiuix 绿卡公式——亮 `0xFFDFFAE4`/暗 `0xFF1A3825` 底 + `0xFF36D167` 装饰图标 + 110~150dp 右下溢出裁切大图标 + 22~36sp Bold 状态词 + Monospace 版本行；动态色开启时换 `secondaryContainer/tertiaryContainer`
- 列表分组：官方 `SegmentedColumn`（外角 16dp/内角 4dp/间距 2dp/spring 圆角动画）或 Miuix `Card` 分组 + `ArrowPreference/SwitchPreference`
- 徽章：StatusTag（4~6dp 圆角小色块）或 MMRL `LabelItem`（Next 路线）
- 底栏：优先复用官方/SukiSU 的 `FloatingBottomBar`（vibrancy+blur+lens 折射+重力高光，两仓库几乎同源）；Next 路线则自绘胶囊 + 可拖拽 pill
- 按压反馈：Miuix `PressFeedbackType.Tilt/Sink`；Material 卡用缩放 0.97f + 触觉
- **禁改 Miuix vendor 源码本身**；风格全部通过 token 与组合实现

## 红线（写完逐条自查）

- 状态卡不实底 = 不合格（必须是容器色/品牌绿实底 + onColor 文字，LKM/GKI 用 StatusTag 标注）
- 卡片加描边或大阴影 = 不合格（分层只靠填充色；描边仅允许出现在小按钮 0.5dp outlineVariant 与 FAB 0.05dp）
- 版本号/内核参数不用 Monospace = 不合格
- 页面标题随意混用字重 = 不合格（Next 路线必须 titleLarge+Black；Miuix/Material 路线走 Large/Flexible 大标题）
- 底栏做成普通实底 NavigationBar 却声称「KSU 风格」= 不合格（要么液态玻璃胶囊，要么标注用的是 Next/标准形态）
- 换主题硬切颜色 = 不合格（逐色 spring 动画）
- 与 czero-ui/fruit-flavor-design 冲突时：用户点名 KSU 系风格则一切以本 skill references 实测值为准
