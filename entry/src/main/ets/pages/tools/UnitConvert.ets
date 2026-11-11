import { common } from '@kit.AbilityKit';
import { UNIT_CATEGORIES, UnitCategory, convertValue, formatResult } from '../../utils/units';

/**
 * 单位换算工具。
 *
 * 分类与单位全部来自 utils/units.ets 的数据表，
 * 新增一个单位只需要往数组里加一行，界面无需改动。
 */
@Component
export struct UnitConvert {
  @State categoryIndex: number = 0;
  @State fromIndex: number = 2;
  @State toIndex: number = 0;
  @State input: string = '1';
  @State categoryLabels: string[] = [];

  aboutToAppear(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    const labels: string[] = [];
    for (let i = 0; i < UNIT_CATEGORIES.length; i++) {
      labels.push(this.resolveText(context, UNIT_CATEGORIES[i].resName));
    }
    this.categoryLabels = labels;
  }

  private resolveText(context: common.Context, name: string): string {
    try {
      return context.resourceManager.getStringByNameSync(name);
    } catch (error) {
      return name;
    }
  }

  private currentCategory(): UnitCategory {
    return UNIT_CATEGORIES[this.categoryIndex];
  }

  private unitSymbols(): SelectOption[] {
    const options: SelectOption[] = [];
    const category: UnitCategory = this.currentCategory();
    for (let i = 0; i < category.units.length; i++) {
      options.push({ value: category.units[i].symbol });
    }
    return options;
  }

  private resultText(): string {
    const value: number = Number.parseFloat(this.input);
    if (this.input.trim() === '' || Number.isNaN(value)) {
      return '-';
    }
    const category: UnitCategory = this.currentCategory();
    const converted: number = convertValue(category, this.fromIndex, this.toIndex, value);
    return formatResult(converted);
  }

  private switchCategory(index: number): void {
    this.categoryIndex = index;
    this.fromIndex = 0;
    this.toIndex = 1;
  }

  private swapUnits(): void {
    const from: number = this.fromIndex;
    this.fromIndex = this.toIndex;
    this.toIndex = from;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Row({ space: 8 }) {
            ForEach(this.categoryLabels, (label: string, index: number) => {
              Button(label)
                .fontSize(13)
                .height(34)
                .layoutWeight(1)
                .backgroundColor(this.categoryIndex === index
                  ? $r('app.color.accent')
                  : $r('app.color.chip_bg'))
                .fontColor(this.categoryIndex === index
                  ? $r('app.color.accent_on')
                  : $r('app.color.text_primary'))
                .onClick(() => {
                  this.switchCategory(index);
                })
            }, (label: string, index: number) => `cat-${index}-${label}`)
          }
          .width('100%')

          Column({ space: 6 }) {
            Text($r('app.string.unit_value'))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            TextInput({ text: this.input })
              .type(InputType.NUMBER_DECIMAL)
              .height(44)
              .onChange((value: string) => {
                this.input = value;
              })
          }

          Row({ space: 10 }) {
            Column({ space: 6 }) {
              Text($r('app.string.unit_from'))
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
              Select(this.unitSymbols())
                .selected(this.fromIndex)
                .value(this.currentCategory().units[this.fromIndex].symbol)
                .width('100%')
                .onSelect((index: number) => {
                  this.fromIndex = index;
                })
            }
            .layoutWeight(1)

            Button('⇄')
              .width(44)
              .height(36)
              .fontSize(16)
              .backgroundColor($r('app.color.chip_bg'))
              .fontColor($r('app.color.text_primary'))
              .margin({ top: 18 })
              .onClick(() => {
                this.swapUnits();
              })

            Column({ space: 6 }) {
              Text($r('app.string.unit_to'))
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
              Select(this.unitSymbols())
                .selected(this.toIndex)
                .value(this.currentCategory().units[this.toIndex].symbol)
                .width('100%')
                .onSelect((index: number) => {
                  this.toIndex = index;
                })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)

          Column({ space: 6 }) {
            Text($r('app.string.unit_result'))
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            Row() {
              Text(this.resultText())
                .fontSize(30)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
              Text(this.currentCategory().units[this.toIndex].symbol)
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
                .margin({ left: 6 })
            }
            .width('100%')
            .height(64)
            .padding({ left: 12 })
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(12)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
          }
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor($r('app.color.surface_bg'))
    }
    .title($r('app.string.tool_unit'))
  }
}
