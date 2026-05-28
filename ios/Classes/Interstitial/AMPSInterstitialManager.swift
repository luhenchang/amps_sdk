//
//  AMPSInterstitialManager.swift
//  amps_sdk
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSInterstitialManager: NSObject {

    static let shared = AMPSInterstitialManager()
    private override init() { super.init() }

    private var ads: [String: InterstitialAdEntry] = [:]

    private final class InterstitialAdEntry {
        let instanceId: String
        var interstitialAd: AMPSInterstitialAd?
        lazy var delegateHandler: InterstitialDelegateHandler = InterstitialDelegateHandler(entry: self)

        init(instanceId: String) {
            self.instanceId = instanceId
        }

        func cleanup() {
            interstitialAd?.delegate = nil
            interstitialAd = nil
        }
    }

    private final class InterstitialDelegateHandler: NSObject, AMPSInterstitialAdDelegate {
        private weak var entry: InterstitialAdEntry?

        init(entry: InterstitialAdEntry) {
            self.entry = entry
        }

        func ampsInterstitialAdLoadSuccess(_ interstitialAd: AMPSInterstitialAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onLoadSuccess, instanceId: id)
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onRenderOk, instanceId: id)
        }

        func ampsInterstitialAdLoadFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(
                AMPSAdCallBackChannelMethod.onLoadFailure,
                instanceId: id,
                data: ["code": (error as? NSError)?.code ?? 0, "message": (error as? NSError)?.localizedDescription ?? ""]
            )
        }

        func ampsInterstitialAdDidShow(_ interstitialAd: AMPSInterstitialAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdShow, instanceId: id)
        }

        func ampsInterstitialAdExposured(_ interstitialAd: AMPSInterstitialAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdExposure, instanceId: id)
        }

        func ampsInterstitialAdDidClick(_ interstitialAd: AMPSInterstitialAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdClicked, instanceId: id)
        }

        func ampsInterstitialAdShowFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(
                AMPSAdCallBackChannelMethod.onAdShowError,
                instanceId: id,
                data: ["code": (error as? NSError)?.code ?? 0, "message": (error as? NSError)?.localizedDescription ?? ""]
            )
        }

        func ampsInterstitialAdDidClose(_ interstitialAd: AMPSInterstitialAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdClosed, instanceId: id)
            entry?.cleanup()
        }
    }

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AMPSAdSdkMethodNames.interstitialLoad:
            handleInterstitialLoad(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialShowAd:
            handleInterstitialShowAd(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialGetEcpm:
            result(findEntry(from: call.arguments)?.interstitialAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.interstitialNotifyRtbWin:
            handleNotifyRTBWin(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialIsReadyAd:
            result(findEntry(from: call.arguments)?.interstitialAd != nil)
        default:
            result(false)
        }
    }

    private func findEntry(from arguments: Any?) -> InterstitialAdEntry? {
        guard let id = InstanceChannelHelper.instanceId(from: arguments) else { return nil }
        return ads[id]
    }

    private func handleInterstitialLoad(arguments: Any?, result: @escaping FlutterResult) {
        guard let map = arguments as? [String: Any],
              let instanceId = map[InstanceChannelKeys.instanceId] as? String else {
            result(false)
            return
        }

        ads[instanceId]?.cleanup()

        let entry = InterstitialAdEntry(instanceId: instanceId)
        let config = AdOptionModule.getAdConfig(para: map)
        entry.interstitialAd = AMPSInterstitialAd(adConfiguration: config)
        entry.interstitialAd?.delegate = entry.delegateHandler
        ads[instanceId] = entry
        entry.interstitialAd?.load()
        result(true)
    }

    private func handleInterstitialShowAd(arguments: Any?, result: @escaping FlutterResult) {
        guard let entry = findEntry(from: arguments),
              let interstitialAd = entry.interstitialAd,
              let vc = getKeyWindow()?.rootViewController else {
            result(false)
            return
        }
        interstitialAd.show(withRootViewController: vc)
        result(true)
    }

    private func handleNotifyRTBWin(arguments: Any?, result: @escaping FlutterResult) {
        guard let map = arguments as? [String: Any],
              let entry = findEntry(from: arguments) else {
            result(false)
            return
        }
        let winPrice = map[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = map[ArgumentKeys.adSecPrice] as? Int ?? 0
        entry.interstitialAd?.sendWinNotification(withInfo: [BidKeys.winPrince: winPrice, BidKeys.lossSecondPrice: secPrice])
        result(true)
    }

    private func handleNotifyRTBLoss(arguments: Any?, result: @escaping FlutterResult) {
        guard let map = arguments as? [String: Any],
              let entry = findEntry(from: arguments) else {
            result(false)
            return
        }
        let lossWinPrice = map[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = map[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = map[ArgumentKeys.adLossReason] as? String ?? ""
        entry.interstitialAd?.sendLossNotification(withInfo: [
            BidKeys.winPrince: lossWinPrice,
            BidKeys.lossSecondPrice: lossSecPrice,
            BidKeys.lossReason: lossReason,
        ])
        result(true)
    }
}
