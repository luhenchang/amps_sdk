import {
  AbilityPluginBinding,
  Any, FlutterPlugin, FlutterPluginBinding, MethodCall,
  MethodCallHandler,
  MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSSplashAd } from 'biz.beizi.adn';
import { AMPSAdSdkMethodNames, AMPSChannels, AMPSAdCallBackChannelMethod } from '../data/common';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { UIContext, window } from '@kit.ArkUI';
import { SplashBottomModule } from '../data/SplashBottomModule';
import { common } from '@kit.AbilityKit';

export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(SplashBottomBuilder);
@Observed
export class AMPSSplashPlugin implements FlutterPlugin,MethodCallHandler {
  // 使用private修饰符限制访问，并添加明确类型
  private mMethodChannel: MethodChannel | null = null;
  private mWindowStage?: window.WindowStage;
  private mSplashAd?: AMPSSplashAd;
  private mWindow?: window.Window;
  private mUIBContext?: common.UIAbilityContext | null= null;
  static splashBottomModule: SplashBottomModule | null | undefined = null

  // 优化回调定义，减少重复代码
  private callback: ampsAd.CallBack = {
    onLoadSuccess: () => this.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess),
    onLoadFailure: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, { code, message }),
    onRenderOk: () => this.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk),
    onAdShow: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdShow),
    onAdExposure: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure),
    onAdClicked: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked),
    onAdClosed: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdClosed),
    onRenderFailure: () => this.sendMessage(AMPSAdCallBackChannelMethod.onRenderFailure),
    onAdShowError: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onAdShowError, { code, message }),
    onVideoPlayStart: () => this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayStart),
    onVideoPlayEnd: () => this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd),
    onVideoPlayError: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd, { code, message }),
    onVideoSkipToEnd: (playDurationMs?: number) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs }),
    onAdReward: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdReward)
  };

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.mUIBContext = binding.getAbility().context;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case AMPSAdSdkMethodNames.splashLoad:
        this.handleSplashLoad(call, result);
        break;
      case AMPSAdSdkMethodNames.splashShowAd:
        this.handleSplashShowAd(result,call.args);
        break;
      default:
        result.notImplemented();
    }
  }

  getUniqueClassName(): string {
    return "AMPSSplashPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), AMPSChannels.ampsSdkSplashAdLoad);
    this.mMethodChannel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.mMethodChannel?.setMethodCallHandler(null)
  }

  // 处理开屏广告加载
  private handleSplashLoad(call: MethodCall, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      this.mWindowStage = this.mUIBContext?.windowStage;
      if (this.mWindowStage) {
        this.mWindow = this.mWindowStage.getMainWindowSync();
        if (this.mWindow) {
          this.mSplashAd = new AMPSSplashAd(adOption, this.callback,this.mWindow.getUIContext());
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
  private handleSplashShowAd(result: MethodResult, args: Any): void {
    try {
      if (this.mSplashAd && this.mWindowStage) {
        AMPSSplashPlugin.splashBottomModule = new SplashBottomModule(args);
        this.mSplashAd.showAd({ windowStage: this.mWindowStage, bottomWrappedBuilder: globalSplashBottomBuilder });
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在',undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
  }

  sendMessage = (method: string, args?: Any): void => {
    try {
      this.mMethodChannel?.invokeMethod(method, args);
    } catch (error) {
      console.error(`发送消息失败 [${method}]: ${error instanceof Error ? error.message : error}`);
    }
  };
}


@Builder
export function SplashBottomBuilder() {
  if (AMPSSplashPlugin.splashBottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${AMPSSplashPlugin.splashBottomModule?.imgChildren?.imageUrl}`))
        .width(AMPSSplashPlugin.splashBottomModule?.imgChildren?.width)
        .height(AMPSSplashPlugin.splashBottomModule?.imgChildren?.height)
        .offset({
          x: AMPSSplashPlugin.splashBottomModule?.imgChildren?.x,
          y: AMPSSplashPlugin.splashBottomModule?.imgChildren?.y
        })
      Text(AMPSSplashPlugin.splashBottomModule?.textChildren?.text)
        .fontColor(AMPSSplashPlugin.splashBottomModule?.textChildren?.color)
        .offset({
          x: AMPSSplashPlugin.splashBottomModule?.textChildren?.x,
          y: AMPSSplashPlugin.splashBottomModule?.textChildren?.y
        })
    }
    .backgroundColor(AMPSSplashPlugin.splashBottomModule?.backgroundColor)
    .height(AMPSSplashPlugin.splashBottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}
