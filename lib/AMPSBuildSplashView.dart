import 'dart:io';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class AMPSBuildSplashView extends StatefulWidget {
  final AMPSSplashAd? adSplash;
  final SplashBottomWidget? splashBottomWidget;
  const AMPSBuildSplashView(this.adSplash, {super.key,this.splashBottomWidget});

  @override
  State<StatefulWidget> createState() => _AMPSBuildSplashViewState();
}

class _AMPSBuildSplashViewState extends State<AMPSBuildSplashView> {
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
      return Container();
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.adSplash?.registerChannel(id);
  }
}
