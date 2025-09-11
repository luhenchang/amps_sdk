import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'amps_sdk_platform_interface.dart';

/// An implementation of [AmpsSdkPlatform] that uses method channels.
class MethodChannelAmpsSdk extends AmpsSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('amps_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
