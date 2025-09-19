import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk/controller/AMPSSplashAd.dart';
import 'package:amps_sdk/data/ampsAd.dart';
import 'package:flutter/material.dart';
class InterstitialPage extends StatefulWidget {
  const InterstitialPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<InterstitialPage> {
  late AdCallBack _adCallBack;
  AMPSInterstitialAd? _interAd;
  @override
  void initState() {
    super.initState();
    _adCallBack = AdCallBack(
        onRenderOk: () {
          //_interAd?.showAd();
          debugPrint("ad load onRenderOk");
        },
        onLoadFailure: (code, msg) {
          debugPrint("ad load failure=$code;$msg");
        },
        onAdClicked: () {
          debugPrint("ad load onAdClicked");
        },
        onAdExposure: () {
          debugPrint("ad load onAdExposure");
        },
        onAdClosed: () {
          setState(() {
          });
          debugPrint("ad load onAdClosed");
        },
        onAdReward: () {
          debugPrint("ad load onAdReward");
        },
        onAdShow: () {
          debugPrint("ad load onAdShow");
        },
        onAdShowError: (code, msg) {
          debugPrint("ad load onAdShowError");
        },
        onRenderFailure: () {
          debugPrint("ad load onRenderFailure");
        },
        onVideoPlayStart: () {
          debugPrint("ad load onVideoPlayStart");
        },
        onVideoPlayError: (code,msg) {
          debugPrint("ad load onVideoPlayError");
        },
        onVideoPlayEnd: () {
          debugPrint("ad load onVideoPlayEnd");
        },
        onVideoSkipToEnd: (duration) {
          debugPrint("ad load onVideoSkipToEnd=$duration");
        });

    AdOptions options = AdOptions(spaceId: '111502');
    _interAd = AMPSInterstitialAd(config: options, mCallBack: _adCallBack);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AMPSBuildInterstitialView(_interAd)
      // Center(
      //   child: ElevatedButton(
      //     child: const Text('点击展示插屏'),
      //     onPressed: () {
      //       // 返回上一页
      //    _interAd?.load();
      //     },
      //   ),
      // ),
    );
  }
}