import { Any, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { AMPSAdSdk, AMPSIInitCallback, AMPSInitConfig } from 'biz.beizi.adn';
import { AMPSAdSdkMethodNames, AMPSChannels, AMPSInitChannelMethod } from '../data/common';
import { common } from '@kit.AbilityKit';
import { AMPSInitConfigConverter } from '../data/AMPSInitConfigConverter';

@Observed
export class AMPS {
  methodChannel: MethodChannel;

  constructor(flutterEngine: FlutterEngine, context: common.UIAbilityContext) {
    this.methodChannel = new MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), AMPSChannels.ampsSdkInit)
    this.methodChannel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult) => {
        let method: string = call.method;
        let flutterParams: Map<string, Any> = call.args;
        switch (method) {
          case AMPSAdSdkMethodNames.init:
            const ampsConfig = new AMPSInitConfigConverter().convert(flutterParams, context);
            this.initAMPSSDK(ampsConfig)
            result.success(true);
            break;
        }
      }
    })
  }

  initAMPSSDK(ampsInitConfig: AMPSInitConfig) {
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
    AMPSAdSdk.init(ampsInitConfig, callback)
  }


  public sendMessage = (method: string, args?: Any) => {
    this.methodChannel.invokeMethod(method, args);
  }
}