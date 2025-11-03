//
//  AMPSNativeManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/24.
//

import Foundation

import Flutter
import AMPSAdSDK
//import ASNPAdSDK

class AMPSNativeManager: NSObject {
    
    private static var instance: AMPSNativeManager?
//    var nativeAd: ASNPNativeExpressManager?
//    var adIdMap: [ASNPNativeExpressView: String] = [:]
    var nativeAd: AMPSNativeExpressManager?
    var adIdMap: [AMPSNativeExpressView: String] = [:]
    
    let unifiedManager: AmpsIosUnifiedNativeManager = .init()
    

    var isNativeExpress:Bool = true

    // Singleton
    static func getInstance() -> AMPSNativeManager {
        if instance == nil {
            instance = AMPSNativeManager()
        }
        return instance!
    }

    private override init() {}
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        if let type = arguments["nativeType"] as? Int, type == 1 {
            self.unifiedManager.handleMethodCall(call, result: result)
            return
        }
        switch call.method {
        case AMPSAdSdkMethodNames.nativeLoad:
            handleNativeLoad(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.nativeGetEcpm:
            if let adId = arguments["adId"] as? String {
                if  let view = self.getAdView(adId: adId) {
                    result(view.eCPM())
                    return
                }
            }
            result(0)
            
        case AMPSAdSdkMethodNames.nativeIsNativeExpress:
            result(true)
        case AMPSAdSdkMethodNames.nativeNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeIsReadyAd:
            result(nativeAd?.viewsArray.count ?? 0 > 0)
//            result(false)
        default:
            result(false)
        }
    }

    // MARK: - Private Methods
    private func handleNativeLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            return
        }
        
        let configAM = AdOptionModule.getAdConfig(para: param)
//        let config = AdOptionModule.getAsnpAdConfig(para: param)
    
//        configAM.spaceId = "15354"
//        nativeAd = ASNPNativeExpressManager(adConfiguration: config)
//        nativeAd?.delegate = self
//        nativeAd?.loadAd(withCount: configAM.adCount)
        nativeAd = AMPSNativeExpressManager(spaceId: configAM.spaceId, adConfiguration: configAM)
        nativeAd?.delegate = self
        nativeAd?.load()
        result(true)
    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        self.adIdMap.forEach({ (view,_) in
            view.sendWinNotification(withInfo: [BidKeys.winPrince:winPrice,BidKeys.lossSecondPrice:secPrice])
        })
        result(true)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        
        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
        self.adIdMap.forEach({ (view,_) in
            view.sendLossNotification(withInfo: [
                BidKeys.winPrince:lossWinPrice,
                BidKeys.lossSecondPrice:lossSecPrice,
                BidKeys.lossReason:lossReason
            ])
        })
        result(true)
    }
    
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.getInstance().sendToFlutter(method, arg: args)
    }
    
    
    //根据adID获取广告位
    func getAdView(adId:String) -> AMPSNativeExpressView?{
        if let (view,_) =  self.adIdMap.first(where: { (key: AMPSNativeExpressView, value: String) in
            return  value == adId
        }) {
            return view
        }
        return nil
    }
    
    func getUnifiedNativeView(_ adId: String) -> AMPSUnifiedNativeView?{
       return self.unifiedManager.getUnifiedNativeAdView(adId)
    }
    
    
}
extension AMPSNativeManager: AMPSNativeExpressManagerDelegate{
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSNativeExpressManager) {
        self.adIdMap.removeAll()
        let ids: [String]? =  nativeAd.viewsArray.map({ view in
            let id = UUID().uuidString
            self.adIdMap[view] = id
            return id
        })
        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ids)
        
        nativeAd.viewsArray.forEach { view in
            view.delegate = self
            view.render()
        }
    }
    func ampsNativeAdLoadFail(_ nativeAd: AMPSNativeExpressManager, error: (any Error)?) {
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail,["code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
    }
    
}

extension AMPSNativeManager: AMPSNativeExpressViewDelegate{
    
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.renderSuccess,adID)
        }
    }
    
    func ampsNativeAdRenderFail(_ nativeView: AMPSNativeExpressView, error: (any Error)?) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.renderFailed,["adId":adID,"code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
        }
    }
    
    func ampsNativeAdExposured(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.onAdExposure,adID)
        }
    }
    
    func ampsNativeAdDidClick(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.onAdClicked,adID)
        }
    }
    
    func ampsNativeAdDidClose(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.onAdClosed,adID)
        }
        self.adIdMap.removeValue(forKey: nativeView)
    }
    
    
}
//extension AMPSNativeManager: ASNPNativeExpressAdDelegate {
//    func adnNativeExpressAdLoadSuccess(_ nativeAd: ASNPNativeExpressManager, views: [ASNPNativeExpressView]) {
//        self.adIdMap.removeAll()
//        let ids: [String]? =  views.map({ view in
//            let id = UUID().uuidString
//            self.adIdMap[view] = id
//            return id
//        })
//        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ids)
//        
//       views.forEach { view in
//            view.delegate = self
//            view.renderAd()
//        }
//    }
//    func adnNativeExpressAdLoadFail(_ nativeAd: ASNPNativeExpressManager, error: (any Error)?) {
//        sendMessage(AMPSNativeCallBackChannelMethod.loadFail,["code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
//    }
//}

//extension AMPSNativeManager :ASNPNativeExpressViewDelegate {
//    func adnNativeExpressViewRenderSuccess(_ nativeView: ASNPNativeExpressView) {
//        if let adID = self.adIdMap[nativeView] {
//            sendMessage(AMPSNativeCallBackChannelMethod.renderSuccess,adID)
//        }
//    }
//    func adnNativeExpressViewRenderFail(_ nativeView: ASNPNativeExpressView, error: (any Error)?) {
//        if let adID = self.adIdMap[nativeView] {
//            sendMessage(AMPSNativeCallBackChannelMethod.renderFailed,["adId":adID,"code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
//        }
//    }
//    func adnNativeExpressViewExposured(_ nativeView: ASNPNativeExpressView) {
//        if let adID = self.adIdMap[nativeView] {
//            sendMessage(AMPSNativeCallBackChannelMethod.onAdExposure,adID)
//        }
//    }
//    func adnNativeExpressViewDidShow(_ nativeView: ASNPNativeExpressView) {
//        if let adID = self.adIdMap[nativeView] {
//            sendMessage(AMPSNativeCallBackChannelMethod.onAdShow,adID)
//        }
//    }
//    func adnNativeExpressViewDidClick(_ nativeView: ASNPNativeExpressView) {
//        if let adID = self.adIdMap[nativeView] {
//            sendMessage(AMPSNativeCallBackChannelMethod.onAdClicked,adID)
//        }
//    }
//    func adnNativeExpressViewDidClose(_ nativeView: ASNPNativeExpressView) {
//        if let adID = self.adIdMap[nativeView] {
//            sendMessage(AMPSNativeCallBackChannelMethod.onAdClosed,adID)
//        }
//        self.adIdMap.removeValue(forKey: nativeView)
//    }
//}







