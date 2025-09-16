import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'common.dart';
import 'controller/AMPSSplashAd.dart';

class AMPSBuildSplashView extends StatefulWidget {
  final AMPSSplashAd? adSplash;

  const AMPSBuildSplashView(this.adSplash, {super.key});

  @override
  State<StatefulWidget> createState() => _AMPSBuildSplashViewState();
}

class _AMPSBuildSplashViewState extends State<AMPSBuildSplashView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _getAmpsSplashView();
  }

  Widget _getAmpsSplashView() {
    if (Platform.isAndroid) {
      return AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          onPlatformViewCreated: _onPlatformViewCreated);
    } else if (Platform.isIOS) {
      return UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          onPlatformViewCreated: _onPlatformViewCreated);
    } else {
      return Container();
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.adSplash?.registerChannel(id);
  }
}
