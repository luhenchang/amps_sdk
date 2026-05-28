package com.example.amps_sdk.manager

import biz.beizi.adn.amps.ad.interstitial.AMPSInterstitialAd
import biz.beizi.adn.amps.ad.interstitial.AMPSInterstitialLoadEventListener
import biz.beizi.adn.amps.common.AMPSError
import biz.beizi.adn.amps.config.AMPSRequestParameters
import com.example.amps_sdk.data.*
import com.example.amps_sdk.utils.FlutterPluginUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

/**
 * 多实例插屏广告管理器。
 */
class AMPSInterstitialManager private constructor() {

    private class AdEntry(val instanceId: String) {
        var interstitialAd: AMPSInterstitialAd? = null
    }

    private val ads = mutableMapOf<String, AdEntry>()

    companion object {
        @Volatile
        private var instance: AMPSInterstitialManager? = null

        fun getInstance(): AMPSInterstitialManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSInterstitialManager().also { instance = it }
            }
        }
    }

    private fun findEntry(call: MethodCall): AdEntry? {
        val id = InstanceChannelHelper.instanceId(call.arguments) ?: return null
        return ads[id]
    }

    private fun getOrCreateEntry(instanceId: String): AdEntry {
        return ads.getOrPut(instanceId) { AdEntry(instanceId) }
    }

    private fun createAdListener(instanceId: String): AMPSInterstitialLoadEventListener =
        object : AMPSInterstitialLoadEventListener {
            override fun onAmpsAdLoaded() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS, instanceId)
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_RENDER_OK, instanceId)
            }

            override fun onAmpsAdShow() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_AD_SHOW, instanceId)
            }

            override fun onAmpsAdClicked() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_AD_CLICKED, instanceId)
            }

            override fun onAmpsAdDismiss() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_AD_CLOSED, instanceId)
                ads[instanceId]?.interstitialAd?.destroy()
                ads[instanceId]?.interstitialAd = null
            }

            override fun onAmpsAdFailed(error: AMPSError?) {
                InstanceChannelHelper.send(
                    AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                    instanceId,
                    mapOf("code" to error?.code, "message" to error?.message),
                )
            }

            override fun onAmpsSkippedAd() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_VIDEO_SKIP_TO_END, instanceId)
            }

            override fun onAmpsVideoPlayStart() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_VIDEO_PLAY_START, instanceId)
            }

            override fun onAmpsVideoPlayEnd() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_VIDEO_PLAY_END, instanceId)
            }
        }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments<Map<String, Any>?>()
        when (call.method) {
            AMPSAdSdkMethodNames.INTERSTITIAL_LOAD -> handleInterstitialLoad(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_SHOW_AD -> handleInterstitialShowAd(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_GET_ECPM -> {
                result.success(findEntry(call)?.interstitialAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_NOTIFY_RTB_WIN -> {
                val entry = findEntry(call)
                val winPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val secPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                entry?.interstitialAd?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_NOTIFY_RTB_LOSS -> {
                val entry = findEntry(call)
                val lossWinPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val lossSecPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                val lossReason =
                    args?.get(AD_LOSS_REASON) as? String ?: StringConstants.EMPTY_STRING
                entry?.interstitialAd?.notifyRTBLoss(
                    lossWinPrice.toInt(),
                    lossSecPrice.toInt(),
                    lossReason,
                )
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_IS_READY_AD -> {
                result.success(findEntry(call)?.interstitialAd?.isReady ?: false)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleInterstitialLoad(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading interstitial ad.", null)
            return
        }

        val instanceId = InstanceChannelHelper.instanceId(call.arguments)
        if (instanceId.isNullOrEmpty()) {
            result.error("LOAD_FAILED", "instanceId is required.", null)
            return
        }

        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val adOption: AMPSRequestParameters =
                AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
            val entry = getOrCreateEntry(instanceId)
            entry.interstitialAd =
                AMPSInterstitialAd(activity, adOption, createAdListener(instanceId))
            entry.interstitialAd?.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading interstitial ad: ${e.message}", e.toString())
        }
    }

    private fun handleInterstitialShowAd(call: MethodCall, result: Result) {
        val entry = findEntry(call)
        val interstitialAd = entry?.interstitialAd
        val activity = FlutterPluginUtil.getActivity()
        if (interstitialAd == null) {
            result.error("SHOW_FAILED", "Interstitial ad not loaded.", null)
            return
        }
        if (activity == null) {
            result.error("SHOW_FAILED", "Activity not available.", null)
            return
        }
        interstitialAd.show(activity)
        result.success(true)
    }
}
