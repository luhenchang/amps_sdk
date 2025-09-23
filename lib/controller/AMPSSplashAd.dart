import 'package:flutter/services.dart';

import '../common.dart';
import '../data/ampsAd.dart';
import '../widget/splash_bottom_widget.dart';

class AMPSSplashAd {
  MethodChannel? _channel;
  AdOptions config;
  AdCallBack? mCallBack;
  AdCallBack? mViewCallBack;

  AMPSSplashAd({required this.config, this.mCallBack});

  setAMPSViewCallBack (AdCallBack viewCallBack) {
    mViewCallBack = viewCallBack;
  }
  void registerChannel(int id) {
    _channel = null;
    _channel = MethodChannel('${AMPSPlatformViewRegistry.ampsSdkSplashViewId}$id');
    setMethodCallHandler();
    _channel?.invokeMethod(
      AMPSAdSdkMethodNames.splashLoad,
      config.toMap(),
    );
  }

  void setMethodCallHandler() {
    _channel?.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case AMPSAdCallBackChannelMethod.onLoadSuccess:
            mCallBack?.onLoadSuccess?.call();
            break;
          case AMPSAdCallBackChannelMethod.onLoadFailure:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onLoadFailure?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onRenderOk:
            mViewCallBack?.onRenderOk?.call();
            mCallBack?.onRenderOk?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShow:
            mCallBack?.onAdShow?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdExposure:
            mCallBack?.onAdExposure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClicked:
            mCallBack?.onAdClicked?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClosed:
            mViewCallBack?.onAdClosed?.call();
            mCallBack?.onAdClosed?.call();
            break;
          case AMPSAdCallBackChannelMethod.onRenderFailure:
            mCallBack?.onRenderFailure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShowError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onAdShowError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayStart:
            mCallBack?.onVideoPlayStart?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayEnd:
            mCallBack?.onVideoPlayEnd?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onVideoPlayError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoSkipToEnd:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onVideoSkipToEnd?.call(map[AMPSSdkCallBackParamsKey.playDurationMs]);
            break;
          case AMPSAdCallBackChannelMethod.onAdReward:
            mCallBack?.onAdReward?.call();
            break;
        }
      },
    );
  }

  void load() async {
    _channel = const MethodChannel(AMPSChannels.ampsSdkSplashAdLoad);
    setMethodCallHandler();
    await _channel?.invokeMethod(
      AMPSAdSdkMethodNames.splashLoad,
      config.toMap(),
    );
  }

  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    await _channel?.invokeMethod(AMPSAdSdkMethodNames.splashShowAd, splashBottomWidget?.toMap());
  }
}
