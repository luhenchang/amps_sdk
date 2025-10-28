package com.example.amps_sdk.manager

import android.app.Activity
import android.content.Context
import android.view.View
import biz.beizi.adn.amps.ad.nativead.AMPSNativeAd
import biz.beizi.adn.amps.ad.nativead.AMPSNativeLoadEventListener
import biz.beizi.adn.amps.ad.nativead.adapter.AMPSNativeAdExpressListener
import biz.beizi.adn.amps.ad.nativead.inter.AMPSNativeAdExpressInfo
import biz.beizi.adn.amps.ad.unified.AMPSUnifiedNativeAd
import biz.beizi.adn.amps.ad.unified.AMPSUnifiedNativeLoadEventListener
import biz.beizi.adn.amps.ad.unified.inter.AMPSUnifiedAdEventListener
import biz.beizi.adn.amps.ad.unified.inter.AMPSUnifiedNativeItem
import biz.beizi.adn.amps.common.AMPSError
import biz.beizi.adn.amps.config.AMPSRequestParameters
import com.example.amps_sdk.data.AD_ID
import com.example.amps_sdk.data.AD_LOSS_REASON
import com.example.amps_sdk.data.AD_SEC_PRICE
import com.example.amps_sdk.data.AD_WIN_PRICE
import com.example.amps_sdk.data.AMPSAdSdkMethodNames
import com.example.amps_sdk.data.AMPSNativeCallBackChannelMethod
import com.example.amps_sdk.data.AdOptionsModule
import com.example.amps_sdk.data.NATIVE_TYPE
import com.example.amps_sdk.data.NativeType
import com.example.amps_sdk.data.StringConstants
import com.example.amps_sdk.data.VIDEO_LOOP_REPLAY
import com.example.amps_sdk.data.VIDEO_PLAY_TYPE
import com.example.amps_sdk.data.VIDEO_SOUND
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference
import java.util.UUID

class AMPSNativeManager {
    private var nativeType: Int = 0

    //原生广告
    private var mNativeAd: AMPSNativeAd? = null

    //自渲染广告
    private var mUnifiedAd: AMPSUnifiedNativeAd? = null
    private var currentActivityRef: WeakReference<Activity>? =
        WeakReference(AMPSEventManager.getInstance().getContext())

    private fun getCurrentActivity(): Activity? = currentActivityRef?.get()

    // 用于存储广告项与唯一ID的映射关系
    private val adIdMap = mutableMapOf<AMPSNativeAdExpressInfo, String>()
    private val adCallback = object : AMPSNativeLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSNativeAdExpressInfo?>?) {
            // 清除之前的映射
            adIdMap.clear()
            // 为每个有效广告项生成唯一ID并建立映射
            val adIdList = adItems?.filterNotNull()?.map { item ->
                // 生成UUID作为唯一标识
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                adIdMap[item] = uniqueId
                uniqueId
            }
            sendMessage(AMPSNativeCallBackChannelMethod.LOAD_OK, adIdList)
            adItems?.filterNotNull()?.forEach { item ->
                // 从映射中获取当前广告项的唯一ID
                val uniqueId = adIdMap[item]
                if (uniqueId != null) {
                    item.setAMPSNativeAdExpressListener(object : AMPSNativeAdExpressListener() {
                        override fun onAdShow() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_SHOW, uniqueId)
                        }

                        override fun onAdClicked() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLICKED, uniqueId)
                        }

                        override fun onAdClosed(p0: View?) {
                            adIdMap.remove(item)
                            AdWrapperManager.getInstance().removeAdItem(uniqueId)
                            AdWrapperManager.getInstance().removeAdView(uniqueId)
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLOSED, uniqueId)
                        }

                        override fun onRenderFail(p0: View?, p1: String?, p2: Int) {
                            sendMessage(
                                AMPSNativeCallBackChannelMethod.RENDER_FAILED,
                                mapOf("adId" to uniqueId, "code" to p2, "message" to p1)
                            )
                        }

                        override fun onRenderSuccess(p0: View?, p1: Float, p2: Float) {
                            if (p0 != null) {
                                AdWrapperManager.getInstance().addAdItem(uniqueId, item)
                                AdWrapperManager.getInstance().addAdView(uniqueId, p0)
                            }
                            sendMessage(AMPSNativeCallBackChannelMethod.RENDER_SUCCESS, uniqueId)
                        }
                    })
                    item.render()
                }
            }
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            sendMessage(
                AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                mapOf("code" to p0?.code, "message" to p0?.message)
            )
        }
    }

    private val adUnifiedIdMap = mutableMapOf<AMPSUnifiedNativeItem, String>()
    private val adUnifiedCallback = object : AMPSUnifiedNativeLoadEventListener {
        override fun onAmpsAdLoad(adItems: List<AMPSUnifiedNativeItem?>?) {
            // 清除之前的映射
            adUnifiedIdMap.clear()
            // 为每个有效广告项生成唯一ID并建立映射
            val adIdList = adItems?.filterNotNull()?.map { item ->
                // 生成UUID作为唯一标识
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                adUnifiedIdMap[item] = uniqueId
                uniqueId
            }
            sendMessage(AMPSNativeCallBackChannelMethod.LOAD_OK, adIdList)
            adItems?.filterNotNull()?.forEach { item ->
                // 从映射中获取当前广告项的唯一ID
                val uniqueId = adUnifiedIdMap[item]
                if (uniqueId != null) {
                    item.setNativeAdEventListener(object : AMPSUnifiedAdEventListener {
                        override fun onADExposed() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_SHOW, uniqueId)
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE, uniqueId)
                        }

                        override fun onADClicked() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLICKED, uniqueId)
                        }

                        override fun onADExposeError(p0: Int, p1: String?) {
                            sendMessage(
                                AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE_FAIL,
                                mapOf("adId" to uniqueId, "code" to p0, "message" to p1)
                            )
                        }
                    })
                    AdUnifiedWrapperManager.getInstance().addAdItem(uniqueId, item)
                    sendMessage(AMPSNativeCallBackChannelMethod.RENDER_SUCCESS, uniqueId)
                }
            }
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            sendMessage(
                AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                mapOf("code" to p0?.code, "message" to p0?.message)
            )
        }
    }

    companion object {
        @Volatile
        private var instance: AMPSNativeManager? = null

        fun getInstance(): AMPSNativeManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSNativeManager().also { instance = it }
            }
        }
    }

    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments
        when (call.method) {
            AMPSAdSdkMethodNames.NATIVE_LOAD -> {
                handleLoadAd(call, result)
            }

            AMPSAdSdkMethodNames.NATIVE_GET_ECPM -> {
                if (nativeType == 0) {
                    val foundWrapper = getAdWrapperByAdId(call.arguments as String)
                    val mEcpm = foundWrapper?.ecpm ?: 0
                    result.success(mEcpm)
                } else {
                    val foundWrapper = getAdUnifiedByAdId(call.arguments as String)
                    val mEcpm = foundWrapper?.ecpm ?: 0
                    result.success(mEcpm)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_NOTIFY_RTB_WIN -> {
                val params = args as HashMap<String, Any>
                val winPrice = params[AD_WIN_PRICE] as? Number ?: 0
                val secPrice = params[AD_SEC_PRICE] as? Number ?: 0
                val mAdId = params[AD_ID] as? String ?: ""
                if (nativeType == 0) {
                    val foundWrapper = getAdWrapperByAdId(mAdId)
                    foundWrapper?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                } else {
                    val foundWrapper = getAdUnifiedByAdId(mAdId)
                    foundWrapper?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                }
            }

            AMPSAdSdkMethodNames.NATIVE_NOTIFY_RTB_LOSS -> {
                val lossParams = args as HashMap<String, Any>
                val lossWinPrice = lossParams[AD_WIN_PRICE] as? Number ?: 0
                val lossSecPrice = lossParams[AD_SEC_PRICE] as? Number ?: 0
                val lossReason =
                    lossParams[AD_LOSS_REASON] as? String ?: StringConstants.EMPTY_STRING
                val lossAdId = lossParams[AD_ID] as? String ?: ""
                if (nativeType == 0) {
                    val foundWrapper = getAdWrapperByAdId(lossAdId)
                    foundWrapper?.notifyRTBLoss(
                        lossWinPrice.toInt(),
                        lossSecPrice.toInt(),
                        lossReason
                    )
                } else {
                    val foundWrapper = getAdUnifiedByAdId(lossAdId)
                    foundWrapper?.notifyRTBLoss(
                        lossWinPrice.toInt(),
                        lossSecPrice.toInt(),
                        lossReason
                    )
                }
            }

            AMPSAdSdkMethodNames.NATIVE_IS_READY_AD -> {
                // 原代码中未实现
            }

            AMPSAdSdkMethodNames.NATIVE_IS_NATIVE_EXPRESS -> {
                if (nativeType == 0) {
                    result.success(true)
                } else {
                    val foundWrapper = getAdUnifiedByAdId(call.arguments as String)
                    val isNativeExpress = foundWrapper?.isExpressAd ?: false
                    result.success(isNativeExpress)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_GET_VIDEO_DURATION -> {
                val wrapperByAdId = getAdWrapperByAdId(call.arguments as String)
                //val foundWrapper = getAdUnifiedByAdId(call.arguments as String)
                //TODO 获取视频播放时长【目前不支持】
                //val duration = wrapperByAdId?.videoDuration ?: 0
                //result.success(duration)
                result.success(0)
            }

            AMPSAdSdkMethodNames.NATIVE_SET_VIDEO_PLAY_CONFIG -> {
                val vdConfigParams = args as HashMap<String, Any>
                val videoSound = vdConfigParams[VIDEO_SOUND] as? Boolean ?: false
                val videoPlayType = vdConfigParams[VIDEO_PLAY_TYPE] as? Number ?: 0
                val videoLoopReplay = vdConfigParams[VIDEO_LOOP_REPLAY] as? Boolean ?: false
               //TODO 视频设置[目前不支持]
               //mVideoConfig = VideoConfig(
               //    videoSoundEnable = videoSound,
               //    videoAutoPlayType = videoPlayType.toInt(),
               //    videoLoopReplay = videoLoopReplay
               //)
                result.success(true)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getAdWrapperByAdId(targetAdId: String): AMPSNativeAdExpressInfo? {
        return AdWrapperManager.getInstance().getAdItem(targetAdId)
    }

    private fun getAdUnifiedByAdId(targetAdId: String): AMPSUnifiedNativeItem? {
        return AdUnifiedWrapperManager.getInstance().getAdItem(targetAdId)
    }

    private fun handleLoadAd(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val activity = getCurrentActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading native ad.", null)
            return
        }
        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            nativeType = (adOptionsMap?.get(NATIVE_TYPE) ?: NativeType.NATIVE.value) as Int
            val adOption: AMPSRequestParameters = AdOptionsModule.getNativeAdOptionFromMap(adOptionsMap, activity)
            if (nativeType == NativeType.NATIVE.value) {
                mNativeAd = AMPSNativeAd(activity as Context, adOption, adCallback)
                mNativeAd?.loadAd()
            } else {
                mUnifiedAd = AMPSUnifiedNativeAd(activity as Context, adOption, adUnifiedCallback)
                mUnifiedAd?.loadAd()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading native ad: ${e.message}", e.toString())
        }
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}