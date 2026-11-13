import { common } from '@kit.AbilityKit';
import { ROUTE_ABOUT, ROUTE_CALCULATOR, ROUTE_BASE, ROUTE_DATE, ROUTE_PERCENT, ROUTE_SETTINGS, ROUTE_UNIT } from '../utils/routes';
import { Calculator } from './tools/Calculator';
import { BaseConvert } from './tools/BaseConvert';
import { DateCalc } from './tools/DateCalc';
import { Percent } from './tools/Percent';
import { UnitConvert } from './tools/UnitConvert';
import { Settings } from './Settings';
import { About } from './About';

/** 列数断点：手机两列，平板三列，2in1 四列 */
const THREE_COLUMN_WIDTH: number = 520;
const FOUR_COLUMN_WIDTH: number = 720;

/** 宽屏判定：进入宽屏时自动选中默认工具 */
const WIDE_BREAKPOINT: number = 600;

const ROUTE_DEFAULT: string = ROUTE_CALCULATOR;

/**
 * 工具定义：路由、文案资源名、卡片底色。
 * 文案在运行时按当前语言解析，便于搜索与显示保持一致。
 */
class ToolSpec {
  route: string = '';
  resName: string = '';
  color: string = '';

  constructor(route: string, resName: string, color: string) {
    this.route = route;
    this.resName = resName;
    this.color = color;
  }
}

class ToolItem {
  route: string = '';
  label: string = '';
  color: string = '';
}

const TOOL_SPECS: ToolSpec[] = [
  new ToolSpec(ROUTE_CALCULATOR, 'tool_calculator', '#E8F0FE'),
  new ToolSpec(ROUTE_UNIT, 'tool_unit', '#E6F4EA'),
  new ToolSpec(ROUTE_BASE, 'tool_base', '#FEF7E0'),
  new ToolSpec(ROUTE_DATE, 'tool_date', '#FCE8E6'),
  new ToolSpec(ROUTE_PERCENT, 'tool_percent', '#F3E8FD'),
  new ToolSpec(ROUTE_SETTINGS, 'tool_settings', '#ECEFF1'),
  new ToolSpec(ROUTE_ABOUT, 'tool_about', '#F1F3F4')
];

@Entry
@Component
struct Index {
  @Provide('navStack') pathStack: NavPathStack = new NavPathStack();
  /** 由 Settings 页写入 AppStorage */
  @StorageProp('nickname') nickname: string = '';
  private autoSelected: boolean = false;

  @State keyword: string = '';
  @State columnsTemplate: string = '1fr 1fr';
  @State tools: ToolItem[] = [];

  aboutToAppear(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    const list: ToolItem[] = [];
    for (let i = 0; i < TOOL_SPECS.length; i++) {
      const spec: ToolSpec = TOOL_SPECS[i];
      const item: ToolItem = new ToolItem();
      item.route = spec.route;
      item.label = this.resolveText(context, spec.resName);
      item.color = spec.color;
      list.push(item);
    }
    this.tools = list;
  }

  private resolveText(context: common.Context, name: string): string {
    try {
      return context.resourceManager.getStringByNameSync(name);
    } catch (error) {
      return name;
    }
  }

  private visibleTools(): ToolItem[] {
    const key: string = this.keyword.trim().toLowerCase();
    if (key === '') {
      return this.tools;
    }
    return this.tools.filter((item: ToolItem) => {
      return item.label.toLowerCase().indexOf(key) >= 0 || item.route.toLowerCase().indexOf(key) >= 0;
    });
  }

  @Builder
  pageMap(name: string) {
    if (name === ROUTE_CALCULATOR) {
      Calculator()
    } else if (name === ROUTE_UNIT) {
      UnitConvert()
    } else if (name === ROUTE_BASE) {
      BaseConvert()
    } else if (name === ROUTE_DATE) {
      DateCalc()
    } else if (name === ROUTE_PERCENT) {
      Percent()
    } else if (name === ROUTE_SETTINGS) {
      Settings()
    } else if (name === ROUTE_ABOUT) {
      About()
    }
  }

  @Builder
  ToolCard(item: ToolItem) {
    Column({ space: 6 }) {
      Text(item.label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.palette_text'))
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(92)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(item.color)
    .borderRadius(14)
    .onClick(() => {
      this.pathStack.pushPathByName(item.route, null)
    })
  }

  @Builder
  homePanel() {
    Column({ space: 12 }) {
      Column({ space: 2 }) {
        Text($r('app.string.home_title'))
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Text(this.nickname === '' ? $r('app.string.home_subtitle') : $r('app.string.home_greeting', this.nickname))
          .fontSize(13)
          .fontColor($r('app.color.text_secondary'))
          .width('100%')
      }
      .width('100%')

      TextInput({ text: this.keyword, placeholder: $r('app.string.search_placeholder') })
        .placeholderColor($r('app.color.text_tertiary'))
        .fontSize(14)
        .height(38)
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(10)
        .onChange((value: string) => {
          this.keyword = value;
        })

      if (this.visibleTools().length === 0) {
        Text($r('app.string.search_empty'))
          .fontSize(13)
          .fontColor($r('app.color.text_tertiary'))
          .width('100%')
          .padding({ top: 24 })
      } else {
        Grid() {
          ForEach(this.visibleTools(), (item: ToolItem) => {
            GridItem() {
              this.ToolCard(item)
            }
          }, (item: ToolItem) => item.route)
        }
        .columnsTemplate(this.columnsTemplate)
        .columnsGap(12)
        .rowsGap(12)
        .width('100%')
        .layoutWeight(1)
        .onAreaChange((oldArea: Area, newArea: Area) => {
          const width: number = newArea.width as number;
          if (width >= FOUR_COLUMN_WIDTH) {
            this.columnsTemplate = '1fr 1fr 1fr 1fr';
          } else if (width >= THREE_COLUMN_WIDTH) {
            this.columnsTemplate = '1fr 1fr 1fr';
          } else {
            this.columnsTemplate = '1fr 1fr';
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }

  build() {
    Navigation(this.pathStack) {
      this.homePanel()
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
    .mode(NavigationMode.Auto)
    .navBarWidth(300)
    .navBarWidthRange([260, 340])
    .navDestination(this.pageMap)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      const width: number = newArea.width as number;
      if (width >= WIDE_BREAKPOINT && !this.autoSelected) {
        this.autoSelected = true;
        setTimeout(() => {
          this.pathStack.pushPathByName(ROUTE_DEFAULT, null);
        }, 0);
      }
    })
  }
}
