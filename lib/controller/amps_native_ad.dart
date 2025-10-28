import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_ad_video_play_config.dart';
import '../data/amps_native_Interactive_listener.dart';
import '../data/amps_ad.dart';
///原生广告类
class AMPSNativeAd {
  NativeType nativeType = NativeType.native;///默认原生模式【鸿蒙中原生和自渲染是一样的调用入口；Android是两个不同的入口，所以这里需要说明文档说明】
  AdOptions config;
  AmpsNativeAdListener? mCallBack;
  AMPSNativeRenderListener? mRenderCallBack;
  AmpsNativeInteractiveListener? mInteractiveCallBack;
  AmpsVideoPlayListener? mVideoPlayerCallBack;
  AdWidgetNeedCloseCall? mCloseWidgetCall;
  AMPSUnifiedDownloadListener? mDownloadListener;
  AMPSNativeAd(
      {required this.config,
      this.nativeType = NativeType.native,
      this.mCallBack,
      this.mRenderCallBack,
      this.mInteractiveCallBack,
      this.mVideoPlayerCallBack});

  void load() async {
    AmpsSdk.channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case AMPSNativeCallBackChannelMethod.loadOk:
            final List<String>? receivedList = call.arguments?.cast<String>();
            if (receivedList != null) {
              mCallBack?.loadOk?.call(receivedList);
            }
            break;
          case AMPSNativeCallBackChannelMethod.loadFail:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.loadFail?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSNativeCallBackChannelMethod.renderSuccess:
            mRenderCallBack?.renderSuccess?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.renderFailed:
            var map = call.arguments as Map<dynamic, dynamic>;
            mRenderCallBack?.renderFailed?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSNativeCallBackChannelMethod.onAdShow:
            mInteractiveCallBack?.onAdShow?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdExposure:
            mInteractiveCallBack?.onAdExposure?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdClicked:
            mInteractiveCallBack?.onAdClicked?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdClosed:
            mCloseWidgetCall?.call();
            mInteractiveCallBack?.toCloseAd?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoInit:
            mVideoPlayerCallBack?.onVideoInit?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoLoading:
            mVideoPlayerCallBack?.onVideoLoading?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoReady:
            mVideoPlayerCallBack?.onVideoReady?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoLoaded:
            mVideoPlayerCallBack?.onVideoLoaded?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayStart:
            mVideoPlayerCallBack?.onVideoPlayStart?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayComplete:
            mVideoPlayerCallBack?.onVideoPlayComplete?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPause:
            mVideoPlayerCallBack?.onVideoPause?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoResume:
            mVideoPlayerCallBack?.onVideoResume?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoStop:
            mVideoPlayerCallBack?.onVideoStop?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoClicked:
            mVideoPlayerCallBack?.onVideoClicked?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mVideoPlayerCallBack?.onVideoPlayError?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.extra]);
            break;
          case DownLoadCallBackChannelMethod.onInstalled:
            var adId = call.arguments as String;
            mDownloadListener?.onInstalled?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadFailed:
            var adId = call.arguments as String;
            mDownloadListener?.onDownloadFailed?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadStarted:
            var adId = call.arguments as String;
            mDownloadListener?.onDownloadStarted?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadFinished:
            var adId = call.arguments as String;
            mDownloadListener?.onDownloadFinished?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadProgressUpdate:
            var argMap = call.arguments as Map<dynamic, dynamic>;
            var position = argMap["position"] ?? 0;
            var adId = argMap["adId"] ?? "";
            mDownloadListener?.onDownloadProgressUpdate?.call(position, adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadPaused:
            var argMap = call.arguments as Map<dynamic, dynamic>;
            var position = argMap["position"] ?? 0;
            var adId = argMap["adId"] ?? "";
            mDownloadListener?.onDownloadPaused?.call(position, adId);
            break;
        }
      },
    );
    AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeLoad,
      config.toMap(nativeType: nativeType),
    );
  }
  ///获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    return await AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeIsReadyAd,adId);
  }
  ///获取ecpm
  Future<num> getECPM(String adId) async {
    return await AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeGetECPM,adId);
  }
  ///上报竞胜
  notifyRTBWin(double winPrice, double secPrice, String adId, {String? winAdnId}) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adAdId: adId,
      adWinAdnId: winAdnId
    };
    AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeNotifyRTBWin, args);
  }

  ///上报竞败
  notifyRTBLoss(double winPrice, double secPrice, String lossReason,String adId, {String? winAdnId}) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adLossReason: lossReason,
      adAdId: adId,
      adWinAdnId: winAdnId
    };
    AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeNotifyRTBLoss,args);
  }
  ///获取是否是自渲染
  Future<bool> isNativeExpress(String adId) async{
    return await AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeIsNativeExpress, adId);
  }
  ///获取视频播放时长
  Future<num> getVideoDuration(String adId) async{
    return await AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeGetVideoDuration, adId);
  }
  ///设置视频播放配置
  void setVideoPlayConfig(AMPSAdVideoPlayConfig videoPlayConfig) {
    AmpsSdk.channel.invokeMethod(AMPSAdSdkMethodNames.nativeSetVideoPlayConfig,
        videoPlayConfig.toJson());
  }


  void setAdCloseCallBack(AdWidgetNeedCloseCall? closeWidgetCall) {
    mCloseWidgetCall = closeWidgetCall;
  }

  void setDownloadListener(AMPSUnifiedDownloadListener? downloadListener) {
    mDownloadListener = downloadListener;
  }
}
