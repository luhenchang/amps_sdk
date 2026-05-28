package com.example.amps_sdk.manager

import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import biz.beizi.adn.amps.ad.splash.AMPSSplashAd
import biz.beizi.adn.amps.ad.splash.AMPSSplashLoadEventListener
import biz.beizi.adn.amps.common.AMPSError
import biz.beizi.adn.amps.config.AMPSRequestParameters
import com.example.amps_sdk.data.*
import com.example.amps_sdk.utils.FlutterPluginUtil
import com.example.amps_sdk.utils.dpToPx
import com.example.amps_sdk.view.SplashBottomViewFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

/**
 * 多实例开屏广告管理器。
 */
class AMPSSplashManager private constructor() {

    private class AdEntry(val instanceId: String) {
        var mSplashAd: AMPSSplashAd? = null
        val containerTag: String = "splash_main_container_tag_$instanceId"
    }

    private val ads = mutableMapOf<String, AdEntry>()

    companion object {
        @Volatile
        private var instance: AMPSSplashManager? = null

        fun getInstance(): AMPSSplashManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSSplashManager().also { instance = it }
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

    private fun createAdListener(instanceId: String): AMPSSplashLoadEventListener =
        object : AMPSSplashLoadEventListener {
            override fun onAmpsAdLoaded() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS, instanceId)
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_RENDER_OK, instanceId)
            }

            override fun onAmpsAdShow() {
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_AD_SHOW, instanceId)
            }

            override fun onAmpsAdClicked() {
                cleanupViewsAfterAdClosed(instanceId)
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_AD_CLICKED, instanceId)
            }

            override fun onAmpsAdDismiss() {
                cleanupViewsAfterAdClosed(instanceId)
                InstanceChannelHelper.send(AMPSAdCallBackChannelMethod.ON_AD_CLOSED, instanceId)
            }

            override fun onAmpsAdFailed(error: AMPSError?) {
                InstanceChannelHelper.send(
                    AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                    instanceId,
                    mapOf("code" to error?.code, "message" to error?.message),
                )
            }
        }

    private fun cleanupViewsAfterAdClosed(instanceId: String) {
        val entry = ads[instanceId] ?: return
        val activity = FlutterPluginUtil.getActivity()
        val decorView = activity?.window?.decorView as? ViewGroup
        decorView?.findViewWithTag<View>(entry.containerTag)?.let { viewToRemove ->
            decorView.removeView(viewToRemove)
        }
        entry.mSplashAd = null
        SplashBottomModule.current = null
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments<Map<String, Any>?>()
        when (call.method) {
            AMPSAdSdkMethodNames.SPLASH_LOAD -> handleSplashLoad(call, result)
            AMPSAdSdkMethodNames.SPLASH_SHOW_AD -> handleSplashShowAd(call, result)
            AMPSAdSdkMethodNames.SPLASH_GET_ECPM -> {
                result.success(findEntry(call)?.mSplashAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.SPLASH_NOTIFY_RTB_WIN -> {
                val entry = findEntry(call)
                val winPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val secPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                entry?.mSplashAd?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_NOTIFY_RTB_LOSS -> {
                val entry = findEntry(call)
                val lossWinPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val lossSecPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                val lossReason =
                    args?.get(AD_LOSS_REASON) as? String ?: StringConstants.EMPTY_STRING
                entry?.mSplashAd?.notifyRTBLoss(
                    lossWinPrice.toInt(),
                    lossSecPrice.toInt(),
                    lossReason,
                )
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_IS_READY_AD -> {
                result.success(findEntry(call)?.mSplashAd?.isReady ?: false)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleSplashLoad(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading splash ad.", null)
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
            entry.mSplashAd = AMPSSplashAd(activity, adOption, createAdListener(instanceId))
            entry.mSplashAd?.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading splash ad: ${e.message}", e.toString())
        }
    }

    private fun handleSplashShowAd(call: MethodCall, result: Result) {
        val instanceId = InstanceChannelHelper.instanceId(call.arguments)
        val entry = if (instanceId != null) ads[instanceId] else null
        val mSplashAd = entry?.mSplashAd

        val activity = FlutterPluginUtil.getActivity()
        if (mSplashAd == null) {
            result.error("SHOW_FAILED", "Splash ad not loaded.", null)
            return
        }
        if (activity == null) {
            result.error("SHOW_FAILED", "Activity not available for showing splash ad.", null)
            return
        }

        val decorView = activity.window.decorView as? ViewGroup
        if (decorView == null) {
            result.error("SHOW_FAILED", "Could not get decorView to show ad.", null)
            return
        }

        try {
            decorView.findViewWithTag<View>(entry!!.containerTag)?.let {
                decorView.removeView(it)
            }

            val mainContainerLocal = RelativeLayout(activity)
            mainContainerLocal.tag = entry.containerTag
            mainContainerLocal.layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )

            val args = call.arguments<Map<String, Any>?>()
            val splashBottomData = SplashBottomModule.fromMap(args)
            SplashBottomModule.current = splashBottomData

            var customBottomLayoutLocal: View? = null
            var customBottomLayoutId: Int = View.NO_ID

            if (splashBottomData != null && splashBottomData.height > 0) {
                customBottomLayoutLocal =
                    SplashBottomViewFactory.createSplashBottomLayout(activity, splashBottomData)

                if (customBottomLayoutLocal != null) {
                    val bottomLp = RelativeLayout.LayoutParams(
                        RelativeLayout.LayoutParams.MATCH_PARENT,
                        splashBottomData.height.dpToPx(activity),
                    )
                    bottomLp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                    customBottomLayoutLocal.layoutParams = bottomLp
                    customBottomLayoutLocal.id = View.generateViewId()
                    customBottomLayoutId = customBottomLayoutLocal.id
                    mainContainerLocal.addView(customBottomLayoutLocal)
                }
            }

            val adContainerLocal = FrameLayout(activity)
            val adContainerParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT,
            )
            if (customBottomLayoutLocal != null &&
                customBottomLayoutLocal.parent == mainContainerLocal &&
                customBottomLayoutId != View.NO_ID
            ) {
                adContainerParams.addRule(RelativeLayout.ABOVE, customBottomLayoutId)
            }
            adContainerLocal.layoutParams = adContainerParams
            mainContainerLocal.addView(adContainerLocal)

            decorView.addView(mainContainerLocal)

            if (mSplashAd.isReady) {
                mSplashAd.show(adContainerLocal)
                result.success(true)
            } else {
                decorView.removeView(mainContainerLocal)
                result.error("SHOW_FAILED", "Splash ad not ready to be shown.", null)
            }
        } catch (e: Exception) {
            decorView.findViewWithTag<View>(entry!!.containerTag)?.let {
                decorView.removeView(it)
            }
            result.error("SHOW_EXCEPTION", "Error showing splash ad: ${e.message}", e.toString())
        }
    }
}
