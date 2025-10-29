
//
//  AMPSNativeView.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/24.
//

import Foundation
import Flutter


class AMPSNAtiveViewFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AMPSNativeView(frame: frame, viewId: viewId, args: args)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    
}

class AMPSNativeView : NSObject, FlutterPlatformView {
    
    private var iosView: UIView
    init(frame: CGRect,viewId: Int64,args:Any?) {
        self.iosView = UIView(frame: frame)
        self.iosView.backgroundColor = UIColor.orange
        if let param = args as? [String: Any?]{
           if let adId = param["adId"] as? String {
               if let adView = AMPSNativeManager.getInstance().getAdView(adId: adId) {
                   if let width = param["width"] as? CGFloat {
                       adView.bounds.size.width = width
                       self.iosView.frame.size.width = UIScreen.main.bounds.width
                       adView.frame.origin.x =  (self.iosView.frame.size.width - width)/2
                    
                   }
                   self.iosView.clipsToBounds = true
                   self.iosView.addSubview(adView)
               }
           }
        }
    }
    func view() -> UIView {
        return iosView
    }
}
