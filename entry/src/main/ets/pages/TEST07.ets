import { common } from '@kit.AbilityKit';
import { KEY_FONT_SCALE, KEY_NICKNAME, STORAGE_NICKNAME, loadSetting, saveSetting } from '../utils/settings';

/**
 * 设置项与本地持久化示例。
 *
 * 演示点：
 * 1. Preferences 读写：退出应用后再次进入，昵称与字号仍然保留；
 * 2. 状态与存储的同步时机：改完点保存才落盘，而不是每次输入都写；
 * 3. AppStorage 跨页共享：保存后首页能立即看到问候语。
 */

/** 字号档位与对应的实际字号 */
const SCALE_S: string = 'S';
const SCALE_M: string = 'M';
const SCALE_L: string = 'L';

function sizeOfScale(scale: string): number {
  if (scale === SCALE_S) {
    return 14;
  }
  if (scale === SCALE_L) {
    return 24;
  }
  return 18;
}

@Component
export struct TEST07 {
  @State nickname: string = '';
  @State fontScale: string = SCALE_M;

  aboutToAppear(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    this.nickname = loadSetting(context, KEY_NICKNAME, '');
    this.fontScale = loadSetting(context, KEY_FONT_SCALE, SCALE_M);
  }

  private remember(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    saveSetting(context, KEY_NICKNAME, this.nickname);
    saveSetting(context, KEY_FONT_SCALE, this.fontScale);
    // 同步到内存，首页通过 @StorageProp 读取
    AppStorage.setOrCreate<string>(STORAGE_NICKNAME, this.nickname);
    this.getUIContext().getPromptAction().showToast({
      message: $r('app.string.settings_saved'),
      duration: 1500
    });
  }

  @Builder
  ScaleButton(scale: string) {
    Button(scale)
      .width(64)
      .height(36)
      .fontSize(14)
      .backgroundColor(this.fontScale === scale ? 0x0A59F7 : 0xE8E8E8)
      .fontColor(this.fontScale === scale ? 0xFFFFFF : 0x333333)
      .onClick(() => {
        this.fontScale = scale;
      })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 6 }) {
            Text($r('app.string.settings_nickname'))
              .fontSize(14)
              .fontColor(0x666666)
              .width('100%')
            TextInput({ text: this.nickname })
              .height(44)
              .onChange((value: string) => {
                this.nickname = value;
              })
          }

          Column({ space: 6 }) {
            Text($r('app.string.settings_font'))
              .fontSize(14)
              .fontColor(0x666666)
              .width('100%')
            Row({ space: 10 }) {
              this.ScaleButton(SCALE_S)
              this.ScaleButton(SCALE_M)
              this.ScaleButton(SCALE_L)
            }
            .width('100%')
          }

          Column({ space: 6 }) {
            Text($r('app.string.settings_preview'))
              .fontSize(14)
              .fontColor(0x666666)
              .width('100%')
            Text($r('app.string.settings_preview_text'))
              .fontSize(sizeOfScale(this.fontScale))
              .fontColor(0x333333)
              .width('100%')
          }

          Button($r('app.string.settings_save'))
            .width('100%')
            .height(44)
            .onClick(() => {
              this.remember();
            })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor('#F5F7FA')
    }
    .title($r('app.string.entry_test07'))
  }
}
