import 'dart:io';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class InterstitialWidget extends StatefulWidget {
  final AMPSInterstitialAd? ad;
  const InterstitialWidget(this.ad, {super.key});

  @override
  State<StatefulWidget> createState() => _InterstitialWidgetState();
}

class _InterstitialWidgetState extends State<InterstitialWidget> {
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
          creationParams: param,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      return UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          creationParams: param,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    }
    else if(Platform.isOhos) {
      return OhosView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          creationParams: param,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec:  const StandardMessageCodec());
    }
    else {
      return const Center(child: Text("暂不支持此平台"));
    }
  }

  void _onPlatformViewCreated(int id) {
    widget.ad?.registerChannel(id);
  }
}
