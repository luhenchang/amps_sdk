
import 'amps_sdk_platform_interface.dart';

class AmpsSdk {
  Future<String?> getPlatformVersion() {
    return AmpsSdkPlatform.instance.getPlatformVersion();
  }
}
