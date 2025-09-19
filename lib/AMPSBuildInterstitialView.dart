import 'dart:io';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class AMPSBuildInterstitialView extends StatefulWidget {
  final AMPSInterstitialAd? ad;
  const AMPSBuildInterstitialView(this.ad, {super.key});

  @override
  State<StatefulWidget> createState() => _AMPSBuildInterstitialViewState();
}

class _AMPSBuildInterstitialViewState extends State<AMPSBuildInterstitialView> {
  var param = <dynamic, dynamic>{};
  @override
  void initState() {
    super.initState();
    param[splashConfig] = widget.ad?.config.toMap();
  }

  @override
  Widget build(BuildContext context) {
    return _getAmpsSplashView();
  }

  Widget _getAmpsSplashView() {
    if (Platform.isAndroid) {
      return AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          onPlatformViewCreated: _onPlatformViewCreated);
    } else if (Platform.isIOS) {
      return UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          onPlatformViewCreated: _onPlatformViewCreated);
    }
    else if(Platform.isOhos) {
      return OhosView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: param,
          creationParamsCodec:  const StandardMessageCodec());
    }
    else {
      return Container();
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.ad?.registerChannel(id);
  }
}
