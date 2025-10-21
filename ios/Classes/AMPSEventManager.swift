//
//  AMPSEventManager.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation
import Flutter


class AMPSEventManager : NSObject{
   
    private static let instance = AMPSEventManager()
    private override init(){ }
    static func getInstance() -> AMPSEventManager{
        return AMPSEventManager.instance
    }
    var channel: FlutterMethodChannel?
    func regist(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "amps_sdk", binaryMessenger:  messenger)
        channel?.setMethodCallHandler { methodCall, result in
            switch methodCall.method {
            case let name where  initMethodNames.contains(name):
                print("")
            default:
                print("")
            }
        }
        
    }
    func sendToFlutter(_ method:String,arg:Any? = nil){
        channel?.invokeMethod(method, arguments: arg)
    }
    
}
