import { Request } from '@hm/basic'
import { LoginFormModel, RegisterFormModel, UserCarDataTypeModel, UserInfoModel } from '../models'
import { UserTaskInfoModel, UserTaskInfoParamsModel } from '../models'
import { http } from '@kit.NetworkKit'


// 登录接口实现
export const login = (data: LoginFormModel) => {
  return Request.post<string>("/login/account", data)
}

//注册接口实现
export const register = (data: RegisterFormModel) => {
  return Request.post<string>("/register/account", data)
}


// 获取用户信息
export const getUserInfo = () => {
  return Request.get<UserInfoModel>("/users")
}

// 获取用户任务数据
export const getUserTaskInfo = (data: UserTaskInfoParamsModel) => {
  return Request.get<UserTaskInfoModel>("/users/taskReport", data)
}

// 获取用户车辆信息
export const getUserCarInfo = () => {
  return Request.get<UserCarDataTypeModel>("/users/truck")
}