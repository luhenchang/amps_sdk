import 'package:flutter/services.dart';
import '../common.dart';
import '../data/AMPSNativeInteractiveListener.dart';
import '../data/ampsAd.dart';

class AMPSNativeAd {
  MethodChannel? _channel;
  MethodChannel? _viewChannel;
  AdOptions config;
  AmpsNativeAdListener? mCallBack;
  AMPSNativeRenderListener? mRenderCallBack;
  AmpsNativeInteractiveListener? mInteractiveCallBack;
  AmpsVideoPlayListener? mVideoPlayerCallBack;

  AMPSNativeAd(
      {required this.config,
      this.mCallBack,
      this.mRenderCallBack,
      this.mInteractiveCallBack,
      this.mVideoPlayerCallBack});

  void registerChannel(int id) {
    _viewChannel = null;
    _viewChannel =
        MethodChannel('${AMPSPlatformViewRegistry.ampsSdkNativeViewId}$id');
    setMethodCallHandler();
  }

  void setMethodCallHandler() {
    _viewChannel?.setMethodCallHandler(
      (call) async {
        switch (call.method) {}
      },
    );
  }

  void load() async {
    _channel = const MethodChannel(AMPSChannels.ampsSdkNativeAdLoad);
    _channel?.setMethodCallHandler(
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
            mInteractiveCallBack?.toCloseAd?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoReady:
            mVideoPlayerCallBack?.onVideoReady?.call(call.arguments);
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
          case AMPSNativeCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mVideoPlayerCallBack?.onVideoPlayError?.call(
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.extra]);
            break;
        }
      },
    );
    _channel?.invokeMethod(
      AMPSAdSdkMethodNames.nativeLoad,
      config.toMap(),
    );
  }

}
