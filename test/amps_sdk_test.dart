import 'package:flutter_test/flutter_test.dart';
import 'package:amps_sdk/amps_sdk.dart';
import 'package:amps_sdk/amps_sdk_platform_interface.dart';
import 'package:amps_sdk/amps_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAmpsSdkPlatform
    with MockPlatformInterfaceMixin
    implements AmpsSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AmpsSdkPlatform initialPlatform = AmpsSdkPlatform.instance;

  test('$MethodChannelAmpsSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAmpsSdk>());
  });

  test('getPlatformVersion', () async {
    AmpsSdk ampsSdkPlugin = AmpsSdk();
    MockAmpsSdkPlatform fakePlatform = MockAmpsSdkPlatform();
    AmpsSdkPlatform.instance = fakePlatform;

    expect(await ampsSdkPlugin.getPlatformVersion(), '42');
  });
}
