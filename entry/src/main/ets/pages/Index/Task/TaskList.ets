import { HmList, HmLoading } from '@hm/basic/Index'
import { getTaskList } from '../../../api'
import { TaskInfoItem, TaskInfoItemModel, TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'
import TaskItemCard from './TaskItemCard'

// 待提货
@Component
struct TaskList {
  @State
  reset: boolean = false // 用于控制重置状态
  loading: CustomDialogController = new CustomDialogController({
    builder: HmLoading({
      title: '搜索查询中'
    }),
    customStyle: true,
    autoCancel: false,
    alignment: DialogAlignment.Center
  })
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
      this.taskListData.push(...result.items || []) // 延展运算符的写法
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

  // 日期补零
  addZero(value: number) {
    return value.toString().padStart(2, "0")
  }

  // 控制筛选按钮可点
  getSearchEnable() {
    return !!(this.queryParams.startTime && this.queryParams.endTime)
  }

  @Builder
  getSearchForm() {
    Column() {
      Row() {
        Search({ placeholder: '请输入任务编号' }).backgroundColor($r('app.color.background_page')).height(32)
          .onSubmit(async value => {
            this.loading.open()
            this.queryParams.page = 1
            if (value) {
              this.queryParams.startTime = ''
              this.queryParams.endTime = ''
              this.reset = false
              this.allPage = 0 // 有值意味着只有一条 因为是根据单号传的，所以不让它继续往后查 否则会重复
              this.queryParams.transportTaskId = isNaN(parseInt(value)) ? "0" : value
            } else {
              this.allPage = 1 // 没值意味着查不到 重新加载
              this.queryParams.transportTaskId = ""
            }
            const result = await getTaskList(this.queryParams)
            this.taskListData = result.items || []
            this.loading.close()
          })
      }
      .justifyContent(FlexAlign.Center)
      .padding({ left: 15, right: 15, bottom: 5 })


      Row() {
        // 完成搜索页需要测试点击之后键盘和弹层同时弹出的情况
        Button(this.queryParams.startTime || '开始时间')
          .fontSize(14)
          .width(106)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onAccept: (value: DatePickerResult) => {
                this.queryParams.startTime =
                  `${value.year}-${this.addZero(value.month! + 1)}-${this.addZero(value.day)}`

              }
            })
          })

        Text("至")
        Button(this.queryParams.endTime || '结束时间')
          .fontSize(14)
          .width(110)
          .height(32)
          .padding({ left: 0, right: 0 })
          .fontColor('#999')
          .backgroundColor($r('app.color.background_page'))
          .onClick(() => {
            DatePickerDialog.show({
              selected: new Date(),
              onAccept: (value: DatePickerResult) => {
                this.queryParams.endTime = `${value.year}-${this.addZero(value.month! + 1)}-${this.addZero(value.day)}`

              }
            })
          })
        Button(this.reset ? "重置" : "筛选")
          .backgroundColor(this.getSearchEnable() ? $r('app.color.primary') : $r('app.color.primary_disabled'))
          .height(32)
          .width(60)
          .onClick(async () => {
            if (this.reset) {
              this.queryParams.startTime = ''
              this.queryParams.endTime = ''
              this.reset = false
            } else {
              this.reset = true
            }
            this.loading.open()
            this.allPage = 1
            this.queryParams.page = 1
            await this.getTaskList(false)
            this.loading.close()
          })
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceAround)
    }
    .backgroundColor($r('app.color.white'))
    .padding(15)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  build() {
    Column() {
      if (this.queryParams.status === TaskTypeEnum.Finish) {
        this.getSearchForm()
      }
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
      })
    }
    .height('100%')
  }
}

export default TaskList