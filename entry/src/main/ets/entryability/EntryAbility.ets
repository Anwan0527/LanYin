import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { UserSettingClass, defaultAd, AdvertClass, TOKEN_KEY } from '@hm/basic';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    const manager = abilityAccessCtrl.createAtManager()
    manager.requestPermissionsFromUser(this.context, [
      "ohos.permission.LOCATION",
      "ohos.permission.APPROXIMATELY_LOCATION"
    ])
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    // 检查是否有广告
    const setting = new UserSettingClass(this.context) // getContext拿到的是undefined
    //
    const ad = await new Promise<AdvertClass>((resolve, reject) => {
      setTimeout(() => {
        resolve(defaultAd) // 广告信息
      }, 500)
      // resolve()
    })
    // 通过模拟请求拿到广告信息
    await setting.setUserAd(ad) // 写入首选项
    if (ad.showAd) {
      // 展示广告的情况 展示广告页 有时限
      // 创建一个子窗口 子窗口加载广告 广告播完 窗口销毁
      // pages/Start/Start
      const win = await windowStage.createSubWindow("ad_window") // 创建一个广告的窗口
      await win.showWindow() // 展示窗口
      win.setUIContent("pages/Start/Start") // 加载广告页
    }
    const token = await setting.getUserToken()
    // windowStage.getMainWindowSync().setWindowLayoutFullScreen(true)
    // AppStorage.setOrCreate("topHeight", px2vp(windowStage.getMainWindowSync().getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
    //   .topRect.height)  )
    // AppStorage.setOrCreate("bottomHeight", px2vp(windowStage.getMainWindowSync().getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
    //   .bottomRect.height)  )

    // AppStorage如果当前key里面不存在 调用set的话 是设置不进去的
    AppStorage.setOrCreate(TOKEN_KEY, token) // 写到全局内存中
    if (token) {
      // token
      windowStage.loadContent('pages/Index/Index'); // 正常加载页面
    } else {
      windowStage.loadContent('pages/Login/Login'); // 正常加载页面
    }

  }

  onWindowStageDestroy(): void {

    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  async onForeground(): Promise<void> {
    // 相隔一段时间  当前时间 - 上次显示广告时间 > 5分钟
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
