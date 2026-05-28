import 'dart:async';

import 'package:flutter/services.dart';

import '../amps_sdk.dart';
import '../common.dart';
import '../data/amps_channel_dispatcher.dart';
import '../data/amps_init_config.dart';

/// SDK初始化入口类
class AMPSAdSDK {
  static AMPSIInitCallBack? _initCallBack;
  static bool _dispatcherRegistered = false;

  final StreamController<String> _controller = StreamController<String>();

  static bool testModel = false;

  AMPSAdSDK() {
    _ensureDispatcherRegistered();
  }

  Stream<String> get customDataStream => _controller.stream;

  static void _ensureDispatcherRegistered() {
    if (_dispatcherRegistered) return;
    _dispatcherRegistered = true;
    AmpsChannelDispatcher.register(_handleInitCall);
  }

  static Future<void> _handleInitCall(MethodCall call) async {
    switch (call.method) {
      case AMPSInitChannelMethod.initSuccess:
        _initCallBack?.initSuccess?.call();
        break;
      case AMPSInitChannelMethod.initializing:
        _initCallBack?.initializing?.call();
        break;
      case AMPSInitChannelMethod.alreadyInit:
        _initCallBack?.alreadyInit?.call();
        break;
      case AMPSInitChannelMethod.initFailed:
        final map = call.arguments as Map<dynamic, dynamic>?;
        final code = map?[AMPSSdkCallBackErrorKey.code];
        final message = map?[AMPSSdkCallBackErrorKey.message];
        _initCallBack?.initFailed?.call(code, message);
        break;
      default:
        break;
    }
  }

  /// 发送数据给native
  Future<void> init(AMPSInitConfig sdkConfig, AMPSIInitCallBack callBack) async {
    _initCallBack = callBack;
    await AmpsSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.init,
      sdkConfig.toMap(AMPSAdSDK.testModel),
    );
  }
}

typedef InitSuccessCallBack = void Function();
typedef InitializingCallBack = void Function();
typedef AlreadyInitCallBack = void Function();
typedef InitFailedCallBack = void Function(int? code, String? msg);

/// 1. 定义回调接口（抽象类）
class AMPSIInitCallBack {
  /// 初始化成功的回调
  late final InitSuccessCallBack? initSuccess;

  /// 正在初始化的回调
  late final InitializingCallBack? initializing;

  /// 已经初始化的回调
  late final AlreadyInitCallBack? alreadyInit;

  /// 初始化失败的回调
  late final InitFailedCallBack? initFailed;

  AMPSIInitCallBack({this.initSuccess, this.initializing, this.alreadyInit, this.initFailed});
}
