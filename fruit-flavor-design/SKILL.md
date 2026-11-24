---
name: fruit-flavor-design
description: 果子味道·全平台 UI/UX 设计总指令——以 Apple Design Language / HIG 为核心理念的界面设计规范。凡涉及做 UI、写界面、设计页面、视觉/交互/设计系统（Design Tokens、配色、排版、间距）、跨平台前端（iOS/macOS/Android/Web）、审查或重构现有界面观感时使用。用户可能直接说「用果子味道」「果子味道的 skill」，也可能只说「帮我做个界面」「这个 UI 太丑了重构一下」。
---

# 果子味道 · 全平台 UI/UX 设计总指令

把 Apple 级设计质感落进真实产品：简洁、优雅、精致、统一，同时尊重各平台原生习惯。
**本 skill 生效期间，思维链（thinking）一律用中文展示。**

## 核心理念

以 Apple Human Interface Guidelines 为主参考（https://developer.apple.com/design/human-interface-guidelines/ ，需要细节时用 WebFetch 抓取对应章节）：

1. 极简主义：留白、排版、视觉层级、色彩协调、细节。
2. 拒绝模板化、廉价感、过度装饰和典型 AI 生成式 UI。
3. 不为视觉效果牺牲易用性和可访问性。
4. 一致性、完整性、真实商业产品质感。

## 工作流程（严格执行，不跳步）

1. **先分析后动手**：项目结构、技术栈、现有代码；不做没有分析的重构。
2. 理解产品需求和目标用户。
3. 确定视觉方向与设计语言（与现有产品一致，或明确声明要建立新方向）。
4. 建立规范与 Design Tokens，再写页面。
5. 设计页面结构、导航、交互逻辑。
6. 实现可复用组件，而非复制粘贴样式。
7. 完整响应式与跨平台适配。
8. 检查不同屏幕尺寸与设备表现。
9. 检查视觉一致性、无障碍、交互体验。
10. 主动发现问题并持续优化，直到达到交付标准。

## 平台差异

- **iOS / iPadOS**：SwiftUI 优先；iPad 考虑多栏与自适应布局。
- **macOS**：桌面窗口交互规范。
- **Android**：Material Design 与 Android 原生习惯；若项目已用 Miuix 等既定设计语言，尊重之，把 Apple 级标准落成该语言的精修，不强行换库。
- **Web**：响应式，兼容桌面/平板/手机。

统一品牌视觉语言，但不强迫所有平台用相同组件。

## Design System 交付

涉及新界面或成规模重构时，建立并集中管理：Design Tokens、Color System（含深浅色）、Typography、Spacing、Grid、Border Radius、Shadow、Icon、Component Library、Interaction States。
动效时长等参数也令牌化，并尊重系统「减少动画」设置。

## 组件状态清单

每个组件过一遍：默认、悬停、按下、选中、禁用、加载、错误、空状态。缺一个就不算完成。

## 质量红线

- 不只交能跑的页面，要交真正优秀的产品界面。
- 不用默认模板样式、无意义渐变背景。
- 不堆砌卡片、阴影、圆角、毛玻璃。
- 不忽略空状态、错误状态、加载状态、边缘情况。
- 功能正确是底线，在此之上追求设计品质与细节完成度。

## 关联 Skills 调用

用户环境中若安装了 Frontend Design、UI UX Pro Max、Expo Skills、Swift UI Design、Web Design Guidelines 等 skill，按任务选用调用；**未安装时按本文件执行，不要因缺失而中断**。不机械套用，按项目技术栈选择最合适的能力。
