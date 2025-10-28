//
//  AMPSInitConfigConverter.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation


// MARK: - 常量定义
/// UI 模式常量
enum UiModelConstant {
    static let auto = "uiModelAuto"
    static let dark = "uiModelDark"
    static let light = "uiModelLight"
}

/// 坐标系常量
enum CoordinateConstant {
    static let baidu = "BAIDU"
    static let wgs84 = "WGS84"
    static let gcj02 = "GCJ02"
}

/// 参数键常量
enum ParamsKey {
    // 核心参数
    static let testModel = "testModel"
    static let appId = "appId"
    static let isDebugSetting = "_isDebugSetting"
    static let isUseHttps = "_isUseHttps"
    static let isTestAd = "isTestAd"
    
    // 基础信息参数
    static let currency = "currency"
    static let countryCN = "countryCN"
    static let userId = "userId"
    static let appName = "appName"
    static let province = "province"
    static let city = "city"
    static let region = "region"
    
    // 聚合与 UI 参数
    static let isMediation = "isMediation"
    static let isMediationStatic = "isMediationStatic"
    static let uiModel = "uiModel"
    static let adapterNames = "adapterNames"
    
    // 扩展与配置参数
    static let extensionParam = "extensionParam"
    static let optionFields = "optionFields"
    static let adController = "adController"
    static let adapterStatusBarHeight = "adapterStatusBarHeight"
}

/// 广告控制器属性键常量
enum AdControllerPropKey {
    static let isCanUsePhoneState = "isCanUsePhoneState"
    static let oaid = "OAID"
    static let androidID = "AndroidID"  // iOS 无此概念，仅保留键名
    static let gaid = "GAID"            // iOS 对应 IDFA，键名保留
    static let isSupportPersonalized = "isSupportPersonalized"
    static let isCanGatherOAID = "isCanGatherOAID"  // iOS 无此概念
    static let getUnderageTag = "getUnderageTag"
    static let userAgent = "userAgent"
    static let isCanUseSensor = "isCanUseSensor"
    static let isLocationEnabled = "isLocationEnabled"
    static let isCanUseAndroidID = "isCanUseAndroidID"  // iOS 无此概念
    static let location = "location"
}

/// 定位属性键常量
enum LocationPropKey {
    static let latitude = "latitude"    // 纬度
    static let longitude = "longitude"  // 经度
    static let timeStamp = "timeStamp"  // 时间戳
    static let coordinate = "coordinate"// 坐标系
}

// MARK: - 配置转换类（核心逻辑）
//class AMPSInitConfigConverter {
//    // 静态测试模式变量（对应原 companion object 的 @JvmField）
//    static var testModel: Bool = false
//    
//    /// 将 Flutter 参数转换为 AMPSInitConfig
//    /// - Parameter flutterParams: Flutter 传递的参数（字典）
//    /// - Returns: 转换后的初始化配置，nil 表示转换失败
//    func convert(_ flutterParams: [String: Any]?) -> AMPSInitConfig? {
//        guard let params = flutterParams else {
//            print("AMPSInitConfigConverter: flutterParams are null.")
//            return nil
//        }
//        
//        // 1. 校验 AppID（必填）
//        guard let appId = params[ParamsKey.appId] as? String, !appId.isEmpty else {
//            print("AMPSInitConfigConverter: App ID is missing or empty.")
//            return nil
//        }
//        
//        // 2. 初始化配置构建器
//        let builder = AMPSInitConfig.Builder()
//        builder.setAppId(appId)
//        
//        // 3. 配置基础参数
//        // 测试模式
//        if let testModel = params[ParamsKey.testModel] as? Bool {
//            AMPSInitConfigConverter.testModel = testModel
//        }
//        // 调试日志
//        if let isDebug = params[ParamsKey.isDebugSetting] as? Bool {
//            builder.openDebugLog(isDebug)
//        }
//        // HTTPS 开关
//        if let useHttps = params[ParamsKey.isUseHttps] as? Bool {
//            builder.setUseHttps(useHttps)
//        }
//        // 自定义 UA（原 currency 参数映射，根据实际逻辑调整）
//        if let currency = params[ParamsKey.currency] as? String {
//            builder.setCustomUA(currency)
//        }
//        // App 名称
//        if let appName = params[ParamsKey.appName] as? String {
//            builder.setAppName(appName)
//        }
//        // 用户 ID
//        if let userId = params[ParamsKey.userId] as? String {
//            builder.setUserId(userId)
//        }
//        
//        // 4. 配置 UI 模式（原逻辑注释，保留结构供后续扩展）
//        if let uiModel = params[ParamsKey.uiModel] as? String {
//            switch uiModel {
//            case UiModelConstant.auto:
//                // 原逻辑：设置自动模式，根据真实 SDK 接口补充
//                break
//            case UiModelConstant.dark:
//                // 原逻辑：设置暗黑模式
//                break
//            case UiModelConstant.light:
//                // 原逻辑：设置亮色模式
//                break
//            default:
//                break
//            }
//        }
//        
//        // 5. 配置适配器名称（原逻辑注释，保留结构）
//        if let adapterNames = params[ParamsKey.adapterNames] as? [Any] {
//            let stringNames = adapterNames.compactMap { $0 as? String }
//            if !stringNames.isEmpty {
//                // 原逻辑：设置适配器名称，根据真实 SDK 接口补充
//                // builder.setAdapterNames(stringNames)
//            }
//        }
//        
//        // 6. 配置扩展参数（原逻辑注释，保留结构）
//        if let extensionParam = params[ParamsKey.extensionParam] as? [AnyHashable: Any] {
//            for (key, value) in extensionParam {
//                if let valueMap = value as? [String: Any?] {
//                    do {
//                        // 原逻辑：设置扩展参数项，根据真实 SDK 接口补充
//                        // builder.setExtensionParamItems(key as? String, valueMap)
//                    } catch {
//                        print("AMPSInitConfigConverter: Error casting extensionParam value for key \(key) - \(error)")
//                    }
//                }
//            }
//        }
//        
//        // 7. 配置选项字段（过滤非 String 类型值）
//        if let optionFields = params[ParamsKey.optionFields] as? [AnyHashable: Any] {
//            // 过滤值为 String 类型的键值对
//            let safeFields = optionFields.compactMapValues { $0 as? String }
//            if !safeFields.isEmpty {
//                // 原逻辑：设置选项字段，根据真实 SDK 接口补充
//                // builder.setOptionFields(safeFields)
//            }
//        }
//        
//        // 8. 配置状态栏高度（iOS 无此概念，保留结构供后续调整）
//        if let _ = params[ParamsKey.adapterStatusBarHeight] as? Bool {
//            // 原逻辑：设置状态栏高度，iOS 可忽略或替换为安全区域逻辑
//            // builder.setLandStatusBarHeight(...)
//        }
//        
//        // 9. 配置隐私信息（核心逻辑）
//        if let adController = params[ParamsKey.adController] as? [AnyHashable: Any] {
//            // 自定义隐私配置（继承基础类重写方法）
//            let privacyConfig = CustomPrivacyConfig(adController: adController)
//            builder.setAMPSPrivacyConfig(privacyConfig)
//        }
//        
//        // 10. 构建并返回配置
//        return builder.build()
//    }
//}

// MARK: - 自定义隐私配置（实现具体逻辑）
///// 基于 AdController 参数的隐私配置实现
//class CustomPrivacyConfig: AMPSPrivacyConfig {
//    private let adController: [AnyHashable: Any]
//    
//    init(adController: [AnyHashable: Any]) {
//        self.adController = adController
//        super.init()
//    }
//    
//    // 重写：是否允许使用 AndroidID（iOS 无此概念，返回 false）
//    override func isCanUseAndroidID() -> Bool {
//        return adController[AdControllerPropKey.isCanUseAndroidID] as? Bool ?? false
//    }
//    
//    // 重写：是否允许使用定位
//    override func isCanUseLocation() -> Bool {
//        return adController[AdControllerPropKey.isLocationEnabled] as? Bool ?? true
//    }
//    
//    // 重写：是否允许使用摇一摇广告（传感器）
//    override func isCanUseShakeAd() -> Bool {
//        return adController[AdControllerPropKey.isCanUseSensor] as? Bool ?? true
//    }
//    
//    // 重写：是否支持个性化广告
//    override func isSupportPersonalized() -> Bool {
//        return adController[AdControllerPropKey.isSupportPersonalized] as? Bool ?? true
//    }
//    
//    // 重写：获取定位信息
//    override func getLocation() -> AMPSLocation? {
//        guard let locationMap = adController[AdControllerPropKey.location] as? [AnyHashable: Any] else {
//            return nil
//        }
//        
//        let location = AMPSLocation()
//        // 解析纬度（支持 Number 类型转换）
//        if let latitudeNum = locationMap[LocationPropKey.latitude] as? NSNumber {
//            location.latitude = latitudeNum.doubleValue
//        }
//        // 解析经度
//        if let longitudeNum = locationMap[LocationPropKey.longitude] as? NSNumber {
//            location.longitude = longitudeNum.doubleValue
//        }
//        // 解析时间戳
//        if let timeStampNum = locationMap[LocationPropKey.timeStamp] as? NSNumber {
//            location.timestamp = timeStampNum.int64Value
//        }
//        // 解析坐标系类型
//        if let coordinate = locationMap[LocationPropKey.coordinate] as? String {
//            location.coordinateType = coordinate
//        }
//        
//        return location
//    }
//}
