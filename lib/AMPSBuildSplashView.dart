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
    return  _getAmpsSplashView();
  }

  Widget _getAmpsSplashView() {
    return AndroidView(
      viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
      onPlatformViewCreated: _onPlatformViewCreated
    );
  }

  void _onPlatformViewCreated(int id) {
    widget.adSplash?.registerChannel(id);
  }
}
