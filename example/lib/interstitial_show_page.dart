import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';
class InterstitialShowPage extends StatefulWidget {
  const InterstitialShowPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialShowPage> createState() => _InterstitialShowPageState();
}

class _InterstitialShowPageState extends State<InterstitialShowPage> {
  late AdCallBack _adCallBack;
  AMPSInterstitialAd? _interAd;
  bool couldBack = true;
  num eCpm = 0;
  @override
  void initState() {
    super.initState();
    _adCallBack = AdCallBack(
        onRenderOk: () {
          couldBack = false;
          _interAd?.showAd();
          debugPrint("ad load onRenderOk");
        },
        onLoadFailure: (code, msg) {
          debugPrint("ad load failure=$code;$msg");
        },
        onAdClicked: () {
          setState(() {
            couldBack = true;
          });
          debugPrint("ad load onAdClicked");
        },
        onAdExposure: () {
          debugPrint("ad load onAdExposure");
        },
        onAdClosed: () {
          setState(() {
            couldBack = true;
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
  void dispose() {
    debugPrint("差评调用来了11");
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: couldBack,
        child:   Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: [
        Column(
          children:[
            ElevatedButton(
            child: const Text('点击展示插屏'),
            onPressed: () {
              // 返回上一页
              debugPrint("差评调用来了11");
              _interAd?.load();
            },
          ),
            ButtonWidget(
                buttonText: '获取竞价=$eCpm',
                callBack: () async {
                  bool? isReadyAd = await _interAd?.isReadyAd();
                  debugPrint("isReadyAd=$isReadyAd");
                  if(_interAd != null){
                    num ecPmResult =  await _interAd!.getECPM();
                    setState(() {
                      eCpm = ecPmResult;
                      debugPrint("ecPm请求结果=$eCpm");
                    });
                  }
                }),
            ButtonWidget(
                buttonText: '上报竞胜',
                callBack: () async {
                  _interAd?.notifyRTBWin(11, 3);
                }),
            ButtonWidget(
                buttonText: '上报竞价失败',
                callBack: () async {
                  _interAd?.notifyRTBLoss(11, 3,"给的价格太低");
                }),
            
          ]
        ),
      ],)
    ));
  }
}