import { HmNavBar, HmCard, HmCardItem } from '@hm/basic'
import { MapComponent } from '@hms.core.map.MapComponent'
import { geoLocationManager } from '@kit.LocationKit'
import { map, mapCommon, site } from "@kit.MapKit"
import { router } from '@kit.ArkUI'

@Entry
@Component
struct SelectLocation {
  @State
  list: SiteClass[] = []
  mapController: map.MapComponentController = new map.MapComponentController()

  async getLocation() {
    const rightResult = await geoLocationManager.getCurrentLocation()


    // let wgs84Position: mapCommon.LatLng = {
    //   longitude: result.longitude,
    //   latitude: result.latitude
    // }
    // // 正确的坐标
    // const rightResult = await map.convertCoordinate(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position)
    // 获取位置经纬WGS84
    // 花瓣地图 GCJ02
    // 地图上 将可相机挪动到具体的位置
    this.mapController.moveCamera(map.newCameraPosition({
      target: {
        longitude: rightResult.longitude,
        latitude: rightResult.latitude
      },
      zoom: 16
    }))
    // 添加一个标记
    this.mapController.addPointAnnotation({
      position: {
        longitude: rightResult.longitude,
        latitude: rightResult.latitude
      },
      titles: [{
        content: '您当前的位置'
      }]
    })
    const res = await site.nearbySearch({
      location: {
        longitude: rightResult.longitude,
        latitude: rightResult.latitude
      },
      pageSize: 4,
      pageIndex: 1,
      radius: 50
    })
    this.list = res.sites?.slice(0, 4) as SiteClass[] // 只拿4条数据
  }

  build() {
    Column() {
      HmNavBar({ title: '当前位置' })
      Stack({ alignContent: Alignment.Bottom }) {
        //  地图区域
        MapComponent({
          mapOptions: {
            position: {
              target: {
                latitude: 39.9,
                longitude: 116.4
              },
              zoom: 10
            }
          },
          mapCallback: (err, controller) => {
            if (!err) {
              this.mapController = controller // 此时此刻 地图渲染完毕 地图控制器也有值了
              this.getLocation() // 获取定位
            }
          }
        })
          .width('100%')
          .height('100%')
        Column() {
          HmCard() {
            ForEach(this.list, (item: SiteClass) => {
              HmCardItem({ leftTitle: item.name, rightText: `${item.distance}m` })
                .onClick(() => {
                  router.back({
                    url: "pages/ExceptionReport/ExceptionReport",
                    params: {
                      address: item.name
                    }
                  })
                })
            })


          }
        }
        .padding({
          bottom: 60
        })
      }
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}

class SiteClass {
  name: string = ""
  distance: number = 0
}