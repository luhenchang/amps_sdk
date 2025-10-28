//
//  AMPSSplashManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import Flutter
import AMPSAdSDK


class AMPSSplashManager: NSObject, AMPSSplashAdDelegate {
    
    private static var instance: AMPSSplashManager?
    private var splashAd: AMPSSplashAd?

    // Singleton
    static func getInstance() -> AMPSSplashManager {
        if instance == nil {
            instance = AMPSSplashManager()
        }
        return instance!
    }
//    
    private override init() {}
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.splashLoad:
            handleSplashLoad(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.splashShowAd:
            handleSplashShowAd(arguments: arguments, result: result)
            result(true)
        case AMPSAdSdkMethodNames.splashGetEcpm:
            result(splashAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.splashNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashIsReadyAd:
            result(splashAd?.isReadyAd() ?? false)
        default:
            result(false)
        }
    }
//    
//    // MARK: - Private Methods
    private func handleSplashLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        
        splashAd = AMPSSplashAd(spaceId: config.spaceId, adConfiguration: config)
        splashAd?.delegate = self
        splashAd?.load()
        result(true)
    }
    
    private func handleSplashShowAd(arguments: [String: Any]?, result: FlutterResult) {
        guard let splashAd = splashAd else {
            result(false)
            return
        }
        
        guard let window = getKeyWindow() else {
            
            result(false)
            return
        }
        splashAd.showSplashView(in: window)
        
    
        
//        do {
//            // Clean up any existing splash views
//            cleanupExistingSplashViews()
//            
//            // Create main container
//            let mainContainer = UIView()
//            mainContainer.tag = 12345 // Using tag instead of string for easier handling
//            mainContainer.translatesAutoresizingMaskIntoConstraints = false
//            window.addSubview(mainContainer)
//            
//            // Pin main container to all edges
//            NSLayoutConstraint.activate([
//                mainContainer.topAnchor.constraint(equalTo: window.topAnchor),
//                mainContainer.leadingAnchor.constraint(equalTo: window.leadingAnchor),
//                mainContainer.trailingAnchor.constraint(equalTo: window.trailingAnchor),
//                mainContainer.bottomAnchor.constraint(equalTo: window.bottomAnchor)
//            ])
//            
//            // Create and configure bottom view if needed
//            var customBottomLayout: UIView?
//            let splashBottomData = SplashBottomModule.fromMap(arguments)
//            SplashBottomModule.current = splashBottomData
//            
//            if let data = splashBottomData, data.height > 0 {
//                customBottomLayout = SplashBottomViewFactory.createSplashBottomLayout(viewController, data)
//                if let bottomView = customBottomLayout {
//                    bottomView.translatesAutoresizingMaskIntoConstraints = false
//                    mainContainer.addSubview(bottomView)
//                    
//                    NSLayoutConstraint.activate([
//                        bottomView.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
//                        bottomView.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
//                        bottomView.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor),
//                        bottomView.heightAnchor.constraint(equalToConstant: data.height)
//                    ])
//                }
//            }
//            
//            // Create ad container
//            let adContainer = UIView()
//            adContainer.translatesAutoresizingMaskIntoConstraints = false
//            mainContainer.addSubview(adContainer)
//            
//            // Configure ad container constraints
//            var adConstraints = [
//                adContainer.leadingAnchor.constraint(equalTo: mainContainer.leadingAnchor),
//                adContainer.trailingAnchor.constraint(equalTo: mainContainer.trailingAnchor),
//                adContainer.topAnchor.constraint(equalTo: mainContainer.topAnchor)
//            ]
//            
//            if let bottomView = customBottomLayout {
//                adConstraints.append(adContainer.bottomAnchor.constraint(equalTo: bottomView.topAnchor))
//            } else {
//                adConstraints.append(adContainer.bottomAnchor.constraint(equalTo: mainContainer.bottomAnchor))
//            }
//            
//            NSLayoutConstraint.activate(adConstraints)
//            
//            // Show the ad if ready
//            if splashAd.isReady {
//                splashAd.show(adContainer)
//                result(true, nil)
//            } else {
//                cleanupExistingSplashViews()
//                result(false, NSError(domain: "AMPSSplashManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Splash ad not ready to be shown"]))
//            }
//        } catch {
//            cleanupExistingSplashViews()
//            result(false)
//        }
    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
//        let winPrice = arguments?[StringConstants.AD_WIN_PRICE] as? Int ?? 0
//        let secPrice = arguments?[StringConstants.AD_SEC_PRICE] as? Int ?? 0
//        splashAd?.notifyRTBWin(winPrice, secPrice)
//        result(nil, nil)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
//        let lossWinPrice = arguments?[StringConstants.AD_WIN_PRICE] as? Int ?? 0
//        let lossSecPrice = arguments?[StringConstants.AD_SEC_PRICE] as? Int ?? 0
//        let lossReason = arguments?[StringConstants.AD_LOSS_REASON] as? String ?? StringConstants.EMPTY_STRING
//        splashAd?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason)
//        result(nil, nil)
    }
    
    private func cleanupExistingSplashViews() {
        UIApplication.shared.windows.forEach { window in
            window.subviews.forEach { subview in
                if subview.tag == 12345 { // Match the tag used for main container
                    subview.removeFromSuperview()
                }
            }
        }
    }
    
    private func cleanupViewsAfterAdClosed() {
        cleanupExistingSplashViews()
        splashAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.getInstance().sendToFlutter(method, arg: args)
    }
    
    // MARK: - AMPSSplashLoadEventListener
    func ampsSplashAdLoadSuccess(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
        sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
    }
    func ampsSplashAdLoadFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsSplashAdDidShow(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
    }
    func ampsSplashAdExposured(_ splashAd: AMPSSplashAd){
        sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
    }
    func ampsSplashAdDidClick(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
    }
    
    func ampsSplashAdShowFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShowError,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsSplashAdDidClose(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
    }

//    func onAmpsAdShow() {
//        sendMessage(AMPSAdCallBackChannelMethod.ON_AD_SHOW)
//    }
//    
//    func onAmpsAdClicked() {
//        cleanupViewsAfterAdClosed()
//        sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLICKED)
//    }
//    
//    func onAmpsAdDismiss() {
//        cleanupViewsAfterAdClosed()
//        sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLOSED)
//    }
//    
//    func onAmpsAdFailed(error: AMPSError?) {
//        let errorDict: [String: Any?] = [
//            "code": error?.code,
//            "message": error?.message
//        ]
//        sendMessage(AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE, args: errorDict)
//    }
}

