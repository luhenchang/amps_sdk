import 'package:flutter/services.dart';

import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../data/amps_channel_dispatcher.dart';
import '../widget/splash_bottom_widget.dart';

/// 开屏广告类
class AMPSSplashAd {
  final AdOptions config;
  AdCallBack? mCallBack;

  final String _instanceId;
  MethodChannel? _channel;

  static int _idCounter = 0;
  static final Map<String, AMPSSplashAd> _instances = <String, AMPSSplashAd>{};
  static bool _dispatcherRegistered = false;

  static String _generateInstanceId() {
    _idCounter++;
    return 'splash_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  AMPSSplashAd({required this.config, this.mCallBack})
      : _instanceId = _generateInstanceId() {
    _ensureDispatcherRegistered();
    _instances[_instanceId] = this;
  }

  String get instanceId => _instanceId;

  void registerChannel(int id, AdWidgetNeedCloseCall? closeWidgetCall) {
    _channel = MethodChannel('${AMPSPlatformViewRegistry.ampsSdkSplashViewId}$id');
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
            closeWidgetCall?.call('');
            mCallBack?.onAdClicked?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClosed:
            closeWidgetCall?.call('');
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

  static void _ensureDispatcherRegistered() {
    if (_dispatcherRegistered) return;
    _dispatcherRegistered = true;
    AmpsChannelDispatcher.register(_handleChannelCall);
  }

  static Future<void> _handleChannelCall(MethodCall call) async {
    switch (call.method) {
      case AMPSAdCallBackChannelMethod.onLoadSuccess:
      case AMPSAdCallBackChannelMethod.onLoadFailure:
      case AMPSAdCallBackChannelMethod.onRenderOk:
      case AMPSAdCallBackChannelMethod.onAdShow:
      case AMPSAdCallBackChannelMethod.onAdExposure:
      case AMPSAdCallBackChannelMethod.onAdClicked:
      case AMPSAdCallBackChannelMethod.onAdClosed:
      case AMPSAdCallBackChannelMethod.onRenderFailure:
      case AMPSAdCallBackChannelMethod.onAdShowError:
      case AMPSAdCallBackChannelMethod.onVideoPlayStart:
      case AMPSAdCallBackChannelMethod.onVideoPlayEnd:
      case AMPSAdCallBackChannelMethod.onVideoPlayError:
      case AMPSAdCallBackChannelMethod.onVideoSkipToEnd:
      case AMPSAdCallBackChannelMethod.onAdReward:
        break;
      default:
        return;
    }
    final id = AmpsChannelDispatcher.extractInstanceId(call);
    if (id == null) return;
    final instance = _instances[id];
    if (instance == null) return;
    final data = AmpsChannelDispatcher.extractData(call);
    switch (call.method) {
      case AMPSAdCallBackChannelMethod.onLoadSuccess:
        instance.mCallBack?.onLoadSuccess?.call();
        break;
      case AMPSAdCallBackChannelMethod.onLoadFailure:
        if (data is Map) {
          instance.mCallBack?.onLoadFailure?.call(
            data[AMPSSdkCallBackErrorKey.code],
            data[AMPSSdkCallBackErrorKey.message],
          );
        }
        break;
      case AMPSAdCallBackChannelMethod.onRenderOk:
        instance.mCallBack?.onRenderOk?.call();
        break;
      case AMPSAdCallBackChannelMethod.onAdShow:
        instance.mCallBack?.onAdShow?.call();
        break;
      case AMPSAdCallBackChannelMethod.onAdExposure:
        instance.mCallBack?.onAdExposure?.call();
        break;
      case AMPSAdCallBackChannelMethod.onAdClicked:
        instance.mCallBack?.onAdClicked?.call();
        break;
      case AMPSAdCallBackChannelMethod.onAdClosed:
        instance.mCallBack?.onAdClosed?.call();
        break;
      case AMPSAdCallBackChannelMethod.onRenderFailure:
        instance.mCallBack?.onRenderFailure?.call();
        break;
      case AMPSAdCallBackChannelMethod.onAdShowError:
        if (data is Map) {
          instance.mCallBack?.onAdShowError?.call(
            data[AMPSSdkCallBackErrorKey.code],
            data[AMPSSdkCallBackErrorKey.message],
          );
        }
        break;
      case AMPSAdCallBackChannelMethod.onVideoPlayStart:
        instance.mCallBack?.onVideoPlayStart?.call();
        break;
      case AMPSAdCallBackChannelMethod.onVideoPlayEnd:
        instance.mCallBack?.onVideoPlayEnd?.call();
        break;
      case AMPSAdCallBackChannelMethod.onVideoPlayError:
        if (data is Map) {
          instance.mCallBack?.onVideoPlayError?.call(
            data[AMPSSdkCallBackErrorKey.code],
            data[AMPSSdkCallBackErrorKey.message],
          );
        }
        break;
      case AMPSAdCallBackChannelMethod.onVideoSkipToEnd:
        if (data is Map) {
          instance.mCallBack?.onVideoSkipToEnd?.call(
            data[AMPSSdkCallBackParamsKey.playDurationMs],
          );
        }
        break;
      case AMPSAdCallBackChannelMethod.onAdReward:
        instance.mCallBack?.onAdReward?.call();
        break;
      default:
        break;
    }
  }

  /// 开屏广告加载调用
  void load() async {
    _channel = AmpsSdk.channel;
    await _channel?.invokeMethod(
      AMPSAdSdkMethodNames.splashLoad,
      {
        ...config.toMap(),
        AmpsChannelDispatcher.kInstanceId: _instanceId,
      },
    );
  }

  /// 开屏广告显示调用
  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    await _channel?.invokeMethod(
      AMPSAdSdkMethodNames.splashShowAd,
      {
        AmpsChannelDispatcher.kInstanceId: _instanceId,
        ...?splashBottomWidget?.toMap(),
      },
    );
  }

  /// 开屏广告是否有预加载
  Future<bool> isReadyAd() async {
    return await _channel?.invokeMethod(
      AMPSAdSdkMethodNames.splashIsReadyAd,
      AmpsChannelDispatcher.payload(_instanceId),
    );
  }

  /// 获取ecpm
  Future<num> getECPM() async {
    return await _channel?.invokeMethod(
      AMPSAdSdkMethodNames.splashGetECPM,
      AmpsChannelDispatcher.payload(_instanceId),
    );
  }

  /// 上报竞胜
  notifyRTBWin(double winPrice, double secPrice, {String? winAdnId}) {
    _channel?.invokeMethod(AMPSAdSdkMethodNames.splashNotifyRTBWin, {
      AmpsChannelDispatcher.kInstanceId: _instanceId,
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adWinAdnId: winAdnId,
    });
  }

  /// 上报竞败
  notifyRTBLoss(double winPrice, double secPrice, String lossReason, {String? winAdnId}) {
    _channel?.invokeMethod(AMPSAdSdkMethodNames.splashNotifyRTBLoss, {
      AmpsChannelDispatcher.kInstanceId: _instanceId,
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adLossReason: lossReason,
      adWinAdnId: winAdnId,
    });
  }
}
