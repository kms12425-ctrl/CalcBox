import { router } from '@kit.ArkUI';

@Entry
@Component
struct TEST03 {
  @State OPERATE: string = '';
  @State ANSWER: string = '';
  @State answer_num: number = 0;
  @State the1_num: number = 0;
  @State num_count: number = 1;
  @State Index: router.RouterOptions = { 'url': 'pages/Index' };


  build() {
    RelativeContainer() {
      Column({ space: 20 }) {
        Column({ space: 5 }) {
          Row({}) {
          Button('<', { type: ButtonType.Normal, stateEffect: true })
            .width(50)
            .height(30)
            .fontSize(15)
            .borderRadius(8)
            .backgroundColor(0xF55A42)
            .onClick(()=>{
              router.pushUrl(this.Index)
            })
          Text('Calculator').fontSize(30).fontColor(0xc1b2a3).width('90%');
          }.width('95%')
          Row().width('90%').height(70)
          Row({}) {
            Text(this.OPERATE).fontSize(50).fontWeight(FontWeight.Medium).fontColor(0x000000)
          }
          .width('90%')
          .height(70)
          .id('OPERATE_ROW')
          .justifyContent(FlexAlign.End)

          Row({}) {
            Text(this.ANSWER).fontSize(30).fontWeight(FontWeight.Medium).fontColor(0x9fa39a)
          }
          .width('90%')
          .height(70)
          .id('ANSWER_ROW')
          .justifyContent(FlexAlign.End)
        }

        Column({ space: 15 }) {
          Row({}) {
            Column() {
              Button('AC', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('%', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('<=', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .fontSize(27)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('÷', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .fontSize(30)
                .width(65)
                .height(65)
            }.width('20%').height(70)
          }
          .width('90%')
          .height(70)
          .id('OPERATE')
          .justifyContent(FlexAlign.SpaceAround)

          Row({}) {
            Column() {
              Button('7', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('8', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('9', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('X', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)
          }
          .width('90%')
          .height(70)
          .id('OPERATE')
          .justifyContent(FlexAlign.SpaceAround)

          Row({}) {
            Column() {
              Button('4', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('5', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('6', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('一', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Bold)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)
          }
          .width('90%')
          .height(70)
          .id('OPERATE')
          .justifyContent(FlexAlign.SpaceAround)

          Row({}) {
            Column() {
              Button('1', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('2', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('3', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('+', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xcdd1d3)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Regular)
                .fontSize(42)
                .width(65)
                .height(65)
            }.width('20%').height(70)
          }
          .width('90%')
          .height(70)
          .id('OPERATE')
          .justifyContent(FlexAlign.SpaceAround)

          Row({}) {
            Column() {
              Button('00', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('0', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('.', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfffef9)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .fontSize(23)
                .width(65)
                .height(65)
            }.width('20%').height(70)

            Column() {
              Button('=', { type: ButtonType.Circle, stateEffect: true })
                .backgroundColor(0xfb8b05)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Regular)
                .fontSize(42)
                .width(65)
                .height(65)
            }.width('20%').height(70)
          }
          .width('90%')
          .height(70)
          .id('OPERATE')
          .justifyContent(FlexAlign.SpaceAround)

        }.width('100%')
      }
    }.width('100%').backgroundColor('rgb(242,242,242)')
    .height('100%')
    .width('100%')
  }
}

function type(arg0: string) {
  throw new Error('Function not implemented.');
}
