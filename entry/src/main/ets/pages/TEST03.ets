import { curves } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { EvalResult, canAppendDot, isLastCharNotDigit, tryEvaluate } from '../utils/expression';
import { HistoryEntry, MAX_HISTORY, loadHistory, saveHistory } from '../utils/history';

/**
 * 按键类别，决定点击后走哪条处理分支。
 */
enum KeyKind {
  Digit,
  Operator,
  Func,
  Equals,
  /** 直接插入一段文本，例如 sin( 、π 、√ */
  Insert
}

/**
 * 一个按键的全部描述：文案、类别、要追加的字符、配色与尺寸。
 * 键盘布局与样式都由此数据推导，新增按键只需往 rows 里加一项。
 */
class KeyDef {
  label: string = '';
  kind: KeyKind = KeyKind.Digit;
  value: string = '';
  bgColor: number = 0xfffef9;
  fontColor: number = 0x000000;
  weight: FontWeight = FontWeight.Medium;
  fontSize: number = 23;
  size: number = 64;
}

const BG_DIGIT: number = 0xfffef9;
const BG_FUNC: number = 0xcdd1d3;
const BG_EQUAL: number = 0xfb8b05;
const BG_SCI: number = 0xe3e8ee;

/** 内容区最大宽度：平板与 2in1 上避免按键被拉伸 */
const CONTENT_MAX_WIDTH: number = 520;

function makeKey(label: string, kind: KeyKind, value: string, bgColor: number,
                 fontSize: number, weight: FontWeight, size: number = 64): KeyDef {
  const key: KeyDef = new KeyDef();
  key.label = label;
  key.kind = kind;
  key.value = value;
  key.bgColor = bgColor;
  key.fontSize = fontSize;
  key.weight = weight;
  key.size = size;
  if (kind === KeyKind.Equals) {
    key.fontColor = 0xffffff;
  }
  return key;
}

@Component
export struct TEST03 {
  @State operate: string = '';
  @State answer: ResourceStr = '';
  @State frontSizeOp: number = 50;
  @State frontColorOp: number = 0x000000;
  @State frontSizeAns: number = 30;
  @State frontColorAns: number = 0x9fa39a;
  @State answerAnimate: boolean = false;
  @State history: HistoryEntry[] = [];
  /** 三角函数按角度制还是弧度制计算 */
  @State useDegrees: boolean = true;

  /**
   * 键盘布局：首行 5 个功能键（含括号），其余 4 行 4 列。
   */
  private rows: KeyDef[][] = [
    [
      makeKey('AC', KeyKind.Func, 'AC', BG_FUNC, 18, FontWeight.Bold, 54),
      makeKey('( )', KeyKind.Func, 'PAREN', BG_FUNC, 18, FontWeight.Bold, 54),
      makeKey('%', KeyKind.Func, '%', BG_FUNC, 20, FontWeight.Bold, 54),
      makeKey('<=', KeyKind.Func, 'BACK', BG_FUNC, 20, FontWeight.Bold, 54),
      makeKey('÷', KeyKind.Operator, '÷', BG_FUNC, 22, FontWeight.Bold, 54)
    ],
    [
      makeKey('7', KeyKind.Digit, '7', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('8', KeyKind.Digit, '8', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('9', KeyKind.Digit, '9', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('X', KeyKind.Operator, 'x', BG_FUNC, 23, FontWeight.Bold)
    ],
    [
      makeKey('4', KeyKind.Digit, '4', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('5', KeyKind.Digit, '5', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('6', KeyKind.Digit, '6', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('一', KeyKind.Operator, '-', BG_FUNC, 23, FontWeight.Bold)
    ],
    [
      makeKey('1', KeyKind.Digit, '1', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('2', KeyKind.Digit, '2', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('3', KeyKind.Digit, '3', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('+', KeyKind.Operator, '+', BG_FUNC, 42, FontWeight.Regular)
    ],
    [
      makeKey('00', KeyKind.Digit, '00', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('0', KeyKind.Digit, '0', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('.', KeyKind.Digit, '.', BG_DIGIT, 23, FontWeight.Medium),
      makeKey('=', KeyKind.Equals, '=', BG_EQUAL, 42, FontWeight.Regular)
    ]
  ];

  /**
   * 科学函数栏：点击插入函数名或常量，算式里可继续嵌套括号。
   */
  private scienceKeys: KeyDef[] = [
    makeKey('sin', KeyKind.Insert, 'sin(', BG_SCI, 13, FontWeight.Medium, 40),
    makeKey('cos', KeyKind.Insert, 'cos(', BG_SCI, 13, FontWeight.Medium, 40),
    makeKey('tan', KeyKind.Insert, 'tan(', BG_SCI, 13, FontWeight.Medium, 40),
    makeKey('ln', KeyKind.Insert, 'ln(', BG_SCI, 13, FontWeight.Medium, 40),
    makeKey('log', KeyKind.Insert, 'log(', BG_SCI, 13, FontWeight.Medium, 40),
    makeKey('√', KeyKind.Insert, '√', BG_SCI, 15, FontWeight.Medium, 40),
    makeKey('π', KeyKind.Insert, 'π', BG_SCI, 15, FontWeight.Medium, 40)
  ];

  aboutToAppear(): void {
    this.history = loadHistory(this.historyContext());
  }

  private historyContext(): common.Context {
    return this.getUIContext().getHostContext() as common.Context;
  }

  /**
   * 只展示最近三条，避免占用算式区空间。
   */
  private recentEntries(): HistoryEntry[] {
    const total: number = this.history.length;
    if (total === 0) {
      return [];
    }
    const start: number = total > 3 ? total - 3 : 0;
    return this.history.slice(start);
  }

  /**
   * 把当前算式与结果记入历史并持久化。
   */
  private rememberCurrent(): void {
    const result: EvalResult = tryEvaluate(this.operate, this.useDegrees);
    if (!result.ok) {
      return;
    }
    const entry: HistoryEntry = new HistoryEntry(this.operate, result.value);
    const merged: HistoryEntry[] = this.history.concat([entry]);
    const trimmed: HistoryEntry[] = merged.length > MAX_HISTORY
      ? merged.slice(merged.length - MAX_HISTORY)
      : merged;
    this.history = trimmed;
    saveHistory(this.historyContext(), trimmed);
  }

  /**
   * 括号键的智能插入：能用右括号就补右括号，否则在合法位置补左括号。
   */
  private parenToAppend(): string {
    const op: string = this.operate;
    const openMatches: RegExpMatchArray | null = op.match(/\(/g);
    const closeMatches: RegExpMatchArray | null = op.match(/\)/g);
    const openCount: number = openMatches === null ? 0 : openMatches.length;
    const closeCount: number = closeMatches === null ? 0 : closeMatches.length;
    const lastIsValue: boolean = /[\d%)π]$/.test(op);
    if (openCount > closeCount && lastIsValue) {
      return ')';
    }
    if (op === '' || /[+\-x÷(]$/.test(op)) {
      return '(';
    }
    return '';
  }

  /**
   * 从“结果展示态”复位到“输入态”：算式恢复大字黑色，结果恢复小字灰色。
   */
  private resetAnimate(): void {
    this.getUIContext().animateTo({ curve: curves.springMotion() }, () => {
      this.answerAnimate = false;
      this.frontSizeOp = this.answerAnimate ? 30 : 50;
      this.frontSizeAns = this.answerAnimate ? 50 : 30;
      this.frontColorOp = this.answerAnimate ? 0x9fa39a : 0x000000;
      this.frontColorAns = this.answerAnimate ? 0x000000 : 0x9fa39a;
    })
  }

  /**
   * 按下“=”：把视觉重心从算式切到结果。
   */
  private showAnswerAnimate(): void {
    this.getUIContext().animateTo({ curve: curves.springMotion() }, () => {
      this.answerAnimate = true;
      this.frontSizeOp = this.answerAnimate ? 30 : 50;
      this.frontSizeAns = this.answerAnimate ? 50 : 30;
      this.frontColorOp = this.answerAnimate ? 0x9fa39a : 0x000000;
      this.frontColorAns = this.answerAnimate ? 0x000000 : 0x9fa39a;
    })
  }

  /**
   * 刷新结果行：算式没输完就保持上一次的有效结果，
   * 计算出错才提示错误，避免把半截算式当成结果显示出来。
   */
  private updateAnswer(): void {
    if (this.operate === '') {
      this.answer = '';
      return;
    }
    const result: EvalResult = tryEvaluate(this.operate, this.useDegrees);
    if (result.ok) {
      this.answer = result.value;
    } else if (result.failed) {
      this.answer = $r('app.string.cannot_compute');
    }
  }

  private onFunc(action: string): void {
    this.resetAnimate();
    if (action === 'AC') {
      this.operate = '';
      this.answer = '';
    } else if (action === '%') {
      if (!isLastCharNotDigit(this.operate)) {
        this.operate = this.operate + '%';
        this.updateAnswer();
      }
    } else if (action === 'BACK') {
      if (this.operate) {
        this.operate = this.operate.slice(0, -1);
      }
      this.updateAnswer();
    } else if (action === 'PAREN') {
      const next: string = this.parenToAppend();
      if (next !== '') {
        this.operate = this.operate + next;
        this.updateAnswer();
      }
    } else if (action === 'DEG') {
      this.useDegrees = !this.useDegrees;
      this.updateAnswer();
    }
  }

  private onKey(key: KeyDef): void {
    switch (key.kind) {
      case KeyKind.Digit:
        this.resetAnimate();
        if (key.value === '.') {
          if (canAppendDot(this.operate)) {
            this.operate = this.operate + '.';
            this.updateAnswer();
          }
        } else {
          this.operate = this.operate + key.value;
          this.updateAnswer();
        }
        break;
      case KeyKind.Operator:
        this.resetAnimate();
        if (key.value === '-') {
          if (!(/-$/.test(this.operate))) {
            this.operate = this.operate + '-';
          }
        } else if (!isLastCharNotDigit(this.operate)) {
          this.operate = this.operate + key.value;
        }
        break;
      case KeyKind.Func:
        this.onFunc(key.value);
        break;
      case KeyKind.Insert:
        this.resetAnimate();
        this.operate = this.operate + key.value;
        this.updateAnswer();
        break;
      case KeyKind.Equals:
        this.showAnswerAnimate();
        this.rememberCurrent();
        break;
      default:
        break;
    }
  }

  @Builder
  KeyButton(key: KeyDef) {
    Button(key.label, { type: ButtonType.Circle, stateEffect: true })
      .backgroundColor(key.bgColor)
      .fontColor(key.fontColor)
      .fontWeight(key.weight)
      .fontSize(key.fontSize)
      .width(key.size)
      .height(key.size)
      .onClick(() => {
        this.onKey(key);
      })
  }

  @Builder
  FunctionStrip() {
    Scroll() {
      Row({ space: 8 }) {
        ForEach(this.scienceKeys, (key: KeyDef) => {
          Button(key.label)
            .fontSize(key.fontSize)
            .fontColor(0x333333)
            .backgroundColor(key.bgColor)
            .height(32)
            .width(52)
            .onClick(() => {
              this.onKey(key);
            })
        }, (key: KeyDef) => `sci-${key.value}`)

        Button(this.useDegrees ? 'DEG' : 'RAD')
          .fontSize(12)
          .height(32)
          .width(52)
          .backgroundColor(0x0A59F7)
          .fontColor(0xFFFFFF)
          .onClick(() => {
            this.onFunc('DEG');
          })
      }
    }
    .width('90%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
  }

  @Builder
  HistoryArea() {
    Column({ space: 4 }) {
      ForEach(this.recentEntries(), (entry: HistoryEntry, index: number) => {
        Text(`${entry.expr} = ${entry.result}`)
          .fontSize(14)
          .fontColor(0x9fa39a)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }, (entry: HistoryEntry, index: number) => `hist-${index}-${entry.expr}-${entry.result}`)
    }
    .width('90%')
    .height(60)
    .alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  HeaderArea() {
    Column({ space: 5 }) {
      this.HistoryArea()

      Row() {
        Text(this.operate)
          .fontSize(this.frontSizeOp)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.frontColorOp)
      }
      .width('90%')
      .height(70)
      .justifyContent(FlexAlign.End)

      Row() {
        Text(this.answer)
          .fontSize(this.frontSizeAns)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.frontColorAns)
      }
      .width('90%')
      .height(70)
      .justifyContent(FlexAlign.End)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column({ space: 14 }) {
          this.HeaderArea()

          this.FunctionStrip()

          Column({ space: 14 }) {
            ForEach(this.rows, (row: KeyDef[], rowIndex: number) => {
              Row() {
                ForEach(row, (key: KeyDef, keyIndex: number) => {
                  this.KeyButton(key)
                }, (key: KeyDef, keyIndex: number) => `key-${rowIndex}-${key.label}-${keyIndex}`)
              }
              .width('90%')
              .height(70)
              .justifyContent(FlexAlign.SpaceAround)
            }, (row: KeyDef[], rowIndex: number) => `row-${rowIndex}`)
          }.width('100%')
        }
        .width('100%')
        .constraintSize({ maxWidth: CONTENT_MAX_WIDTH })
        .padding({ top: 12, bottom: 12 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgb(242,242,242)')
    }
    .title($r('app.string.entry_test03'))
  }
}
