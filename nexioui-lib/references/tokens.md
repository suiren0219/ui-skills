# NexioUI Tokens（源码实测）

来源：`nexioui/src/commonMain/kotlin/com/haooz/nexioui/theme/NexioColorScheme.kt`、`NexioTextStyles.kt`（`main` @ `3fa6c2f`，v0.1.2）。
**页面代码一律从 `NexioTheme.colorScheme` 取值**；下表是基准值，用于核对与生成新配色，不是让你复制成常量。

## 1. 语义色板

`NexioColorScheme` 只保留控件实际用到的角色，不是完整 Material 色板。应用要接动态取色时，整体替换实例传给 `NexioTheme`，库内不内置取色算法。

### 1.1 主色与强调

| 槽位 | 浅色 | 深色 | 用途 |
| --- | --- | --- | --- |
| `primary` | `#3482FF` | `#277AF7` | 主按钮、光标、强调数字 |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | 主色上的文字 |
| `primaryContainer` | `#5D9BFF` | `#338FE4` | 主色容器 |
| `onPrimaryContainer` | `#FFFFFF` | `#FFFFFF` | 容器上的文字 |
| `tertiaryContainer` | `#EAF2FF` | `#2B3B54` | 浅色强调底（选中、提示块） |
| `onTertiaryContainer` | `#3482FF` | `#4788FF` | 强调底上的文字 |
| `error` | `#E94634` | `#F12522` | 失败态 |

### 1.2 背景与表面

| 槽位 | 浅色 | 深色 | 用途 |
| --- | --- | --- | --- |
| `background` | `#FFFFFF` | `#242424` | 页面底 |
| `onBackground` | `#000000` | `#E6FFFFFF` | 页面主文字 / 按压指示器基色 |
| `surface` | `#F4F4F4` | `#000000` | 次级表面 |
| `onSurface` | `#000000` | `#F2F2F2` | 表面主文字 |
| `surfaceContainer` | `#FFFFFF` | `#242424` | **Card 默认底** |
| `onSurfaceContainer` | `#000000` | `#E6FFFFFF` | **Card 默认文字** |
| `surfaceContainerHigh` | `#E8E8E8` | `#242424` | 高一级容器 |
| `surfaceContainerHighest` | `#E8E8E8` | `#2D2D2D` | 最高级容器 |
| `onSurfaceContainerHigh` | `#A2A2A2` | `#666666` | 容器内次级文字 |
| `onSurfaceContainerHighest` | `#000000` | `#E9E9E9` | 容器内主文字 |
| `surfaceVariant` | `#FFFFFF` | `#242424` | 变体表面 |
| `onSurfaceVariant` | `#959595` | `#737373` | 辅助文字（最淡一档） |
| `onSurfaceVariantSummary` | `#99000000` | `#80FFFFFF` | 摘要 / 说明 |
| `onSurfaceVariantActions` | `#66000000` | `#66FFFFFF` | 次级图形、分隔线基色 |
| `onSurfaceSecondary` | `#CC000000` | `#CCFFFFFF` | 次级正文 |
| `outline` | `#D9D9D9` | `#404040` | 边框 |
| `dividerLine` | `#E0E0E0` | `#393939` | 分隔线 |

> 深色档两处刻意的不对称：`surface = #000000` 而 `surfaceContainer = #242424`（卡片比页面亮），`onSurfaceContainer` 带 90% alpha。改配色时保留这种「卡片浮在纯黑页面上」的关系，不要把两者调成一个值。

### 1.3 次级与禁用

| 槽位 | 浅色 | 深色 |
| --- | --- | --- |
| `secondary` | `#F4F4F4` | `#363636` |
| `onSecondary` | `#FFFFFF` | `#FFFFFF` |
| `onSecondaryVariant` | `#303030` | `#D9D9D9` |
| `secondaryVariant` | `#F0F0F0` | `#434343` |
| `secondaryContainer` | `#ECECEC` | `#434343` |
| `onSecondaryContainer` | `#A9A9A9` | `#7C7C7C` |
| `disabledSecondary` | `#F0F0F0` | `#3F3F3F` |
| `disabledSecondaryVariant` | `#F2F2F2` | `#404040` |
| `disabledOnSecondaryVariant` | `#B2B2B2` | `#707170` |
| `disabledOnSurface` | `#B2B2B2` | `#666666` |
| `disabledPrimaryButton` | `#C2D9FF` | `#253E64` |
| `disabledOnPrimaryButton` | `#FFFFFF` | `#677893` |
| `disabledOnPrimary` | `#F3F8FF` | `#677993` |
| `disabledPrimarySlider` | `#B8CFF5` | `#44587C` |

### 1.4 滑块专用

| 槽位 | 浅色 | 深色 |
| --- | --- | --- |
| `sliderBackground` | `#0F000000` | `#26FFFFFF` |
| `sliderKeyPoint` | `#4DA3B3CD` | `#4D7A8AA6` |
| `sliderKeyPointForeground` | `#6EB5FF` | `#5DAAFF` |

## 2. 文字层级

`NexioTextStyles`（`theme/NexioTextStyles.kt`）——只保留控件实际层级，默认实例可直接替换。

| style | 字号 | 说明 |
| --- | --- | --- |
| `main` | 17sp | 控件默认正文 |
| `paragraph` | 17sp / lineHeight 1.2em | 段落 |
| `body1` | 16sp | 正文 |
| `body2` | 14sp | 次级正文、偏好行摘要 |
| `button` | 17sp | 按钮默认（放进小按钮要压扁尺寸，不是改字号） |
| `footnote1` | 13sp | 辅助说明 |
| `footnote2` | 11sp | 最小注脚 |
| `headline1` | 17sp | 偏好项标题 |
| `headline2` | 16sp | 次级标题 |
| `subtitle` | 14sp **Bold** | SmallTitle 基础样式（`SmallTitle` 内部叠 `Medium`） |
| `title1` | 32sp | 最大标题 |
| `title2` | 24sp | 大标题 |
| `title3` | 20sp | 页面标题 |
| `title4` | 18sp | 区块标题 |

## 3. 圆角与线宽

| 项 | 值 | 出处 |
| --- | --- | --- |
| 卡片圆角 | **20dp**，`continuousSurface` 连续曲率 | `card/CardDefaults.kt` |
| 输入框圆角 | 20dp | `textfield/TextField.kt` |
| 按钮圆角 | 16dp | `button/ButtonDefaults.kt` |
| 对话框圆角 | **42dp** | `overlaydialog/DialogDefaults.kt` |
| 搜索栏圆角 | 20dp（`ContinuousRoundedRectangle`） | `searchbar/SearchBar.kt` |
| 开关外形 | `ContinuousCapsule` | `switch/Switch.kt` |
| 分隔线 | **0.75dp** | `divider/Divider.kt` |
| 进度条高 | 5dp；细规则线 0.5dp | `progressbar/ProgressBarDefaults.kt` |

## 4. 禁用态取值规则

`button/ButtonDefaults.textButtonColors` 用**主题自身背景的明度**判断，而不是宿主的「是否深色」：

```kotlin
color = if (NexioTheme.colorScheme.background.luminance() < 0.5f) Color.White else Color.Black
alpha = 0.06f
```

原因写在源码注释里：宿主用强制深色覆盖主题时，按「isDark」取色会与背景对不上。复制这段逻辑时保留注释意图，不要换回 `isDark`。