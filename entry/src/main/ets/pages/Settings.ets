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
export struct Settings {
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
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.settings_saved'),
        duration: 1500
      });
    } catch (error) {
      // 提示失败不影响保存结果
    }
  }

  @Builder
  ScaleButton(scale: string) {
    Button(scale)
      .width(64)
      .height(36)
      .fontSize(14)
      .backgroundColor(this.fontScale === scale ? $r('app.color.accent') : $r('app.color.chip_bg'))
      .fontColor(this.fontScale === scale ? $r('app.color.accent_on') : $r('app.color.text_primary'))
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
              .fontColor($r('app.color.text_secondary'))
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
              .fontColor($r('app.color.text_secondary'))
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
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
            Text($r('app.string.settings_preview_text'))
              .fontSize(sizeOfScale(this.fontScale))
              .fontColor($r('app.color.text_primary'))
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
      .backgroundColor($r('app.color.surface_bg'))
    }
    .title($r('app.string.tool_settings'))
  }
}
