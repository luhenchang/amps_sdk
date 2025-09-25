import 'dart:async';
import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_init_config.dart';

class AMPSAdSdk {
  final StreamController<String> _controller = StreamController<String>();
  AMPSIInitCallBack?  _callBack;

  static bool testModel = false;
  AMPSAdSdk() {
    AmpsSdk.channel.setMethodCallHandler(
          (call) async {
        switch (call.method) {
          case AMPSInitChannelMethod.initSuccess:
            _callBack?.initSuccess?.call();
            break;
          case AMPSInitChannelMethod.initializing:
            _callBack?.initializing?.call();
            break;
          case AMPSInitChannelMethod.alreadyInit:
            _callBack?.alreadyInit?.call();
            break;
          case AMPSInitChannelMethod.initFailed:
            var map = call.arguments as Map<dynamic, dynamic>;
            _callBack?.initFailed?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
        }
      },
    );
  }

  Stream<String> get customDataStream => _controller.stream;

  // 发送数据给native
  Future<void> init(AMPSInitConfig sdkConfig,AMPSIInitCallBack callBack) async {
    _callBack = callBack;
    // 使用时
    await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.init,
      sdkConfig.toMap(AMPSAdSdk.testModel),
    );
  }
}

typedef InitSuccessCallBack = void Function();
typedef InitializingCallBack = void Function();
typedef AlreadyInitCallBack = void Function();
typedef InitFailedCallBack = void Function(int? code, String? msg);
// 1. 定义回调接口（抽象类）
class AMPSIInitCallBack {
  // 初始化成功的回调
  late final InitSuccessCallBack? initSuccess;

  // 正在初始化的回调
  late final InitializingCallBack? initializing;

  // 已经初始化的回调
  late final  AlreadyInitCallBack? alreadyInit;

  // 初始化失败的回调
  late final  InitFailedCallBack? initFailed;

  AMPSIInitCallBack({this.initSuccess, this.initializing, this.alreadyInit, this.initFailed});
}