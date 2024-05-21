export interface LoginForm {
  /** 登录账号 */
  account: string;

  /** 登录密码 */
  password: string;
}

export interface RegisterForm {
  account: string; //用户名
  password: string; //密码
  key: string; //验证码key
  code: string; //验证码答案
}


export interface UserInfo {
  /** 头像 */
  avatar: string;

  /** 姓名 */
  name: string;

  /** 司机编号 */
  number: string;

  /** 手机号 */
  phone: string;
}


export class LoginFormModel implements LoginForm {
  account: string = ''
  password: string = ''

  constructor(model: LoginForm) {
    this.account = model.account
    this.password = model.password
  }
}

export class RegisterFormModel implements RegisterForm {
  account: string = ''
  password: string = ''
  key: string = ''
  code: string = ''

  constructor(model: RegisterForm) {
    this.account = model.account
    this.password = model.password
    this.key = model.key
    this.code = model.code
  }
}

export class UserInfoModel implements UserInfo {
  avatar: string = ''
  name: string = ''
  number: string = ''
  phone: string = ''

  constructor(model: UserInfo) {
    this.avatar = model.avatar
    this.name = model.name
    this.number = model.number
    this.phone = model.phone
  }
}
