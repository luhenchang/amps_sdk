import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSBuildNativeView, AMPSNativeAdWrapper } from 'biz.beizi.adn';
import { AdWrapperManager } from '../manager/AdWrapperManager';
import { OhosPlatformInterstitialView } from './OhosPlatformInterstitialView';

@Component
export struct AMPSNativeAdComponent {
  @Prop params: Params
  @Prop adId: string
  @State customView: OhosPlatformInterstitialView = this.params.platformView as OhosPlatformInterstitialView
  @State wrapper: AMPSNativeAdWrapper | undefined = undefined
  @State closeAd: boolean = false
  aboutToAppear(): void {
    this.wrapper = AdWrapperManager.getInstance().getAd(this.adId)
  }

  build() {
    if (this.wrapper && !this.closeAd)
      Column() {
        AMPSBuildNativeView(this.wrapper)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .direction(Direction.Ltr)
      .width('100%')
      .height('100%')
  }
}
