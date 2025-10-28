//
//  AdOptionModule.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import AMPSAdSDK

struct AdOptionModule{
    
    static func getAdConfig(para:[String:Any?]) -> AMPSAdConfiguration{
        let config = AMPSAdConfiguration()
        config.adCount = para[AdOptionKeys.keyAdCount] as? Int ?? 1
        config.spaceId = para[AdOptionKeys.keySpaceId] as? String ?? ""
        if let timeout = para[AdOptionKeys.keyTimeoutInterval] as? TimeInterval {
            config.timeoutInterval = timeout
        }
        return config
    }
}
