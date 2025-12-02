package com.example.amps_sdk

import com.example.amps_sdk.manager.AMPSEventManager
import com.example.amps_sdk.manager.AMPSPlatformViewManager
import com.example.amps_sdk.utils.FlutterPluginUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

/** AmpsSdkPlugin */
class AmpsSdkPlugin :
    FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AMPSEventManager.getInstance().init(flutterPluginBinding.binaryMessenger)
        AMPSPlatformViewManager.getInstance().init(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AMPSEventManager.getInstance().release()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        FlutterPluginUtil.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }
}
