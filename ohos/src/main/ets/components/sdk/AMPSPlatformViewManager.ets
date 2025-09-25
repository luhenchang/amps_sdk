import { FlutterPluginBinding, StandardMessageCodec } from '@ohos/flutter_ohos';
import { AMPSPlatformViewRegistry } from '../data/common';
import { InterstitialFactory } from '../view/InterstitialFactory';
import { NativeFactory } from '../view/NativeFactory';
import { SplashFactory } from '../view/SplashFactory';
import { UnifiedFactory } from '../view/UnifiedFactory';

export class AMPSPlatformViewManager {
  private static sInstance: AMPSPlatformViewManager;

  private AMPSEventManger() {
  }

  static getInstance() {
    if (AMPSPlatformViewManager.sInstance == null) {
      AMPSPlatformViewManager.sInstance = new AMPSPlatformViewManager();
    }
    return AMPSPlatformViewManager.sInstance;
  }

  init(binding: FlutterPluginBinding) {
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkSplashViewId,
      new SplashFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
      new InterstitialFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkNativeViewId,
      new NativeFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
      new UnifiedFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
  }
}