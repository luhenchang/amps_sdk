import 'dart:collection';
import 'package:amps_sdk_example/widgets/blurred_background.dart';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

import 'InterstitialPage.dart';
import 'NativePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       initialRoute: 'splashPage',
       routes: {
         'splashPage':(context)=>const SplashPage(title: '开屏页面'),
         'InterstitialPage':(context)=> const InterstitialPage(title: '插屏页面'),
         'NativePage':(context)=> const NativePage(title: '原生页面')
       },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.title});

  final String title;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late AMPSIInitCallBack _callBack;
  AMPSSplashAd? _splashAd;
  late AdCallBack _adCallBack;
  bool initSuccess = false;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _callBack = AMPSIInitCallBack(
        initSuccess: () {
          debugPrint("adk is initSuccess");
          setState(() {
            initSuccess = true;
          });
          _splashAd?.load();
        },
        initializing: () {
          debugPrint("adk is initializing");
        },
        alreadyInit: () {
          debugPrint("adk is alreadyInit");
          setState(() {
            initSuccess = true;
            _splashAd?.load();
          });
        },
        initFailed: (code, msg) {
          debugPrint("adk is initFailed");
          debugPrint("result callBack=code$code;message=$msg");
        });
    HashMap<String, dynamic> optionFields = HashMap();
    optionFields["crashCollectSwitch"] = true;
    optionFields["lightColor"] = "#FFFF0000";
    optionFields["darkColor"] = "#0000FF00";
    HashMap<String, dynamic> ksSdkEx = HashMap();
    ksSdkEx["crashLog"] = true;
    ksSdkEx["ks_sdk_roller"] = "roller_click";
    ksSdkEx["ks_sdk_location"] = "baidu";
    AMPSInitConfig sdkConfig = AMPSBuilder("12379")
        .setCity("北京")
        .setRegion("朝阳区双井")
        .setCurrency(CurrencyType.CURRENCY_TYPE_USD)
        .setCountryCN(CountryType.COUNTRY_TYPE_CHINA_MAINLAND)
        .setDebugSetting(true)
        .setIsMediation(false)
        .setIsTestAd(false)
        .setLandStatusBarHeight(true)
        .setOptionFields(optionFields)
        .setProvince("北京市")
        .setUiModel(UiModel.uiModelDark)
        .setUseHttps(true)
        .setUserId("12345656")
        .setExtensionParamItems("KuaiShouSDK", ksSdkEx)
        .setAppName("Flutter测试APP")
        .setAdapterNames(["ampskuaishouAdapter", "ampsJdSplashAdapter"])
        .setAdCustomController(AMPSCustomController(
            param: AMPSCustomControllerParam(
                isCanUsePhoneState: true,
                isCanUseSensor: true,
                isSupportPersonalized: true,
                isLocationEnabled: true,
                getUnderageTag: UnderageTag.underage,
                userAgent:
                    "Mozilla/5.0 (Phone; OpenHarmony 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile",
                location: AMPSLocation(
                    latitude: 39.959836,
                    longitude: 116.31985,
                    timeStamp: 1113939393,
                    coordinate: CoordinateType.baidu)))) //个性化，传感器等外部设置
        .setIsMediation(false)
        .setUiModel(UiModel.uiModelAuto)
        .build();
    debugPrint("sdkConfigJson=${sdkConfig.toMap(true)}");
    AMPSAdSdk.testModel = true;
    AMPSAdSdk().init(sdkConfig, _callBack);
    _adCallBack = AdCallBack(
        onRenderOk: () {
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
                  ])
          );
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

    AdOptions options = AdOptions(spaceId: '15288',splashAdBottomBuilderHeight: 200);
    _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const BlurredBackground(),
        ButtonWidget(
          buttonText: '点击跳转插屏页面',
          callBack: () {
            // 使用命名路由跳转
            Navigator.pushNamed(context, 'InterstitialPage');
          }
        ),
        ButtonWidget(
            buttonText: '点击跳转原生页面',
            callBack: () {
              // 使用命名路由跳转
              Navigator.pushNamed(context, 'NativePage');
            }
        )
        //_buildSplashWidget(),
      ],
    ));
  }

  Widget _buildSplashWidget() {
    return AMPSBuildSplashView(_splashAd,
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
