import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSNativeAd,
  AMPSNativeAdListener,
  AMPSAdVideoPlayConfig,
  AMPSNativeAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSNativeRenderListener,
} from 'biz.beizi.adn';
import {
  AD_ID,
  AD_LOSS_REASON,
  AD_SEC_PRICE,
  AD_WIN_PRICE,
  AMPSAdSdkMethodNames,
  AMPSNativeCallBackChannelMethod,
  VIDEO_LOOP_REPLAY,
  VIDEO_PLAY_TYPE,
  VIDEO_SOUND,
} from '../data/common';
import { InstanceChannelHelper } from '../data/InstanceChannelHelper';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AdWrapperManager } from '../manager/AdWrapperManager';
import { AMPSEventManager } from '../sdk/AMPSEventManager';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../data/StringConstants';

class NativeAdEntry {
  instanceId: string;
  mNativeAd?: AMPSNativeAd;
  mVideoConfig?: AMPSAdVideoPlayConfig;

  constructor(instanceId: string) {
    this.instanceId = instanceId;
  }
}

export class AMPSNativeManager {
  private static instance: AMPSNativeManager;
  private ads: Map<string, NativeAdEntry> = new Map();
  private mWindowStage?: window.WindowStage;

  public static getInstance(): AMPSNativeManager {
    if (!AMPSNativeManager.instance) {
      AMPSNativeManager.instance = new AMPSNativeManager();
    }
    return AMPSNativeManager.instance;
  }

  private findEntry(args: Any): NativeAdEntry | undefined {
    const id = InstanceChannelHelper.instanceId(args);
    if (!id) {
      return undefined;
    }
    return this.ads.get(id);
  }

  private getOrCreateEntry(instanceId: string): NativeAdEntry {
    let entry = this.ads.get(instanceId);
    if (!entry) {
      entry = new NativeAdEntry(instanceId);
      this.ads.set(instanceId, entry);
    }
    return entry;
  }

  private resolveAdId(args: Any): string | undefined {
    const data = InstanceChannelHelper.data(args);
    if (typeof data === 'string') {
      return data;
    }
    if (typeof args === 'string') {
      return args;
    }
    if (args instanceof HashMap) {
      return args.get(AD_ID) as string | undefined;
    }
    return undefined;
  }

  private createInteractiveListener(instanceId: string): AMPSNativeInteractiveListener {
    return {
      onAdShow: (adId?: string | undefined): void => {
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdShow, instanceId, adId);
      },
      onAdExposure: (adId?: string | undefined): void => {
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdExposure, instanceId, adId);
      },
      onAdClicked: (adId?: string | undefined): void => {
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdClicked, instanceId, adId);
      },
      toCloseAd: (adId?: string | undefined): void => {
        if (adId) {
          AdWrapperManager.getInstance().removeAd(adId);
          InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdClosed, instanceId, adId);
        }
      },
    };
  }

  private createRenderListener(entry: NativeAdEntry): AMPSNativeRenderListener {
    const instanceId = entry.instanceId;
    const interactCallBack = this.createInteractiveListener(instanceId);
    return {
      renderSuccess: (adWrapper: AMPSNativeAdWrapper): void => {
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.renderSuccess, instanceId, adWrapper.adId);
        adWrapper.interactCallBack = interactCallBack;
        adWrapper.videoPlayCallBack = {
          onVideoReady: () => {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoReady, instanceId, adWrapper.adId);
          },
          onVideoPlayStart: () => {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPlayStart, instanceId, adWrapper.adId);
          },
          onVideoPause: () => {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPause, instanceId, adWrapper.adId);
          },
          onVideoResume: () => {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoResume, instanceId, adWrapper.adId);
          },
          onVideoPlayComplete: () => {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPlayComplete, instanceId, adWrapper.adId);
          },
          onVideoPlayError: (code, extra) => {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPlayError, instanceId, {
              adId: adWrapper.adId,
              code,
              extra,
            });
          },
        };
        if (entry.mVideoConfig) {
          adWrapper.setVideoPlayConfig(entry.mVideoConfig);
        }
        AdWrapperManager.getInstance().addAd(adWrapper);
      },
      renderFailed: (adWrapper: AMPSNativeAdWrapper): void => {
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.renderFailed, instanceId, {
          adId: adWrapper.adId,
          code: 0,
          message: '',
        });
      },
    };
  }

  private createLoadListener(entry: NativeAdEntry): AMPSNativeAdListener {
    const instanceId = entry.instanceId;
    const renderCallBack = this.createRenderListener(entry);
    return {
      loadOk: (adItems: AMPSNativeAdWrapper[]): void => {
        const adIdList: string[] = adItems.map(ad => ad.adId);
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.loadOk, instanceId, adIdList);
        adItems.forEach((item) => {
          item.renderCallBack = renderCallBack;
          item.renderAd();
        });
      },
      loadFail: (code: number, message: string): void => {
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.loadFail, instanceId, { code, message });
      },
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.nativeLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.nativeGetECPM: {
        const adId = this.resolveAdId(call.args);
        const foundWrapper = adId ? this.getAdWrapperByAdId(adId) : undefined;
        result.success(foundWrapper?.getECPM() ?? 0);
        break;
      }
      case AMPSAdSdkMethodNames.nativeNotifyRTBWin: {
        const params: HashMap<String, Any> = call.args;
        const winPrice: number = params.get(AD_WIN_PRICE) ?? 0;
        const secPrice: number = params.get(AD_SEC_PRICE) ?? 0;
        const mAdId: string = params.get(AD_ID) ?? '';
        const foundWrapper = this.getAdWrapperByAdId(mAdId);
        foundWrapper?.notifyRTBWin(winPrice, secPrice);
        result.success(null);
        break;
      }
      case AMPSAdSdkMethodNames.nativeNotifyRTBLoss: {
        const lossParams: HashMap<String, Any> = call.args;
        const lossWinPrice: number = lossParams.get(AD_WIN_PRICE) ?? 0;
        const lossSecPrice: number = lossParams.get(AD_SEC_PRICE) ?? 0;
        const lossReason: string = lossParams.get(AD_LOSS_REASON) ?? StringConstants.EMPTY_STRING;
        const lossAdId: string = lossParams.get(AD_ID) ?? '';
        const foundWrapper = this.getAdWrapperByAdId(lossAdId);
        foundWrapper?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason);
        result.success(null);
        break;
      }
      case AMPSAdSdkMethodNames.nativeIsReadyAd: {
        const adId = this.resolveAdId(call.args);
        if (!adId) {
          result.success(false);
          break;
        }
        result.success(this.getAdWrapperByAdId(adId) != undefined);
        break;
      }
      case AMPSAdSdkMethodNames.nativeIsNativeExpress: {
        const adId = this.resolveAdId(call.args);
        const wrapperForAId = adId ? this.getAdWrapperByAdId(adId) : undefined;
        result.success(wrapperForAId?.isNativeExpress() ?? false);
        break;
      }
      case AMPSAdSdkMethodNames.nativeGetVideoDuration: {
        const adId = this.resolveAdId(call.args);
        const wrapperByAdId = adId ? this.getAdWrapperByAdId(adId) : undefined;
        result.success(wrapperByAdId?.getVideoDuration() ?? 0);
        break;
      }
      case AMPSAdSdkMethodNames.nativeSetVideoPlayConfig: {
        const entry = this.findEntry(call.args);
        const vdConfigParams: HashMap<String, Any> = call.args;
        const videoSound: boolean = vdConfigParams.get(VIDEO_SOUND) ?? false;
        const videoPlayType: number = vdConfigParams.get(VIDEO_PLAY_TYPE) ?? 0;
        const videoLoopReplay: boolean = vdConfigParams.get(VIDEO_LOOP_REPLAY) ?? false;
        if (entry) {
          entry.mVideoConfig = {
            videoSoundEnable: videoSound,
            videoAutoPlayType: videoPlayType,
            videoLoopReplay: videoLoopReplay,
          };
        }
        result.success(true);
        break;
      }
      default:
        result.notImplemented();
    }
  }

  private getAdWrapperByAdId(targetAdId: string): AMPSNativeAdWrapper | undefined {
    return AdWrapperManager.getInstance().getAd(targetAdId);
  }

  private handleLoadAd(call: MethodCall, result: MethodResult): void {
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
        const mWindow = this.mWindowStage.getMainWindowSync();
        if (mWindow) {
          const entry = this.getOrCreateEntry(instanceId);
          entry.mNativeAd = new AMPSNativeAd(mWindow.getUIContext(), adOption, this.createLoadListener(entry));
          entry.mNativeAd.load();
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
}
