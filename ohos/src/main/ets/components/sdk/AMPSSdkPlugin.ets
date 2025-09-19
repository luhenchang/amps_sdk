import {
  AbilityPluginBinding,
  Any,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';
import { AMPSAdSdk, AMPSIInitCallback, AMPSInitConfig } from 'biz.beizi.adn';
import { AMPSAdSdkMethodNames, AMPSChannels, AMPSInitChannelMethod } from '../data/common';
import { AMPSInitConfigConverter } from '../data/AMPSInitConfigConverter';
import { common } from '@kit.AbilityKit';

@Observed
export class AMPSSdkPlugin implements FlutterPlugin, MethodCallHandler {
  private methodChannel?: MethodChannel;
  private uiContext: common.UIAbilityContext | null= null;

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.uiContext = binding.getAbility().context;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    let method: string = call.method;
    let flutterParams: Map<string, Any> = call.args;
    switch (method) {
      case AMPSAdSdkMethodNames.init:
        if (this.uiContext) {
          const ampsConfig = new AMPSInitConfigConverter().convert(flutterParams, this.uiContext);
          this.initAMPSSDK(ampsConfig)
          result.success(true);
        }
        break;
    }
  }

  getUniqueClassName(): string {
    return "AMPSSdkPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), AMPSChannels.ampsSdkInit)
    this.methodChannel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.methodChannel?.setMethodCallHandler(null)
  }

  initAMPSSDK(ampsInitConfig?: AMPSInitConfig) {
    let callback: AMPSIInitCallback = {
      initSuccess: (): void => {
        this.sendMessage(AMPSInitChannelMethod.initSuccess)
      },
      initializing: (): void => {
        this.sendMessage(AMPSInitChannelMethod.initializing)
      },
      alreadyInit: (): void => {
        this.sendMessage(AMPSInitChannelMethod.alreadyInit)
      },
      initFailed: (code: number, message: string): void => {
        this.sendMessage(AMPSInitChannelMethod.initFailed, { code, message })
      }
    }
    if (ampsInitConfig) {
      AMPSAdSdk.init(ampsInitConfig, callback)
    }
  }

  public sendMessage = (method: string, args?: Any) => {
    this.methodChannel?.invokeMethod(method, args);
    this.uiContext = null
  }
}