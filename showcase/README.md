# 实作案例

这里的截图来自实际使用对应 skill 的项目，不是设计稿。图片按 skill 分目录，与规范正文隔离——截图不参与 skill 加载，只用于说明落地效果。

| 图片 | 项目 | 对应 skill | 说明 |
| --- | --- | --- | --- |
| [`czero-ui/schedule.png`](czero-ui/schedule.png) | gdust-v2 广科课程表 | `czero-ui` | 课表空状态页：浅灰底、白卡、纯黑大标题、实底胶囊底栏 |
| [`nexio-ui/mcp-service.png`](nexio-ui/mcp-service.png) | NexioSchedule | `nexio-ui` | MCP 服务设置页：20dp 连续圆角卡、0.5dp 分隔线、胶囊按钮、掩码字段 |
| [`ksu-ui/dashboard.png`](ksu-ui/dashboard.png) | astrbot_plugin_github_bridge | `ksu-ui` | 管理面板总览：绿实底状态卡、StatusTag 徽章、液态玻璃悬浮底栏 |

## 隐私与真实性说明

- **gdust-v2**：登录页截图含验证码与钉钉登录二维码，未收录；只保留无账号信息的课表页。
- **NexioSchedule**：服务器地址为 `127.0.0.1`，Token 与云端地址均为空/掩码状态，不含凭据。
- **github_bridge**：截图为本地静态渲染（`python -m http.server` 打开 `views/dashboard`），未连接 AstrBot 宿主，因此状态卡停在等待态、计数为占位符。它展示的是视觉语言与组件形态，不代表运行数据。

以后补图时遵守同样的规则：不含账号、验证码、Token、真实服务器地址和设备标识；运行时截图需注明是否连接了真实宿主。
