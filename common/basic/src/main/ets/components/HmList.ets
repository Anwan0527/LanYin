import { promptAction } from '@kit.ArkUI'
import { ListDataSource } from '../models'
import vibrator from '@ohos.vibrator';
import { AVPlayerClass } from '../utils';

// 加载的状态
export enum PullEnum {
  none = 0, // 正常状态
  show = 1, // 显示下拉状态
  loading = 2, // 下拉刷新中
  waiting = 3 // 等待下拉刷新完成
}

@Component
struct HmList {
  @State
  refreshStatus: PullEnum = PullEnum.none
  @State
  refreshIng: boolean = false // 控制下拉刷新的变量
  // 传入数据的数组 根据数组进行渲染
  @Link
  @Watch("updateDataSource")
  dataSource: object[] // 数据源
  // 需要一个标记 还没有数据的标记
  @Prop
  finished: boolean = false // 是否还有下一页数据
  @State
  loading: boolean = false // 是否正在加载中 1.显示加载中文本 2. 用来做阀门 当前这次请求没结束之前 下次请求滚远点
  loadingText: string = "加载中.." // 加载中的文本
  finishText: string = "没有数据啦" // 所有数据加载完成的文本
  @BuilderParam
  renderItem: (item: object) => void // 由调用者传入 由HmList调用 传入每一个项的数据
  lazyDataSource: ListDataSource = new ListDataSource()
  @State
  translateY: number = 0 // 列表偏移量
  refreshLimit: number = 50 // 阈值
  startY: number = 0 // 实际偏移量
  // 上拉加载的方法
  onLoad: () => void = () => {
  } // 由调用者传入
  // 下拉刷新方法
  onRefresh: () => void = () => {
  } // 下拉刷新的方法

  //阻尼函数
  ease(distance: number) {
    const damp = 0.2 // 阻尼系数
    if (distance > this.refreshLimit) {
      return this.refreshLimit + (distance - this.refreshLimit) * damp
    }
    return distance
  }

  // 更新数据
  updateDataSource() {
    this.lazyDataSource.reloadData(this.dataSource)
  }

  @Builder
  getRefreshDisplay() {
    Row() {
      LoadingProgress().color($r('app.color.primary')).width(40).height(40).animation({
        duration: 100
      })
      Text(this.getRefreshText(this.refreshStatus))
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({
          left: 10
        })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(50)
  }

  // 动态生成文本
  getRefreshText(status: PullEnum) {
    switch (status) {
      case PullEnum.none:
        return ""
      case PullEnum.show:
        return "继续下拉"
      case PullEnum.loading:
        return "松手加载"
      case PullEnum.waiting:
        return "加载中"
    }

  }

  @Builder
  getBottomDisplay() {
    // 获取底部的展示内容
    Row({ space: 10 }) {
      if (this.finished) {
        // 此时应该没有动画的loading
        Text(this.finishText)
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
      } else {
        Text(this.loadingText)
          .fontSize(14)
          .fontColor($r("app.color.text_secondary"))
        LoadingProgress()
          .width(20)
          .aspectRatio(1)
          .color($r("app.color.text_secondary"))
      }
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      if (this.refreshStatus !== PullEnum.none) {
        this.getRefreshDisplay()
      }
      List() {
        LazyForEach(this.lazyDataSource, (item: object) => {
          // 每一项的结构的UI内容不是由列表决定 而由使用者决定
          // 传入builderParam
          if (this.renderItem) {
            this.renderItem(item)
          }
        })
        // 最后放置提示文本的地方
        ListItem() {
          this.getBottomDisplay()
        }
      }
      .translate({
        y: this.translateY // 记录偏移量
      })
      .onReachEnd(async () => {
        // 实现上拉加载
        // 需要一个标记 是否已经加载完所有数据
        // 在没有加载完所有页数据的情况 且没有请求在进程中的情况下
        if (!this.finished && !this.loading) {
          this.loading = true // 关闭阀门
          await this.onLoad() // 实现上拉加载
          this.loading = false // 打开阀门
        }
      })
      .onTouch(async (event?: TouchEvent) => {
        if (!event) {
          return;
        }
        switch (event.type) {
          case TouchType.Down:
            this.startY = event.touches[0].y // 鼠标按下时 记录起始的y坐标
            break
          case TouchType.Move:
            const offset = this.ease(event.touches[0].y - this.startY) // 移动后的偏移量
            if (offset > 0) {
              // 只有大于0的情况下 才位移 否则不管
              this.translateY = this.ease(offset) // 设置阻尼
            }
          // 如果确认往下拉了 但是小于设定的阈值 状态为show
            if (this.translateY > 0 && this.translateY < this.refreshLimit) {
              this.refreshStatus = PullEnum.show;
            }
            // 如果超过阈值 就设置为加载状态
            else if (this.translateY > this.refreshLimit) {
              this.refreshStatus = PullEnum.loading;
            } else {
              // 否则就是往上拉了 往上拉是没有加载进度
              this.refreshStatus = PullEnum.none
            }
            break;
          case TouchType.Up:
          // 如果松手时 是加载状态 表示是去加载 就开始加载
            if (this.refreshStatus === PullEnum.loading) {
              // 将状态设置为等待 表示等待它加载完毕
              this.refreshStatus = PullEnum.waiting
              await this.onRefresh()
              vibrator.startVibration({ duration: 300, type: 'time' }, { id: 0, usage: 'touch' }) // 震动
              AVPlayerClass.playAudio("success.wav", getContext(this))
            }
          // 松手之后，一切应该恢复正常
          // 恢复正常
            animateTo({ duration: 300 }, () => {
              this.translateY = 0
              this.refreshStatus = PullEnum.none;
            })
            break;
          default:
            break;
        }
      })
    }
  }
}

export { HmList }