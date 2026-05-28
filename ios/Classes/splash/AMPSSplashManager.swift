//
//  AMPSSplashManager.swift
//  amps_sdk
//

import Foundation
import Flutter
import AMPSAdSDK

private enum AMPSSplashConstant {
    static let defaultBottomViewHeight: CGFloat = 0
    static let defaultImageSize: CGSize = CGSize(width: 100, height: 100)
    static let defaultFontSize: CGFloat = 14
}

class AMPSSplashManager: NSObject {

    static let shared = AMPSSplashManager()
    private override init() { super.init() }

    private var ads: [String: SplashAdEntry] = [:]

    private final class SplashAdEntry {
        let instanceId: String
        var splashAd: AMPSSplashAd?
        lazy var delegateHandler: SplashDelegateHandler = SplashDelegateHandler(entry: self)

        init(instanceId: String) {
            self.instanceId = instanceId
        }

        func cleanup() {
            splashAd?.delegate = nil
            splashAd = nil
        }
    }

    private final class SplashDelegateHandler: NSObject, AMPSSplashAdDelegate {
        private weak var entry: SplashAdEntry?

        init(entry: SplashAdEntry) {
            self.entry = entry
        }

        func ampsSplashAdLoadSuccess(_ splashAd: AMPSSplashAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onLoadSuccess, instanceId: id)
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onRenderOk, instanceId: id)
        }

        func ampsSplashAdLoadFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(
                AMPSAdCallBackChannelMethod.onLoadFailure,
                instanceId: id,
                data: ["code": (error as? NSError)?.code ?? 0, "message": (error as? NSError)?.localizedDescription ?? ""]
            )
        }

        func ampsSplashAdDidShow(_ splashAd: AMPSSplashAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdShow, instanceId: id)
        }

        func ampsSplashAdExposured(_ splashAd: AMPSSplashAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdExposure, instanceId: id)
        }

        func ampsSplashAdDidClick(_ splashAd: AMPSSplashAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdClicked, instanceId: id)
        }

        func ampsSplashAdShowFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(
                AMPSAdCallBackChannelMethod.onAdShowError,
                instanceId: id,
                data: ["code": (error as? NSError)?.code ?? 0, "message": (error as? NSError)?.localizedDescription ?? ""]
            )
        }

        func ampsSplashAdDidClose(_ splashAd: AMPSSplashAd) {
            guard let id = entry?.instanceId else { return }
            InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.onAdClosed, instanceId: id)
            entry?.cleanup()
        }
    }

    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case AMPSAdSdkMethodNames.splashLoad:
            handleSplashLoad(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.splashShowAd:
            handleSplashShowAd(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.splashGetEcpm:
            result(findEntry(from: call.arguments)?.splashAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.splashNotifyRtbWin:
            handleNotifyRTBWin(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.splashNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: call.arguments, result: result)
        case AMPSAdSdkMethodNames.splashIsReadyAd:
            result(findEntry(from: call.arguments)?.splashAd != nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func findEntry(from arguments: Any?) -> SplashAdEntry? {
        guard let id = InstanceChannelHelper.instanceId(from: arguments) else { return nil }
        return ads[id]
    }

    private func handleSplashLoad(arguments: Any?, result: @escaping FlutterResult) {
        guard let map = arguments as? [String: Any],
              let instanceId = map[InstanceChannelKeys.instanceId] as? String else {
            result(false)
            return
        }

        ads[instanceId]?.cleanup()

        let entry = SplashAdEntry(instanceId: instanceId)
        let config = AdOptionModule.getAdConfig(para: map)
        entry.splashAd = AMPSSplashAd(adConfiguration: config)
        entry.splashAd?.delegate = entry.delegateHandler
        ads[instanceId] = entry
        entry.splashAd?.load()
        result(true)
    }

    private func handleSplashShowAd(arguments: Any?, result: @escaping FlutterResult) {
        guard let entry = findEntry(from: arguments),
              let splashAd = entry.splashAd,
              let window = getKeyWindow() else {
            result(false)
            return
        }

        if let param = arguments as? [String: Any] {
            let height = param["height"] as? CGFloat ?? 0
            let bgColor = param["backgroundColor"] as? String
            var imageModel: SplashBottomImage?
            var textModel: SplashBottomText?
            if let children = param["children"] as? [[String: Any]] {
                children.forEach { child in
                    let type = child["type"] as? String ?? ""
                    if type == "image" {
                        imageModel = Tools.convertToModel(from: child)
                    } else if type == "text" {
                        textModel = Tools.convertToModel(from: child)
                    }
                }
            }
            if height > 1 {
                let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(window.bounds.width), height: height))
                if let bgColor = bgColor {
                    bottomView.backgroundColor = UIColor(hexString: bgColor)
                }
                if let imageModel = imageModel {
                    let imageView = UIImageView(frame: CGRect(
                        x: imageModel.x ?? 0,
                        y: imageModel.y ?? 0,
                        width: imageModel.width ?? 100,
                        height: imageModel.height ?? 100
                    ))
                    if let imageName = imageModel.imagePath {
                        imageView.image = AMPSEventManager.shared.getImage(imageName)
                    }
                    bottomView.addSubview(imageView)
                }
                if let text = textModel?.text {
                    let width = window.bounds.width - (textModel?.x ?? 0)
                    let tagLabel = UILabel(frame: CGRect(x: textModel?.x ?? 0, y: textModel?.y ?? 0, width: width, height: 0))
                    tagLabel.numberOfLines = 0
                    if let color = textModel?.color {
                        tagLabel.textColor = UIColor(hexString: color)
                    }
                    tagLabel.text = text
                    if let font = textModel?.fontSize {
                        tagLabel.font = UIFont.systemFont(ofSize: font)
                    }
                    bottomView.addSubview(tagLabel)
                    let fittingSize = tagLabel.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
                    tagLabel.frame.size.height = fittingSize.height
                }
                splashAd.showSplashView(in: window, bottomView: bottomView)
            } else {
                splashAd.showSplashView(in: window)
            }
        } else {
            splashAd.showSplashView(in: window)
        }
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
        entry.splashAd?.sendWinNotification(withInfo: [BidKeys.winPrince: winPrice, BidKeys.lossSecondPrice: secPrice])
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
        entry.splashAd?.sendLossNotification(withInfo: [
            BidKeys.winPrince: lossWinPrice,
            BidKeys.lossSecondPrice: lossSecPrice,
            BidKeys.lossReason: lossReason,
        ])
        result(true)
    }
}
