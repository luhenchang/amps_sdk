import 'package:flutter/services.dart';

import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';

class AMPSInterstitialAd {
  AdOptions config;
  AdCallBack? mCallBack;
  bool needLoad = false;

  MethodChannel? _channel;

  AMPSInterstitialAd({required this.config, this.mCallBack});

  void registerChannel(int id,AdWidgetNeedCloseCall? closeWidgetCall) {
    _channel = MethodChannel('${AMPSPlatformViewRegistry.ampsSdkInterstitialViewId}$id');
    setMethodCallHandler(closeWidgetCall);
  }

  void setMethodCallHandler(AdWidgetNeedCloseCall? closeWidgetCall) {
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
            mCallBack?.onRenderOk?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShow:
            mCallBack?.onAdShow?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdExposure:
            mCallBack?.onAdExposure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClicked:
            closeWidgetCall?.call();
            mCallBack?.onAdClicked?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClosed:
            closeWidgetCall?.call();
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
    _channel = AmpsSdk.channel;
    setMethodCallHandler(null);
    await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad,
      config.toMap(),
    );
  }

  void showAd() async {
    await _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialShowAd);
  }

  Future<bool> isReadyAd() async {
    return await _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialIsReadyAd);
  }

  Future<num> getECPM() async {
    return await _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialGetECPM);
  }

  notifyRTBWin(double winPrice, double secPrice) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
    };
    _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialNotifyRTBWin, args);
  }

  notifyRTBLoss(double winPrice, double secPrice, String lossReason) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adLossReason: lossReason,
    };
    _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialNotifyRTBLoss,args);
  }
}
