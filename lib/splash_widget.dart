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
  @override
  void initState() {
    super.initState();
    splashParam[splashConfig] = widget.adSplash?.config.toMap();
    splashParam[splashBottomView] = widget.splashBottomWidget?.toMap();
  }

  @override
  Widget build(BuildContext context) {
    return _getAmpsSplashView();
  }

  Widget _getAmpsSplashView() {
    if (Platform.isAndroid) {
      return AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          creationParams: splashParam,
          onPlatformViewCreated: _onPlatformViewCreated);
    } else if (Platform.isIOS) {
      return UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          creationParams: splashParam,
          onPlatformViewCreated: _onPlatformViewCreated);
    }
    else if(Platform.isOhos) {
      return OhosView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: splashParam,
          creationParamsCodec:  const StandardMessageCodec());
    }
    else {
      return const Center(child: Text("暂不支持此平台"));
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.adSplash?.registerChannel(id);
  }
}
