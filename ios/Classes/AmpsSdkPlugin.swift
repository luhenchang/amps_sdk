import Flutter
import UIKit
import AMPSAdSDK

public class AmpsSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    AMPSEventManager.getInstance().regist(messenger: registrar.messenger())
  }
}
