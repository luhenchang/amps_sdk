import 'package:flutter/services.dart';

import '../amps_sdk.dart';

/// 通道调用处理函数。
typedef AmpsChannelHandler = Future<void> Function(MethodCall call);

/// 所有广告类型共用的 MethodChannel 分发器：
///
/// - 全局只对 [AmpsSdk.channel] 注册一次 `setMethodCallHandler`；
/// - 各广告类型在首次实例化时 [register] 自己的处理函数；
/// - 回调协议：`{ instanceId, data }`，init 回调除外（无 instanceId）。
class AmpsChannelDispatcher {
  AmpsChannelDispatcher._();

  static const String kInstanceId = 'instanceId';
  static const String kData = 'data';

  static final List<AmpsChannelHandler> _handlers = <AmpsChannelHandler>[];
  static bool _installed = false;

  static void register(AmpsChannelHandler handler) {
    _ensureInstalled();
    if (!_handlers.contains(handler)) {
      _handlers.add(handler);
    }
  }

  static void unregister(AmpsChannelHandler handler) {
    _handlers.remove(handler);
  }

  static void _ensureInstalled() {
    if (_installed) return;
    _installed = true;
    AmpsSdk.channel.setMethodCallHandler((call) async {
      for (final h in List<AmpsChannelHandler>.from(_handlers)) {
        try {
          await h(call);
        } catch (_) {
          // 单个 handler 出错不影响其它 handler
        }
      }
    });
  }

  static String? extractInstanceId(MethodCall call) {
    final args = call.arguments;
    if (args is Map) {
      final id = args[kInstanceId];
      if (id is String) return id;
    }
    return null;
  }

  static dynamic extractData(MethodCall call) {
    final args = call.arguments;
    if (args is Map) {
      return args[kData];
    }
    return null;
  }

  static Map<String, dynamic> payload(String instanceId, [Object? data]) {
    final map = <String, dynamic>{kInstanceId: instanceId};
    if (data != null) {
      map[kData] = data;
    }
    return map;
  }
}
