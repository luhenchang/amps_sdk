//原生和原生自渲染广告相关回调
//原生广告加载回调
typedef AdLoadCallback = void Function(List<String> adIds);
typedef AdLoadErrorCallback = void Function(int code, String message);

class AmpsNativeAdListener {
  final AdLoadCallback? loadOk;
  final AdLoadErrorCallback? loadFail;

  const AmpsNativeAdListener({this.loadOk, this.loadFail});
}

// 渲染回调
typedef AMPSNativeRenderCallback = void Function(String adId);
typedef AMPSNativeRenderFailedCallback = void Function(int code, String message);

class AMPSNativeRenderListener {
  final AMPSNativeRenderCallback? renderSuccess;
  final AMPSNativeRenderFailedCallback? renderFailed;

  const AMPSNativeRenderListener({this.renderSuccess, this.renderFailed});
}

//广告View事件相关回调
typedef AdEventCallback = void Function(String? adId);

class AmpsNativeInteractiveListener {
  final AdEventCallback? onAdShow;
  final AdEventCallback? onAdExposure;
  final AdEventCallback? onAdClicked;
  final AdEventCallback? toCloseAd;

  const AmpsNativeInteractiveListener({
    this.onAdShow,
    this.onAdExposure,
    this.onAdClicked,
    this.toCloseAd,
  });
}

// 视频相关回调
typedef VideoPlayerEventCallback = void Function(String adId);
typedef VideoPlayerErrorCallback = void Function(int code, String extra);

class AmpsVideoPlayListener {
  final VideoPlayerEventCallback? onVideoReady;
  final VideoPlayerEventCallback? onVideoPlayStart;
  final VideoPlayerEventCallback? onVideoPlayComplete;
  final VideoPlayerEventCallback? onVideoPause;
  final VideoPlayerEventCallback? onVideoResume;
  final VideoPlayerErrorCallback? onVideoPlayError;

  const AmpsVideoPlayListener({
    this.onVideoReady,
    this.onVideoPlayStart,
    this.onVideoPlayComplete,
    this.onVideoPause,
    this.onVideoResume,
    this.onVideoPlayError,
  });
}
