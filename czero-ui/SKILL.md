---
name: czero-ui
description: CZeroX UI 设计语言——以 CZero（Xocio/CZero）官方截图实测取色为基准的工具型实底卡片风格，含 App 内组件与桌面小部件（widget）两套规范。凡涉及 UI 重写、新页面设计、widget 视觉调整、用户说「CZeroX 风格」「照 CZero 改」「彻底重写 UI」「小部件太丑」时使用。依赖 Miuix 组件体系；与 fruit-flavor-design 共用时以本 skill 的视觉基准为准。
---

# CZeroX UI 设计语言

视觉基准：`assets/czerox-home.png`（官方主页截图）+ `assets/czerox-logo.png`（品牌蓝来源）。
来源：[Xocio/CZero](https://github.com/Xocio/CZero) 的 CZeroX 应用（Jetpack Compose + Miuix 风格）。
**其 Compose 源码未公开，且官方只有这两张图**——本 skill 是从官方图实测 + 视觉语言推导的设计规范，不是抄源码。各处色值均已用脚本实测校准，详见 references，**不要再凭印象写 iOS 系统色**。

## 工作流（动手前按序执行）

1. **先 Read `assets/czerox-home.png`**，把目标页面的信息与图中最接近的卡型对号——先读懂这张图再写代码。
2. 按任务类型读规范（都在 skill 目录下）：
   - 改 App 内页面 → 读 `references/tokens.md`（色板/字号/间距）+ `references/components.md`（六种卡与状态清单）
   - 改桌面小部件 → 读 `references/tokens.md` + `references/widgets.md`（九款 widget 的实底卡映射）
3. 套用下方「迁移映射」写代码，写完过一遍「红线」自检。

## 设计气质（先读懂再动手）

工具型应用的「数据卡流」：浅灰底、白卡平铺、超大纯黑数字、状态色只在关键卡上大面积 tint。
克制、安静、信息密度高但不拥挤——不追求玻璃拟态的炫，而追求一眼读数。
分层靠底色明度差，**不靠描边、阴影、分割线**。

## 迁移映射（gdust-v2 = Miuix + Ds tokens）

App 内页面：
- `Miuix Card`（cornerRadius 24dp+）承载所有卡；`SuperArrow`/`BasicComponent` 只用于真正的列表行，不要把每张卡都做成列表项。
- 数据大数字用现有 `Ds.text` + Bold；标签用 `Ds.sub`（色值对齐 tokens.md 的 `#666666`）；状态 tint 用 `Ds.success.copy(alpha = 0.15f)` 落在白卡上（≈ `#DEFAE4`）。
- 浮动胶囊可复用 Nexio 底栏的玻璃底（`layerBackdrop` 采样层已有），但样式收窄为胶囊。
- 环形图用 Canvas 自绘（项目已有先例），结构按 components.md 图表卡。

桌面小部件：
- 样式集中在 `widget/WidgetStyle.kt`（当前是玻璃卡风，需按 `references/widgets.md` 二节映射表换血）；机制类文件（`GdustWidgets.kt` 等）只动视觉相关 composable。
- widget 规范为推导基准：视觉会话产出规范、主线会话落地时以 `references/widgets.md` 为准，冲突由用户裁决。

**禁改 Miuix vendor 源码本身**；所有风格通过 token 与组合实现。

## 红线（写完逐条自查）

- 大数字/主文字与底对比度不足 = 不合格（浅色纯黑 `#000000`，深色 `#F2F2F7`；标签灰用 `#666666` 不用更浅的 iOS 灰）
- 状态 tint 卡上叠加普通白卡内容 = 不合格（tint 卡独立承载状态语义）
- 每张卡都加图标/阴影/描边/分割线 = 不合格（信息靠字号与留白分层）
- 图表必须可读出具体数值（中央数字 + 图例数值），不能只有比例图形
- 混用双蓝 = 不合格：品牌露出 `#106DFD`、交互强调 `#3482FF`，两者不得互换
- widget 保留玻璃扫光/描边 = 不合格（见 widgets.md 映射表）
- 与 fruit-flavor-design 冲突时：整体理念沿用 HIG，视觉基准以本 skill 实测值为准
