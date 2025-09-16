import MethodChannel, {
  MethodCallHandler,
  MethodResult
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { AMPSSplashComponent } from './AMPSSplashComponent';
import { AMPSAdSdkMethodNames, AMPSPlatformViewRegistry, AD_OPTION } from '../data/common';
import { Any } from '@ohos/flutter_ohos';
import { ampsAd } from 'biz.beizi.adn';
import { AdOptionsModule } from '../data/AdOptionsModule';

@Observed
export class OhosPlatformSplashView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    // 注册消息通道，消息通道根据具体需求添加
    this.methodChannel =
      new MethodChannel(message, `${AMPSPlatformViewRegistry.ampsSdkSplashViewId}${viewId}`,
        StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  //接收来自Flutter的消息
  onMethodCall(call: MethodCall, result: MethodResult): void {
    let method: string = call.method;
    let splashLink: SubscribedAbstractProperty<ampsAd.AdOptions> = AppStorage.link(AD_OPTION);
    switch (method) {
      case AMPSAdSdkMethodNames.splashLoad:
        let adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
        splashLink.set(adOption)
        result.success(true);
        break;
    }
  }

  public sendMessage = (methodName: string, args: Any) => {
    this.methodChannel.invokeMethod(methodName, args);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
  }
}
@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSSplashComponent({ params: params })
}
