import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import { AMPSPlatformViewRegistry } from '../data/common';
import { Any } from '@ohos/flutter_ohos';
import { AMPSUnifiedAdComponent } from './AMPSUnifiedAdComponent';
import { NativeUnifiedModule } from '../data/UnifiedNativeModule';

@Observed
export class OhosPlatformUnifiedView extends PlatformView {
  methodChannel: MethodChannel | null | undefined
  static adId: string | undefined;
  static nativeUnifiedModule: NativeUnifiedModule | undefined;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    const channelName = `${AMPSPlatformViewRegistry.ampsSdkNativeViewId}${viewId}`;
    OhosPlatformUnifiedView.adId = args.get("posId");
    OhosPlatformUnifiedView.nativeUnifiedModule = new NativeUnifiedModule(args.get("unifiedWidget"));
    this.methodChannel = new MethodChannel(message, channelName, StandardMethodCodec.INSTANCE);
  }

  public sendMessage = (methodName: string, args: Any) => {
    this.methodChannel?.invokeMethod(methodName, args);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSUnifiedWrappedBuilder);
  }

  dispose(): void {
    this.methodChannel = null;
  }
}


@Builder
export function AMPSUnifiedWrappedBuilder(params: Params) {
  AMPSUnifiedAdComponent({
    params: params,
    adId: OhosPlatformUnifiedView.adId,
    unifiedModule: OhosPlatformUnifiedView.nativeUnifiedModule
  })
}
