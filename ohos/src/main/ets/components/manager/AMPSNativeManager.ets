import {
  Any, MethodCall, MethodResult
} from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSNativeAd,
  AMPSNativeAdListener,
  AMPSNativeAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSNativeRenderListener
} from 'biz.beizi.adn';
import { AMPSAdSdkMethodNames, AMPSNativeCallBackChannelMethod } from '../data/common';
import { AdOptionsModule } from '../data/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AdWrapperManager } from '../manager/AdWrapperManager';
import { AMPSEventManager } from '../sdk/AMPSEventManager';

export class AMPSNativeManager {
  private static instance: AMPSNativeManager;
  // 使用private修饰符限制访问，并添加明确类型
  private mWindowStage?: window.WindowStage;
  private mNativeAd?: AMPSNativeAd;
  private mAdWrapperCallBack: AMPSNativeInteractiveListener = {
    onAdShow: (adId?: string | undefined): void => {
      this.sendMessage(AMPSNativeCallBackChannelMethod.onAdShow, adId)
    },
    onAdExposure: (adId?: string | undefined): void => {
      this.sendMessage(AMPSNativeCallBackChannelMethod.onAdExposure, adId)
    },
    onAdClicked: (adId?: string | undefined): void => {
      this.sendMessage(AMPSNativeCallBackChannelMethod.onAdClicked, adId)
    },
    toCloseAd: (adId?: string | undefined): void => {
      if (adId) {
        AdWrapperManager.getInstance().removeAd(adId);
        this.sendMessage(AMPSNativeCallBackChannelMethod.onAdClosed, adId)
      }
    }
  }
  private mRenderCallBack: AMPSNativeRenderListener = {
    renderSuccess: (adWrapper: AMPSNativeAdWrapper): void => {
      this.sendMessage(AMPSNativeCallBackChannelMethod.renderSuccess, adWrapper.adId)
      adWrapper.interactCallBack = this.mAdWrapperCallBack;
      adWrapper.videoPlayCallBack = {
        onVideoReady: () => {
          this.sendMessage(AMPSNativeCallBackChannelMethod.onVideoReady, adWrapper.adId)
        },
        onVideoPlayStart: () => {
          this.sendMessage(AMPSNativeCallBackChannelMethod.onVideoPlayStart, adWrapper.adId)
        },
        onVideoPause: () => {
          this.sendMessage(AMPSNativeCallBackChannelMethod.onVideoPause, adWrapper.adId)
        },
        onVideoResume: () => {
          this.sendMessage(AMPSNativeCallBackChannelMethod.onVideoResume, adWrapper.adId)
        },
        onVideoPlayComplete: () => {
          this.sendMessage(AMPSNativeCallBackChannelMethod.onVideoPlayComplete, adWrapper.adId)
        },
        onVideoPlayError: (code, extra) => {
          let adId = adWrapper.adId
          this.sendMessage(AMPSNativeCallBackChannelMethod.onVideoPlayError, { adId, code, extra })
        }
      };
      //需要缓存到单利。使用完毕之后移除
      AdWrapperManager.getInstance().addAd(adWrapper);
    },
    renderFailed: (adWrapper: AMPSNativeAdWrapper): void => {
      this.sendMessage(AMPSNativeCallBackChannelMethod.renderFailed, adWrapper.adId)
    }
  }
  private callback: AMPSNativeAdListener = {
    loadOk: (adItems: AMPSNativeAdWrapper[]): void => {
      const adIdList: string[] = adItems.map(ad => ad.adId);
      //回调给Flutter端
      this.sendMessage(AMPSNativeCallBackChannelMethod.loadOk, adIdList)
      //render
      adItems.forEach((item) => {
        item.renderCallBack = this.mRenderCallBack;
        item.renderAd();
      })
    },
    loadFail: (code: number, message: string): void => {
      this.sendMessage(AMPSNativeCallBackChannelMethod.loadFail,{ code, message })
    }
  };

  public static getInstance(): AMPSNativeManager {
    if (!AMPSNativeManager.instance) {
      AMPSNativeManager.instance = new AMPSNativeManager();
    }
    return AMPSNativeManager.instance;
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.nativeLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.nativeShowAd:
        break;
      default:
        result.notImplemented();
    }
  }

  // 处理开屏广告加载
  private handleLoadAd(call: MethodCall, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      let context = AMPSEventManager.getInstance().getContext()
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        let mWindow = this.mWindowStage.getMainWindowSync();
        if (mWindow) {
          this.mNativeAd = new AMPSNativeAd(mWindow.getUIContext(), adOption, this.callback);
          this.mNativeAd.load();
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

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}