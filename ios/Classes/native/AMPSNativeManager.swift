//
//  AMPSNativeManager.swift
//  amps_sdk
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSNativeManager: NSObject {

    static let shared = AMPSNativeManager()
    private override init() { super.init() }

    private var ads: [String: NativeAdEntry] = [:]
    private var unifiedEntries: [String: AmpsIosUnifiedNativeManager] = [:]

    private final class NativeAdEntry {
        let instanceId: String
        var nativeAd: AMPSNativeExpressManager?
        var adIdMap: [AMPSNativeExpressView: String] = [:]
        lazy var managerDelegate: NativeManagerDelegateHandler = NativeManagerDelegateHandler(entry: self)
        lazy var viewDelegate: NativeViewDelegateHandler = NativeViewDelegateHandler(entry: self)

        init(instanceId: String) {
            self.instanceId = instanceId
        }

        func cleanup() {
            nativeAd?.delegate = nil
            nativeAd = nil
            adIdMap.removeAll()
        }
    }

    private final class NativeManagerDelegateHandler: NSObject, AMPSNativeExpressManagerDelegate {
        private weak var entry: NativeAdEntry?

        init(entry: NativeAdEntry) {
            self.entry = entry
        }

        func ampsNativeAdLoadSuccess(_ nativeAd: AMPSNativeExpressManager) {
            guard let entry = entry else { return }
            entry.adIdMap.removeAll()
            let ids: [String]? = nativeAd.viewsArray.map { view in
                let id = UUID().uuidString
                entry.adIdMap[view] = id
                return id
            }
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.loadOk, instanceId: entry.instanceId, data: ids)
            nativeAd.viewsArray.forEach { view in
                view.delegate = entry.viewDelegate
                view.renderAd()
            }
        }

        func ampsNativeAdLoadFail(_ nativeAd: AMPSNativeExpressManager, error: (any Error)?) {
            guard let entry = entry else { return }
            InstanceChannelHelper.send(
                AMPSNativeCallBackChannelMethod.loadFail,
                instanceId: entry.instanceId,
                data: ["code": (error as? NSError)?.code ?? 0, "message": error?.localizedDescription ?? ""]
            )
        }
    }

    private final class NativeViewDelegateHandler: NSObject, AMPSNativeExpressViewDelegate {
        private weak var entry: NativeAdEntry?

        init(entry: NativeAdEntry) {
            self.entry = entry
        }

        func ampsNativeAdRenderSuccess(_ nativeView: AMPSNativeExpressView) {
            guard let entry = entry, let adID = entry.adIdMap[nativeView] else { return }
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.renderSuccess, instanceId: entry.instanceId, data: adID)
        }

        func ampsNativeAdRenderFail(_ nativeView: AMPSNativeExpressView, error: (any Error)?) {
            guard let entry = entry, let adID = entry.adIdMap[nativeView] else { return }
            InstanceChannelHelper.send(
                AMPSNativeCallBackChannelMethod.renderFailed,
                instanceId: entry.instanceId,
                data: ["adId": adID, "code": (error as? NSError)?.code ?? 0, "message": error?.localizedDescription ?? ""]
            )
        }

        func ampsNativeAdExposured(_ nativeView: AMPSNativeExpressView) {
            guard let entry = entry, let adID = entry.adIdMap[nativeView] else { return }
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdExposure, instanceId: entry.instanceId, data: adID)
        }

        func ampsNativeAdDidClick(_ nativeView: AMPSNativeExpressView) {
            guard let entry = entry, let adID = entry.adIdMap[nativeView] else { return }
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdClicked, instanceId: entry.instanceId, data: adID)
        }

        func ampsNativeAdDidClose(_ nativeView: AMPSNativeExpressView) {
            guard let entry = entry, let adID = entry.adIdMap[nativeView] else { return }
            InstanceChannelHelper.send(AMPSNativeCallBackChannelMethod.onAdClosed, instanceId: entry.instanceId, data: adID)
            entry.adIdMap.removeValue(forKey: nativeView)
        }
    }

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }

        if let type = arguments["nativeType"] as? Int, type == 1 {
            let instanceId = InstanceChannelHelper.instanceId(from: arguments) ?? ""
            let unified = unifiedManager(for: instanceId)
            unified.handleMethodCall(call, result: result)
            return
        }

        switch call.method {
        case AMPSAdSdkMethodNames.nativeLoad:
            handleNativeLoad(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeGetEcpm:
            if let adId = resolveAdId(from: arguments),
               let view = getAdView(adId: adId) {
                result(view.eCPM())
            } else {
                result(0)
            }
        case AMPSAdSdkMethodNames.nativeIsNativeExpress:
            result(true)
        case AMPSAdSdkMethodNames.nativeNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeIsReadyAd:
            if let adId = resolveAdId(from: arguments) {
                result(getAdView(adId: adId) != nil)
            } else {
                result(false)
            }
        default:
            result(false)
        }
    }

    private func unifiedManager(for instanceId: String) -> AmpsIosUnifiedNativeManager {
        if let manager = unifiedEntries[instanceId] {
            return manager
        }
        let manager = AmpsIosUnifiedNativeManager(instanceId: instanceId)
        unifiedEntries[instanceId] = manager
        return manager
    }

    private func findEntry(from arguments: [String: Any]) -> NativeAdEntry? {
        guard let id = InstanceChannelHelper.instanceId(from: arguments) else { return nil }
        return ads[id]
    }

    private func resolveAdId(from arguments: [String: Any]) -> String? {
        if let data = InstanceChannelHelper.data(from: arguments) as? String {
            return data
        }
        return arguments["adId"] as? String
    }

    private func handleNativeLoad(arguments: [String: Any], result: @escaping FlutterResult) {
        guard let instanceId = InstanceChannelHelper.instanceId(from: arguments) else {
            result(false)
            return
        }

        ads[instanceId]?.cleanup()

        let entry = NativeAdEntry(instanceId: instanceId)
        let config = AdOptionModule.getAdConfig(para: arguments)
        entry.nativeAd = AMPSNativeExpressManager(adConfiguration: config)
        entry.nativeAd?.delegate = entry.managerDelegate
        ads[instanceId] = entry
        entry.nativeAd?.load()
        result(true)
    }

    private func handleNotifyRTBWin(arguments: [String: Any], result: @escaping FlutterResult) {
        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        if let adId = arguments[ArgumentKeys.adId] as? String,
           let view = getAdView(adId: adId) {
            view.sendWinNotification(withInfo: [BidKeys.winPrince: winPrice, BidKeys.lossSecondPrice: secPrice])
        }
        result(true)
    }

    private func handleNotifyRTBLoss(arguments: [String: Any], result: @escaping FlutterResult) {
        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
        if let adId = arguments[ArgumentKeys.adId] as? String,
           let view = getAdView(adId: adId) {
            view.sendLossNotification(withInfo: [
                BidKeys.winPrince: lossWinPrice,
                BidKeys.lossSecondPrice: lossSecPrice,
                BidKeys.lossReason: lossReason,
            ])
        }
        result(true)
    }

    func getAdView(adId: String) -> AMPSNativeExpressView? {
        for entry in ads.values {
            if let (view, _) = entry.adIdMap.first(where: { $0.value == adId }) {
                return view
            }
        }
        return nil
    }

    func getUnifiedNativeView(_ adId: String) -> AMPSUnifiedNativeView? {
        for manager in unifiedEntries.values {
            if let view = manager.getUnifiedNativeAdView(adId) {
                return view
            }
        }
        return nil
    }
}
