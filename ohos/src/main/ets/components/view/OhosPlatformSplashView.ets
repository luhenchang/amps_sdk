import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import { AMPSSplashComponent } from './AMPSSplashComponent';
import { AMPSPlatformViewRegistry, defaultAdOption, SPLASH_BOTTOM, CONFIG } from '../data/common';
import { Any } from '@ohos/flutter_ohos';
import { ampsAd } from 'biz.beizi.adn';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { SplashBottomModule } from '../data/SplashBottomModule';

//底部自定义组件全局WrappedBuilder
export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(MyBuilder);
@Observed
export class OhosPlatformSplashView extends PlatformView {
  methodChannel: MethodChannel | null | undefined
  static adOptionsWeakRef: WeakRef<ampsAd.AdOptions> | undefined;
  static splashBottomModule: SplashBottomModule | null | undefined = null

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    const channelName = `${AMPSPlatformViewRegistry.ampsSdkSplashViewId}${viewId}`;
    OhosPlatformSplashView.splashBottomModule = new SplashBottomModule(args.get(SPLASH_BOTTOM));
    OhosPlatformSplashView.adOptionsWeakRef = new WeakRef(AdOptionsModule.getAdOptionFromMap(args.get(CONFIG)));
    this.methodChannel = new MethodChannel(message, channelName, StandardMethodCodec.INSTANCE);
  }

  public sendMessage = (methodName: string, args: Any) => {
    this.methodChannel?.invokeMethod(methodName, args);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
    this.methodChannel = null;
    globalSplashBottomBuilder = undefined;
    OhosPlatformSplashView.splashBottomModule = null;
  }
}


@Builder
export function MyBuilder() {
  if (OhosPlatformSplashView.splashBottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${OhosPlatformSplashView.splashBottomModule?.imgChildren?.imageUrl}`))
        .width(OhosPlatformSplashView.splashBottomModule?.imgChildren?.width)
        .height(OhosPlatformSplashView.splashBottomModule?.imgChildren?.height)
        .offset({
          x: OhosPlatformSplashView.splashBottomModule?.imgChildren?.x,
          y: OhosPlatformSplashView.splashBottomModule?.imgChildren?.y
        })
      Text(OhosPlatformSplashView.splashBottomModule?.textChildren?.text)
        .fontColor(OhosPlatformSplashView.splashBottomModule?.textChildren?.color)
        .offset({
          x: OhosPlatformSplashView.splashBottomModule?.textChildren?.x,
          y: OhosPlatformSplashView.splashBottomModule?.textChildren?.y
        })
    }
    .backgroundColor(OhosPlatformSplashView.splashBottomModule?.backgroundColor)
    .height(OhosPlatformSplashView.splashBottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}


@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSSplashComponent(
    {
      params: params, adOption: OhosPlatformSplashView.adOptionsWeakRef?.deref() ?? defaultAdOption
    }
  )
}
