//
//  AMPS interstitialManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/23.
//

import Foundation

import Flutter
import AMPSAdSDK
//import ASNPAdSDK


class AMPSInterstitialManager: NSObject {
    
    static let shared: AMPSInterstitialManager = .init()
    private override init() {}
    
    private var interstitialAd: AMPSInterstitialAd?
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.interstitialLoad:
            handleInterstitialLoad(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.interstitialShowAd:
            handleInterstitialShowAd(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.interstitialGetEcpm:
            result(interstitialAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.interstitialNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialIsReadyAd:
//            result(interstitialAd?.isReadyAd() ?? false)
            
            result(false)
        default:
            result(false)
        }
    }
//
//    // MARK: - Private Methods
    private func handleInterstitialLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            return
        }
//        let config = AdOptionModule.getAsnpAdConfig(para: param)
        let config = AdOptionModule.getAdConfig(para: param)
        interstitialAd = AMPSInterstitialAd(adConfiguration: config)
//        interstitialAd = ASNPInterstitialAd(adConfiguration: config)
        interstitialAd?.delegate = self
        interstitialAd?.load()
        result(true)
    }
    
    private func handleInterstitialShowAd(arguments: [String: Any]?, result: FlutterResult) {
        guard let interstitialAd = interstitialAd else {
            result(false)
            return
        }
        
        guard let vc = getKeyWindow()?.rootViewController else {
            
            result(false)
            return
        }
        interstitialAd.show(withRootViewController: vc)
//        interstitialAd.showInterstitialView(inRootViewController: vc)
        
    
       
    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        interstitialAd?.sendWinNotification(withInfo: [BidKeys.winPrince:winPrice,BidKeys.lossSecondPrice:secPrice])
        result(true)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
        interstitialAd?.sendLossNotification(withInfo: [
            BidKeys.winPrince:lossWinPrice,
            BidKeys.lossSecondPrice:lossSecPrice,
            BidKeys.lossReason:lossReason
        ])
        result(true)
    }
    
    private func cleanupExistingInterstitialViews() {
        UIApplication.shared.windows.forEach { window in
            window.subviews.forEach { subview in
                if subview.tag == 12345 { // Match the tag used for main container
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    private func cleanupViewsAfterAdClosed() {
        cleanupExistingInterstitialViews()
        interstitialAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
}
//extension AMPSInterstitialManager : ASNPInterstitialAdDelegate {
//    func adnInterstitialAdLoadSuccess(_ interstitalAd: ASNPInterstitialAd) {
//        sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
//    }
//    func adnInterstitialAdLoadFail(_ interstitalAd: ASNPInterstitialAd, error: (any Error)?) {
//        sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
//    }
//    func adnInterstitialAdRenderSuccess(_ interstitalAd: ASNPInterstitialAd) {
//        sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
//    }
//    func adnInterstitialAdRenderFail(_ interstitalAd: ASNPInterstitialAd, error: (any Error)?) {
//        sendMessage(AMPSAdCallBackChannelMethod.onRenderFailure,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
//    }
//    func adnInterstitialAdExposured(_ interstitalAd: ASNPInterstitialAd) {
//        sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
//    }
//    func adnInterstitialAdDidShowSuccess(_ interstitalAd: ASNPInterstitialAd) {
//        sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
//    }
//    func adnInterstitialAdDidShowFail(_ interstitalAd: ASNPInterstitialAd, error: (any Error)?) {
//        sendMessage(AMPSAdCallBackChannelMethod.onAdShowError,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
//    }
//    func adnInterstitialAdDidClick(_ interstitalAd: ASNPInterstitialAd) {
//        sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
//    }
//    func adnInterstitialAdDidClose(_ interstitalAd: ASNPInterstitialAd) {
//        sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
//    }
//}

extension AMPSInterstitialManager : AMPSInterstitialAdDelegate {
    func ampsInterstitialAdLoadSuccess(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
        sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
    }
    func ampsInterstitialAdLoadFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsInterstitialAdDidShow(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
    }
    func ampsInterstitialAdExposured(_ interstitialAd: AMPSInterstitialAd){
        sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
    }
    func ampsInterstitialAdDidClick(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
    }
    
    func ampsInterstitialAdShowFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShowError,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsInterstitialAdDidClose(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
    }
}
