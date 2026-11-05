import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State TEST01: router.RouterOptions = { 'url': 'pages/TEST01' }
  @State TEST02: router.RouterOptions = { 'url': 'pages/TEST02' }
  @State TEST03: router.RouterOptions = { 'url': 'pages/TEST03' }

  build() {
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
            this.getUIContext().getRouter().pushUrl(this.TEST01)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test02')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST02)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test03')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST03)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test04')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST01)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test05')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST01)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test06')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST01)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test07')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST01)
          })
            .width('50%')
            .borderRadius(20)
            .height(40)
        }
        ListItem() {
          Button($r('app.string.entry_test08')).onClick(() => {
            this.getUIContext().getRouter().pushUrl(this.TEST01)
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
}
