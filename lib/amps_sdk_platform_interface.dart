import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'amps_sdk_method_channel.dart';

abstract class AmpsSdkPlatform extends PlatformInterface {
  /// Constructs a AmpsSdkPlatform.
  AmpsSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AmpsSdkPlatform _instance = MethodChannelAmpsSdk();

  /// The default instance of [AmpsSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAmpsSdk].
  static AmpsSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AmpsSdkPlatform] when
  /// they register themselves.
  static set instance(AmpsSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
