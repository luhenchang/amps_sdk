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
import { ampsAd, AMPSInterstitialAd } from 'biz.beizi.adn';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../data/StringConstants';

class InterstitialAdEntry {
  instanceId: string;
  interstitialAd?: AMPSInterstitialAd;

  constructor(instanceId: string) {
    this.instanceId = instanceId;
  }
}

export class AMPSInterstitialManager {
  private static instance: AMPSInterstitialManager;
  private ads: Map<string, InterstitialAdEntry> = new Map();

  public static getInstance(): AMPSInterstitialManager {
    if (!AMPSInterstitialManager.instance) {
      AMPSInterstitialManager.instance = new AMPSInterstitialManager();
    }
    return AMPSInterstitialManager.instance;
  }

  private findEntry(args: Any): InterstitialAdEntry | undefined {
    const id = InstanceChannelHelper.instanceId(args);
    if (!id) {
      return undefined;
    }
    return this.ads.get(id);
  }

  private getOrCreateEntry(instanceId: string): InterstitialAdEntry {
    let entry = this.ads.get(instanceId);
    if (!entry) {
      entry = new InterstitialAdEntry(instanceId);
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
      case AMPSAdSdkMethodNames.interstitialLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.interstitialShowAd:
        this.handleShowAd(result, call.args);
        break;
      case AMPSAdSdkMethodNames.interstitialGetECPM:
        result.success(this.findEntry(call.args)?.interstitialAd?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.interstitialNotifyRTBWin: {
        const entry = this.findEntry(call.args);
        const params: HashMap<String, number> = call.args;
        const winPrice: number = params.get(AD_WIN_PRICE) ?? 0;
        const secPrice: number = params.get(AD_SEC_PRICE) ?? 0;
        entry?.interstitialAd?.notifyRTBWin(winPrice, secPrice);
        result.success(null);
        break;
      }
      case AMPSAdSdkMethodNames.interstitialNotifyRTBLoss: {
        const entry = this.findEntry(call.args);
        const lossParams: HashMap<String, Any> = call.args;
        const lossWinPrice: number = lossParams.get(AD_WIN_PRICE) ?? 0;
        const lossSecPrice: number = lossParams.get(AD_SEC_PRICE) ?? 0;
        const lossReason: string = lossParams.get(AD_LOSS_REASON) ?? StringConstants.EMPTY_STRING;
        entry?.interstitialAd?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason);
        result.success(null);
        break;
      }
      case AMPSAdSdkMethodNames.interstitialIsReadyAd:
        result.success(this.findEntry(call.args)?.interstitialAd?.isReadyAd() ?? false);
        break;
      default:
        result.notImplemented();
    }
  }

  private handleLoadAd(call: MethodCall, result: MethodResult): void {
    const instanceId = InstanceChannelHelper.instanceId(call.args);
    if (!instanceId) {
      result.error('LOAD_FAILED', 'instanceId is required', undefined);
      return;
    }

    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      const entry = this.getOrCreateEntry(instanceId);
      entry.interstitialAd = new AMPSInterstitialAd(adOption, this.createCallback(instanceId));
      entry.interstitialAd.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleShowAd(result: MethodResult, args: Any): void {
    const entry = this.findEntry(args);
    try {
      const context = AMPSEventManager.getInstance().getContext();
      if (entry?.interstitialAd && context) {
        entry.interstitialAd.showAd({
          windowStage: context.windowStage,
          uiContext: context.windowStage.getMainWindowSync().getUIContext(),
        });
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }
}
