import 'package:flutter/services.dart';

import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';

class AMPSInterstitialAd {
  AdOptions config;
  AdCallBack? mCallBack;
  AdCallBack? mViewCallBack;
  bool needLoad = false;

  AMPSInterstitialAd({required this.config, this.mCallBack});

  void registerChannel(int id) {
    var channel = MethodChannel('${AMPSPlatformViewRegistry.ampsSdkInterstitialViewId}$id');
    setMethodCallHandler(channel);
    channel.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad,
      config.toMap(),
    );
  }

  void setMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler(
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
    setMethodCallHandler(AmpsSdk.channel);
    await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad,
      config.toMap(),
    );
  }

  void showAd() async {
    await AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.interstitialShowAd);
  }
}
