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
    static let shared: AMPSSDKInitManager = AMPSSDKInitManager()
    
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
        
        let config =  AMPSAdSDKConfiguration()
       
        if let https = initParam?._isUseHttps{
            config.isUseHttps = https
        }
        if let recommend = initParam?.adController?.isSupportPersonalized{
            config.recommend = recommend ? .open : .close
        }
//        if let adapterNames = initParam?.adapterNames {
//            config. = adapterNames
//        }
        let locationPro =  AMPSAdSDKLocationProvider()
        if let idfa = initParam?.adController?.OAID{
            config.customIDFA = idfa
        }
        if let currency = initParam?.currency{
            config.county_CN =  currency == "CNY" ? true : false
        }
        
         
        if let location = initParam?.adController?.location{
            locationPro.canUseLocation = initParam?.adController?.isLocationEnabled ?? true
            if let coordinate = location.coordinate{
                locationPro.coordinate = coordinate
            }
            if let latitude = location.latitude {
                locationPro.latitude = Float(latitude)
            }
            if let longitude = location.longitude{
                locationPro.longitude = Float(longitude)
            }
            if let timeStamp = location.timeStamp{
                locationPro.timestamp = UInt64(timeStamp)
            }
        
        }
        AMPSAdSDKManager.sharedInstance().startAsync(withAppId: appid, configuration: config) { status in
    
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
    
    }
    
    func sendMessage(_ method: String, args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method)
    }
}


