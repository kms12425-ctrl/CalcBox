import { curves } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { calculateExpression, isLastCharNotDigit } from '../utils/expression';

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
 * 一个按键的全部描述：文案、类别、要追加的字符以及配色。
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
}

const BG_DIGIT: number = 0xfffef9;
const BG_FUNC: number = 0xcdd1d3;
const BG_EQUAL: number = 0xfb8b05;

function makeKey(label: string, kind: KeyKind, value: string, bgColor: number,
                 fontSize: number, weight: FontWeight): KeyDef {
  const key: KeyDef = new KeyDef();
  key.label = label;
  key.kind = kind;
  key.value = value;
  key.bgColor = bgColor;
  key.fontSize = fontSize;
  key.weight = weight;
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
  @State indexPage: router.RouterOptions = { 'url': 'pages/Index' };

  /**
   * 键盘布局：5 行 × 4 列，与界面一一对应。
   */
  private rows: KeyDef[][] = [
    [
      makeKey('AC', KeyKind.Func, 'AC', BG_FUNC, 23, FontWeight.Bold),
      makeKey('%', KeyKind.Func, '%', BG_FUNC, 23, FontWeight.Bold),
      makeKey('<=', KeyKind.Func, 'BACK', BG_FUNC, 27, FontWeight.Bold),
      makeKey('÷', KeyKind.Operator, '÷', BG_FUNC, 30, FontWeight.Bold)
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

  private onFunc(action: string): void {
    this.resetAnimate();
    if (action === 'AC') {
      this.operate = '';
      this.answer = '';
    } else if (action === '%') {
      if (!isLastCharNotDigit(this.operate)) {
        this.operate = this.operate + '%';
        this.answer = calculateExpression(this.operate);
      }
    } else if (action === 'BACK') {
      if (this.operate) {
        this.operate = this.operate.slice(0, -1);
      }
      this.answer = calculateExpression(this.operate);
    }
  }

  private onKey(key: KeyDef): void {
    switch (key.kind) {
      case KeyKind.Digit:
        this.resetAnimate();
        if (key.value === '.') {
          if (!isLastCharNotDigit(this.operate)) {
            this.operate = this.operate + '.';
          }
        } else {
          this.operate = this.operate + key.value;
          this.answer = calculateExpression(this.operate);
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
      .width(65)
      .height(65)
      .onClick(() => {
        this.onKey(key);
      })
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

      Row().width('90%').height(70)

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
              }, (key: KeyDef, keyIndex: number) => `key-${key.label}-${keyIndex}`)
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
