const channelDomain = "biz.beizi.adn";

export class AMPSChannels {
  static readonly ampsSdkInit = `${channelDomain}/sdk`;
  static readonly ampsSdkSplash = `${channelDomain}/splash`;
  static readonly ampsSdkSplashViewLoadAdId = `${channelDomain}/splash_view_load_id`;
}

export class AMPSPlatformViewRegistry {
  static readonly ampsSdkSplashViewId = `${channelDomain}/splash_view_id`;
}

//初始化交互通道方法名称
export class AMPSInitChannelMethod {
  static readonly initSuccess = "initSuccess";
  static readonly initializing = "initializing";
  static readonly alreadyInit = "alreadyInit";
  static readonly initFailed = "initFailed";
}

//开屏广告加载方法
export class AMPSSplashChannelMethod {
  static readonly onLoadSuccess = "onLoadSuccess";
  static readonly onLoadFailure = "onLoadFailure";
  static readonly onRenderOk = "onRenderOk";
  static readonly onAdShow = "onAdShow";
  static readonly onAdExposure = "onAdExposure";
  static readonly onAdClicked = "onAdClicked";
  static readonly onAdClosed = "onAdClosed";
  static readonly onRenderFailure = "onRenderFailure";
  static readonly onAdShowError = "onAdShowError";
  static readonly onVideoPlayStart = "onVideoPlayStart";
  static readonly onVideoPlayEnd = "onVideoPlayEnd";
  static readonly onVideoPlayError = "onVideoPlayError";
  static readonly onVideoSkipToEnd = "onVideoSkipToEnd";
  static readonly onAdReward = "onAdReward";
}

export class AMPSAdSdkMethodNames {
  // 初始化AMPS广告SDK的方法名
  static readonly init = 'AMPSAdSdk_init';
  static readonly splashLoad = 'AMPSSplashAd_load';
  static readonly splashShowAd = 'AMPSSplashAd_showAd';
}

export const AD_OPTION = 'AdOption';