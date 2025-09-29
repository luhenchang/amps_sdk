class AdOptions {
  final String spaceId;
  final String? apiKey;
  final int? adCount;
  final String? s2sImpl;
  final int? timeoutInterval;
  final List<num?>? expressSize;
  final int? splashAdBottomBuilderHeight;
  final String? userId;
  final String? extra;
  final String? ipAddress;

  AdOptions({
    required this.spaceId,
    this.apiKey,
    this.adCount,
    this.s2sImpl,
    this.timeoutInterval,
    this.expressSize,
    this.splashAdBottomBuilderHeight,
    this.userId,
    this.extra,
    this.ipAddress,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'spaceId': spaceId,
      'apiKey': apiKey,
      'adCount': adCount,
      's2sImpl': s2sImpl,
      'timeoutInterval': timeoutInterval,
      'expressSize': expressSize,
      'splashAdBottomBuilderHeight': splashAdBottomBuilderHeight,
      'userId': userId,
      'extra': extra,
      'ipAddress': ipAddress,
    };
  }
}

typedef AdSuccessCallback = void Function();
typedef AdFailureCallback = void Function(int code, String message);
typedef VideoPlayErrorCallback = void Function(int code, String message);
typedef VideoSkipToEndCallback = void Function(int? playDurationMs);

class AdCallBack {
  final AdSuccessCallback? onLoadSuccess;
  final AdFailureCallback? onLoadFailure;
  final AdSuccessCallback? onRenderOk;
  final AdSuccessCallback? onRenderFailure;
  final AdFailureCallback? onAdShowError;
  final AdSuccessCallback? onAdShow;
  final AdSuccessCallback? onAdExposure;
  final AdSuccessCallback? onAdClicked;
  final AdSuccessCallback? onAdClosed;
  final AdSuccessCallback? onVideoPlayStart;
  final AdSuccessCallback? onVideoPlayEnd;
  final VideoPlayErrorCallback? onVideoPlayError;
  final VideoSkipToEndCallback? onVideoSkipToEnd;
  final AdSuccessCallback? onAdReward;

  const AdCallBack({
    this.onLoadSuccess,
    this.onLoadFailure,
    this.onRenderOk,
    this.onRenderFailure,
    this.onAdShowError,
    this.onAdShow,
    this.onAdExposure,
    this.onAdClicked,
    this.onAdClosed,
    this.onVideoPlayStart,
    this.onVideoPlayEnd,
    this.onVideoPlayError,
    this.onVideoSkipToEnd,
    this.onAdReward,
  });
}

typedef AdWidgetNeedCloseCall = void Function();
