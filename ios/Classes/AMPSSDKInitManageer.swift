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
        let appid = flutterParams?["appId"] as? String
        AMPSAdSDKManager.sharedInstance().startAsync(withAppId: "") { status in
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

// 初始化回调实现类
//class InitCallback: IAMPSInitCallback {
//    private let onSuccess: () -> Void
//    private let onFail: (AMPSError?) -> Void
//    
//    init(success: @escaping () -> Void, failCallback: @escaping (AMPSError?) -> Void) {
//        self.onSuccess = success
//        self.onFail = failCallback
//    }
//    
//    func successCallback() {
//        onSuccess()
//    }
//    
//    func failCallback(_ error: AMPSError?) {
//        onFail(error)
//    }
//}
