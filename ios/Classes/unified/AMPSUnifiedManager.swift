//
//  AMPSUnifiedManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/28.
//

import Foundation
import AMPSAdSDK
import Flutter

class AmpsIosUnifiedNativeManager: NSObject,AMPSUnifiedNativeManagerDelegate,AMPSUnifiedNativeViewDelegate {
    
    var unifiedNative: AMPSUnifiedNativeManager?
    var adIdMap: [String: AMPSUnifiedNativeAd] = [:]
    
    
    func getUnifiedNativeAd(_ adId: String) -> AMPSUnifiedNativeAd?{
        let ad = self.adIdMap[adId]
        return ad
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
            result(unifiedNative?.adArray.first?.eCPM)
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
        unifiedNative = AMPSUnifiedNativeManager(spaceId: config.spaceId, adConfiguration: config)
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
        AMPSEventManager.getInstance().sendToFlutter(method, arg: args)
    }
    
    
    //AMPSUnifiedNativeManagerDelegate
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSUnifiedNativeManager) {
        
        
    }
    func ampsNativeAdLoadFail(_ nativeAd: AMPSUnifiedNativeManager, error: (any Error)?) {
        
    }
    
    //AMPSUnifiedNativeViewDelegate
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    func ampsNativeAdRenderFail(_ nativeView: AMPSUnifiedNativeView, error: (any Error)?) {
        
    }
    func ampsNativeAdExposured(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    func ampsNativeAdDidClick(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    func ampsNativeAdDidClose(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    func ampsNativeAdDidPlayFinish(_ nativeView: AMPSUnifiedNativeView) {
        
    }
    func ampsNativeAdDidCloseOtherController(_ nativeView: AMPSUnifiedNativeView) {
        
    }
}
