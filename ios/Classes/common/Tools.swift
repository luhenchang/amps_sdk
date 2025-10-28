//
//  Tools.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import UIKit

func getKeyWindow() -> UIWindow? {
    // iOS 15+ 推荐使用 sceneDelegate 管理的窗口
    if #available(iOS 15.0, *) {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    } else if #available(iOS 13.0, *) {
        // iOS 13-14 多场景适配
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    } else {
        // iOS 12 及以下（单窗口时代）
        return UIApplication.shared.keyWindow
    }
}
