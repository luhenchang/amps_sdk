import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AMPSNativeAdWrapper } from 'biz.beizi.adn';
import { AdWrapperManager } from '../manager/AdWrapperManager';
import { AMPSNativeAdComponent } from './AMPSNativeAdComponent';

@Observed
export class OhosPlatformNativeView extends PlatformView {
  adId?: string;
  wrapper?: AMPSNativeAdWrapper;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    this.adId = args.get('adId');
    if (this.adId) {
      this.wrapper = AdWrapperManager.getInstance().getAd(this.adId);
    }
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSNativeWrappedBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSNativeWrappedBuilder(params: Params) {
  const platformView = params.platformView as OhosPlatformNativeView;
  AMPSNativeAdComponent({ params: params, adId: platformView.adId ?? '' });
}
