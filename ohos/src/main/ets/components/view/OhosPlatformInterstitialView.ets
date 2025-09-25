import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import { AMPSPlatformViewRegistry, defaultAdOption, CONFIG } from '../data/common';
import { Any, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd } from 'biz.beizi.adn';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { AMPSInterstitialComponent } from './AMPSInterstitialComponent';

@Observed
export class OhosPlatformInterstitialView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel | null | undefined
  static adOptionsWeakRef: WeakRef<ampsAd.AdOptions> | undefined;
  currentResult?: MethodResult
  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    const channelName = `${AMPSPlatformViewRegistry.ampsSdkInterstitialViewId}${viewId}`;
    OhosPlatformInterstitialView.adOptionsWeakRef = new WeakRef(AdOptionsModule.getAdOptionFromMap(args.get(CONFIG)));
    this.methodChannel = new MethodChannel(message, channelName, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.currentResult = result;
    let method: string = call.method;
    switch (method) {
    }
  }

  public sendMessage = (methodName: string, args: Any) => {
    this.methodChannel?.invokeMethod(methodName, args);
  }


  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
    this.methodChannel = null;
  }
}

@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSInterstitialComponent(
    {
      params: params, adOption: OhosPlatformInterstitialView.adOptionsWeakRef?.deref() ?? defaultAdOption
    }
  )
}
