import 'package:amps_sdk_example/widgets/blurred_background.dart';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class SplashWidgetPage extends StatefulWidget {
  const SplashWidgetPage({super.key, required this.title});

  final String title;

  @override
  State<SplashWidgetPage> createState() => _SplashWidgetPageState();
}

class _SplashWidgetPageState extends State<SplashWidgetPage> {
  AMPSSplashAd? _splashAd;
  late AdCallBack _adCallBack;
  bool splashVisible = false;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _adCallBack = AdCallBack(onRenderOk: () {
      setState(() {
        splashVisible = true;
      });
      debugPrint("ad load onRenderOk");
    },onAdClicked: () {
      setState(() {
        splashVisible = false;
      });
      debugPrint("ad load onAdClicked");
    }, onAdClosed: () {
      setState(() {
        splashVisible = false;
      });
      debugPrint("ad load onAdClosed");
    });

    AdOptions options = AdOptions(spaceId: '15288', splashAdBottomBuilderHeight: 200);
    _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            ),
            if (splashVisible) _buildSplashWidget()
          ],
        ));
  }

  Widget _buildSplashWidget() {
    return SplashWidget(_splashAd,
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
  }
}
