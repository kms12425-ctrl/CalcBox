# Harmony-calculator

HarmonyOS NEXT（ArkTS + ArkUI 声明式开发）练习项目。首页是一个“实验入口列表”，前三项分别演示布局与图片填充、列表数据渲染，以及一个可用的计算器。

![运行截图](https://github.com/user-attachments/assets/24db932e-b661-4d10-a1b6-7195a3a5c52e)

## 页面一览

| 页面 | 说明 |
| --- | --- |
| `pages/Index` | 入口列表：8 个按钮，前 3 个进入已实现的实验页，4–8 为占位 |
| `pages/TEST01` | 布局与图片实验：`@State` 中英文切换、`List` 分割线与多列（`lanes`）、`objectFit` 四种填充模式 |
| `pages/TEST02` | 数据渲染实验：`PEOPLE_DATA` + `mock()` 样本数据，用 `ForEach` 生成列表项 |
| `pages/TEST03` | 计算器：表达式求值、输入校验、`springMotion` 结果切换动画 |

## 计算器实现要点

- **表达式求值**：`calculateExpression()` 先把 `50%` 这类写法转成 `0.5`，再用正则循环折叠所有 `x`、`÷`，最后折叠加减，以此近似“先乘除后加减”。不支持括号。
- **输入校验**：`isLastCharNotDigit()` 保证运算符只能跟在数字或 `%` 之后；减号额外避免连续输入；`.` 同样受约束。
- **实时结果**：每次按键都会重算 `ANSWER`；`=` 不参与计算，只负责通过 `animateTo` + `curves.springMotion()` 把显示重心从算式切到结果。
- **已知局限**：`%` 固定按“除以 100”解释；连续运算依赖每次输入后的中间结果。

## 环境与运行

- DevEco Studio（HarmonyOS NEXT SDK）
- 兼容版本 `5.0.0(12)`，编译目标 `6.1.0(23)`
- 设备类型：phone / tablet / 2in1

打开方式：用 DevEco Studio 打开工程根目录，在 **Project Structure → Signing Configs** 配置自动签名后运行 `entry` 模块。命令行构建请使用 DevEco Studio 自带的 hvigor（本工程未附带 `hvigorw` 包装脚本）。

## 目录结构

```
AppScope/                  应用级配置：包名、版本、图标
entry/                     主模块（HAP）
  src/main/ets/
    entryability/          UIAbility，负责加载 pages/Index
    entrybackupability/    备份与恢复扩展
    pages/                 Index / TEST01 / TEST02 / TEST03
  src/main/resources/      base、en_US、zh_CN 资源与页面路由表
  src/test/                本地单元测试（hypium）
  src/ohosTest/            设备侧测试模块
build-profile.json5        工程构建配置：产品、SDK 版本、签名
oh-package.json5           ohpm 依赖（hypium / hamock）
```

## 后续计划

- 为 `calculateExpression` 补单元测试，覆盖 `%`、小数与连续运算
- 支持括号与真正的运算优先级
- 首页 4–8 号入口接入新实验
