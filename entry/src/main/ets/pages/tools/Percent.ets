import {
  PercentResult, changeRate, discountedPrice, formatMoney, formatPercent, shareOf
} from '../../utils/percent';

/**
 * 百分比计算工具：占比 / 涨跌幅 / 折扣价三种场景共用一套输入。
 */
@Component
export struct Percent {
  @State mode: number = 0;
  @State aText: string = '25';
  @State bText: string = '200';

  private valueA(): number {
    return Number.parseFloat(this.aText);
  }

  private valueB(): number {
    return Number.parseFloat(this.bText);
  }

  private inputsValid(): boolean {
    return !Number.isNaN(this.valueA()) && !Number.isNaN(this.valueB())
      && this.aText.trim() !== '' && this.bText.trim() !== '';
  }

  private compute(): PercentResult {
    if (!this.inputsValid()) {
      return new PercentResult();
    }
    if (this.mode === 1) {
      return changeRate(this.valueA(), this.valueB());
    }
    if (this.mode === 2) {
      return discountedPrice(this.valueA(), this.valueB());
    }
    return shareOf(this.valueA(), this.valueB());
  }

  private resultText(): string {
    const result: PercentResult = this.compute();
    if (!result.ok) {
      return '-';
    }
    if (this.mode === 2) {
      return formatMoney(result.value);
    }
    return formatPercent(result.value);
  }

  private resultLabel(): ResourceStr {
    if (this.mode === 1) {
      return $r('app.string.percent_result_change', this.resultText());
    }
    if (this.mode === 2) {
      return $r('app.string.percent_result_discount', this.resultText());
    }
    return $r('app.string.percent_result_share', this.resultText());
  }

  private hint(): Resource {
    if (this.mode === 1) {
      return $r('app.string.percent_hint_change');
    }
    if (this.mode === 2) {
      return $r('app.string.percent_hint_discount');
    }
    return $r('app.string.percent_hint_share');
  }

  @Builder
  ModeButton(label: Resource, index: number) {
    Button(label)
      .fontSize(13)
      .height(34)
      .layoutWeight(1)
      .backgroundColor(this.mode === index
        ? $r('app.color.accent')
        : $r('app.color.chip_bg'))
      .fontColor(this.mode === index
        ? $r('app.color.accent_on')
        : $r('app.color.text_primary'))
      .onClick(() => {
        this.mode = index;
      })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 14 }) {
          Row({ space: 8 }) {
            this.ModeButton($r('app.string.percent_mode_share'), 0)
            this.ModeButton($r('app.string.percent_mode_change'), 1)
            this.ModeButton($r('app.string.percent_mode_discount'), 2)
          }
          .width('100%')

          Text(this.hint())
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .width('100%')

          Column({ space: 10 }) {
            Text($r('app.string.percent_a'))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            TextInput({ text: this.aText })
              .type(InputType.NUMBER_DECIMAL)
              .height(44)
              .onChange((value: string) => {
                this.aText = value;
              })
          }

          Column({ space: 10 }) {
            Text($r('app.string.percent_b'))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            TextInput({ text: this.bText })
              .type(InputType.NUMBER_DECIMAL)
              .height(44)
              .onChange((value: string) => {
                this.bText = value;
              })
          }

          Column({ space: 6 }) {
            if (this.compute().ok) {
              Text(this.resultLabel())
                .fontSize(24)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
            } else {
              Text($r('app.string.percent_invalid'))
                .fontSize(14)
                .fontColor($r('app.color.text_tertiary'))
            }
          }
          .width('100%')
          .height(64)
          .padding({ left: 14 })
          .backgroundColor($r('app.color.card_bg'))
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor($r('app.color.surface_bg'))
    }
    .title($r('app.string.tool_percent'))
  }
}
