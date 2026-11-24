# UI Skills

一组给 AI agent（ZCode / Claude Skills 格式）使用的界面设计规范。每个子目录是一份独立 skill：`SKILL.md` 提供触发条件与纪律，`references/` 放实测色值、组件签名和迁移映射。

规范不是凭空写的，每份都标明了基准来源——截图实测、Compose 源码实测或官方框架仓库。目的是让 agent 在写界面时按已有设计语言落地，而不是每次重新发明一套样式。

## 收录

| Skill | 基准来源 | 适用场景 | 实作案例 |
| --- | --- | --- | --- |
| [`ksu-ui`](ksu-ui/SKILL.md) | KernelSU 官方 / KernelSU-Next / SukiSU-Ultra 三家 Compose 源码 | root 管理器风格：Monet 动态色 + AMOLED、实底状态卡、StatusTag 徽章、液态玻璃悬浮底栏 | [管理面板](showcase/ksu-ui/dashboard.png) |
| [`czero-ui`](czero-ui/SKILL.md) | CZero（Xocio/CZero）官方截图实测取色 | 工具型数据卡流：浅灰底白卡、超大纯黑数字、状态 tint 卡；含 App 页面与桌面 widget 两套规范 | [课表页](showcase/czero-ui/schedule.png) |
| [`nexio-ui`](nexio-ui/SKILL.md) | [NexioSchedule](https://github.com/suiren0219/NexioSchedule) 工程真实源码 | Miuix 设置页体系：20dp 连续圆角卡、胶囊按钮、CardExpand 淡入渐变、柔光玻璃/磨砂 | [设置页](showcase/nexio-ui/mcp-service.png) |
| [`fruit-flavor-design`](fruit-flavor-design/SKILL.md) | Apple Human Interface Guidelines | 全平台 UI/UX 总纲：工作流、平台差异、Design Tokens、组件状态清单、质量红线 | 贯穿各项目，无独立截图 |
| [`rust-desktop-ui`](rust-desktop-ui/SKILL.md) | GPUI Kit / egui / Slint / Iced / Tauri 官方仓库 | Rust 桌面应用：GUI 框架选型、历史记录与托盘设计、交付验证边界 | — |

## 使用方式

把需要的目录复制到 agent 的 skills 目录即可，例如：

```text
~/.zcode/skills/          # ZCode
~/.claude/skills/         # Claude Code
```

每个 skill 的 `description` 字段已写好触发条件，agent 会在相关任务里自动加载；也可以直接点名，例如「用果子味道做这个界面」「照 SukiSU 改」。

## 优先级

几份规范同时存在时的裁决顺序：

1. 用户点名某个具体设计语言（「CZeroX 风格」「KSU 风格」「Nexio 风格」）→ 对应 skill 的实测值优先；
2. 没点名 → `fruit-flavor-design` 的 HIG 理念打底，落到项目已有的设计语言（Miuix / Material 3），不强行换库；
3. 具体 skill 与总纲冲突时，以具体 skill 的实测取值为准，各 skill 的红线章节已写明这条规则。

## 共同约定

- **先读基准再动手**：截图 / 源码 / 仓库实测，不凭印象写系统色。
- **禁改 vendor 源码**：Miuix 等上游组件库不改，风格只通过 token 与组合实现。
- **红线即自检**：每份 skill 末尾都有可判定的「不合格」条目，交付前逐条过。
- **数值可追溯**：色值、圆角、间距、动效时长都标注来源文件或截图，不发明尺寸。

## 实作记录

[`USAGE.md`](USAGE.md) 按项目记录每个 skill 的落地程度（深度落地 / 局部应用 / 仅参考）和证据链接。截图放在 [`showcase/`](showcase/README.md)，附隐私与真实性说明，与规范正文隔离。

## 目录结构

```text
ui-skills/
├── ksu-ui/
│   ├── SKILL.md
│   └── references/            # 三家管理器各自的规范
├── czero-ui/
│   ├── SKILL.md
│   ├── references/            # tokens / components / widgets
│   └── assets/                # 官方截图基准
├── nexio-ui/SKILL.md
├── fruit-flavor-design/SKILL.md
├── rust-desktop-ui/SKILL.md
├── showcase/                  # 实作截图，不参与 skill 加载
├── tools/sync.sh              # 本机源目录 -> 仓库，单向
├── USAGE.md
├── README.md
└── LICENSE
```

## 隔离与维护

- **仓库是分发副本**：skill 的权威版本在本机源目录，改完用 `tools/sync.sh` 单向复制过来，不要把仓库里的改动反向覆盖回本机。
- **skill 自包含**：每个目录只依赖自身文件；跨 skill 的引用只出现在「冲突裁决」文字里，不加载对方的文件。
- **截图不进 skill**：`showcase/` 与 skill 目录分离，避免素材体积影响 skill 加载，也避免把项目细节混进通用规范。
- **发布前脱敏**：`sync.sh` 会把 skill 正文里的本机项目路径替换为公开仓库地址；新增内容若含本地路径，提交前要检查。
- **同步状态检查**：`tools/sync.sh --check` 只报告差异，不写文件。

## 许可

MIT，见 [LICENSE](LICENSE)。各 skill 中引用的第三方项目（KernelSU、SukiSU-Ultra、CZero、Miuix 等）版权归各自作者所有，本仓库仅包含独立撰写的设计规范文本，未复制上游源码。
