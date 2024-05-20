import { TaskDetailInfoModel, TaskListData, TaskListParams, PickUpParamsModel, DeliverParamsTypeModel } from '../models'
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

// 获取任务列表
export const getTaskDetail = (id: string) => {
  return Request.get<TaskDetailInfoModel>(`/tasks/details/${id}`)
}