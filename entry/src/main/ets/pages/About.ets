import { bundleManager } from '@kit.AbilityKit';

/**
 * 关于页：展示真实的应用与构建信息。
 *
 * 演示点：
 * 1. 通过 bundleManager 读取当前应用的真实版本信息（异步 + 兜底）；
 * 2. 用 @Builder 复用「标签 - 值」行，避免重复的布局代码。
 */

@Component
export struct About {
  @State versionName: string = '-';
  @State versionCode: string = '-';
  @State bundleNameValue: string = '-';

  aboutToAppear(): void {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
      .then((info: bundleManager.BundleInfo) => {
        this.versionName = info.versionName;
        this.versionCode = info.versionCode.toString();
        this.bundleNameValue = info.name;
      })
      .catch((error: Error) => {
        // 读取失败时保持占位符，不影响页面其他内容
        this.versionName = '-';
      });
  }

  @Builder
  InfoRow(label: Resource, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .layoutWeight(1)
      Text(value)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  DividerLine() {
    Divider().color($r('app.color.divider')).strokeWidth(1)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 4 }) {
          Text($r('app.string.tool_about'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .margin({ bottom: 8 })

          this.InfoRow($r('app.string.about_version_name'), this.versionName)
          this.DividerLine()
          this.InfoRow($r('app.string.about_version_code'), this.versionCode)
          this.DividerLine()
          this.InfoRow($r('app.string.about_bundle'), this.bundleNameValue)
          this.DividerLine()
          this.InfoRow($r('app.string.about_devices'), 'phone / tablet / 2in1')
          this.DividerLine()
          this.InfoRow($r('app.string.about_sdk'), '5.0.0(12) → 6.1.0(23)')
          this.DividerLine()
          this.InfoRow($r('app.string.about_deps'), 'hypium 1.0.29 / hamock 1.0.0')
          this.DividerLine()
          this.InfoRow($r('app.string.about_pages'), 'Home + 6 tools + Settings + About')

          Text($r('app.string.about_licenses'))
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .margin({ top: 14 })

          Text('hypium 1.0.29 · Apache-2.0')
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding({ top: 6 })

          Text('hamock 1.0.0 · Apache-2.0')
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding({ top: 4 })

          Text('HarmonyCalc · MIT')
            .fontSize(13)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .padding({ top: 4 })

          Text($r('app.string.about_footer'))
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .width('100%')
            .margin({ top: 16 })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      .align(Alignment.Top)
      .backgroundColor($r('app.color.surface_bg'))
    }
    .title($r('app.string.tool_about'))
  }
}
