import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AMPSUnifiedAdComponent } from './AMPSUnifiedAdComponent';
import { NativeUnifiedModule } from '../data/UnifiedNativeModule';

@Observed
export class OhosPlatformUnifiedView extends PlatformView {
  adId?: string;
  nativeUnifiedModule?: NativeUnifiedModule;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    this.adId = args.get('adId');
    this.nativeUnifiedModule = new NativeUnifiedModule(args.get('unifiedWidget'));
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSUnifiedWrappedBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSUnifiedWrappedBuilder(params: Params) {
  const platformView = params.platformView as OhosPlatformUnifiedView;
  AMPSUnifiedAdComponent({
    params: params,
    adId: platformView.adId,
    unifiedModule: platformView.nativeUnifiedModule,
  });
}
