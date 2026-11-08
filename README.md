# Harmony-calculator

HarmonyOS NEXT（ArkTS + ArkUI 声明式开发）练习项目。首页是一个“实验目录”，收录 8 个小实验，其中第 3 个是完整的表达式计算器。

![运行截图](https://github.com/user-attachments/assets/24db932e-b661-4d10-a1b6-7195a3a5c52e)

## 实验目录

| 页面 | 内容 | 涉及的 API |
| --- | --- | --- |
| `TEST01` | 布局与图片：中英文切换、List 分隔线/多列、objectFit 四种填充 | `List`、`lanes`、`objectFit` |
| `TEST02` | 数据渲染：样本数据 + `ForEach` 生成列表 | `ForEach`、`keyGenerator` |
| `TEST03` | 计算器：表达式求值、括号与百分比、结果动画、历史记录 | 递归下降解析、`animateTo`、`Preferences` |
| `TEST04` | 网格与卡片：列数随宽度自适应，点按选中 | `Grid`、`GridItem`、`onAreaChange` |
| `TEST05` | 动画与转场：三种缓动曲线对比、多属性联动、增删过渡 | `animateTo`、`TransitionEffect` |
| `TEST06` | 表单与校验：实时校验、错误提示、提交按钮联动 | `TextInput`、`enabled` |
| `TEST07` | 设置与持久化：昵称与字号，重启后仍保留 | `Preferences`、`AppStorage` |
| `TEST08` | 关于：读取真实版本信息 | `bundleManager` |

## 导航与分栏

工程只有一个 `@Entry` 页面（`pages/Index`），其余 7 个都是 `NavDestination` 组件，由 `Index` 里的 `Navigation` 统一承载：

- 路由名集中在 `utils/routes.ets`，`pageMap` 负责按名称分发；
- 页面返回交给 `NavDestination` 的标题栏，不再自己画返回按钮，页面栈不会随返回而增长；
- `Navigation.mode(NavigationMode.Auto)`：宽度不足时堆叠（手机），足够时**自动分栏**（平板 / 2in1，左侧 280vp 导航栏 + 右侧内容）；
- 宽屏首次进入会自动选中“关于”页，避免右侧空白。

## 计算器实现要点

- **表达式求值**（`utils/expression.ets`）：递归下降解析，三层文法 `expression / term / factor`，天然满足“先乘除后加减”，支持任意层嵌套括号与一元正负号。
- **百分比语义**：作为加减的右操作数时取左侧的百分比（`200+10%` = 220）；乘除上下文中按除以 100 处理（`10%x50` = 5）。
- **输入校验**：`isLastCharNotDigit()` 限制运算符只能跟在数字、百分号或右括号之后；`canAppendDot()` 保证同一段数字内只有一个小数点；括号键做智能插入。
- **结果语义**：`tryEvaluate()` 区分「未输完」「算不出」「有结果」——末位是运算符或括号未配平时保持上一次结果，除以零等错误才提示无法计算。
- **显示与动画**：浮点结果经 `toFixed(10)` 归一化（`0.1+0.2` 显示 `0.3`）；`=` 通过 `UIContext.animateTo` + `springMotion` 把视觉重心从算式切到结果。
- **历史记录**（`utils/history.ets`）：用 `Preferences` 保存最近 20 条，结果区上方展示最近三条。

## 环境与运行

- DevEco Studio（HarmonyOS NEXT SDK）
- 兼容版本 `5.0.0(12)`，编译目标 `6.1.0(23)`
- 设备类型：phone / tablet / 2in1

打开方式：用 DevEco Studio 打开工程根目录，在 **Project Structure → Signing Configs** 配置自动签名后运行 `entry` 模块。命令行构建请使用 DevEco Studio 自带的 hvigor（本工程未附带 `hvigorw` 包装脚本）。

### 关于签名

工程未附带签名材料（`signingConfigs` 为空，product 也不再引用不存在的配置），因此默认构建产物是 `entry-default-unsigned.hap`，**无法直接安装到真机**。开启方式：

1. 在 DevEco Studio 中登录华为账号；
2. 打开 `File → Project Structure → Signing Configs`，勾选 `Automatically generate signature`；
3. IDE 会把生成好的 `signingConfigs` 写回 `build-profile.json5`，此后构建即产出已签名 HAP。

签名材料含私钥，请勿提交到仓库。

### 单元测试

`entry/src/test/` 下是基于 hypium 的本地单元测试，覆盖求值器与输入校验：

```powershell
hvigorw test --mode module -p module=entry@default -p product=default
```

## 目录结构

```
AppScope/                  应用级配置：包名、版本、图标
entry/                     主模块（HAP）
  src/main/ets/
    entryability/          UIAbility，负责加载 pages/Index
    entrybackupability/    备份与恢复扩展
    pages/
      Index.ets            唯一的 @Entry：Navigation 宿主 + 导航栏
      TEST01 ~ TEST08      8 个实验页，均为 NavDestination 组件
    utils/
      routes.ets           路由名常量
      expression.ets       表达式解析与求值
      history.ets          计算历史读写
      settings.ets         设置项读写
  src/main/resources/      base、en_US、zh_CN 资源与页面路由表
  src/test/                本地单元测试（hypium）
  src/ohosTest/            设备侧测试模块
build-profile.json5        工程构建配置：产品、SDK 版本、签名
oh-package.json5           ohpm 依赖（hypium / hamock）
```

## 后续计划

- 计算器支持科学函数（三角、对数）与角度/弧度切换
- 首页支持搜索与分组，实验数量继续增加
- 深色模式适配
