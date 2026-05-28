import 'package:flutter/services.dart';

import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../data/amps_ad_video_play_config.dart';
import '../data/amps_channel_dispatcher.dart';
import '../data/amps_native_Interactive_listener.dart';

/// 原生广告类
class AMPSNativeAd {
  NativeType nativeType = NativeType.native;
  final AdOptions config;
  AmpsNativeAdListener? mCallBack;
  AMPSNativeRenderListener? mRenderCallBack;
  AmpsNativeInteractiveListener? mInteractiveCallBack;
  AmpsVideoPlayListener? mVideoPlayerCallBack;
  AdWidgetNeedCloseCall? mCloseWidgetCall;
  AMPSUnifiedDownloadListener? mDownloadListener;

  final String _instanceId;

  static int _idCounter = 0;
  static final Map<String, AMPSNativeAd> _instances = <String, AMPSNativeAd>{};
  static bool _dispatcherRegistered = false;

  static String _generateInstanceId() {
    _idCounter++;
    return 'native_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  AMPSNativeAd({
    required this.config,
    this.nativeType = NativeType.native,
    this.mCallBack,
    this.mRenderCallBack,
    this.mInteractiveCallBack,
    this.mVideoPlayerCallBack,
  }) : _instanceId = _generateInstanceId() {
    _ensureDispatcherRegistered();
    _instances[_instanceId] = this;
  }

  String get instanceId => _instanceId;

  static void _ensureDispatcherRegistered() {
    if (_dispatcherRegistered) return;
    _dispatcherRegistered = true;
    AmpsChannelDispatcher.register(_handleChannelCall);
  }

  static Future<void> _handleChannelCall(MethodCall call) async {
    switch (call.method) {
      case AMPSNativeCallBackChannelMethod.loadOk:
      case AMPSNativeCallBackChannelMethod.loadFail:
      case AMPSNativeCallBackChannelMethod.renderSuccess:
      case AMPSNativeCallBackChannelMethod.renderFailed:
      case AMPSNativeCallBackChannelMethod.onAdShow:
      case AMPSNativeCallBackChannelMethod.onAdExposure:
      case AMPSNativeCallBackChannelMethod.onAdClicked:
      case AMPSNativeCallBackChannelMethod.onAdClosed:
      case AMPSNativeCallBackChannelMethod.onVideoInit:
      case AMPSNativeCallBackChannelMethod.onVideoLoading:
      case AMPSNativeCallBackChannelMethod.onVideoReady:
      case AMPSNativeCallBackChannelMethod.onVideoLoaded:
      case AMPSNativeCallBackChannelMethod.onVideoPlayStart:
      case AMPSNativeCallBackChannelMethod.onVideoPlayComplete:
      case AMPSNativeCallBackChannelMethod.onVideoPause:
      case AMPSNativeCallBackChannelMethod.onVideoResume:
      case AMPSNativeCallBackChannelMethod.onVideoStop:
      case AMPSNativeCallBackChannelMethod.onVideoClicked:
      case AMPSNativeCallBackChannelMethod.onVideoPlayError:
      case DownLoadCallBackChannelMethod.onInstalled:
      case DownLoadCallBackChannelMethod.onDownloadFailed:
      case DownLoadCallBackChannelMethod.onDownloadStarted:
      case DownLoadCallBackChannelMethod.onDownloadFinished:
      case DownLoadCallBackChannelMethod.onDownloadProgressUpdate:
      case DownLoadCallBackChannelMethod.onDownloadPaused:
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
      case AMPSNativeCallBackChannelMethod.loadOk:
        if (data is List) {
          instance.mCallBack?.loadOk?.call(data.cast<String>());
        }
        break;
      case AMPSNativeCallBackChannelMethod.loadFail:
        if (data is Map) {
          instance.mCallBack?.loadFail?.call(
            data[AMPSSdkCallBackErrorKey.code],
            data[AMPSSdkCallBackErrorKey.message],
          );
        }
        break;
      case AMPSNativeCallBackChannelMethod.renderSuccess:
        instance.mRenderCallBack?.renderSuccess?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.renderFailed:
        if (data is Map) {
          instance.mRenderCallBack?.renderFailed?.call(
            data[AMPSSdkCallBackErrorKey.adId],
            data[AMPSSdkCallBackErrorKey.code],
            data[AMPSSdkCallBackErrorKey.message],
          );
        }
        break;
      case AMPSNativeCallBackChannelMethod.onAdShow:
        instance.mInteractiveCallBack?.onAdShow?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onAdExposure:
        instance.mInteractiveCallBack?.onAdExposure?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onAdClicked:
        instance.mInteractiveCallBack?.onAdClicked?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onAdClosed:
        final adId = data as String?;
        if (adId != null) {
          instance.mCloseWidgetCall?.call(adId);
          instance.mInteractiveCallBack?.toCloseAd?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoInit:
        instance.mVideoPlayerCallBack?.onVideoInit?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoLoading:
        instance.mVideoPlayerCallBack?.onVideoLoading?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoReady:
        instance.mVideoPlayerCallBack?.onVideoReady?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoLoaded:
        instance.mVideoPlayerCallBack?.onVideoLoaded?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPlayStart:
        instance.mVideoPlayerCallBack?.onVideoPlayStart?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPlayComplete:
        instance.mVideoPlayerCallBack?.onVideoPlayComplete?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPause:
        instance.mVideoPlayerCallBack?.onVideoPause?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoResume:
        instance.mVideoPlayerCallBack?.onVideoResume?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoStop:
        instance.mVideoPlayerCallBack?.onVideoStop?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoClicked:
        instance.mVideoPlayerCallBack?.onVideoClicked?.call(data);
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPlayError:
        if (data is Map) {
          instance.mVideoPlayerCallBack?.onVideoPlayError?.call(
            data[AMPSSdkCallBackErrorKey.adId],
            data[AMPSSdkCallBackErrorKey.code],
            data[AMPSSdkCallBackErrorKey.extra],
          );
        }
        break;
      case DownLoadCallBackChannelMethod.onInstalled:
        if (data is String) {
          instance.mDownloadListener?.onInstalled?.call(data);
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadFailed:
        if (data is String) {
          instance.mDownloadListener?.onDownloadFailed?.call(data);
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadStarted:
        if (data is String) {
          instance.mDownloadListener?.onDownloadStarted?.call(data);
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadFinished:
        if (data is String) {
          instance.mDownloadListener?.onDownloadFinished?.call(data);
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadProgressUpdate:
        if (data is Map) {
          instance.mDownloadListener?.onDownloadProgressUpdate?.call(
            data['position'] ?? 0,
            data['adId'] ?? '',
          );
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadPaused:
        if (data is Map) {
          instance.mDownloadListener?.onDownloadPaused?.call(
            data['position'] ?? 0,
            data['adId'] ?? '',
          );
        }
        break;
      default:
        break;
    }
  }

  void load() async {
    await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeLoad,
      {
        ...config.toMap(nativeType: nativeType),
        AmpsChannelDispatcher.kInstanceId: _instanceId,
      },
    );
  }

  /// 获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    return await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeIsReadyAd,
      AmpsChannelDispatcher.payload(_instanceId, adId),
    );
  }

  /// 获取ecpm
  Future<num> getECPM(String adId) async {
    return await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeGetECPM,
      AmpsChannelDispatcher.payload(_instanceId, adId),
    );
  }

  /// 上报竞胜
  notifyRTBWin(double winPrice, double secPrice, String adId, {String? winAdnId}) {
    AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeNotifyRTBWin, {
      AmpsChannelDispatcher.kInstanceId: _instanceId,
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adAdId: adId,
      adWinAdnId: winAdnId,
    });
  }

  /// 上报竞败
  notifyRTBLoss(double winPrice, double secPrice, String lossReason, String adId, {String? winAdnId}) {
    AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeNotifyRTBLoss, {
      AmpsChannelDispatcher.kInstanceId: _instanceId,
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adLossReason: lossReason,
      adAdId: adId,
      adWinAdnId: winAdnId,
    });
  }

  /// 获取是否是自渲染
  Future<bool> isNativeExpress(String adId) async {
    return await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeIsNativeExpress,
      AmpsChannelDispatcher.payload(_instanceId, adId),
    );
  }

  /// 获取视频播放时长
  Future<num> getVideoDuration(String adId) async {
    return await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeGetVideoDuration,
      AmpsChannelDispatcher.payload(_instanceId, adId),
    );
  }

  /// 设置视频播放配置
  void setVideoPlayConfig(AMPSAdVideoPlayConfig videoPlayConfig) {
    AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeSetVideoPlayConfig,
      {
        AmpsChannelDispatcher.kInstanceId: _instanceId,
        ...videoPlayConfig.toJson(),
      },
    );
  }

  void setAdCloseCallBack(AdWidgetNeedCloseCall? closeWidgetCall) {
    mCloseWidgetCall = closeWidgetCall;
  }

  void setDownloadListener(AMPSUnifiedDownloadListener? downloadListener) {
    mDownloadListener = downloadListener;
  }
}
