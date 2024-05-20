import {
  TaskDetailInfoModel,
  TaskListData,
  TaskListParams,
  PickUpParamsModel,
  DeliverParamsTypeModel,
  CarRecordTypeModel,
  DelayParamsTypeModel,
  ExceptionParamsTypeModel
} from '../models'
import { Request } from '@hm/basic'


// 提货
export const pickUp = (data: PickUpParamsModel) => {
  return Request.post<null>("/tasks/takeDelivery", data)
}

// 交货
export const deliver = (data: DeliverParamsTypeModel) => {
  return Request.post<null>("/tasks/deliver", data)
}

export const getTaskList = (params: TaskListParams) => {
  return Request.get<TaskListData>("/tasks/list", params)
}

export const carRecord = (data: CarRecordTypeModel) => {
  return Request.post<null>("/tasks/truckRegistration", data)
}

// 延迟收货
export const delay = (data: DelayParamsTypeModel) => {
  return Request.put<null>("/tasks/delay", data)
}

// 上报异常
export const exceptionReport = (data: ExceptionParamsTypeModel) => {
  return Request.post<null>("/tasks/reportException", data)
}

// 获取任务列表
export const getTaskDetail = (id: string) => {
  return Request.get<TaskDetailInfoModel>(`/tasks/details/${id}`)
}