import { RadixResult, parseRadix, toRadix } from '../../utils/radix';

/**
 * 进制转换工具。
 *
 * 输入框按所选进制校验，四个结果行（2/8/10/16）实时同步；
 * 解析与格式化逻辑在 utils/radix.ets，可被单元测试直接覆盖。
 */

/** 输入进制候选 */
const INPUT_BASES: number[] = [2, 8, 10, 16];
const BASE_LABELS: string[] = ['BIN', 'OCT', 'DEC', 'HEX'];

class OutputRow {
  label: string = '';
  value: string = '';
}

@Component
export struct BaseConvert {
  @State baseIndex: number = 2;
  @State input: string = '255';
  @State invalid: boolean = false;

  private currentBase(): number {
    return INPUT_BASES[this.baseIndex];
  }

  private parsed(): RadixResult {
    return parseRadix(this.input, this.currentBase());
  }

  private outputRows(): OutputRow[] {
    const parsed: RadixResult = this.parsed();
    const rows: OutputRow[] = [];
    for (let i = 0; i < INPUT_BASES.length; i++) {
      const row: OutputRow = new OutputRow();
      row.label = BASE_LABELS[i];
      row.value = parsed.ok ? toRadix(parsed.value, INPUT_BASES[i]) : '-';
      rows.push(row);
    }
    return rows;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Text($r('app.string.base_input'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          Row({ space: 8 }) {
            ForEach(BASE_LABELS, (label: string, index: number) => {
              Button(label)
                .fontSize(13)
                .height(34)
                .layoutWeight(1)
                .backgroundColor(this.baseIndex === index
                  ? $r('app.color.accent')
                  : $r('app.color.chip_bg'))
                .fontColor(this.baseIndex === index
                  ? $r('app.color.accent_on')
                  : $r('app.color.text_primary'))
                .onClick(() => {
                  this.baseIndex = index;
                })
            }, (label: string, index: number) => `base-${index}`)
          }
          .width('100%')

          TextInput({ text: this.input })
            .height(48)
            .fontSize(18)
            .onChange((value: string) => {
              this.input = value;
              this.invalid = parseRadix(value, this.currentBase()).invalid;
            })

          if (this.invalid) {
            Text($r('app.string.base_invalid'))
              .fontSize(12)
              .fontColor($r('app.color.danger'))
              .width('100%')
          }

          Column({ space: 8 }) {
            ForEach(this.outputRows(), (row: OutputRow) => {
              Row() {
                Text(row.label)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .width(44)
                Text(row.value)
                  .fontSize(17)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height(52)
              .padding({ left: 12, right: 12 })
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius(10)
            }, (row: OutputRow) => `out-${row.label}`)
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor($r('app.color.surface_bg'))
    }
    .title($r('app.string.tool_base'))
  }
}
