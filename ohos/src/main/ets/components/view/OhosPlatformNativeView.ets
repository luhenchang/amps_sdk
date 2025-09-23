import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import { AMPSPlatformViewRegistry, SPLASH_CONFIG } from '../data/common';
import { Any } from '@ohos/flutter_ohos';
import { AMPSNativeAdWrapper } from 'biz.beizi.adn';
import { AdWrapperManager } from '../manager/AdWrapperManager';
import { AMPSNativeAdComponent } from './AMPSNativeAdComponent';

@Observed
export class OhosPlatformNativeView extends PlatformView {
  methodChannel: MethodChannel | null | undefined
  static adId: string | undefined;
  static wrapper: AMPSNativeAdWrapper | undefined
  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    const channelName = `${AMPSPlatformViewRegistry.ampsSdkNativeViewId}${viewId}`;
    OhosPlatformNativeView.adId = args.get("posId")
    this.methodChannel = new MethodChannel(message, channelName, StandardMethodCodec.INSTANCE);
    if (OhosPlatformNativeView.adId) {
      OhosPlatformNativeView.wrapper = AdWrapperManager.getInstance().getAd(OhosPlatformNativeView.adId)
    }
  }

  public sendMessage = (methodName: string, args: Any) => {
    this.methodChannel?.invokeMethod(methodName, args);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSNativeWrappedBuilder);
  }

  dispose(): void {
    this.methodChannel = null;
  }
}


@Builder
export function AMPSNativeWrappedBuilder(params: Params) {
  AMPSNativeAdComponent({ params: params, adId: OhosPlatformNativeView.adId })
}
