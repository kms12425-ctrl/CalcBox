import { common } from '@kit.AbilityKit';
import {
  ROUTE_TEST01, ROUTE_TEST02, ROUTE_TEST03, ROUTE_TEST04,
  ROUTE_TEST05, ROUTE_TEST06, ROUTE_TEST07, ROUTE_TEST08
} from '../utils/routes';
import { TEST01 } from './TEST01';
import { TEST02 } from './TEST02';
import { TEST03 } from './TEST03';
import { TEST04 } from './TEST04';
import { TEST05 } from './TEST05';
import { TEST06 } from './TEST06';
import { TEST07 } from './TEST07';
import { TEST08 } from './TEST08';

/** 宽屏判定阈值：与 Navigation 的 navBarWidth + minContentWidth 大致对齐 */
const WIDE_BREAKPOINT: number = 600;

/** 宽屏下默认选中的实验页 */
const ROUTE_DEFAULT: string = ROUTE_TEST08;

const GROUP_BASIC: string = 'basic';
const GROUP_ADVANCED: string = 'advanced';

/** 入口定义：路由、显示文案（运行时按当前语言取），以及所属分组 */
class EntryDef {
  route: string = '';
  label: string = '';
  group: string = GROUP_BASIC;
}

/** 与 routes.ets 一一对应的资源名，用于在运行时取到本地化文案 */
const ENTRY_ROUTES: string[] = [
  ROUTE_TEST01, ROUTE_TEST02, ROUTE_TEST03, ROUTE_TEST04,
  ROUTE_TEST05, ROUTE_TEST06, ROUTE_TEST07, ROUTE_TEST08
];

const ENTRY_RES_NAMES: string[] = [
  'entry_test01', 'entry_test02', 'entry_test03', 'entry_test04',
  'entry_test05', 'entry_test06', 'entry_test07', 'entry_test08'
];

@Entry
@Component
struct Index {
  @Provide('navStack') pathStack: NavPathStack = new NavPathStack();
  /** 由 TEST07 的设置页写入 AppStorage，首页实时显示 */
  @StorageProp('nickname') nickname: string = '';
  /** 是否只自动选中过一次，避免旋转屏幕时反复 push */
  private autoSelected: boolean = false;

  @State keyword: string = '';
  @State entries: EntryDef[] = [];

  aboutToAppear(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    const list: EntryDef[] = [];
    for (let i = 0; i < ENTRY_ROUTES.length; i++) {
      const entry: EntryDef = new EntryDef();
      entry.route = ENTRY_ROUTES[i];
      entry.label = this.resolveText(context, ENTRY_RES_NAMES[i]);
      entry.group = i < 3 ? GROUP_BASIC : GROUP_ADVANCED;
      list.push(entry);
    }
    this.entries = list;
  }

  /**
   * 取当前语言下的文案：显示与搜索共用同一份文本，避免“看到的中文搜不到”。
   */
  private resolveText(context: common.Context, name: string): string {
    try {
      return context.resourceManager.getStringByNameSync(name);
    } catch (error) {
      return name;
    }
  }

  /** 按关键字过滤（忽略大小写，同时匹配显示文案与路由名） */
  private visibleEntries(group: string): EntryDef[] {
    const key: string = this.keyword.trim().toLowerCase();
    return this.entries.filter((item: EntryDef) => {
      if (item.group !== group) {
        return false;
      }
      if (key === '') {
        return true;
      }
      return item.label.toLowerCase().indexOf(key) >= 0 || item.route.toLowerCase().indexOf(key) >= 0;
    });
  }

  /**
   * 路由表：名称由 utils/routes.ets 统一维护，与首页入口一一对应。
   */
  @Builder
  pageMap(name: string) {
    if (name === ROUTE_TEST01) {
      TEST01()
    } else if (name === ROUTE_TEST02) {
      TEST02()
    } else if (name === ROUTE_TEST03) {
      TEST03()
    } else if (name === ROUTE_TEST04) {
      TEST04()
    } else if (name === ROUTE_TEST05) {
      TEST05()
    } else if (name === ROUTE_TEST06) {
      TEST06()
    } else if (name === ROUTE_TEST07) {
      TEST07()
    } else if (name === ROUTE_TEST08) {
      TEST08()
    }
  }

  @Builder
  GroupHeader(group: string) {
    Text(group === GROUP_BASIC ? $r('app.string.group_basic') : $r('app.string.group_advanced'))
      .fontSize(13)
      .fontColor(0x999999)
      .width('100%')
      .padding({ top: 8, bottom: 4 })
  }

  @Builder
  navBar() {
    Column({ space: 10 }) {
      Column({ space: 4 }) {
        Text($r('app.string.home_title'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Start)
        if (this.nickname !== '') {
          Text($r('app.string.home_greeting', this.nickname))
            .fontSize(13)
            .fontColor(0x666666)
            .width('100%')
        }
      }
      .width('100%')

      TextInput({ text: this.keyword, placeholder: $r('app.string.search_placeholder') })
        .placeholderColor(0x999999)
        .fontSize(14)
        .height(38)
        .backgroundColor(0xFFFFFF)
        .borderRadius(10)
        .onChange((value: string) => {
          this.keyword = value;
        })

      if (this.visibleEntries(GROUP_BASIC).length === 0 && this.visibleEntries(GROUP_ADVANCED).length === 0) {
        Text($r('app.string.search_empty'))
          .fontSize(13)
          .fontColor(0x999999)
          .width('100%')
          .padding({ top: 24 })
      } else {
        List({ space: 8 }) {
          ForEach([GROUP_BASIC, GROUP_ADVANCED], (group: string) => {
            if (this.visibleEntries(group).length > 0) {
              ListItem() {
                this.GroupHeader(group)
              }
            }
            ForEach(this.visibleEntries(group), (entry: EntryDef) => {
              ListItem() {
                Button(entry.label)
                  .width('100%')
                  .borderRadius(20)
                  .height(40)
                  .fontSize(14)
                  .onClick(() => {
                    this.pathStack.pushPathByName(entry.route, null)
                  })
              }
            }, (entry: EntryDef) => entry.route)
          }, (group: string) => group)
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
  }

  build() {
    Navigation(this.pathStack) {
      this.navBar()
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Auto)
    .navBarWidth(280)
    .navBarWidthRange([240, 320])
    .navDestination(this.pageMap)
    .onAreaChange((oldArea: Area, newArea: Area) => {
      const width: number = newArea.width as number;
      // 宽屏首次进入时自动选中默认实验，避免右侧空白
      if (width >= WIDE_BREAKPOINT && !this.autoSelected) {
        this.autoSelected = true;
        setTimeout(() => {
          this.pathStack.pushPathByName(ROUTE_DEFAULT, null);
        }, 0);
      }
    })
  }
}
