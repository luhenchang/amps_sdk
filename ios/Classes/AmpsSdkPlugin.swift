import Flutter
import UIKit


public class AmpsSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AmpsSdkPlugin()
    AMPSEventManager.getInstance().regist(messenger: registrar.messenger())
  }
}
