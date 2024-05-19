import { TaskDetailInfoModel, TaskListData, TaskListParams, PickUpParamsModel } from '../models'
import { Request } from '@hm/basic'


// 提货
export const pickUp = (data: PickUpParamsModel) => {
  return Request.post<null>("/tasks/takeDelivery", data)
}


export const getTaskList = (params: TaskListParams) => {
  return Request.get<TaskListData>("/tasks/list", params)
}

// 获取任务列表
export const getTaskDetail = (id: string) => {
  return Request.get<TaskDetailInfoModel>(`/tasks/details/${id}`)
}