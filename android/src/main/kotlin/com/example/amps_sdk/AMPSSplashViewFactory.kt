package com.example.amps_sdk

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

// 2. Create the PlatformViewFactory
class AMPSSplashViewFactory(mActivity: Activity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    var activity = mActivity
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<*, *>?
        return AMPSSplashView(context,activity, viewId, creationParams)
    }
}