import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/widgets/blurred_background.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class SplashShowPage extends StatefulWidget {
  const SplashShowPage({super.key, required this.title});

  final String title;

  @override
  State<SplashShowPage> createState() => _SplashShowPageState();
}

class _SplashShowPageState extends State<SplashShowPage> {
  late AMPSIInitCallBack _callBack;
  AMPSSplashAd? _splashAd;
  late AdCallBack _adCallBack;
  bool initSuccess = false;
  bool couldBack = true;
  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _adCallBack = AdCallBack(onRenderOk: () {
      _splashAd?.showAd(
          splashBottomWidget: SplashBottomWidget(
              height: 100.0,
              backgroundColor: "#FFFFFFFF",
              children: [
            ImageComponent(
              width: 25,
              height: 25,
              x: 170,
              y: 10,
              imageUrl: 'assets/images/img.png',
            ),
            TextComponent(
              fontSize: 24,
              color: "#00ff00",
              x: 140,
              y: 50,
              text: 'Hello Android!',
            ),
          ]));
      debugPrint("ad load onRenderOk");
    }, onLoadFailure: (code, msg) {
      debugPrint("ad load failure=$code;$msg");
    }, onAdClicked: () {
      setState(() {
        couldBack = true;
      });
      debugPrint("ad load onAdClicked");
    }, onAdExposure: () {
      setState(() {
        couldBack = false;
      });
      debugPrint("ad load onAdExposure");
    }, onAdClosed: () {
      setState(() {
        couldBack = true;
      });
      debugPrint("ad load onAdClosed");
    }, onAdReward: () {
      debugPrint("ad load onAdReward");
    }, onAdShow: () {
      debugPrint("ad load onAdShow");
    }, onAdShowError: (code, msg) {
      debugPrint("ad load onAdShowError");
    }, onRenderFailure: () {
      debugPrint("ad load onRenderFailure");
    }, onVideoPlayStart: () {
      debugPrint("ad load onVideoPlayStart");
    }, onVideoPlayError: (code, msg) {
      debugPrint("ad load onVideoPlayError");
    }, onVideoPlayEnd: () {
      debugPrint("ad load onVideoPlayEnd");
    }, onVideoSkipToEnd: (duration) {
      debugPrint("ad load onVideoSkipToEnd=$duration");
    });

    AdOptions options =
        AdOptions(spaceId: '15288', splashAdBottomBuilderHeight: 200);
    _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: couldBack,
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                const BlurredBackground(),
                Column(
                  children: [
                    const SizedBox(height: 100, width: 0),
                    ButtonWidget(
                        buttonText: '点击加载开屏页面',
                        callBack: () {
                          // 使用命名路由跳转
                          _splashAd?.load();
                        }),
                  ],
                )
              ],
            )));
  }
}
