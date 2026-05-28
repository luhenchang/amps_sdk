//
//  InstanceChannelHelper.swift
//  amps_sdk
//
//  Flutter ↔ iOS 多实例协议辅助：{ instanceId, data }
//

import Foundation

enum InstanceChannelKeys {
    static let instanceId = "instanceId"
    static let data = "data"
}

enum InstanceChannelHelper {
    static func instanceId(from arguments: Any?) -> String? {
        guard let map = arguments as? [String: Any] else { return nil }
        return map[InstanceChannelKeys.instanceId] as? String
    }

    static func data(from arguments: Any?) -> Any? {
        guard let map = arguments as? [String: Any] else { return nil }
        return map[InstanceChannelKeys.data]
    }

    static func payload(instanceId: String, data: Any? = nil) -> [String: Any?] {
        return [
            InstanceChannelKeys.instanceId: instanceId,
            InstanceChannelKeys.data: data,
        ]
    }

    static func send(_ method: String, instanceId: String, data: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: payload(instanceId: instanceId, data: data))
    }
}
