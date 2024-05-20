import { HmList } from '@hm/basic/Index'
import { getTaskList } from '../../../api'
import { TaskInfoItem, TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItemCard'

// 待提货
@Component
struct TaskList {
  @State
  queryParams: TaskListParamsModel = new TaskListParamsModel(
    {
      status: TaskTypeEnum.Waiting, // 待提货的类型
      page: 1, // 第几页
      pageSize: 5 // 每页几条数据
    } as TaskListParams
  )
  @State
  taskListData: TaskInfoItem[] = []
  @State
  allPage: number = 1 // 默认只有一页

  //上拉加载
  async getTaskList(append: boolean) {
    const result = await getTaskList(this.queryParams)
    // 追加数据
    // this.taskListData = this.taskListData.concat(result.items) // 拿到返回的数组
    if (append) {
      this.taskListData.push(...result.items) // 延展运算符的写法
    } else {
      this.taskListData = result.items
    }
    this.allPage = result.pages // 总页数
    this.queryParams.page++ // 下次请求的页码
  }

  // 下拉刷新函数
  async onRefresh() {
    // 重新请求第一页数据
    this.queryParams.page = 1 // 重置第一页
    await this.getTaskList(false) // 直接赋值
  }

  @Builder
  renderItem(item: object) {
    TaskItemCard({ taskItemData: item as TaskInfoItemModel })
  }

  build() {
    HmList({
      onLoad: async () => {
        await this.getTaskList(true)
      },
      onRefresh: async () => {
        await this.onRefresh()
      },
      dataSource: this.taskListData,
      renderItem: this.renderItem,
      finished: this.allPage < this.queryParams.page,
      finishText: '没啦没啦',
      loadingText: '拼命加载中'
    }).height('100%')
  }
}

export default TaskList