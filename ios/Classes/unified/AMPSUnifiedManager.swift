//
//  AMPSUnifiedManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/28.
//

import Foundation
import AMPSAdSDK
import Flutter

class AmpsIosUnifiedNativeManager: NSObject,AMPSUnifiedNativeManagerDelegate {
    
    var unifiedNative: AMPSUnifiedNativeManager?
    var adIdMap: [String: AMPSUnifiedNativeView] = [:]
    
    
    func getUnifiedNativeAdView(_ adId: String) -> AMPSUnifiedNativeView?{
        let ad = self.adIdMap[adId]
        return ad
    }
    
    func getadId(unifiedAd: AMPSUnifiedNativeView) -> String? {
        if let (id,_) = self.adIdMap.first(where: { (key: String, value: AMPSUnifiedNativeView) in
            return value == unifiedAd
        }){
            return id
        }
        return nil
    }
    
    
    func getadIdFrom(mediaView: AMPSMediaView) -> String? {
        if let (id,_) = self.adIdMap.first(where: { (key: String, value: AMPSUnifiedNativeView) in
            return value.mediaView == mediaView
        }){
            return id
        }
        return nil
    }
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        
        switch call.method {
        case AMPSAdSdkMethodNames.nativeLoad:
            handleNativeLoad(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.nativeGetEcpm:
            if let adId = arguments["adId"] as? String {
                if  let view = self.getUnifiedNativeAdView(adId) {
                   result(view.eCPM())
                return
                }
            }
            result(0)
        case AMPSAdSdkMethodNames.nativeIsNativeExpress:
            result(false)
        case AMPSAdSdkMethodNames.nativeNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeIsReadyAd:
            result(unifiedNative?.adArray.count ?? 0 > 0)
        default:
            result(false)
        }
    }

    // MARK: - Private Methods
    private func handleNativeLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            return
        }
        
        let config = AdOptionModule.getAdConfig(para: param)
//        config.spaceId = "117907"
        unifiedNative = AMPSUnifiedNativeManager(adConfiguration: config)
        unifiedNative?.delegate = self
        unifiedNative?.load()
        result(true)
    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
//        guard let arguments =  arguments else{
//            return
//        }
//        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
//        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
//    
//        unifiedNative?.adArray.forEach({ ad in
//            ad.sendWinNotification(withInfo: [BidKeys.winPrince:winPrice,BidKeys.lossSecondPrice:secPrice])
//        })
        result(false)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
//        guard let arguments =  arguments else{
//            return
//        }
//        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
//        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
//        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
//        unifiedNative?.adArray.forEach({ view in
//            ad.sendLossNotification(withInfo: [
//                BidKeys.winPrince:lossWinPrice,
//                BidKeys.lossSecondPrice:lossSecPrice,
//                BidKeys.lossReason:lossReason
//            ])
//        })
        result(false)
    }
    
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
    
    //AMPSUnifiedNativeManagerDelegate
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSUnifiedNativeManager) {
        self.adIdMap.removeAll()
        let ids: [String]? =  nativeAd.adArray.map({ ad in
            let id = UUID().uuidString
            let view = AMPSUnifiedNativeView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
            let vc = UIViewController.current()
            view.viewController = vc
            view.refreshData(ad)
            view.delegate = self
            view.mediaView.delegate = self
            self.adIdMap[id] = view
            return id
        })
        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ids)
        
        ids?.forEach({ adId in
            sendMessage(AMPSNativeCallBackChannelMethod.renderSuccess,adId)
        })
        
        
    }
    func ampsNativeAdLoadFail(_ nativeAd: AMPSUnifiedNativeManager, error: (any Error)?) {
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail,["code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
    }
    
    
}

extension AmpsIosUnifiedNativeManager: AMPSUnifiedNativeViewDelegate,AMPSMediaVideoViewDelegate {
    //AMPSUnifiedNativeViewDelegate
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView){
            sendMessage(AMPSNativeCallBackChannelMethod.renderSuccess,adId)
        }
    }
    func ampsNativeAdRenderFail(_ nativeView: AMPSUnifiedNativeView, error: (any Error)?) {
        if let adID = self.getadId(unifiedAd: nativeView) {
            sendMessage(AMPSNativeCallBackChannelMethod.renderFailed,["adId":adID,"code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
        }
    }
    func ampsNativeAdExposured(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView){
            sendMessage(AMPSNativeCallBackChannelMethod.onAdExposure,adId)
        }
        
    }
    func ampsNativeAdDidClick(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView){
            sendMessage(AMPSNativeCallBackChannelMethod.onAdClicked,adId)
        }
    }
    func ampsNativeAdDidClose(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView){
            sendMessage(AMPSNativeCallBackChannelMethod.onAdClosed,adId)
        }
        
    }
    
    func ampsNativeAdDidPlayFinish(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    func ampsNativeAdDidCloseOtherController(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    
    //AMPSMediaVideoViewDelegate
    func ampsMediaVideoViewDidPlay(_ mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView){
            sendMessage(AMPSNativeCallBackChannelMethod.onVideoPlayStart,adId)
        }
    }
    
    func ampsMediaVideoViewDidPause(_ mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView){
            sendMessage(AMPSNativeCallBackChannelMethod.onVideoPause,adId)
        }
    }
    
    func ampsMediaVideoViewDidFinishPlay(_ mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView){
            sendMessage(AMPSNativeCallBackChannelMethod.onVideoPlayComplete,adId)
        }
    }
    
    func ampsMediaVideoViewDidFailed(toPlay mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView){
            sendMessage(AMPSNativeCallBackChannelMethod.onVideoPlayError,["adId":adId])
        }
    }
    
    func ampsMediaVideoViewPlayerLeftTime(_ leftTime: Int, mediaView: AMPSMediaView) {
        
    }
}
