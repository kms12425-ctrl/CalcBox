/**
 * 网格与卡片布局示例。
 *
 * 演示点：
 * 1. Grid + GridItem 的二维布局，列数随可用宽度自适应；
 * 2. 数据驱动渲染，ForEach 以 id 作为 key；
 * 3. 选中态由 @State 驱动，无需手动操作组件。
 */

class DemoItem {
  id: number = 0;
  color: string = '';
}

const PALETTE: string[] = [
  '#F5F7FA', '#E8F0FE', '#E6F4EA', '#FCE8E6', '#FEF7E0', '#F3E8FD'
];

const CARD_COUNT: number = 12;

/** 宽度达到该值时切换为四列 */
const FOUR_COLUMN_WIDTH: number = 520;

function buildItems(): DemoItem[] {
  const items: DemoItem[] = [];
  for (let i = 0; i < CARD_COUNT; i++) {
    const item: DemoItem = new DemoItem();
    item.id = i;
    item.color = PALETTE[i % PALETTE.length];
    items.push(item);
  }
  return items;
}

@Component
export struct TEST04 {
  @State columnsTemplate: string = '1fr 1fr';
  @State selectedId: number = -1;
  private items: DemoItem[] = buildItems();

  @Builder
  Card(item: DemoItem) {
    Column({ space: 6 }) {
      Text(`#${item.id + 1}`)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.palette_text'))
      Text(this.selectedId === item.id ? '✓' : ' ')
        .fontSize(16)
        .fontColor($r('app.color.accent'))
    }
    .width('100%')
    .height(96)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(item.color)
    .borderRadius(12)
    .borderWidth(this.selectedId === item.id ? 2 : 0)
    .borderColor($r('app.color.accent'))
    .onClick(() => {
      this.selectedId = this.selectedId === item.id ? -1 : item.id;
    })
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text($r('app.string.grid_hint'))
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')

        Grid() {
          ForEach(this.items, (item: DemoItem) => {
            GridItem() {
              this.Card(item)
            }
          }, (item: DemoItem) => `card-${item.id}`)
        }
        .columnsTemplate(this.columnsTemplate)
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        .layoutWeight(1)
        .onAreaChange((oldArea: Area, newArea: Area) => {
          const width: number = newArea.width as number;
          this.columnsTemplate = width >= FOUR_COLUMN_WIDTH ? '1fr 1fr 1fr 1fr' : '1fr 1fr';
        })
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .title($r('app.string.entry_test04'))
  }
}
