import { addDays, daysBetween, formatDate, parseOffset } from '../../utils/datecalc';

/**
 * 日期计算工具：两个日期相差多少天，以及某个日期前后 N 天是哪天。
 */
@Component
export struct DateCalc {
  @State startDate: Date = new Date();
  @State endDate: Date = new Date();
  @State baseDate: Date = new Date();
  @State offsetText: string = '7';

  private diffDays(): number {
    return daysBetween(this.startDate, this.endDate);
  }

  private shiftedDate(): Date {
    const offset: number | null = parseOffset(this.offsetText);
    if (offset === null) {
      return this.baseDate;
    }
    return addDays(this.baseDate, offset);
  }

  private offsetValid(): boolean {
    return parseOffset(this.offsetText) !== null;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Text($r('app.string.date_diff'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          Row({ space: 10 }) {
            Column({ space: 6 }) {
              Text($r('app.string.date_start'))
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .width('100%')
              CalendarPicker({ hintRadius: 8, selected: this.startDate })
                .onChange((value: Date) => {
                  this.startDate = value;
                })
            }
            .layoutWeight(1)

            Column({ space: 6 }) {
              Text($r('app.string.date_end'))
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .width('100%')
              CalendarPicker({ hintRadius: 8, selected: this.endDate })
                .onChange((value: Date) => {
                  this.endDate = value;
                })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Row() {
            Text($r('app.string.date_diff_result', this.diffDays().toString()))
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
          }
          .width('100%')
          .height(56)
          .padding({ left: 14 })
          .backgroundColor($r('app.color.card_bg'))
          .borderRadius(12)
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          Divider().color($r('app.color.divider')).strokeWidth(1)

          Text($r('app.string.date_add'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')

          Column({ space: 6 }) {
            Text($r('app.string.date_base'))
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
            CalendarPicker({ hintRadius: 8, selected: this.baseDate })
              .onChange((value: Date) => {
                this.baseDate = value;
              })
          }
          .width('100%')

          Column({ space: 6 }) {
            Text($r('app.string.date_offset'))
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
            TextInput({ text: this.offsetText })
              .type(InputType.NUMBER_DECIMAL)
              .height(44)
              .onChange((value: string) => {
                this.offsetText = value;
              })
            if (!this.offsetValid()) {
              Text($r('app.string.date_offset_invalid'))
                .fontSize(12)
                .fontColor($r('app.color.danger'))
                .width('100%')
            }
          }
          .width('100%')

          Column({ space: 6 }) {
            Text($r('app.string.date_result'))
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
            Text(this.offsetValid() ? formatDate(this.shiftedDate()) : '-')
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .height(56)
              .padding({ left: 14 })
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius(12)
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
    .title($r('app.string.tool_date'))
  }
}
