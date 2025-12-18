package com.example.amps_sdk.manager

import android.content.Context
import android.os.Handler
import android.os.Looper
import biz.beizi.adn.amps.AMPSSDK
import biz.beizi.adn.amps.common.AMPSError
import biz.beizi.adn.amps.init.AMPSInitConfig
import biz.beizi.adn.amps.init.inter.IAMPSInitCallback
import com.example.amps_sdk.data.AMPSAdSdkMethodNames
import com.example.amps_sdk.data.AMPSInitChannelMethod
import com.example.amps_sdk.data.AMPSInitConfigConverter
import com.example.amps_sdk.data.ParamsKey
import com.example.amps_sdk.utils.FlutterPluginUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.common.v2.log.SDKLog

private val mainThreadHandler = Handler(Looper.getMainLooper())

class AMPSSDKInitManager private constructor() {

    companion object {
        @Volatile
        private var instance: AMPSSDKInitManager? = null

        fun getInstance(): AMPSSDKInitManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSSDKInitManager().also { instance = it }
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        val method: String = call.method
        val flutterParams: Map<String, Any>? = call.arguments as? Map<String, Any>

        when (method) {
            AMPSAdSdkMethodNames.INIT -> {
                val context = FlutterPluginUtil.getActivity()
                if (context != null && flutterParams != null) {
                    val isMediation = flutterParams[ParamsKey.IS_MEDIATION] as? Boolean ?: false
                    val ampsConfig = AMPSInitConfigConverter().convert(flutterParams)
                    initAMPSSDK(ampsConfig, context, isMediation)
                    result.success(true)
                } else {
                    if (context == null) {
                        result.error(
                            "CONTEXT_UNAVAILABLE",
                            "Android context is not available.",
                            null
                        )
                    } else {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Initialization arguments are missing or invalid.",
                            null
                        )
                    }
                }
            }

            else -> result.notImplemented()
        }
    }

    fun initAMPSSDK(ampsInitConfig: AMPSInitConfig?, context: Context, isMediation: Boolean) {
        val callback = object : IAMPSInitCallback {
            override fun successCallback() {
                mainThreadHandler.post {
                    sendMessage(AMPSInitChannelMethod.INIT_SUCCESS)
                }
            }

            override fun failCallback(p0: AMPSError?) {
                mainThreadHandler.post {
                    val code = p0?.code
                    if (code != null && code == "2") {
                        sendMessage(AMPSInitChannelMethod.ALREADY_INIT)
                    } else {
                        sendMessage(
                            AMPSInitChannelMethod.INIT_FAILED,
                            mapOf("code" to ((p0?.code ?: "-1").toInt()), "message" to p0?.message)
                        )
                    }
                }
            }
        }
        if (ampsInitConfig != null) {
            SDKLog.setLogLevel(SDKLog.LOG_LEVEL.LOG_LEVEL_ALL)
            AMPSSDK.setUseMediation(isMediation)
            AMPSSDK.init(context, ampsInitConfig, callback)
        }
    }

    fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}
