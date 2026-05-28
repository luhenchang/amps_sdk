import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AD_LOSS_REASON,
  AD_SEC_PRICE,
  AD_WIN_PRICE,
  AMPSAdCallBackChannelMethod,
  AMPSAdSdkMethodNames,
} from '../data/common';
import { InstanceChannelHelper } from '../data/InstanceChannelHelper';
import { AMPSEventManager } from '../sdk/AMPSEventManager';
import { ampsAd, AMPSSplashAd } from 'biz.beizi.adn';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { SplashBottomModule } from '../data/SplashBottomModule';
import { window } from '@kit.ArkUI';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../data/StringConstants';

export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined = wrapBuilder(SplashBottomBuilder);

class SplashAdEntry {
  instanceId: string;
  mSplashAd?: AMPSSplashAd;
  splashBottomModule?: SplashBottomModule | null;

  constructor(instanceId: string) {
    this.instanceId = instanceId;
  }
}

export class AMPSSplashManager {
  private static instance: AMPSSplashManager;
  private ads: Map<string, SplashAdEntry> = new Map();
  private mWindowStage?: window.WindowStage;
  private mWindow?: window.Window;

  /** 当前展示开屏的底部视图配置（Builder 读取） */
  static splashBottomModule: SplashBottomModule | null | undefined = null;

  public static getInstance(): AMPSSplashManager {
    if (!AMPSSplashManager.instance) {
      AMPSSplashManager.instance = new AMPSSplashManager();
    }
    return AMPSSplashManager.instance;
  }

  private findEntry(args: Any): SplashAdEntry | undefined {
    const id = InstanceChannelHelper.instanceId(args);
    if (!id) {
      return undefined;
    }
    return this.ads.get(id);
  }

  private getOrCreateEntry(instanceId: string): SplashAdEntry {
    let entry = this.ads.get(instanceId);
    if (!entry) {
      entry = new SplashAdEntry(instanceId);
      this.ads.set(instanceId, entry);
    }
    return entry;
  }

  private createCallback(instanceId: string): ampsAd.CallBack {
    return {
      onLoadSuccess: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onLoadSuccess, instanceId),
      onLoadFailure: (code: number, message: string) =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onLoadFailure, instanceId, { code, message }),
      onRenderOk: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onRenderOk, instanceId),
      onAdShow: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdShow, instanceId),
      onAdExposure: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdExposure, instanceId),
      onAdClicked: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdClicked, instanceId),
      onAdClosed: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdClosed, instanceId),
      onRenderFailure: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onRenderFailure, instanceId),
      onAdShowError: (code: number, message: string) =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdShowError, instanceId, { code, message }),
      onVideoPlayStart: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onVideoPlayStart, instanceId),
      onVideoPlayEnd: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onVideoPlayEnd, instanceId),
      onVideoPlayError: (code: number, message: string) =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onVideoPlayError, instanceId, { code, message }),
      onVideoSkipToEnd: (playDurationMs?: number) =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onVideoSkipToEnd, instanceId, { playDurationMs }),
      onAdReward: () =>
        InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdReward, instanceId),
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.splashLoad:
        this.handleSplashLoad(call, result);
        break;
      case AMPSAdSdkMethodNames.splashShowAd:
        this.handleSplashShowAd(result, call.args);
        break;
      case AMPSAdSdkMethodNames.splashGetECPM:
        result.success(this.findEntry(call.args)?.mSplashAd?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.splashNotifyRTBWin: {
        const entry = this.findEntry(call.args);
        const params: HashMap<String, number> = call.args;
        const winPrice: number = params.get(AD_WIN_PRICE) ?? 0;
        const secPrice: number = params.get(AD_SEC_PRICE) ?? 0;
        entry?.mSplashAd?.notifyRTBWin(winPrice, secPrice);
        result.success(null);
        break;
      }
      case AMPSAdSdkMethodNames.splashNotifyRTBLoss: {
        const entry = this.findEntry(call.args);
        const lossParams: HashMap<String, Any> = call.args;
        const lossWinPrice: number = lossParams.get(AD_WIN_PRICE) ?? 0;
        const lossSecPrice: number = lossParams.get(AD_SEC_PRICE) ?? 0;
        const lossReason: string = lossParams.get(AD_LOSS_REASON) ?? StringConstants.EMPTY_STRING;
        entry?.mSplashAd?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason);
        result.success(null);
        break;
      }
      case AMPSAdSdkMethodNames.splashIsReadyAd:
        result.success(this.findEntry(call.args)?.mSplashAd?.isReadyAd() ?? false);
        break;
      default:
        result.notImplemented();
    }
  }

  private handleSplashLoad(call: MethodCall, result: MethodResult): void {
    const instanceId = InstanceChannelHelper.instanceId(call.args);
    if (!instanceId) {
      result.error('LOAD_FAILED', 'instanceId is required', undefined);
      return;
    }

    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      const context = AMPSEventManager.getInstance().getContext();
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        this.mWindow = this.mWindowStage.getMainWindowSync();
        if (this.mWindow) {
          const entry = this.getOrCreateEntry(instanceId);
          entry.mSplashAd = new AMPSSplashAd(adOption, this.createCallback(instanceId), this.mWindow.getUIContext());
          entry.mSplashAd.load();
          result.success(true);
        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
      }
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleSplashShowAd(result: MethodResult, args: Any): void {
    const entry = this.findEntry(args);
    try {
      if (entry?.mSplashAd && this.mWindowStage) {
        entry.splashBottomModule = new SplashBottomModule(args);
        AMPSSplashManager.splashBottomModule = entry.splashBottomModule;
        entry.mSplashAd.showAd({ windowStage: this.mWindowStage, bottomWrappedBuilder: globalSplashBottomBuilder });
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }
}

@Builder
export function SplashBottomBuilder() {
  if (AMPSSplashManager.splashBottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${AMPSSplashManager.splashBottomModule?.imgChildren?.imagePath}`))
        .width(AMPSSplashManager.splashBottomModule?.imgChildren?.width)
        .height(AMPSSplashManager.splashBottomModule?.imgChildren?.height)
        .offset({
          x: AMPSSplashManager.splashBottomModule?.imgChildren?.x,
          y: AMPSSplashManager.splashBottomModule?.imgChildren?.y,
        });
      Text(AMPSSplashManager.splashBottomModule?.textChildren?.text)
        .fontColor(AMPSSplashManager.splashBottomModule?.textChildren?.color)
        .offset({
          x: AMPSSplashManager.splashBottomModule?.textChildren?.x,
          y: AMPSSplashManager.splashBottomModule?.textChildren?.y,
        });
    }
    .backgroundColor(AMPSSplashManager.splashBottomModule?.backgroundColor)
    .height(AMPSSplashManager.splashBottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart);
  }
}
