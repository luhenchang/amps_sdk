import { Any, FlutterAbility, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSAdSdk, AMPSIInitCallback, AMPSInitConfig, AMPSSplashAd } from 'biz.beizi.adn';
import { AMPSAdSdkMethodNames, AMPSChannels, AMPSInitChannelMethod, AMPSSplashChannelMethod } from '../data/common';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { window, UIContext } from '@kit.ArkUI';

@Observed
export class AMPSSplash {
  // 使用private修饰符限制访问，并添加明确类型
  private mMethodChannel: MethodChannel;
  private mWindowStage?: window.WindowStage;
  private mSplashAd?: AMPSSplashAd;
  private mWindow?: window.Window;
  private mUIContext?: UIContext;

  // 优化回调定义，减少重复代码
  private callback: ampsAd.CallBack = {
    onLoadSuccess: () => this.sendMessage(AMPSSplashChannelMethod.onLoadSuccess),
    onLoadFailure: (code: number, message: string) =>
    this.sendMessage(AMPSSplashChannelMethod.onLoadFailure, { code, message }),
    onRenderOk: () => this.sendMessage(AMPSSplashChannelMethod.onRenderOk),
    onAdShow: () => this.sendMessage(AMPSSplashChannelMethod.onAdShow),
    onAdExposure: () => this.sendMessage(AMPSSplashChannelMethod.onAdExposure),
    onAdClicked: () => this.sendMessage(AMPSSplashChannelMethod.onAdClicked),
    onAdClosed: () => this.sendMessage(AMPSSplashChannelMethod.onAdClosed),
    onRenderFailure: () => this.sendMessage(AMPSSplashChannelMethod.onRenderFailure),
    onAdShowError: (code: number, message: string) =>
    this.sendMessage(AMPSSplashChannelMethod.onAdShowError, { code, message }),
    onVideoPlayStart: () => this.sendMessage(AMPSSplashChannelMethod.onVideoPlayStart),
    onVideoPlayEnd: () => this.sendMessage(AMPSSplashChannelMethod.onVideoPlayEnd),
    onVideoPlayError: (code: number, message: string) =>
    this.sendMessage(AMPSSplashChannelMethod.onVideoPlayEnd, { code, message }),
    onVideoSkipToEnd: (playDurationMs?: number) =>
    this.sendMessage(AMPSSplashChannelMethod.onVideoSkipToEnd, { playDurationMs }),
    onAdReward: () => this.sendMessage(AMPSSplashChannelMethod.onAdReward)
  };

  constructor(flutterEngine: FlutterEngine, ability: FlutterAbility) {
    this.mMethodChannel = new MethodChannel(
      flutterEngine.dartExecutor.getBinaryMessenger(),
      AMPSChannels.ampsSdkSplashAdLoad
    );
    this.setupMethodCallHandler(ability);
  }

  // 提取方法调用处理逻辑，使代码结构更清晰
  private setupMethodCallHandler(ability: FlutterAbility): void {
    this.mMethodChannel.setMethodCallHandler({
      onMethodCall: (call: MethodCall, result: MethodResult) => {
        switch (call.method) {
          case AMPSAdSdkMethodNames.splashLoad:
            this.handleSplashLoad(call, ability, result);
            break;
          case AMPSAdSdkMethodNames.splashShowAd:
            this.handleSplashShowAd(result);
            break;
          default:
            result.notImplemented();
        }
      }
    });
  }

  // 处理开屏广告加载
  private handleSplashLoad(call: MethodCall, ability: FlutterAbility, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      this.mWindowStage = ability.context.windowStage;
      if (this.mWindowStage) {
        // 鸿蒙推荐使用同步API时增加空值判断
        this.mWindow = this.mWindowStage.getMainWindowSync();
        this.mUIContext = this.mWindow?.getUIContext();
        if (this.mWindow && this.mUIContext) {
          this.mSplashAd = new AMPSSplashAd(adOption, this.callback, this.mUIContext);
          this.mSplashAd.load();
          result.success(true);
        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败',undefined);
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化',undefined);
      }
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
  }

  // 处理开屏广告显示
  private handleSplashShowAd(result: MethodResult): void {
    try {
      if (this.mSplashAd && this.mWindowStage) {
        this.mSplashAd.showAd({ windowStage: this.mWindowStage });
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在',undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
  }

  // 初始化SDK，优化回调定义
  initAMPSSDK(ampsInitConfig: AMPSInitConfig): void {
    const callback: AMPSIInitCallback = {
      initSuccess: () => this.sendMessage(AMPSInitChannelMethod.initSuccess),
      initializing: () => this.sendMessage(AMPSInitChannelMethod.initializing),
      alreadyInit: () => this.sendMessage(AMPSInitChannelMethod.alreadyInit),
      initFailed: (code: number, message: string) =>
      this.sendMessage(AMPSInitChannelMethod.initFailed, { code, message })
    };
    AMPSAdSdk.init(ampsInitConfig, callback);
  }

  // 发送消息方法，使用箭头函数绑定this，符合ArkTS实践
  sendMessage = (method: string, args?: Any): void => {
    try {
      this.mMethodChannel.invokeMethod(method, args);
    } catch (error) {
      console.error(`发送消息失败 [${method}]: ${error instanceof Error ? error.message : error}`);
    }
  };
}
