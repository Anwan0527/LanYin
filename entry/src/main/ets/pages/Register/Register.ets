import { RegisterFormModel } from '../../models'
import { register } from '../../api'
import { image } from '@kit.ImageKit'
import { promptAction, router } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import { BASE_URL } from '@hm/basic/Index'

@Entry
@Component
struct Register {
  @State showLoading: boolean = false
  @State showcode: boolean = false
  @State
  accountForm: RegisterFormModel = new RegisterFormModel({
    account: '',
    password: '',
    key: '123456789',
    code: ''
  })
  @State pixelMap: Partial<image.PixelMap> = {} as image.PixelMap
  @State timestamp: number = 0

  // 调用注册接口
  async register() {
    try {
      this.showLoading = true
      const res = await register(this.accountForm)
      this.showLoading = false
      promptAction.showToast({
        message: res
      })
      if (res === '注册成功!') {
        router.back()
      }
    } catch (error) {
      promptAction.showToast({
        message: error.message
      })
      if (error.message == '验证码有误或已过期!' || error.message === '验证码不正确') {
        this.accountForm.code = ''
        this.getCode()
      }
    } finally {
      this.showLoading = false
    }

  }

  @Styles
  loginStyle() {
    .backgroundColor('#fff')
    .border({ color: $r('app.color.background_divider'), width: { bottom: 1 } })
    .width('100%')
    .height(58)
    .borderRadius(0)
  }

  // 通过校验
  getFormValidate() {
    if (this.accountForm.password && this.accountForm.account && this.accountForm.key && this.accountForm.code) {
      return true
    }
    return false
  }

  async getCode() {
    try {
      await http.createHttp()
        .request(`${BASE_URL}/register/captcha?key=` + this.accountForm.key, {
          expectDataType: http.HttpDataType.ARRAY_BUFFER
        })
        .then(async res => {
          this.pixelMap = await image.createImageSource(res.result as ArrayBuffer)
            .createPixelMap()
        })

    } catch (err) {
      promptAction.showToast({
        message: JSON.stringify(err)
      })
    }
  }

  build() {
    Column() {
      // 顶部标题
      Text("兰因").fontColor($r('app.color.text_primary')).fontSize(18).height(25)
      // 账号登录
      Row() {
        Text('账号登录').fontColor($r('app.color.text_primary')).fontSize(24).fontWeight(FontWeight.Bold)
        Row() {
          Text("账号登录").fontColor($r('app.color.primary')).fontSize(16).fontWeight(FontWeight.Bold)
          Image($r("app.media.ic_angle")).width(10).height(10).margin({ left: 5 })
        }
        .onClick(() => {
          router.back()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 50, bottom: 50 })

      // 用户名输入框
      TextInput({ placeholder: '请输入账号', text: this.accountForm.account })
        .loginStyle()
        .onChange(value => {
          this.accountForm.account = value
        })
      // 密码框
      TextInput({ placeholder: '请输入密码', text: this.accountForm.password })
        .loginStyle()
        .type(InputType.Password)// 密码框
        .showPasswordIcon(true)// 显示密码按钮
        .onChange((value) => {
          this.accountForm.password = value
        }) // 显示密码按钮

      //验证码框
      Row() {
        TextInput({ placeholder: '请输入验证码', text: this.accountForm.code })
          .loginStyle()
          .layoutWeight(1)
          .onChange(value => {
            this.accountForm.code = value
          })
          .onSubmit(() => {
            if (this.getFormValidate()) {
              this.register()
            }
          })
        if (this.showcode) {
          Image(this.pixelMap as image.PixelMap)
            .width(100)// .backgroundColor(Color.Blue)
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              this.getCode()
            })
            .onClick(() => {
              this.getCode()
            })
        } else {
          Button("获取验证码")
            .onClick(() => {
              this.getCode()
              this.showcode = true
            })
        }
      }

      // 注册按钮
      Button({ type: ButtonType.Capsule, stateEffect: this.getFormValidate() }) {
        Row() {
          if (this.showLoading) {
            // 显示进度条再显示
            LoadingProgress()
              .width(20)
              .height(20)
              .margin({ right: 12 })
              .color($r('app.color.white'))
          }
          Text('注册').fontColor($r('app.color.white'))
        }
      }
      .backgroundColor(this.getFormValidate() ? $r('app.color.primary') : $r('app.color.primary_disabled'))
      .width('100%')
      .height(50)
      .margin({ top: 50 })
      .enabled(this.getFormValidate())
      .onClick(() => {
        this.register()
      })
    }
    .padding({ left: 32, right: 32 })
    .margin({ top: 40 })
  }
}