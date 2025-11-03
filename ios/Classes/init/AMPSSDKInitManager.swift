//
//  AMPSSDKInitManageer.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation
import Flutter
import AMPSAdSDK


class AMPSSDKInitManager {
    static let shared: AMPSSDKInitManager = {
        let instance = AMPSSDKInitManager()
        return instance
    }()
    
    private init() {}
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let flutterParams = call.arguments as? [String: Any]
        switch method {
        case AMPSAdSdkMethodNames.sdk_init:
            initAMPSSDK(flutterParams)
            result(true)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func initAMPSSDK(_ flutterParams: [String:Any]?) {
        guard let flutterParams = flutterParams else {
            return
        }
        let initParam: AMPSIOSInitModel? = Tools.convertToModel(from: flutterParams)
        let appid = initParam?.appId ?? ""
//        let appid = "14659"
        AMPSAdSDKManager.sharedInstance().sdkConfiguration.city = initParam?.city ?? ""
        AMPSAdSDKManager.sharedInstance().sdkConfiguration.province = initParam?.province ?? ""
        AMPSAdSDKManager.sharedInstance().sdkConfiguration.region = initParam?.region ?? ""
        if let https = initParam?._isUseHttps{
            AMPSAdSDKManager.sharedInstance().sdkConfiguration.isUseHttps = https
        }
        if let recommend = initParam?.adController?.isSupportPersonalized{
            AMPSAdSDKManager.sharedInstance().sdkConfiguration.recommend = recommend ? .open : .close
        }
        if let adapterNames = initParam?.adapterNames {
            AMPSAdSDKManager.sharedInstance().sdkConfiguration.adapterName = adapterNames
        }
        AMPSAdSDKManager.sharedInstance().startAsync(withAppId: appid) { status in
            if status == AMPSAdSDKInitStatus.success {
                self.sendMessage(AMPSInitChannelMethod.initSuccess)
            }else if status == AMPSAdSDKInitStatus.fail {
                self.sendMessage(AMPSInitChannelMethod.initFailed)
            }else if status == AMPSAdSDKInitStatus.loading {
                self.sendMessage(AMPSInitChannelMethod.initializing)
            }else{
                self.sendMessage(AMPSInitChannelMethod.alreadyInit)
            }
        }
        AMPSAdSDKManager.sharedInstance().sdkConfiguration.recommend = AMPSPersonalizedRecommendState.open
        
    
    }
    
    func sendMessage(_ method: String, args: Any? = nil) {
        AMPSEventManager.getInstance().sendToFlutter(method)
    }
}


