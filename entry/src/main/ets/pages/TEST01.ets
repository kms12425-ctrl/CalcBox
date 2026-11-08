class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}

@Component
export struct TEST01 {
  @State chinese: boolean = false;
  @State egDivider: DividerTmp = new DividerTmp(1, 60, 10, '#ffe9f0f0')
  @State egLanes: LengthConstrain = { minLength: 200, maxLength: 300 }

  build() {
    NavDestination() {
      RelativeContainer() {
        List({ space: 5 }) {
          ListItem() {
            Text(this.chinese ? $r('app.string.greet_zh') : $r('app.string.greet_en'))
              .id('test01_hi')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
          }

          ListItem() {
            Text(this.chinese ? '马俊豪' : 'JunHao Ma')
              .id('test01_name')
              .fontSize(25)
              .fontWeight(FontWeight.Bolder)
          }


          ListItem() {
            Row() {
              Button($r('app.string.action_translate')).onClick(() => {
                // 在中英文两种展示之间切换
                this.chinese = !this.chinese
              })
                .width('50%')
                .borderRadius(20)
                .height(40)
            }
          }

          ListItem() {
            Row() {
              Image($r('app.media.31e2893f9b7f4680d377946a44e50d973814460'))
                .objectFit(ImageFit.Contain)
            }
          }
          ListItem() {
            Row() {
              Image($r('app.media.0386c7c8e15ce32457efb9e9f60558c83814460'))
                .objectFit(ImageFit.Cover)
            }
          }
          ListItem() {
            Row() {
              Image($r('app.media.b0554cf72e4f7e183a84e51e134fc8ed3814460'))
                .objectFit(ImageFit.Fill)
            }
          }
          ListItem() {
            Row() {
              Image($r('app.media.b0554cf72e4f7e183a84e51e134fc8ed3814460'))
                .objectFit(ImageFit.ScaleDown)
            }
          }
        }
        .backgroundColor('#FFF1F3F5')
        .height('100%')
        .width('100%')
        .constraintSize({ maxWidth: 640 })
        .padding(100)
        .scrollBar(BarState.Auto)
        .divider(this.egDivider)
        .lanes(this.egLanes)
        .alignListItem(ListItemAlign.Center)

      }
    }
    .title($r('app.string.entry_test01'))
  }
}
