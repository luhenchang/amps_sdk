//
//  AMPSSplashManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import Flutter
import AMPSAdSDK


class AMPSSplashManager: NSObject, AMPSSplashAdDelegate {
    
    private static var instance: AMPSSplashManager?
    private var splashAd: AMPSSplashAd?

    // Singleton
    static func getInstance() -> AMPSSplashManager {
        if instance == nil {
            instance = AMPSSplashManager()
        }
        return instance!
    }
//    
    private override init() {}
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.splashLoad:
            handleSplashLoad(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.splashShowAd:
            handleSplashShowAd(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.splashGetEcpm:
            result(splashAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.splashNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashIsReadyAd:
            result(splashAd?.isReadyAd() ?? false)
        default:
            result(false)
        }
    }
    
//    // MARK: - Private Methods
    private func handleSplashLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        
        splashAd = AMPSSplashAd(spaceId: config.spaceId, adConfiguration: config)
        splashAd?.delegate = self
        splashAd?.load()
        result(true)
    }
    
    private func handleSplashShowAd(arguments: [String: Any]?, result: FlutterResult) {
        guard let splashAd = splashAd else {
            result(false)
            return
        }
        
        guard let window = getKeyWindow() else {
            
            result(false)
            return
        }
        if let param = arguments {
            let height = param["height"]  as? CGFloat ?? 0
            let bgColor = param["backgroundColor"] as? String
            var imageModel: SplashBottomImage?
            var textModel: SplashBottomText?
            if let children = param["children"] as? [[String: Any]] {
                children.forEach { child in
                    let type = child["type"] as? String ?? ""
                    if type == "image"{
                        imageModel = Tools.convertToModel(from: child)
                    }else if type == "text" {
                        textModel = Tools.convertToModel(from: child)
                    }
                }
            }
            if height > 1 {
                let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(window.bounds.width), height: height))
                if let bgColor = bgColor{
                    bottomView.backgroundColor = UIColor(hexString: bgColor)
                }
                
                if let imageModel = imageModel {
                    let imageView = UIImageView(frame: CGRect(x: imageModel.x ?? 0, y: imageModel.y ?? 0, width: imageModel.width ?? 100, height: imageModel.height ?? 100))
                    if let imageName =  imageModel.imagePath {
                        imageView.image = AMPSEventManager.getInstance().getImage(imageName)
                    }
                    
                    bottomView.addSubview(imageView)
                    imageView.backgroundColor  = UIColor.orange
                }
                if let text = textModel?.text {
                    let widht = window.bounds.width - (textModel?.x ?? 0)
                    let tagLabel = UILabel(frame: CGRect(x: textModel?.x ?? 0, y: textModel?.y ?? 0, width: widht, height: 0))
                    tagLabel.numberOfLines = 0
                    if let color = textModel?.color {
                        tagLabel.textColor = UIColor(hexString: color)
                    }
                    tagLabel.text = text
                    if let font = textModel?.fontSize {
                        tagLabel.font = UIFont.systemFont(ofSize: font)
                    }
                    bottomView.addSubview(tagLabel)
                    let fittingSize = tagLabel.sizeThatFits(CGSize(width: widht, height: CGFloat.greatestFiniteMagnitude))
                    tagLabel.frame.size.height = fittingSize.height // 应用计算出的高度
                }
                
                splashAd.adConfiguration.bottomView = bottomView
            }
            
        }
        splashAd.showSplashView(in: window)
    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        splashAd?.sendWinNotification(withInfo: [BidKeys.winPrince:winPrice,BidKeys.lossSecondPrice:secPrice])
        result(true)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
        splashAd?.sendLossNotification(withInfo: [
            BidKeys.winPrince:lossWinPrice,
            BidKeys.lossSecondPrice:lossSecPrice,
            BidKeys.lossReason:lossReason
        ])
        result(true)
    }
    
    private func cleanupExistingSplashViews() {
        UIApplication.shared.windows.forEach { window in
            window.subviews.forEach { subview in
                if subview.tag == 12345 { // Match the tag used for main container
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    private func cleanupViewsAfterAdClosed() {
        cleanupExistingSplashViews()
        splashAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.getInstance().sendToFlutter(method, arg: args)
    }
    
    // MARK: - AMPSSplashLoadEventListener
    func ampsSplashAdLoadSuccess(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
        sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
    }
    func ampsSplashAdLoadFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsSplashAdDidShow(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
    }
    func ampsSplashAdExposured(_ splashAd: AMPSSplashAd){
        sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
    }
    func ampsSplashAdDidClick(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
    }
    
    func ampsSplashAdShowFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShowError,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsSplashAdDidClose(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
    }

}

