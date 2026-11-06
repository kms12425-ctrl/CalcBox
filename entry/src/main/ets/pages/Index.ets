import { ROUTE_TEST01, ROUTE_TEST02, ROUTE_TEST03 } from '../utils/routes';
import { TEST01 } from './TEST01';
import { TEST02 } from './TEST02';
import { TEST03 } from './TEST03';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @Provide('navStack') pathStack: NavPathStack = new NavPathStack();

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
    }
  }

  @Builder
  navBar() {
    RelativeContainer() {


      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })


      List({ space: 10 }) {
        ListItem() {
          Button($r('app.string.entry_test01')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test02')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST02, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test03')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST03, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test04')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test05')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test06')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test07')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test08')).onClick(() => {
            this.pathStack.pushPathByName(ROUTE_TEST01, null)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
      }
      .constraintSize({ maxWidth: 420 })
      .alignListItem(ListItemAlign.Center)
    }
    .height('100%')
    .width('100%')
  }

  build() {
    Navigation(this.pathStack) {
      this.navBar()
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap)
  }
}
