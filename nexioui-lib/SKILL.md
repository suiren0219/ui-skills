---
name: nexioui-lib
description: NexioUI 控件库（HaoZai000/NexioUI）的设计语言——Compose Multiplatform 控件库实测规范：NexioTheme 语义色板与文字层级、20dp 连续圆角卡、按压高光替代水波纹、弹簧动效与 CardExpand 进慢出快、液态玻璃 backdrop 采样。凡涉及 NexioUI 库本身的使用、升级、二次封装，或用户说「NexioUI」「用 Nexio 的控件库」「Haooz 那套控件」时使用。与 nexio-ui（NexioSchedule 应用层）区分：本 skill 管库，nexio-ui 管应用页面。
---

# NexioUI 控件库设计语言（源码实测版）

基准：https://github.com/HaoZai000/NexioUI ，`main` @ `3fa6c2f`（2026-11-24，v0.1.2）。
License：**Apache-2.0**，`NOTICE` 声明部分控件派生自 [compose-miuix-ui](https://github.com/miuix-kotlin-multiplatform/miuix)、AndroidLiquidGlass-kmp 与 [SoftGlass](https://github.com/HaoZai000/SoftGlass)。
**本 skill 是独立撰写的规范文字，不含该库源码**；取值均可在上表的文件路径里核对。

⚠ 上游 `NOTICE` 另有一节「视觉与参数参考」：部分动效参数与视觉表现参考了小米 HyperOS 与 COUI 控件，**相关名称、界面与实现的权利归小米集团所有**。上游自称不含其资源文件，仅作观感兼容，并提示商用需自行确认授权。取用本 skill 时同样遵守这条边界：可以描述「按压高光的观感与参数档位」，不要复制 HyperOS 的专有资源、图标或整段实现。

## 与 nexio-ui 的分工

| | `nexioui-lib`（本 skill） | `nexio-ui` |
| --- | --- | --- |
| 对象 | NexioUI 控件库（CMP，Android/JVM/iOS） | NexioSchedule 应用工程 |
| 来源 | 库源码实测 | 应用源码实测（Miuix 体系） |
| 用途 | 引依赖、包组件、升级对齐 | 改页面、加设置项 |

两者视觉同源（都是 HyperOS / Miuix 系），但**主题入口不同**：NexioUI 是 `NexioTheme` + `NexioColorScheme`，NexioSchedule 应用走 `MiuixTheme`。同名组件（Card、Button、CardExpand）不要混用参数。

## 设计气质

MIUI 设置页骨架 + iOS 级细节，靠**语义色板 + 连续圆角 + 物理弹簧**统一：

- 分层靠 `surface` / `surfaceContainer` / `surfaceContainerHigh` 的明度差，不靠描边和阴影。
- **不用 Material 水波纹**：全库统一 `NexioIndication`（整块淡色覆盖）+ `InteractiveHighlight`（AGSL 按压高光）。
- 所有高度/位移变化走弹簧，不出现线性缓动。
- 玻璃是可选层：无 shader、无壁纸时退化为纯色表面，不是异常路径。

## 工作流（动手前按序执行）

1. 先确认引入方式：JitPack `com.github.HaoZai000.NexioUI:nexioui:0.1.2`，或复合构建 `includeBuild("../nexioui")`。
2. 读对应规范：
   - 配色 / 字号 / 语义槽位 → `references/tokens.md`
   - 组件默认尺寸与签名 → `references/components.md`
   - 弹簧、按压、展开动效 → `references/motion.md`
3. 写代码时**只取主题槽位**（`NexioTheme.colorScheme.x`），不写死颜色。
4. 交付前过「红线」自检。

## 平台与依赖边界

- 目标：Android（minSdk 26）、JVM Desktop（JDK 17+）、iOS 13+（`iosArm64` / `iosSimulatorArm64`）。
- 依赖：Compose Multiplatform 1.12、Kotlin 2.4；玻璃能力来自 SoftGlass（传递引入）。
- **JitPack 只产出 Android / JVM 制品**：iOS 需在 macOS 本地克隆发布，不要假设 JitPack 有 iOS 产物。
- 全部控件实现在 `commonMain`，不要新增 `androidMain` 专属逻辑到公共组件里。

## 移植映射（应用侧接入）

- 主题层：`NexioTheme(isDark, colorScheme, textStyles, isDynamicColor)`；动态取色靠整体替换 `NexioColorScheme` 实例，库内不内置 Monet 算法。
- 主题读取：`NexioTheme.colorScheme` / `NexioTheme.textStyles` / `NexioTheme.isDark`（与 `MaterialTheme` 同形）。
- 玻璃组件：先 `rememberLayerBackdrop()` + `Modifier.layerBackdrop(backdrop)` 录采样源，再把 `backdrop` 传给按钮/弹窗/底栏；绘制期实时采样，滚动与换主题后自动重采，**不需要手动刷新**。
- 弹窗采样层统一走 `overlayDialogBackdrop`（v0.1.2 抽出的唯一判定点）。
- 无材质档：`LocalMaterialNoneEnabled` 关闭玻璃、渐进模糊降为渐变遮罩；`LocalUseFakeProgressiveBlur` 用一次 blur + alpha 淡出替代 AGSL 多重采样。
- 文本用 `NexioText`，不要直接 `Text` + 手写样式；图标用库内 `icon/` 图标集，避免风格混杂。

## 红线（写完逐条自查）

- 用 `MaterialTheme` 取色或写死 `Color(0xFF…)` = 不合格（唯一例外见 tokens.md 的说明）
- 给可点控件开 Material 水波纹 = 不合格（与全库统一按压反馈冲突）
- 卡片加描边或投影 = 不合格（分层靠 surface 明度差）
- 高度变化用 `animateContentSize` 包 Card = 不合格（要用 `CardExpand` / `CardDefaults.SizeAnimation`）
- 玻璃组件不传 backdrop、靠自绘模糊伪造 = 不合格
- 无 shader / 无壁纸时玻璃组件不可用 = 不合格（必须退化到纯色表面）
- 把 iOS 产物当作 JitPack 已有 = 不合格（需 macOS 本地发布）
- 与 `nexio-ui` 混用参数 = 不合格（主题入口不同，见上表）