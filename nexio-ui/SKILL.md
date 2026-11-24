---
name: nexio-ui
description: >-
  Nexio 课程表（NexioSchedule）UI 设计语言——以项目真实源码（Miuix 组件库 + 自研组件）实测为基准的规范：
  单位体系（MiuixTheme / 20dp 连续圆角卡 / SmallTitle 分组）、设置页组件库（SwitchPreference / BasicComponent /
  ArrowPreference / OverlayDropdownMenu / CardExpand）、胶囊按钮体系、行内输入与掩码字段、淡入渐变动效
  （高度 spring + 淡入 180ms + 模糊 12dp 进慢出快）、柔光玻璃磨砂（GlassBackdrop / SoftGlassSurface /
  AGSL 着色器 + 壁纸纹理）、全局 Text 组件深色坑、触感反馈。凡涉及 Nexio/NexioSchedule 界面开发或复刻、
  用户说「Nexio 风格」「照 Nexio 改」「课程表 App UI」「Miuix 风格设置页」「液态玻璃」「柔光玻璃」「磨砂卡片」，
  或要在该工程里新增页面/组件时使用。与 fruit-flavor-design（HIG 总纲）共用时以本 skill 的实测取值为准。
---

# Nexio UI 设计语言（源码实测版）

基准仓库：`NexioSchedule`（https://github.com/suiren0219/NexioSchedule ，分支 `feat/island-auth-local-mcp` 实测）。
三层结构：`miuix/`（Miuix 组件库，Apache-2.0 上游 + 定制）→ `ui-shared/`（跨平台页面与自研组件）→ 平台宿主（androidApp / desktopApp / ios / ohos）。
**写任何界面之前先读本文件的「坑清单」**；所有取值都来自当前源码，不要凭感觉发明尺寸。

## 1. 设计理念

MIUI 设置页的骨架 × iOS 级的细节：分组小标题 + 连续圆角卡片 + 行内右对齐输入 + 极淡的按钮覆盖底 + 全链路动效（高度 spring 补间、换字模糊过渡、展开时内容从模糊散尽到清晰）。深浅色、平板、玻璃降级都是一等公民。

## 2. Design Tokens（实测值）

### 2.1 颜色（一律从 `MiuixTheme.colorScheme` 取，不硬编码）

| 槽位 | 用途 |
| --- | --- |
| `surface` | 页面背景 |
| `surfaceContainer` / `onSurfaceContainer` | 卡片底 / 卡上内容（Card 默认色） |
| `onSurface` | 行标题、正文主色 |
| `onSurfaceVariantSummary` | 摘要、辅助说明、hint（13–14sp 灰字） |
| `onSurfaceVariantActions` | 次级图形/分隔线基色（分隔线 = 它 `copy(alpha = 0.1f)`） |
| `primary` | 强调、编号、成功态、光标 |
| `error` | 失败态文字 |
| `disabledSecondaryVariant` / `disabledOnSecondaryVariant` | TextButton 禁用底/字（见 §6 坑） |

深浅色由 `AppDarkTheme` / `ThemeController` 管理；**页面代码永远只写主题槽位**，禁止 `Color(0xFF…)`（唯一例外：主题蓝主按钮 `Color(0xFF0A84FF)`，全工程统一值）。

### 2.2 字号（`MiuixTheme.textStyles`）

| style | sp | 典型用途 |
| --- | --- | --- |
| `headline1` | 17 | 偏好项标题（BasicComponent 内部已用） |
| `subtitle` | 14 Bold | SmallTitle（外部再叠 `Medium`） |
| `body1` | 16 | 正文 |
| `body2` | 14 | 偏好项摘要、按钮行说明 |
| `footnote1` | 13 | 辅助说明、隐私提示、工具描述 |
| `footnote2` | 11 | 最小注脚 |
| `button` | 17 | TextButton 默认字（胶囊小按钮要显式覆盖） |

页面手写 Text 的家族口径：标题 17sp/Medium、摘要 14sp、辅助 13sp、编号 14sp/Medium 主色。

### 2.3 间距与圆角

- 页面水平留白：手机 16dp / 平板（`isTabletWidth()`）20dp。
- 卡片间距 `SECTION_GAP = 12dp`（各页 private val）。
- 设置行内边距：水平 16dp、垂直 14dp；偏好行最小高 56dp（`BasicComponentDefaults`）。
- `Card` 默认圆角 **20dp**（`continuousSurface` 连续圆角），`CardDefaults.InsideMargin = 0.dp`——**卡片内一律自己控 padding**（页首注释原文：「卡片内部一律自己控 padding（insideMargin = 0）」）。
- 按钮：次级胶囊 `cornerRadius = 100.dp`；Card 高度变化由 Card 自带 spring 补间（`CardDefaults.SizeAnimation`，dampingRatio 0.9 / StiffnessMediumLow，首帧不播）。

### 2.4 页面顶部留白（`pageTopExtra`，唯一来源）

| 页面最上方是 | 平板 | 手机 |
| --- | --- | --- |
| SmallTitle（分组小标题） | 12dp | 0 |
| 卡片 / 控件（无小标题） | 24dp | 12dp |

⚠ 有小标题的页面必须传 `hasSmallTitle = true`，传错会多出一截空白。

## 3. 页面骨架（照抄这段）

```kotlin
Scaffold(topBar = {}) { paddingValues ->
    Column(
        modifier = Modifier
            .fillMaxSize()
            .overScrollVertical()
            .scrollEndHaptic(hapticFeedbackType = HapticFeedbackType.TextHandleMove)
            .collapsibleTopInset(scrollBehavior)
            .then(scrollBehavior?.let { Modifier.nestedScroll(it.nestedScrollConnection) } ?: Modifier)
            .verticalScroll(rememberScrollState())
            .padding(
                start = horizontalPadding, end = horizontalPadding,
                top = paddingValues.calculateTopPadding() +
                    CollapsibleTopAppBarDefaults.CollapsedHeight +
                    pageTopExtra(isTablet, hasSmallTitle = true),
                bottom = 120.dp,          // 列表页 120；普通设置页也见 60
            ),
    ) { /* SmallTitle + Card 序列 */ }
}
```

长列表用 `LazyColumn(contentPadding = …, verticalArrangement = Arrangement.spacedBy(12.dp))`；若卡片的条件内容会整体收起，改用 `Arrangement.Top` + 每卡 `padding(bottom = 12.dp)`（空 item 也占位的问题）。

## 4. 设置页组件库

分组 = `SmallTitle(text = …)` + `Card(fillMaxWidth, insideMargin = 0.dp)`，卡内多行用 0.5dp 低对比分隔线：

```kotlin
HorizontalDivider(
    modifier = Modifier.padding(horizontal = 16.dp),
    thickness = 0.5.dp,
    color = theme.onSurfaceVariantActions.copy(alpha = 0.1f),
)
```

| 组件 | 用途 | 要点 |
| --- | --- | --- |
| `SwitchPreference(checked, onCheckedChange, title, summary, enabled)` | 开关行 | 点整行即切换；禁用态由 `enabled` 表达 |
| `BasicComponent(title, summary, endActions = { … })` | 只读展示行 | title 17sp/Medium、summary 14sp 自动；`endActions` 放右侧胶囊按钮 |
| `ArrowPreference(title, summary, endActions, onClick, holdDownState)` | 进入下一页 | 自带 ArrowRight |
| `OverlayDropdownMenu(title, summary, entry = DropdownEntry(items), collapseOnSelection, liquidGlassBackdrop, dropdownColors)` | 下拉选择 | 卡内直接放；玻璃页把 backdrop 传入 |
| `CardExpand(visible) { … }` | 卡内条件内容展开/收起 | 见 §8 动效；卡内唯一正确姿势 |
| `FeatureRow(title, summary, onClick)` | 功能入口行 | title 17sp/Medium + summary 13sp + ArrowRight（各页私有实现） |
| `BasicComponent` + `StatusPill` | 状态行 | 左标题/摘要，右状态胶囊（备份中心范本） |

一行卡内放「开关 + 展示行 + 字段」时：`SwitchPreference → Divider → BasicComponent → Divider → 字段 → 说明文字`，说明文字 `padding(horizontal = 16.dp).padding(bottom = 14.dp)`。

## 5. 按钮体系

```kotlin
// 次级胶囊（复制/保存/取消）：默认色 = 白/黑 6% 透明覆盖
TextButton(
    text = …, onClick = …,
    minWidth = 64.dp, minHeight = 36.dp,
    insideMargin = PaddingValues(horizontal = 16.dp, vertical = 0.dp),
    cornerRadius = 100.dp,
)

// 主蓝胶囊（测试连接/上传/确认）：全工程统一 0xFF0A84FF
TextButton(
    …,
    colors = ButtonDefaults.textButtonColorsPrimary(
        color = Color(0xFF0A84FF), textColor = Color.White,
    ),
    cornerRadius = 100.dp, minWidth = 76.dp, minHeight = 36.dp,
    insideMargin = PaddingValues(horizontal = 20.dp, vertical = 0.dp),
)
```

- TextButton 默认字号 17sp——放进行内的小按钮要 `minWidth/minHeight + insideMargin(horizontal, vertical = 0)` 压扁。
- 主蓝禁用态自动变 `disabledPrimaryButton`，不要手动改透明度。

### ⚠ 禁用态底色坑（实测踩过）

`textButtonColors()` 的 enabled 底 = `Color.White/Black × alpha 0.06f`（几乎透明），**disabled 底 = 实心灰 `disabledSecondaryVariant` 且不再乘 alpha**（Button.kt：`bgColor = color.copy(alpha); disabledBgColor = disabledColor`）。空值字段旁的禁用按钮在深色下会变成突兀实灰块。统一手法：

```kotlin
val dimBackground = if (theme.background.luminance() < 0.5f)
    Color.White.copy(alpha = 0.06f) else Color.Black.copy(alpha = 0.06f)
TextButton(…, colors = ButtonDefaults.textButtonColors(disabledColor = dimBackground))
```

底色与可用态一致、仅文字保持 `disabledTextColor` 变淡。

## 6. 输入体系

```kotlin
// 行内输入（无掩码字段）：左标签 + 右对齐无边框输入（「添加课程」弹窗同款）
Row(Modifier.fillMaxWidth().padding(start = 16.dp, end = 16.dp, top = 14.dp, bottom = 14.dp),
    verticalAlignment = Alignment.CenterVertically) {
    Text(label, fontSize = 17.sp, fontWeight = FontWeight.Medium, color = theme.onSurface)
    NativeTextField(
        value, onValueChange,
        modifier = Modifier.weight(1f).padding(start = 16.dp),
        hint = hint, singleLine = true, textAlign = TextAlign.End,
        textStyle = TextStyle(fontSize = 17.sp, fontWeight = FontWeight.Medium),
    )
}
```

带掩码的私密字段用工程现成组件 `com.haooz.chedule.ui.components.PrivateSettingField`（label 左、胶囊「显示/复制」右、`BasicTextField + PasswordVisualTransformation` 右对齐；30 秒 / 输入框失焦 / 窗口失焦 / 禁用自动重掩码；复制走宿主回调并提示剪贴板敏感）。**不要**给 NativeTextField 外面包底框（页首注释：「不用带底框的 NativeMiuixTextField，避免卡片里再套一层卡片」）；WebDav 页的 `fillMaxWidth(0.65f)` 是另一族变体。

## 7. 全局文字组件（深色黑字坑）

工程有两份同签名的全局 `Text`，**call-site 换 import 即可切换**：

| 包 | 默认 style | 结论 |
| --- | --- | --- |
| `com.haooz.chedule.ui.components.text.miuix.Text` | `MiuixTheme.textStyles.main`，color Unspecified 回退 Miuix 主题 | ✅ 新页面一律用它 |
| `com.haooz.chedule.ui.components.text.material.Text` | M3 `LocalTextStyle.current` | ⚠ 在 Miuix 深色主题下不跟随 → **标题黑字**（上游 AI 页在用，每行都显式传 color 才安全） |

新页面写法：`import com.haooz.chedule.ui.components.text.miuix.Text`，且每行仍显式 `color = theme.onSurface` / `onSurfaceVariantSummary`。两份都会叠加 `TextMotionBox` 换字模糊过渡（见 §8）。

文案全部走 `L(中文, English)` 双语对象（如 `McpStr` / `ReminderStr`），非 Composable 上下文的按调用时刻语言取值。

## 8. 动效系统（淡入渐变）

### 8.1 卡内条件内容：`CardExpand`（全站唯一姿势）

```
展开：高度 0→实际（spring，约 260~320ms） + 淡入 180ms + 模糊 12dp→0（420ms，比高度晚散尽）
收起：内容压到 0（同 spring） + 淡出 180ms + 模糊 0→12dp（160ms，比高度先糊满）
```

参数集中在 `CardExpandSpec`（`HeightSpring = CardDefaults.SizeAnimation`、`FADE_MILLIS = 180`、`BLUR_DP = 12f`、`BLUR_IN_MILLIS = 420`、`BLUR_OUT_MILLIS = 160`）——进慢出快是刻意的。实现要点（自己写类似动效时必须遵守）：

- **不用 `animateContentSize` 包 Card**：它补间占位尺寸、内容按最终尺寸绘制，「收不回去」；高度变化必须 `AnimatedVisibility` 自己算。
- 淡入淡出**不走 enter/exit**（常驻 graphicsLayer 会罩住超长内容导致下半屏触摸失效），改由 `derivedStateOf { transition.currentState != transition.targetState }` 只在动画期临时挂 layer。
- 模糊 = `BlurEffect(px, px, TileMode.Decal)`，先判 `isRenderEffectSupported()`；绘制期读动画值，组合期不读 → 零重组。
- **AnimatedVisibility 内必须再包一层 Column**：它按单子内容设计，多子项会被全部 place 到 (0,0) 叠成一行。
- 纯自绘容器（非 miuix Card）的尺寸变化用 `Modifier.cardContentSize()`（同一条 spring）。
- 同一段内容只用一种机制，`CardExpand` 套 `cardContentSize` = 「动画的动画」发肉。

### 8.2 换字动效

- miuix 偏好行内的文字经 `MotionAwareText`：宿主注册了换字动效就带模糊过渡，否则原样 `Text`；只用于非用户逐字输入的文案。
- 全局 `Text`（miuix/material 两份）内部都包 `TextMotionBox(key = text)`：文字被改写时叠加模糊聚焦过渡。

### 8.3 触感与按压

- 开关/确认 `HapticFeedbackType.Confirm`；下拉选择 `VirtualKey`；列表滚到底 `TextHandleMove`（`scrollEndHaptic`）。
- 可点行支持 `holdDownState = true`（按住视觉驻留），弹窗打开前常配「dialog 状态 + holdDownState」。

## 9. 柔光玻璃 / 磨砂质感

玻璃体系在 `com.haooz.softglass.*` 库（平台实现 AGSL/SkSL 着色器 + 壁纸纹理采样），页面层只碰三个东西：

1. **页面参数注入**：`liquidGlassBackdrop: GlassBackdrop? = null` 由路由层（AppRoutes）创建并传入页面；页面只负责把它继续传给玻璃化的子组件（下拉、按钮、底栏）。
2. **玻璃上的下拉**：`liquidGlassBackdrop != null` 时必须用透明容器，让 backdrop 透出来：

```kotlin
val dropdownColors = if (liquidGlassBackdrop != null)
    DropdownDefaults.dropdownColors(containerColor = Color.Transparent, selectedContainerColor = Color.Transparent)
else DropdownDefaults.dropdownColors()
```

3. **卡片级磨砂**：`SoftGlassSurface.modifier(density, origin = () -> Offset, radiusPx, redraw)`——页面级共享一份（课表/今日各一份，样式互不影响）；只准备壁纸纹理 + 坐标映射，拖模糊/改外观参数只重灌 uniform，不重烘焙。shader 不可用或无壁纸时返回 null，**所有面板退回纯色表面**（降级是常态路径，不是异常）。

其它公开件：`GlassPreset.Default.style`（`SoftGlassStyle`，工程别名 `ScheduleSoftGlassStyle`/`TodaySoftGlassStyle`）、`SOFT_GLASS_LIVE_SHADER`（液态玻璃活体着色器，`LiquidGlassTextButton`/`LiquidTopBarButton`/`CapsuleSegmentedControl`/底栏都用它）、拖拽手感常量 `GlassDragStretchRatio` / `GlassDragTranslationDamping`（定义在 miuix 玻璃档位）。设置里的「应用材质效果」档位切换玻璃样式；**给玻璃控件写样式时永远走样式对象，不散落硬编码模糊半径**。

## 10. 验收清单

- [ ] 深色：所有文字/分隔线/按钮底色跟随主题（无黑字、无突兀实灰禁用块）
- [ ] 平板 20dp / 手机 16dp 边距；`pageTopExtra` 口径与页面首元素匹配
- [ ] 卡内条件内容用 `CardExpand` 收放自如（不是「空白在缩」）
- [ ] 按钮禁用态：底色与可用态一致、文字变淡
- [ ] 玻璃页：无壁纸/无 shader 时退回纯色表面可用
- [ ] 触感：开关 Confirm、下拉 VirtualKey
- [ ] 全部文案双语 `L(中, en)`

## 11. 相关源码索引（相对仓库根）

```
miuix/…/basic/{Card,BasicComponent(Component),Button,SmallTitle,MotionAwareText}.kt
miuix/…/preference/{SwitchPreference,ArrowPreference}.kt
miuix/…/theme/{Colors,TextStyles,AppDarkTheme,ThemeController}.kt
ui-shared/…/components/{CardExpand,SoftGlassSurface,PrivateSettingField,PageTopSpacing}.kt
ui-shared/…/components/text/{miuix/Text.kt,material/Text.kt,TextMotionBox}
ui-shared/…/glass/SoftGlassAliases.kt
ui-shared/…/screens/{AiFeaturesScreen,McpServiceScreen,CloudMcpSection}.kt（页面范本）
ui-shared/…/activities/{WebDavSettingsScreen,BackupCenterScreen}.kt（多字段卡/状态行范本）
```
