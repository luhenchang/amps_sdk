package com.example.amps_sdk.manager
import biz.beizi.adn.amps.AMPSSDK
import biz.beizi.adn.amps.init.AMPSInitConfig
import android.content.Context
import android.os.Handler
import android.os.Looper
import biz.beizi.adn.amps.common.AMPSError
import biz.beizi.adn.amps.init.inter.IAMPSInitCallback
import com.example.amps_sdk.data.AMPSAdSdkMethodNames
import com.example.amps_sdk.data.AMPSInitChannelMethod
import com.example.amps_sdk.data.AMPSInitConfigConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.common.v2.log.SDKLog
import kotlin.synchronized

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
                val context = AMPSEventManager.getInstance().getContext()
                if (context != null && flutterParams != null) {
                    val ampsConfig = AMPSInitConfigConverter().convert(flutterParams)
                    initAMPSSDK(ampsConfig, context)
                    result.success(true)
                } else {
                    if (context == null) {
                        result.error("CONTEXT_UNAVAILABLE", "Android context is not available.", null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Initialization arguments are missing or invalid.", null)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    fun initAMPSSDK(ampsInitConfig: AMPSInitConfig?, context: Context) {
        val callback = object : IAMPSInitCallback {
            override fun successCallback() {
                mainThreadHandler.post {
                    sendMessage(AMPSInitChannelMethod.INIT_SUCCESS)
                }
            }

            override fun failCallback(p0: AMPSError?) {
                mainThreadHandler.post {
                    sendMessage(AMPSInitChannelMethod.INIT_FAILED, mapOf("code" to p0?.code, "message" to p0?.message))
                }
            }
        }

        if (ampsInitConfig != null) {
            SDKLog.setLogLevel(SDKLog.LOG_LEVEL.LOG_LEVEL_ALL);
            AMPSSDK.init(context, ampsInitConfig,callback)
        }
    }

    fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}
