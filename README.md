# HarmonyCalc

一个 HarmonyOS NEXT 工具箱应用：7 个日常小工具 + 设置 + 关于，全部离线可用，无需任何网络与权限。

- 语言：ArkTS / ArkUI 声明式开发，Stage 模型
- 兼容版本 `5.0.0(12)`，编译目标 `6.1.0(23)`，支持 phone / tablet / 2in1
- 单元测试 50 个用例，覆盖核心算法

## 工具箱

| 工具 | 能力 |
| --- | --- |
| 计算器 | 表达式求值、括号与百分比、科学函数（sin/cos/tan/ln/log/√/π）、角度/弧度切换、历史记录 |
| 单位换算 | 长度 / 重量 / 温度 / 面积四类，单位间即时换算，支持一键对调 |
| 进制转换 | 2 / 8 / 10 / 16 实时互转，非法字符即时提示 |
| 日期计算 | 两个日期相差天数、基准日期加减 N 天 |
| 百分比 | 占比、涨跌幅、折扣价三种场景 |
| 金额大写 | 人民币数字转中文大写，支持到万亿位，结果可长按复制 |
| 设置 | 昵称、角度单位、小数位数、千分位，直接影响计算器结果 |
| 关于 | 版本信息、SDK 与依赖版本、开源许可 |

## 技术要点

**导航与分栏**
工程只有一个 `@Entry` 页面（`pages/Index`），其余页面都是 `NavDestination` 组件，由 `Navigation` + `NavPathStack` 统一承载。`NavigationMode.Auto` 在宽度不足时堆叠（手机）、足够时自动分栏（平板 / 2in1，左侧 300vp 工具网格 + 右侧内容），宽屏首次进入会自动选中计算器。路由名集中在 `utils/routes.ets`。

**计算器表达式求值**（`utils/expression.ets`）
递归下降解析，三层文法 `expression / term / factor`：天然满足「先乘除后加减」，支持任意层嵌套括号、一元正负号与隐式乘法（`2π`、`2(3+4)`、`2sin(30)`）。百分比按计算器惯例解释：作为加减右操作数时取左侧的百分比（`200+10%` = 220），乘除上下文中按除以 100 处理。

**结果语义**
`tryEvaluate()` 区分「未输完」「算不出」「有结果」：末位是运算符或括号未配平时保持上一次结果，除以零、对数定义域、开方为负、`tan(90°)` 溢出等才提示不可计算；浮点结果统一归一化，`0.1+0.2` 显示 `0.3`。

**数据与状态**
计算历史用 `Preferences` 保存最近 20 条（`utils/history.ets`）；设置用同一套键值存储但独立命名空间（`utils/settings.ets`），昵称通过 `AppStorage` 共享给首页。

**主题与国际化**
颜色全部走语义化资源（`resources/base/element/color.json`），并在 `resources/dark` 下提供同名深色值，跟随系统深色模式自动切换；文案走 `string.json`，中英双语同步维护，工具名在运行时按当前语言解析，因此搜索匹配的是用户看到的文字。

## 环境与运行

用 DevEco Studio 打开工程根目录，在 **Project Structure → Signing Configs** 配置自动签名后运行 `entry` 模块。

### 关于签名

工程未附带签名材料（`signingConfigs` 为空），默认构建产物是 `entry-default-unsigned.hap`，**无法直接安装到真机**。开启方式：

1. 在 DevEco Studio 中登录华为账号；
2. 打开 `File → Project Structure → Signing Configs`，勾选 `Automatically generate signature`；
3. IDE 会把生成好的 `signingConfigs` 写回 `build-profile.json5`，此后构建即产出已签名 HAP。

签名材料含私钥，请勿提交到仓库。

### 单元测试

```powershell
hvigorw test --mode module -p module=entry@default -p product=default
```

50 个用例分三组：`LocalUnit`（框架示例）、`Expression`（求值器与输入校验）、`Tools`（进制、单位、日期、百分比、金额大写、显示格式化）。

## 目录结构

```
AppScope/                  应用级配置：包名、版本、图标
entry/                     主模块（HAP）
  src/main/ets/
    entryability/          UIAbility，负责加载 pages/Index
    entrybackupability/    备份与恢复扩展
    pages/
      Index.ets            唯一的 @Entry：Navigation 宿主 + 工具网格
      Settings.ets         设置
      About.ets            关于
      tools/
        Calculator.ets     计算器
        UnitConvert.ets    单位换算
        BaseConvert.ets    进制转换
        DateCalc.ets       日期计算
        Percent.ets        百分比
        RmbUpper.ets       金额大写
    utils/
      expression.ets       表达式解析与求值
      history.ets          计算历史
      settings.ets         设置读写
      format.ets           数字显示格式化
      units.ets            单位表与换算
      radix.ets            进制解析与格式化
      datecalc.ets         日期计算
      percent.ets          百分比算法
      rmb.ets              金额大写算法
      routes.ets           路由名常量
  src/main/resources/      base / en_US / zh_CN / dark 等资源
  src/test/                本地单元测试
  src/ohosTest/            设备侧测试模块
```

## 协议

MIT，详见 [LICENSE](LICENSE)。依赖 [hypium](https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Fhypium) 与 [hamock](https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Fhamock)，均为 Apache-2.0。
