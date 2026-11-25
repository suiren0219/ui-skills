# 使用记录

记录每个 skill 在真实项目里的落地程度。分级标准：

| 级别 | 含义 |
| --- | --- |
| **深度落地** | 项目按该规范系统性重写或新建页面，有对应文档、测试或验收流程 |
| **局部应用** | 部分页面、组件或小部件套用规范，其余保持原样 |
| **仅参考** | 只借鉴个别 token 或结构，未形成系统约束 |

判定依据是仓库内的文档、提交记录和代码，不是精确统计。项目链接均为公开仓库。

## 总览

| 项目 | Skill | 程度 | 落地范围 |
| --- | --- | --- | --- |
| [gdust-v2](https://github.com/suiren0219/gdust-v2) 广科课程表 | `czero-ui` | 深度落地 | App 页面 + 九款桌面小部件 |
| [NexioSchedule](https://github.com/suiren0219/NexioSchedule) 课程表 | `nexio-ui` / `nexioui-lib` | 深度落地 | 设置页组件库、动效、柔光玻璃；已接入 NexioUI 复合构建 |
| [astrbot_plugin_github_bridge](https://github.com/suiren0219/astrbot_plugin_github_bridge) | `ksu-ui` | 深度落地（Web 移植） | Dashboard 全套 token 与组件 |
| [astrbot_plugin_schedule_lite](https://github.com/suiren0219/astrbot_plugin_schedule_lite) | 无 | 独立实现 | Miuix / HyperOS 视觉规范的 Web 移植 |

`fruit-flavor-design` 作为总纲贯穿以上项目：先按 HIG 确定信息层级与交互，再落到具体设计语言。`rust-desktop-ui` 用于 Rust 桌面端的框架选型与交付验证，不产生独立视觉规范。

## gdust-v2 · czero-ui

**程度：深度落地。** 整个 App 与桌面小部件统一为 CZeroX 实底卡语言。

- 色板与排版集中在 `ui/Design.kt`；`ui/Themes.kt` 关闭 Miuix 玻璃能力；`ui/AppSurfaces.kt` 定义实底 `AppCard` 与按下 tint。
- 双蓝分工：品牌露出 `#106DFD`、交互强调 `#3482FF`，不互换。
- 全部卡面不透明，无模糊、扫光、阴影；分层只靠底色与留白。
- 小部件按 `widget/WidgetStyle.kt` 改为实底背景、黑白数字与趋势图。
- `CZeroContrastTest` 覆盖日夜模式对比度与卡面不透明性；Debug 包提供 `CZeroPreviewActivity` 用于外观验收，Release 不包含。
- 文档：[`docs/CZERO_UI.md`](https://github.com/suiren0219/gdust-v2/blob/main/docs/CZERO_UI.md)

## NexioSchedule · nexio-ui

**程度：深度落地。** 设置页体系、动效与玻璃库均按规范实现。

- 设置页统一 `SmallTitle` + 20dp 连续圆角 `Card`，偏好行使用 `SwitchPreference` / `ArrowPreference` / `BasicComponent`。
- 卡内条件内容统一走 `CardExpand`：高度 spring + 淡入 180ms + 模糊进出不对称。
- 柔光玻璃独立为 `com.haooz.softglass` 库，页面层只注入 `GlassBackdrop`，无壁纸或无 shader 时退回纯色表面。
- 提交记录可见「nexioui 组件迁移」「外观页开关改用 SwitchPreference」等演进。
- 文档：`docs/SOFTGLASS_LIBRARY_PLAN.md`、`docs/hyperos-glass-token.md`

### 与 `nexioui-lib` 的关系

NexioSchedule 的 `settings.gradle.kts` 用复合构建接入上游控件库：

```kotlin
val nexiouiSource = file("../nexioui")
if (nexiouiSource.resolve("build.gradle.kts").exists()) {
    includeBuild(nexiouiSource) { dependencySubstitution { /* ... */ } }
}
```

即：本地存在 `../nexioui` 源码时改库即改即测，否则回落到 JitPack 坐标 `com.github.HaoZai000.NexioUI:nexioui`。

因此这个项目实际有**两层规范**：应用页面走 `nexio-ui`（Miuix 体系，本仓库实测自应用源码），控件库走 `nexioui-lib`（`NexioTheme` 体系，实测自上游库源码）。两者同名组件（Card / Button / CardExpand）参数不同，改代码前先确认当前文件 import 的是哪一套。

## astrbot_plugin_github_bridge · ksu-ui

**程度：深度落地（Web 移植）。** Dashboard 用原生 HTML/CSS/JS 复刻 SukiSU-Ultra 的视觉语言，不是 Compose 项目。

- `views/dashboard/style.css` 头部声明 `SukiSU-Ultra: solid tonal surfaces, expressive green, soft shapes.`
- 色值与 `references/sukisu-ultra.md` 逐项对应：`#36d167` / `#dffae4` / `#1a3825` / `#b8e8c5` / `#164a29`。
- 状态卡为绿实底 + `StatusTag` 徽章；卡片无阴影；唯一阴影属于液态玻璃悬浮底栏（第 453 行注释）。
- AMOLED 档位把背景压到纯黑；换主题走 `--color-time` 与 spring 曲线。
- README 公开声明界面参考 SukiSU-Ultra 重新实现，未复制上游源码。

## astrbot_plugin_schedule_lite · 独立实现

**程度：不适用现有 skill。** 控制台是 Miuix / HyperOS 视觉规范的 Web 移植，自成一套 token。

- `pages/dashboard/miuix.css`（378 行）定义 `--miuix-*` 命名空间：双主题色板、`28px`/`18px` 圆角、999px 胶囊、`backdrop-filter: blur(22px)` 玻璃卡、自定义滑块开关。
- 字体栈 `MiSans / HarmonyOS Sans SC / PingFang SC`，卡片带 1px 描边与重阴影（`0 18px 50px`），这是 HyperOS 的观感，与 `ksu-ui` 的「无阴影扁平卡」红线相反，所以不能归到 KSU 系。
- 主题三态（跟随系统 / 浅色 / 深色），`localStorage` 记忆，嵌入 AstrBot 插件页时优先读宿主深浅色；三档响应式断点 `1120px` / `860px` / `560px`。
- README 明确写了取舍原因：「Miuix 目前只提供 Compose Multiplatform 组件，没有可直接引用的 Web 构建；控制台按 Miuix / HyperOS 的视觉规范用原生 HTML/CSS 实现，不引入前端构建链。」

**时间线判定**：`miuix.css` 首版提交 2026-10-26（v1.3.0），早于本仓库任何一份 skill 的创建时间（`czero-ui` 11-14、`ksu-ui` 11-15、`nexio-ui` 11-21）。它的 `#3482ff` 与 `czero-ui` 的交互强调色相同，但那是 MIUI 系统蓝本身的取值，不是引用。因此这份实现归入「独立实现」，不虚报为某个 skill 的落地。

它和 `nexio-ui` 同属 Miuix 设计语言，但分别落在 Web 与 Compose 两侧，组件形态差异明显（Shadow 有无、圆角档位、动效机制），目前没有合并依据。若后续要沉淀成 skill，应作为独立的 `miuix-web`，而不是并入 `nexio-ui`。

## 备注

- 使用程度按项目当前代码状态判断，后续改动可能改变结论。
- 截图见 [`showcase/`](showcase/README.md)，均做过隐私检查。
