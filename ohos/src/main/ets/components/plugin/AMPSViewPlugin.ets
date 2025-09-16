import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import StandardMessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMessageCodec';
import { AMPSPlatformViewRegistry } from '../data/common';
import { SplashFactory } from '../view/SplashFactory';

const uniqueClassName = "AMPSViewPlugin"

export class AMPSViewPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return uniqueClassName;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory(AMPSPlatformViewRegistry.ampsSdkSplashViewId,
      new SplashFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
  }
}
