# Harmony-calculator

HarmonyOS NEXT（ArkTS + ArkUI 声明式开发）练习项目。首页是一个“实验入口列表”，前三项分别演示布局与图片填充、列表数据渲染，以及一个可用的计算器。

![运行截图](https://github.com/user-attachments/assets/24db932e-b661-4d10-a1b6-7195a3a5c52e)

## 页面一览

| 页面 | 说明 |
| --- | --- |
| `pages/Index` | 入口列表：8 个按钮，前 3 个进入已实现的实验页，4–8 为占位 |
| `pages/TEST01` | 布局与图片实验：中英文切换、`List` 分割线与多列（`lanes`）、`objectFit` 四种填充模式 |
| `pages/TEST02` | 数据渲染实验：`PEOPLE_DATA` + `mock()` 样本数据，用 `ForEach` 按 key 生成列表项 |
| `pages/TEST03` | 计算器：表达式求值、括号与百分比、输入校验、结果切换动画、历史记录 |

## 计算器实现要点

- **表达式求值**（`utils/expression.ets`）：递归下降解析，三层文法 `expression / term / factor`，天然满足“先乘除后加减”，支持任意层嵌套括号与一元正负号。
- **百分比语义**：按计算器惯例，作为加减的右操作数时取左侧的百分比（`200+10%` = 220）；在乘除上下文中按除以 100 处理（`10%x50` = 5）。
- **输入校验**：`isLastCharNotDigit()` 限制运算符只能跟在数字、百分号或右括号之后；`canAppendDot()` 保证同一段数字内只有一个小数点；括号键做智能插入。
- **结果语义**：`tryEvaluate()` 区分「未输完」「算不出」「有结果」三种状态——末位是运算符或括号未配平时保持上一次结果，除以零等错误才提示无法计算。
- **显示与动画**：浮点结果经 `toFixed(10)` 归一化（`0.1+0.2` 显示 `0.3`）；`=` 通过 `UIContext.animateTo` + `springMotion` 把视觉重心从算式切到结果。
- **历史记录**（`utils/history.ets`）：用 `Preferences` 保存最近 20 条，结果区上方展示最近三条。
- **国际化**：页面文案全部来自 `string.json`，中英文资源同步维护。

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
    pages/                 Index / TEST01 / TEST02 / TEST03
    utils/
      expression.ets       表达式解析与求值
      history.ets          历史记录的读写（Preferences）
  src/main/resources/      base、en_US、zh_CN 资源与页面路由表
  src/test/                本地单元测试（hypium）
  src/ohosTest/            设备侧测试模块
build-profile.json5        工程构建配置：产品、SDK 版本、签名
oh-package.json5           ohpm 依赖（hypium / hamock）
```

## 后续计划

- 用 `Navigation` + `NavPathStack` 替换 `router`，顺带解决页面栈增长问题
- 平板与 2in1 做真正的分栏（左侧历史、右侧键盘）
- 首页 4–8 号入口接入新实验
