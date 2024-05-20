import { fileIo, picker } from '@kit.CoreFileKit';
import { ImageList } from '../models';
import { HmPreview } from './HmPreview';
import { util } from '@kit.ArkTS';
import { request } from '@kit.BasicServicesKit';
import { uploadImage } from '../api';

// 上传方法
const UploadFile = async (list: ImageList[]) => {
  // 因为上传文件只能从沙箱文件中拷贝所以 我们需要把传过来的所有的图片拷贝到沙箱
  const saveDir = getContext().cacheDir // 存储的目录
  const fileParams: request.File[] = [] // 要提交的参数
  list.forEach(item => {
    const file = fileIo.openSync(item.url, fileIo.OpenMode.READ_ONLY) // 读取相册的文件
    // 将文件拷贝到沙箱目录
    // 相册的地址
    const uniqueName = util.generateRandomUUID() + ".jpg"
    fileIo.copyFileSync(file.fd, saveDir + "/" + uniqueName) // 将相册文件拷贝到沙箱
    // 需要生成参数
    fileParams.push({
      filename: uniqueName, // 文件名称
      name: 'file', // 接口的参数名称
      type: 'jpg', // 文件后缀
      uri: `internal://cache/${uniqueName}` // 应该是文件放到cache目录下 如果是cache协议 它会自动找这个文件
    })
    fileIo.closeSync(file.fd)
  })
  // 将参数进行上传
  return await uploadImage(getContext(), fileParams) // 调用上传接口 // 将上传的结果再返回上一层
}

@Component
struct HmUpload {
  @Prop
  canUpload: boolean = true
  title: string = ""
  maxNumber: number = 3
  index: number = -1
  @Prop
  imgList: ImageList[] = []
  preview: CustomDialogController = new CustomDialogController({
    builder: HmPreview({
      urls: this.imgList.map(item => item.url),
      selectIndex: this.index
    }),
    customStyle: true, // 自定义样式
  })
  onListChange: (list: ImageList[]) => void = () => {
  }

  // 弹出相册选择器
  async selectImage() {
    const photoPicker = new picker.PhotoViewPicker()
    const result = await photoPicker.select({
      MIMEType: picker.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: this.maxNumber - this.imgList.length
    })
    // 循环数组
    if (result.photoUris?.length) {
      this.imgList = this.imgList.concat(result.photoUris.map(url => {
        return { url } as ImageList
      }))
      this.onListChange(this.imgList)
    }
  }

  build() {
    Column() {
      Text(this.title).fontSize(14).fontColor($r("app.color.text_secondary")).margin({
        top: 16,
        bottom: 16
      })
      // 渲染图片
      Grid() {
        ForEach(this.imgList, (item: ImageList, index: number) => {
          GridItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item.url)
                .width(95)
                .height(95)
                .borderRadius(4)
                .onClick(() => {
                  this.index = index
                  this.preview.open()
                })
              if (this.canUpload) {
                Image($r('app.media.ic_btn_delete')).width(30).height(30)
                  .onClick(() => {
                    this.imgList.splice(index, 1) // 移除索引
                    this.onListChange(this.imgList) // 通知父组件更新
                  })
              }
            }.margin({ right: 15, bottom: 10 })
          }
        })
        if (this.imgList.length < this.maxNumber && this.canUpload) {
          GridItem() {
            Row() {
              Image($r("app.media.ic_add_img")).width(30).height(30)
            }
            .width(95)
            .height(95)
            .backgroundColor($r("app.color.upload_panel"))
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.selectImage()
            })
          }
        }
      }
      .height(Math.ceil(this.maxNumber / 3) * 105)
      .columnsTemplate("1fr 1fr 1fr")
      .columnsGap(10)
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
}

export { HmUpload, UploadFile }