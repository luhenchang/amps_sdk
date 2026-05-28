//
//  AMPSUnifiedManager.swift
//  amps_sdk
//

import Foundation
import AMPSAdSDK
import Flutter

class AmpsIosUnifiedNativeManager: NSObject, AMPSUnifiedNativeManagerDelegate {

    let instanceId: String
    var unifiedNative: AMPSUnifiedNativeManager?
    var adIdMap: [String: AMPSUnifiedNativeView] = [:]

    init(instanceId: String) {
        self.instanceId = instanceId
        super.init()
    }

    func getUnifiedNativeAdView(_ adId: String) -> AMPSUnifiedNativeView? {
        return adIdMap[adId]
    }

    func getadId(unifiedAd: AMPSUnifiedNativeView) -> String? {
        if let (id, _) = adIdMap.first(where: { $0.value == unifiedAd }) {
            return id
        }
        return nil
    }

    func getadIdFrom(mediaView: AMPSMediaView) -> String? {
        if let (id, _) = adIdMap.first(where: { $0.value.mediaView == mediaView }) {
            return id
        }
        return nil
    }

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }

        switch call.method {
        case AMPSAdSdkMethodNames.nativeLoad:
            handleNativeLoad(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeGetEcpm:
            if let adId = resolveAdId(from: arguments),
               let view = getUnifiedNativeAdView(adId) {
                result(view.eCPM())
            } else {
                result(0)
            }
        case AMPSAdSdkMethodNames.nativeIsNativeExpress:
            result(false)
        case AMPSAdSdkMethodNames.nativeNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeIsReadyAd:
            if let adId = resolveAdId(from: arguments) {
                result(getUnifiedNativeAdView(adId) != nil)
            } else {
                result(unifiedNative?.adArray.count ?? 0 > 0)
            }
        default:
            result(false)
        }
    }

    private func resolveAdId(from arguments: [String: Any]) -> String? {
        if let data = InstanceChannelHelper.data(from: arguments) as? String {
            return data
        }
        return arguments["adId"] as? String
    }

    private func handleNativeLoad(arguments: [String: Any], result: @escaping FlutterResult) {
        let config = AdOptionModule.getAdConfig(para: arguments)
        unifiedNative = AMPSUnifiedNativeManager(adConfiguration: config)
        unifiedNative?.delegate = self
        unifiedNative?.load()
        result(true)
    }

    private func handleNotifyRTBWin(arguments: [String: Any], result: @escaping FlutterResult) {
        result(false)
    }

    private func handleNotifyRTBLoss(arguments: [String: Any], result: @escaping FlutterResult) {
        result(false)
    }

    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSUnifiedNativeManager) {
        adIdMap.removeAll()
        let ids: [String]? = nativeAd.adArray.map { ad in
            let id = UUID().uuidString
            let view = AMPSUnifiedNativeView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
            let vc = UIViewController.current()
            view.viewController = vc
            view.refreshData(ad)
            view.delegate = self
            view.mediaView.delegate = self
            adIdMap[id] = view
            return id
        }
        InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.loadOk, instanceId: instanceId, data: ids)
        ids?.forEach { adId in
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.renderSuccess, instanceId: instanceId, data: adId)
        }
    }

    func ampsNativeAdLoadFail(_ nativeAd: AMPSUnifiedNativeManager, error: (any Error)?) {
        InstanceChannelHelper.send(
            AMPSNativeCallBackChannelMethod.loadFail,
            instanceId: instanceId,
            data: ["code": (error as? NSError)?.code ?? 0, "message": error?.localizedDescription ?? ""]
        )
    }
}

extension AmpsIosUnifiedNativeManager: AMPSUnifiedNativeViewDelegate, AMPSMediaVideoViewDelegate {
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = getadId(unifiedAd: nativeView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.renderSuccess, instanceId: instanceId, data: adId)
        }
    }

    func ampsNativeAdRenderFail(_ nativeView: AMPSUnifiedNativeView, error: (any Error)?) {
        if let adID = getadId(unifiedAd: nativeView) {
            InstanceChannelHelper.send(
                AMPSNativeCallBackChannelMethod.renderFailed,
                instanceId: instanceId,
                data: ["adId": adID, "code": (error as? NSError)?.code ?? 0, "message": error?.localizedDescription ?? ""]
            )
        }
    }

    func ampsNativeAdExposured(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = getadId(unifiedAd: nativeView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdExposure, instanceId: instanceId, data: adId)
        }
    }

    func ampsNativeAdDidClick(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = getadId(unifiedAd: nativeView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdClicked, instanceId: instanceId, data: adId)
        }
    }

    func ampsNativeAdDidClose(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = getadId(unifiedAd: nativeView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdClosed, instanceId: instanceId, data: adId)
        }
    }

    func ampsNativeAdDidPlayFinish(_ nativeView: AMPSUnifiedNativeView) {}

    func ampsNativeAdDidCloseOtherController(_ nativeView: AMPSUnifiedNativeView) {}

    func ampsMediaVideoViewDidPlay(_ mediaView: AMPSMediaView) {
        if let adId = getadIdFrom(mediaView: mediaView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPlayStart, instanceId: instanceId, data: adId)
        }
    }

    func ampsMediaVideoViewDidPause(_ mediaView: AMPSMediaView) {
        if let adId = getadIdFrom(mediaView: mediaView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPause, instanceId: instanceId, data: adId)
        }
    }

    func ampsMediaVideoViewDidFinishPlay(_ mediaView: AMPSMediaView) {
        if let adId = getadIdFrom(mediaView: mediaView) {
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onVideoPlayComplete, instanceId: instanceId, data: adId)
        }
    }

    func ampsMediaVideoViewDidFailed(toPlay mediaView: AMPSMediaView) {
        if let adId = getadIdFrom(mediaView: mediaView) {
            InstanceChannelHelper.send(
                AMPSNativeCallBackChannelMethod.onVideoPlayError,
                instanceId: instanceId,
                data: ["adId": adId]
            )
        }
    }

    func ampsMediaVideoViewPlayerLeftTime(_ leftTime: Int, mediaView: AMPSMediaView) {}
}
