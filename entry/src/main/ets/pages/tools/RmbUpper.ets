import { RmbResult, toRmbUpper } from '../../utils/rmb';

/**
 * 金额大写工具：数字金额转中文大写，结果可长按复制。
 */
@Component
export struct RmbUpper {
  @State input: string = '1234.56';

  private result(): RmbResult {
    if (this.input.trim() === '') {
      return new RmbResult();
    }
    return toRmbUpper(Number.parseFloat(this.input));
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text($r('app.string.rmb_input'))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            TextInput({ text: this.input })
              .type(InputType.NUMBER_DECIMAL)
              .height(48)
              .fontSize(18)
              .onChange((value: string) => {
                this.input = value;
              })
            Text($r('app.string.rmb_hint'))
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
          }
          .width('100%')

          Column({ space: 8 }) {
            Text($r('app.string.rmb_result'))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            if (this.result().ok) {
              Text(this.result().text)
                .fontSize(22)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .copyOption(CopyOptions.LocalDevice)
            } else {
              Text($r('app.string.rmb_invalid'))
                .fontSize(14)
                .fontColor($r('app.color.text_tertiary'))
                .width('100%')
            }
          }
          .width('100%')
          .padding(14)
          .backgroundColor($r('app.color.card_bg'))
          .borderRadius(12)
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor($r('app.color.surface_bg'))
    }
    .title($r('app.string.tool_rmb'))
  }
}
