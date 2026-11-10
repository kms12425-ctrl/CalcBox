import { curves } from '@kit.ArkUI';

/**
 * 动画与转场示例。
 *
 * 演示点：
 * 1. 显式动画 animateTo：同一段位移用三种曲线触发，直观对比缓动差异；
 * 2. 一次 animateTo 同时改变尺寸、圆角与颜色；
 * 3. transition 让列表项在增删时淡入淡出，而不是瞬间出现或消失。
 */

@Component
export struct TEST05 {
  /** 位移动画：0 与 120 之间来回 */
  @State offsetX: number = 0;
  /** 缩放与颜色 */
  @State boxScale: number = 1;
  /** 主色状态：true 用主色，false 用警示色 */
  @State boxAccent: boolean = true;
  /** 列表增删 */
  @State items: number[] = [1, 2, 3];
  @State nextId: number = 4;

  private toggleOffset(curve: Curve | ICurve): void {
    this.getUIContext().animateTo({ duration: 600, curve: curve }, () => {
      this.offsetX = this.offsetX === 0 ? 120 : 0;
    })
  }

  private toggleScaleAndColor(): void {
    this.getUIContext().animateTo({ duration: 400, curve: curves.springMotion() }, () => {
      this.boxScale = this.boxScale === 1 ? 1.35 : 1;
      this.boxAccent = !this.boxAccent;
    })
  }

  private addItem(): void {
    this.items.push(this.nextId);
    this.nextId = this.nextId + 1;
  }

  private removeItem(): void {
    if (this.items.length > 0) {
      this.items.pop();
    }
  }

  @Builder
  SectionTitle(text: Resource) {
    Text(text)
      .fontSize(14)
      .fontColor($r('app.color.text_secondary'))
      .width('100%')
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          // 1. 位移 + 曲线对比
          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.anim_move'))
            Row({ space: 8 }) {
              Button('linear').fontSize(12).height(32)
                .onClick(() => this.toggleOffset(Curve.Linear))
              Button('easeInOut').fontSize(12).height(32)
                .onClick(() => this.toggleOffset(Curve.EaseInOut))
              Button('spring').fontSize(12).height(32)
                .onClick(() => this.toggleOffset(curves.springMotion()))
            }
            .width('100%')

            Row() {
              Text('▶')
                .fontSize(28)
                .fontColor($r('app.color.accent'))
                .translate({ x: this.offsetX })
            }
            .width('100%')
            .height(60)
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(12)
            .padding({ left: 16 })
            .justifyContent(FlexAlign.Start)
          }

          // 2. 缩放与颜色
          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.anim_scale'))
            Row({ space: 12 }) {
              Row()
                .width(64)
                .height(64)
                .borderRadius(this.boxScale === 1 ? 12 : 32)
                .backgroundColor(this.boxAccent ? $r('app.color.accent') : $r('app.color.danger'))
                .scale({ x: this.boxScale, y: this.boxScale })
              Button('toggle').fontSize(13).height(34)
                .onClick(() => this.toggleScaleAndColor())
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
          }

          // 3. 列表增删过渡
          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.anim_list'))
            Row({ space: 8 }) {
              Button('+').width(48).height(32).onClick(() => this.addItem())
              Button('−').width(48).height(32).onClick(() => this.removeItem())
            }
            .width('100%')

            Column({ space: 6 }) {
              ForEach(this.items, (item: number) => {
                Row() {
                  Text(`item ${item}`).fontSize(14).fontColor($r('app.color.text_primary'))
                }
                .width('100%')
                .height(36)
                .backgroundColor($r('app.color.card_bg'))
                .borderRadius(8)
                .padding({ left: 12 })
                .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
              }, (item: number) => `anim-item-${item}`)
            }
            .width('100%')
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
    .title($r('app.string.entry_test05'))
  }
}
