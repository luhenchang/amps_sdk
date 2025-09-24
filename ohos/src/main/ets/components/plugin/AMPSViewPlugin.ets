import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { AMPSPlatformViewRegistry } from '../data/common';
import { InterstitialFactory } from '../view/InterstitialFactory';
import { NativeFactory } from '../view/NativeFactory';
import { SplashFactory } from '../view/SplashFactory';
import { UnifiedFactory } from '../view/UnifiedFactory';

const uniqueClassName = "AMPSViewPlugin"

export class AMPSViewPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return uniqueClassName;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory(AMPSPlatformViewRegistry.ampsSdkSplashViewId,
      new SplashFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry()?.registerViewFactory(AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
      new InterstitialFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry()?.registerViewFactory(AMPSPlatformViewRegistry.ampsSdkNativeViewId,
      new NativeFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry()?.registerViewFactory(AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
      new UnifiedFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }
}
