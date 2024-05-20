import { TabClass } from '@hm/basic'
import TaskList from './TaskList'
import { TaskListParams, TaskListParamsModel, TaskTypeEnum } from '../../../models'

@Preview
@Component
struct TaskTabs {
  tabController: TabsController = new TabsController()
  @State
  tabsData: TabClass[] = [{
    name: 'waiting',
    title: '待提货'
  }, {
    name: 'line',
    title: '在途'
  }, {
    name: 'finish',
    title: '已完成'
  }]
  @State
  currentIndex: number = 0

  @Builder
  getTabBar(item: TabClass) {
    Column() {
      Text(item.title)
        .fontSize(16)
        .fontColor(this.tabsData[this.currentIndex].name === item.name ? $r('app.color.text_primary') :
        $r('app.color.text_secondary'))
        .fontWeight(600)
        .animation({
          duration: 300
        })
        .margin({
          bottom: 10
        })
      Divider()
        .strokeWidth(4)
        .color($r('app.color.primary'))
        .lineCap(LineCapStyle.Round)
        .width(this.tabsData[this.currentIndex].name === item.name ? 23 : 0)
        .animation({
          duration: 300
        })
    }
    .onClick(() => {
      const index = this.tabsData.findIndex(i => i.name === item.name)
      this.tabController.changeIndex(index)
    })
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Tabs({ barPosition: BarPosition.Start, index: $$this.currentIndex, controller: this.tabController }) {
        ForEach(this.tabsData, (item: TabClass) => {
          TabContent() {
            if (item.name === "waiting") {
              TaskList()
            } else if (item.name === 'line') {
              TaskList({
                queryParams: new TaskListParamsModel({
                  page: 1,
                  pageSize: 5,
                  status: TaskTypeEnum.Line
                } as TaskListParams)
              })
            } else {
              Text(item.title)
            }
          }
        })
      }.backgroundColor($r('app.color.background_page')).animationDuration(300)

      Row({ space: 30 }) {
        ForEach(this.tabsData, (item: TabClass) => {
          this.getTabBar(item)
        })
      }
      .padding({
        left: 40,
        right: 40
      })
      .width('100%')
      .height(50)
      .backgroundColor($r("app.color.white"))

    }
  }
}

export default TaskTabs