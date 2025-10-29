//
//  AMPSPlatformViewRegistry.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/29.
//

import Foundation
import Flutter

class AMPSPlatformViewRegistry {
    
    
    private static var instance: AMPSPlatformViewRegistry?
    static func getInstance() -> AMPSPlatformViewRegistry{
        if AMPSPlatformViewRegistry.instance == nil {
            AMPSPlatformViewRegistry.instance = .init()
        }
        return AMPSPlatformViewRegistry.instance!
    }
    private init() {}
    
    
    func regist(_ binding: FlutterPluginRegistrar){
        
        binding.register(AMPSNAtiveViewFactory(), withId: AMPSPlatformViewIds.nativeViewId)
        
        
        
    }
    
    
    
}
