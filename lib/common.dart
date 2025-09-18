const String channelDomain = "biz.beizi.adn";
class AMPSChannels {
  static const String ampsSdkInit = '$channelDomain/sdk';
  static const String ampsSdkSplash = '$channelDomain/splash';
  static const ampsSdkSplashAdLoad = '$channelDomain/splash_ad_load';
}
class AMPSPlatformViewRegistry {
  static const ampsSdkSplashViewId = '$channelDomain/splash_view_id';
}
//初始化交互通道方法名称
class AMPSInitChannelMethod {
  static const String initSuccess = "initSuccess";
  static const String initializing = "initializing";
  static const String alreadyInit = "alreadyInit";
  static const String initFailed = "initFailed";
}


//开屏广告加载方法
class AMPSSplashChannelMethod {
  static const String onLoadSuccess = "onLoadSuccess";
  static const String onLoadFailure = "onLoadFailure";
  static const String onRenderOk = "onRenderOk";
  static const String onAdShow = "onAdShow";
  static const String onAdExposure = "onAdExposure";
  static const String onAdClicked = "onAdClicked";
  static const String onAdClosed = "onAdClosed";
  static const String onRenderFailure = "onRenderFailure";
  static const String onAdShowError = "onAdShowError";
  static const String onVideoPlayStart = "onVideoPlayStart";
  static const String onVideoPlayEnd = "onVideoPlayEnd";
  static const String onVideoPlayError = "onVideoPlayError";
  static const String onVideoSkipToEnd = "onVideoSkipToEnd";
  static const String onAdReward = "onAdReward";
}

class AMPSAdSdkMethodNames {
  // 初始化AMPS广告SDK的方法名
  static const String init = 'AMPSAdSdk_init';
  static const String splashLoad = 'AMPSSplashAd_load';
  static const String splashShowAd = 'AMPSSplashAd_showAd';
}

class AMPSSdkCallBackErrorKey {
  static const String code = "code";
  static const String message = "message";
}

class AMPSSdkCallBackParamsKey {
  static const String playDurationMs = "playDurationMs";
}

const String adOption = 'AdOption';
const String splashConfig = "config";
const String splashBottomView = "SplashBottomView";