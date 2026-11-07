import { ROUTE_TEST01, ROUTE_TEST02, ROUTE_TEST03, ROUTE_TEST04, ROUTE_TEST05, ROUTE_TEST06 } from '../utils/routes';
import { TEST01 } from './TEST01';
import { TEST02 } from './TEST02';
import { TEST03 } from './TEST03';
import { TEST04 } from './TEST04';
import { TEST05 } from './TEST05';
import { TEST06 } from './TEST06';

/** 宽屏判定阈值：与 Navigation 的 navBarWidth + minContentWidth 大致对齐 */
const WIDE_BREAKPOINT: number = 600;

/** 宽屏下默认选中的实验页 */
const ROUTE_DEFAULT: string = ROUTE_TEST01;

@Entry
@Component
struct Index {
  @Provide('navStack') pathStack: NavPathStack = new NavPathStack();
  /** 是否只自动选中过一次，避免旋转屏幕时反复 push */
  private autoSelected: boolean = false;

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
    }
  }

  @Builder
  navBar() {
    Column({ space: 12 }) {
      Text($r('app.string.home_title'))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      List({ space: 10 }) {
        ListItem() {
          Button($r('app.string.entry_test01')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test02')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST02, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test03')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST03, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test04')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test05')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test06')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test07')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test08')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('100%')
            .borderRadius(20)
            .height(40)
        }
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.Off)
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
