import { globalSplashBottomBuilder, OhosPlatformSplashView } from './OhosPlatformSplashView';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { ampsAd, AMPSBuildSplashView, AMPSSplashAd } from 'biz.beizi.adn';
import { common } from '@kit.AbilityKit';
import { AMPSSplashChannelMethod } from '../data/common';
@Component
struct AMPSSplashComponent {
  @State hasSplash: boolean = false
  @Prop params: Params
  @Prop adOption: ampsAd.AdOptions
  customView: OhosPlatformSplashView = this.params.platformView as OhosPlatformSplashView
  @State bkColor: Color = Color.Red
  splashAd?: AMPSSplashAd
  callback: ampsAd.CallBack = {
    onLoadSuccess: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onLoadSuccess, undefined)
    },
    onLoadFailure: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onLoadFailure, { code, message })
    },
    onRenderOk: (): void => {
      this.hasSplash = true
      this.customView.sendMessage(AMPSSplashChannelMethod.onRenderOk, undefined)
    },
    onAdShow: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onAdShow, undefined)
    },
    onAdExposure: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onAdExposure, undefined)
    },
    onAdClicked: (): void => {
      this.hasSplash = false
      this.customView.sendMessage(AMPSSplashChannelMethod.onAdClicked, undefined)
    },
    onAdClosed: (): void => {
      this.hasSplash = false
      this.customView.sendMessage(AMPSSplashChannelMethod.onAdClosed, undefined)
    },
    onRenderFailure: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onRenderFailure, undefined)
    },
    onAdShowError: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onAdShowError, { code, message })
    },
    onVideoPlayStart: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onVideoPlayStart, undefined)
    },
    onVideoPlayEnd: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onVideoPlayEnd, undefined)
    },
    onVideoPlayError: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onVideoPlayEnd, { code, message })
    },
    onVideoSkipToEnd: (playDurationMs?: number): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onVideoSkipToEnd, { playDurationMs })
    },
    onAdReward: (): void => {
      this.customView.sendMessage(AMPSSplashChannelMethod.onAdReward, undefined)
    }
  }

  aboutToAppear(): void {
    this.splashAd = new AMPSSplashAd(this.adOption, this.callback, this.getUIContext())
    this.splashAd?.load()
  }

  build() {
    Column() {
      if (this.hasSplash && this.splashAd) {
          AMPSBuildSplashView(
            this.splashAd, {
            windowStage: (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage,
            bottomWrappedBuilder:globalSplashBottomBuilder
          })
        }
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width('100%')
    .height('100%')
  }
}

export { AMPSSplashComponent };
