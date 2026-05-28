package com.example.amps_sdk.manager

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
import com.example.amps_sdk.data.*
import com.example.amps_sdk.utils.FlutterPluginUtil
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

/**
 * 多实例原生广告管理器。
 */
class AMPSNativeManager {

    private class NativeAdEntry(val instanceId: String) {
        var nativeType: Int = NativeType.NATIVE.value
        var mNativeAd: AMPSNativeAd? = null
        var mUnifiedAd: AMPSUnifiedNativeAd? = null
        val adIdMap = mutableMapOf<AMPSNativeAdExpressInfo, String>()
        val adUnifiedIdMap = mutableMapOf<AMPSUnifiedNativeItem, String>()
    }

    private val ads = mutableMapOf<String, NativeAdEntry>()

    companion object {
        @Volatile
        private var instance: AMPSNativeManager? = null

        fun getInstance(): AMPSNativeManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSNativeManager().also { instance = it }
            }
        }
    }

    private fun findEntry(call: MethodCall): NativeAdEntry? {
        val id = InstanceChannelHelper.instanceId(call.arguments) ?: return null
        return ads[id]
    }

    private fun getOrCreateEntry(instanceId: String): NativeAdEntry {
        return ads.getOrPut(instanceId) { NativeAdEntry(instanceId) }
    }

    private fun resolveAdId(entry: NativeAdEntry, call: MethodCall): String? {
        val data = InstanceChannelHelper.data(call.arguments)
        if (data is String) return data
        val args = call.arguments as? Map<*, *>
        return args?.get(AD_ID) as? String
    }

    private fun createNativeCallback(entry: NativeAdEntry): AMPSNativeLoadEventListener =
        object : AMPSNativeLoadEventListener() {
            override fun onAmpsAdLoad(adItems: List<AMPSNativeAdExpressInfo?>?) {
                val instanceId = entry.instanceId
                entry.adIdMap.clear()
                val adIdList = adItems?.filterNotNull()?.map { item ->
                    val uniqueId = UUID.randomUUID().toString().replace("-", "")
                    entry.adIdMap[item] = uniqueId
                    uniqueId
                }
                InstanceChannelHelper.send(
                    AMPSNativeCallBackChannelMethod.LOAD_OK,
                    instanceId,
                    adIdList,
                )
                adItems?.filterNotNull()?.forEach { item ->
                    val uniqueId = entry.adIdMap[item] ?: return@forEach
                    item.setAMPSNativeAdExpressListener(object : AMPSNativeAdExpressListener() {
                        override fun onAdShow() {
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_SHOW,
                                instanceId,
                                uniqueId,
                            )
                        }

                        override fun onAdClicked() {
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_CLICKED,
                                instanceId,
                                uniqueId,
                            )
                        }

                        override fun onAdClosed(p0: View?) {
                            entry.adIdMap.remove(item)
                            AdWrapperManager.getInstance().removeAdItem(uniqueId)
                            AdWrapperManager.getInstance().removeAdView(uniqueId)
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_CLOSED,
                                instanceId,
                                uniqueId,
                            )
                        }

                        override fun onRenderFail(p0: View?, p1: String?, p2: Int) {
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.RENDER_FAILED,
                                instanceId,
                                mapOf("adId" to uniqueId, "code" to p2, "message" to p1),
                            )
                        }

                        override fun onRenderSuccess(p0: View?, p1: Float, p2: Float) {
                            if (p0 != null) {
                                AdWrapperManager.getInstance().addAdItem(uniqueId, item)
                                AdWrapperManager.getInstance().addAdView(uniqueId, p0)
                            }
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.RENDER_SUCCESS,
                                instanceId,
                                uniqueId,
                            )
                        }
                    })
                    item.render()
                }
            }

            override fun onAmpsAdFailed(p0: AMPSError?) {
                InstanceChannelHelper.send(
                    AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                    entry.instanceId,
                    mapOf("code" to p0?.code, "message" to p0?.message),
                )
            }
        }

    private fun createUnifiedCallback(entry: NativeAdEntry): AMPSUnifiedNativeLoadEventListener =
        object : AMPSUnifiedNativeLoadEventListener {
            override fun onAmpsAdLoad(adItems: List<AMPSUnifiedNativeItem?>?) {
                val instanceId = entry.instanceId
                entry.adUnifiedIdMap.clear()
                val adIdList = adItems?.filterNotNull()?.map { item ->
                    val uniqueId = UUID.randomUUID().toString().replace("-", "")
                    entry.adUnifiedIdMap[item] = uniqueId
                    uniqueId
                }
                InstanceChannelHelper.send(
                    AMPSNativeCallBackChannelMethod.LOAD_OK,
                    instanceId,
                    adIdList,
                )
                adItems?.filterNotNull()?.forEach { item ->
                    val uniqueId = entry.adUnifiedIdMap[item] ?: return@forEach
                    item.setNativeAdEventListener(object : AMPSUnifiedAdEventListener {
                        override fun onADExposed() {
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_SHOW,
                                instanceId,
                                uniqueId,
                            )
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE,
                                instanceId,
                                uniqueId,
                            )
                        }

                        override fun onADClicked() {
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_CLICKED,
                                instanceId,
                                uniqueId,
                            )
                        }

                        override fun onADExposeError(p0: Int, p1: String?) {
                            InstanceChannelHelper.send(
                                AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE_FAIL,
                                instanceId,
                                mapOf("adId" to uniqueId, "code" to p0, "message" to p1),
                            )
                        }
                    })
                    AdUnifiedWrapperManager.getInstance().addAdItem(uniqueId, item, entry.instanceId)
                    InstanceChannelHelper.send(
                        AMPSNativeCallBackChannelMethod.RENDER_SUCCESS,
                        instanceId,
                        uniqueId,
                    )
                }
            }

            override fun onAmpsAdFailed(p0: AMPSError?) {
                InstanceChannelHelper.send(
                    AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                    entry.instanceId,
                    mapOf("code" to p0?.code, "message" to p0?.message),
                )
            }
        }

    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments
        when (call.method) {
            AMPSAdSdkMethodNames.NATIVE_LOAD -> handleLoadAd(call, result)

            AMPSAdSdkMethodNames.NATIVE_GET_ECPM -> {
                val entry = findEntry(call) ?: run {
                    result.success(0)
                    return
                }
                val adId = resolveAdId(entry, call) ?: run {
                    result.success(0)
                    return
                }
                if (entry.nativeType == NativeType.NATIVE.value) {
                    result.success(getAdWrapperByAdId(adId)?.ecpm ?: 0)
                } else {
                    result.success(getAdUnifiedByAdId(adId)?.ecpm ?: 0)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_NOTIFY_RTB_WIN -> {
                val entry = findEntry(call) ?: return
                val params = args as? HashMap<*, *> ?: return
                val winPrice = params[AD_WIN_PRICE] as? Number ?: 0
                val secPrice = params[AD_SEC_PRICE] as? Number ?: 0
                val mAdId = params[AD_ID] as? String ?: ""
                if (entry.nativeType == NativeType.NATIVE.value) {
                    getAdWrapperByAdId(mAdId)?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                } else {
                    getAdUnifiedByAdId(mAdId)?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_NOTIFY_RTB_LOSS -> {
                val entry = findEntry(call) ?: return
                val lossParams = args as? HashMap<*, *> ?: return
                val lossWinPrice = lossParams[AD_WIN_PRICE] as? Number ?: 0
                val lossSecPrice = lossParams[AD_SEC_PRICE] as? Number ?: 0
                val lossReason =
                    lossParams[AD_LOSS_REASON] as? String ?: StringConstants.EMPTY_STRING
                val lossAdId = lossParams[AD_ID] as? String ?: ""
                if (entry.nativeType == NativeType.NATIVE.value) {
                    getAdWrapperByAdId(lossAdId)?.notifyRTBLoss(
                        lossWinPrice.toInt(),
                        lossSecPrice.toInt(),
                        lossReason,
                    )
                } else {
                    getAdUnifiedByAdId(lossAdId)?.notifyRTBLoss(
                        lossWinPrice.toInt(),
                        lossSecPrice.toInt(),
                        lossReason,
                    )
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_IS_READY_AD -> {
                val entry = findEntry(call)
                if (entry == null) {
                    result.success(false)
                    return
                }
                val adId = resolveAdId(entry, call)
                if (adId == null) {
                    result.success(false)
                    return
                }
                if (entry.nativeType == NativeType.NATIVE.value) {
                    result.success(getAdWrapperByAdId(adId) != null)
                } else {
                    result.success(getAdUnifiedByAdId(adId) != null)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_IS_NATIVE_EXPRESS -> {
                val entry = findEntry(call) ?: run {
                    result.success(false)
                    return
                }
                if (entry.nativeType == NativeType.NATIVE.value) {
                    result.success(true)
                } else {
                    val adId = resolveAdId(entry, call) ?: ""
                    result.success(getAdUnifiedByAdId(adId)?.isExpressAd ?: false)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_GET_VIDEO_DURATION -> {
                result.success(0)
            }

            AMPSAdSdkMethodNames.NATIVE_SET_VIDEO_PLAY_CONFIG -> {
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun getAdWrapperByAdId(targetAdId: String): AMPSNativeAdExpressInfo? {
        return AdWrapperManager.getInstance().getAdItem(targetAdId)
    }

    private fun getAdUnifiedByAdId(targetAdId: String): AMPSUnifiedNativeItem? {
        return AdUnifiedWrapperManager.getInstance().getAdItem(targetAdId)
    }

    private fun handleLoadAd(call: MethodCall, result: MethodChannel.Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading native ad.", null)
            return
        }

        val instanceId = InstanceChannelHelper.instanceId(call.arguments)
        if (instanceId.isNullOrEmpty()) {
            result.error("LOAD_FAILED", "instanceId is required.", null)
            return
        }

        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val entry = getOrCreateEntry(instanceId)
            entry.nativeType = (adOptionsMap?.get(NATIVE_TYPE) ?: NativeType.NATIVE.value) as Int
            val adOption: AMPSRequestParameters =
                AdOptionsModule.getNativeAdOptionFromMap(adOptionsMap, activity)
            if (entry.nativeType == NativeType.NATIVE.value) {
                entry.mNativeAd = AMPSNativeAd(activity as Context, adOption, createNativeCallback(entry))
                entry.mNativeAd?.loadAd()
            } else {
                entry.mUnifiedAd =
                    AMPSUnifiedNativeAd(activity as Context, adOption, createUnifiedCallback(entry))
                entry.mUnifiedAd?.loadAd()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading native ad: ${e.message}", e.toString())
        }
    }
}
