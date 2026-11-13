import { common } from '@kit.AbilityKit';
import {
  DEFAULT_ANGLE_DEGREES, DEFAULT_DECIMALS, DEFAULT_THOUSANDS,
  KEY_ANGLE_DEGREES, KEY_DECIMALS, KEY_NICKNAME, KEY_THOUSANDS, STORAGE_NICKNAME,
  loadBool, loadNumber, loadSetting, saveBool, saveNumber, saveSetting
} from '../utils/settings';
import { formatNumberText } from '../utils/format';

/** 可选的小数位数，-1 表示自动 */
const DECIMAL_CHOICES: number[] = [-1, 0, 2, 4, 6];

/**
 * 设置页：昵称、角度单位、小数位数、千分位。
 * 角度与显示格式会直接影响计算器的计算结果与展示。
 */
@Component
export struct Settings {
  @State nickname: string = '';
  @State angleDegrees: boolean = DEFAULT_ANGLE_DEGREES;
  @State decimals: number = DEFAULT_DECIMALS;
  @State thousands: boolean = DEFAULT_THOUSANDS;

  aboutToAppear(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    this.nickname = loadSetting(context, KEY_NICKNAME, '');
    this.angleDegrees = loadBool(context, KEY_ANGLE_DEGREES, DEFAULT_ANGLE_DEGREES);
    this.decimals = loadNumber(context, KEY_DECIMALS, DEFAULT_DECIMALS);
    this.thousands = loadBool(context, KEY_THOUSANDS, DEFAULT_THOUSANDS);
  }

  private remember(): void {
    const context: common.Context = this.getUIContext().getHostContext() as common.Context;
    saveSetting(context, KEY_NICKNAME, this.nickname);
    saveBool(context, KEY_ANGLE_DEGREES, this.angleDegrees);
    saveNumber(context, KEY_DECIMALS, this.decimals);
    saveBool(context, KEY_THOUSANDS, this.thousands);
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
  SectionTitle(text: Resource) {
    Text(text)
      .fontSize(12)
      .fontColor($r('app.color.text_secondary'))
      .width('100%')
  }

  @Builder
  ChipHolder(label: string, active: boolean, onTap: () => void) {
    Button(label)
      .fontSize(13)
      .height(34)
      .layoutWeight(1)
      .backgroundColor(active ? $r('app.color.accent') : $r('app.color.chip_bg'))
      .fontColor(active ? $r('app.color.accent_on') : $r('app.color.text_primary'))
      .onClick(onTap)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.settings_nickname'))
            TextInput({ text: this.nickname })
              .height(44)
              .onChange((value: string) => {
                this.nickname = value;
              })
          }
          .width('100%')

          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.settings_angle'))
            Row({ space: 8 }) {
              this.ChipHolder('DEG', this.angleDegrees, () => {
                this.angleDegrees = true;
              })
              this.ChipHolder('RAD', !this.angleDegrees, () => {
                this.angleDegrees = false;
              })
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.settings_decimals'))
            Row({ space: 8 }) {
              ForEach(DECIMAL_CHOICES, (choice: number) => {
                this.ChipHolder(choice < 0 ? 'AUTO' : choice.toString(), this.decimals === choice, () => {
                  this.decimals = choice;
                })
              }, (choice: number) => `dec-${choice}`)
            }
            .width('100%')
          }
          .width('100%')

          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.settings_thousands'))
            Toggle({ type: ToggleType.Switch, isOn: this.thousands })
              .onChange((isOn: boolean) => {
                this.thousands = isOn;
              })
          }
          .width('100%')

          Column({ space: 8 }) {
            this.SectionTitle($r('app.string.settings_preview'))
            Text(formatNumberText('1234567.891', this.decimals, this.thousands))
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .padding(14)
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius(12)
          }
          .width('100%')

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
