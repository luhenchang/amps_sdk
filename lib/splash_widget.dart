import 'dart:io';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class SplashWidget extends StatefulWidget {
  final AMPSSplashAd? adSplash;
  final SplashBottomWidget? splashBottomWidget;
  const SplashWidget(this.adSplash, {super.key,this.splashBottomWidget});

  @override
  State<StatefulWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  var splashParam = <dynamic, dynamic>{};

  bool splashNeedClose = false;
  @override
  void initState() {
    super.initState();
    splashParam[splashConfig] = widget.adSplash?.config.toMap();
    splashParam[splashBottomView] = widget.splashBottomWidget?.toMap();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return _getAmpsSplashView();
  // }
  //
  // Widget _getAmpsSplashView() {
  //   if (Platform.isAndroid) {
  //     return AndroidView(
  //         viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
  //         creationParams: splashParam,
  //         onPlatformViewCreated: _onPlatformViewCreated);
  //   } else if (Platform.isIOS) {
  //     return UiKitView(
  //         viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
  //         creationParams: splashParam,
  //         onPlatformViewCreated: _onPlatformViewCreated);
  //   }
  //   else if(Platform.isOhos) {
  //     return OhosView(
  //         viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
  //         onPlatformViewCreated: _onPlatformViewCreated,
  //         creationParams: splashParam,
  //         creationParamsCodec:  const StandardMessageCodec());
  //   }
  //   else {
  //     return const Center(child: Text("暂不支持此平台"));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (splashNeedClose) {
      return const SizedBox.shrink();
    }
    Widget view;
    if (Platform.isAndroid) {
      view = AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          creationParams: splashParam,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      view =  UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          creationParams: splashParam,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isOhos) {
      view =  OhosView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: splashParam,
          creationParamsCodec: const StandardMessageCodec());
    } else {
      view =  const Center(child: Text("暂不支持此平台"));
    }
    // 有宽高信息了（渲染成功了）设置对应宽高
    return view;
  }

  void _onPlatformViewCreated(int id) {
    registerChannel(id);
  }

  void registerChannel(int id) {
   var channel = MethodChannel('${AMPSPlatformViewRegistry.ampsSdkSplashViewId}$id');
    setMethodCallHandler(channel);
  }

  void setMethodCallHandler(MethodChannel channel) {
    channel.setMethodCallHandler(
          (call) async {
        switch (call.method) {
          case AMPSAdCallBackChannelMethod.onLoadSuccess:
            widget.adSplash?.mCallBack?.onLoadSuccess?.call();
            break;
          case AMPSAdCallBackChannelMethod.onLoadFailure:
            var map = call.arguments as Map<dynamic, dynamic>;
            widget.adSplash?.mCallBack?.onLoadFailure?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onRenderOk:
            widget.adSplash?.mCallBack?.onRenderOk?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShow:
            widget.adSplash?.mCallBack?.onAdShow?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdExposure:
            widget.adSplash?.mCallBack?.onAdExposure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClicked:
            setState(() {
              splashNeedClose = true;
            });
            widget.adSplash?.mCallBack?.onAdClicked?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClosed:
            setState(() {
              splashNeedClose = true;
            });
            widget.adSplash?.mCallBack?.onAdClosed?.call();
            break;
          case AMPSAdCallBackChannelMethod.onRenderFailure:
            widget.adSplash?.mCallBack?.onRenderFailure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShowError:
            var map = call.arguments as Map<dynamic, dynamic>;
            widget.adSplash?.mCallBack?.onAdShowError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayStart:
            widget.adSplash?.mCallBack?.onVideoPlayStart?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayEnd:
            widget.adSplash?.mCallBack?.onVideoPlayEnd?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            widget.adSplash?.mCallBack?.onVideoPlayError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoSkipToEnd:
            var map = call.arguments as Map<dynamic, dynamic>;
            widget.adSplash?.mCallBack?.onVideoSkipToEnd?.call(map[AMPSSdkCallBackParamsKey.playDurationMs]);
            break;
          case AMPSAdCallBackChannelMethod.onAdReward:
            widget.adSplash?.mCallBack?.onAdReward?.call();
            break;
        }
      },
    );
  }
}
