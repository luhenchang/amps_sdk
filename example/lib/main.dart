import 'dart:collection';
import 'package:amps_sdk_example/widgets/blurred_background.dart';
import 'package:amps_sdk_example/widgets/button_widget.dart';
import 'package:amps_sdk/amps_sdk_export.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AMPSIInitCallBack _callBack;
  AMPSSplashAd? _splashAd;
  late AdCallBack _adCallBack;
  bool _isSplashHidden = true;//默认不可见，但是需要能渲染。所以使用Offstage

  @override
  void initState() {
    super.initState();
    _callBack = AMPSIInitCallBack(
        initSuccess: () {
          _splashAd?.load();
        },
        initializing: () {},
        alreadyInit: () {},
        initFailed: (code, msg) {
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
    debugPrint("sdkConfigJson=${sdkConfig.toMap()}");
    AMPSAdSdk().init(sdkConfig, _callBack);
    _adCallBack = AdCallBack(
        onRenderOk: () {
          _splashAd?.showAd();
          debugPrint("ad load onRenderOk");
          setState(() {
            _isSplashHidden = false;
          });
        },
        onLoadFailure: (code, msg) {
          debugPrint("ad load failure=$code;$msg");
        },
        onAdClicked: () {
          setState(() {
            _isSplashHidden = true;
          });
          debugPrint("ad load onAdClicked");
        },
        onAdExposure: () {
          debugPrint("ad load onAdExposure");
        },
        onAdClosed: () {
          setState(() {
            _isSplashHidden = true;
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

    AdOptions options = AdOptions(spaceId: '15288');
    _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment.center,
      children: [
        const BlurredBackground(),
        ButtonWidget(buttonText: "点击开屏", callBack:(){
           _splashAd?.load();
        }),
        Offstage(
          offstage: false,//使用Offstage保证试图可以被渲染。
          child: AMPSBuildSplashView(_splashAd),
        )
      ],
    ));
  }
}
