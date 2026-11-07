/**
 * 表单输入与实时校验示例。
 *
 * 演示点：
 * 1. TextInput 受控输入：onChange 写回 @State，界面随状态刷新；
 * 2. 校验规则抽成方法，错误提示只在字段非空且不合法时出现；
 * 3. 提交按钮的可用性由整体校验结果决定（enabled），
 *    而不是点击后再弹错误。
 */

@Component
export struct TEST06 {
  @State name: string = '';
  @State email: string = '';
  @State age: string = '';

  /** 姓名：去掉首尾空格后至少 2 个字符 */
  private nameValid(): boolean {
    return this.name.trim().length >= 2;
  }

  /** 邮箱：简化校验，要求含 @ 与域名点号 */
  private emailValid(): boolean {
    return /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);
  }

  /** 年龄：1~120 的整数 */
  private ageValid(): boolean {
    if (!/^\d{1,3}$/.test(this.age)) {
      return false;
    }
    const value: number = Number.parseInt(this.age, 10);
    return value >= 1 && value <= 120;
  }

  private canSubmit(): boolean {
    return this.nameValid() && this.emailValid() && this.ageValid();
  }

  private submit(): void {
    this.getUIContext().getPromptAction().showToast({
      message: $r('app.string.form_ok'),
      duration: 2000
    });
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 18 }) {
          Column({ space: 6 }) {
            Text($r('app.string.form_name'))
              .fontSize(14)
              .fontColor(0x666666)
              .width('100%')
            TextInput({ text: this.name })
              .height(44)
              .onChange((value: string) => {
                this.name = value;
              })
            Text(this.name !== '' && !this.nameValid() ? $r('app.string.err_name') : '')
              .fontSize(12)
              .fontColor(0xE84026)
              .width('100%')
          }

          Column({ space: 6 }) {
            Text($r('app.string.form_email'))
              .fontSize(14)
              .fontColor(0x666666)
              .width('100%')
            TextInput({ text: this.email })
              .height(44)
              .type(InputType.Email)
              .onChange((value: string) => {
                this.email = value;
              })
            Text(this.email !== '' && !this.emailValid() ? $r('app.string.err_email') : '')
              .fontSize(12)
              .fontColor(0xE84026)
              .width('100%')
          }

          Column({ space: 6 }) {
            Text($r('app.string.form_age'))
              .fontSize(14)
              .fontColor(0x666666)
              .width('100%')
            TextInput({ text: this.age })
              .height(44)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.age = value;
              })
            Text(this.age !== '' && !this.ageValid() ? $r('app.string.err_age') : '')
              .fontSize(12)
              .fontColor(0xE84026)
              .width('100%')
          }

          Button($r('app.string.form_submit'))
            .width('100%')
            .height(44)
            .enabled(this.canSubmit())
            .onClick(() => {
              this.submit();
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
    .title($r('app.string.entry_test06'))
  }
}
