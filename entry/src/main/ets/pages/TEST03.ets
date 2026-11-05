import { curves } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
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
  Equals
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

@Entry
@Component
struct TEST03 {
  @State operate: string = '';
  @State answer: string = '';
  @State frontSizeOp: number = 50;
  @State frontColorOp: number = 0x000000;
  @State frontSizeAns: number = 30;
  @State frontColorAns: number = 0x9fa39a;
  @State answerAnimate: boolean = false;
  @State history: HistoryEntry[] = [];
  @State indexPage: router.RouterOptions = { 'url': 'pages/Index' };

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
    const result: EvalResult = tryEvaluate(this.operate);
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
    const lastIsValue: boolean = /[\d%)]$/.test(op);
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
   * 计算出错才提示“无法计算”，避免把半截算式当成结果显示出来。
   */
  private updateAnswer(): void {
    if (this.operate === '') {
      this.answer = '';
      return;
    }
    const result: EvalResult = tryEvaluate(this.operate);
    if (result.ok) {
      this.answer = result.value;
    } else if (result.failed) {
      this.answer = '无法计算';
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
    .height(70)
    .alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  HeaderArea() {
    Column({ space: 5 }) {
      Row() {
        Button('<', { type: ButtonType.Normal, stateEffect: true })
          .width(50)
          .height(30)
          .fontSize(15)
          .borderRadius(8)
          .backgroundColor(0xF55A42)
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.indexPage);
          })
        Text('Calculator').fontSize(30).fontColor(0xc1b2a3).width('90%')
      }.width('95%')

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
    RelativeContainer() {
      Column({ space: 20 }) {
        this.HeaderArea()

        Column({ space: 15 }) {
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
    }.width('100%').backgroundColor('rgb(242,242,242)')
    .height('100%')
    .width('100%')
  }
}
