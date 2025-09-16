package com.example.amps_sdk    // In your Android project (e.g., MainActivity.kt or a new Kotlin file)
import android.R
import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import android.view.View.GONE
import android.view.ViewGroup
import android.widget.FrameLayout
import biz.beizi.adn.ad.publish.ASNPAdSDK
import biz.beizi.adn.ad.publish.ASNPConstants
import biz.beizi.adn.ad.publish.ASNPInitConfig
import biz.beizi.adn.ad.publish.IASNPCustomController
import biz.beizi.adn.ad.publish.IInitCallback
import biz.beizi.adn.ad.publish.ad.IAdListener
import biz.beizi.adn.ad.publish.ad.splash.ISplashAdConfig
import biz.beizi.adn.ad.publish.ad.splash.SplashAd
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import xyz.adscope.common.v2.log.SDKLog


// 1. Define your Native View
class AMPSSplashView(private val mContext: Context,activity: Activity, id: Int, creationParams: Map<*, *>?) : PlatformView,
    MethodChannel.MethodCallHandler {
    private var splashAd: SplashAd? = null
    private var mDecorView: ViewGroup? = null
    private val frameLayout: FrameLayout = FrameLayout(mContext)
    init {
        mDecorView = activity.findViewById<ViewGroup?>(R.id.content)
        frameLayout.setLayoutParams(
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
        mDecorView?.addView(frameLayout)
        initScopeSDK("12379")
    }

    fun getStatusBarHeight(): Int {
        var result = 0
        val resourceId: Int = mContext.getResources().getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            result = mContext.getResources().getDimensionPixelSize(resourceId)
        }
        return result
    }
    private fun initScopeSDK(appID: String?) {
        SDKLog.setLogLevel(SDKLog.LOG_LEVEL.LOG_LEVEL_ALL);
        val builder = ASNPInitConfig.Builder(appID)
        builder.setAppName("ASNP重构测试")
                .setDebugSetting(true)
                .setIsTestAd(false)
                .setUiModel(ASNPConstants.UiModel.UI_MODEL_AUTO)
                .setAdCustomController(CustomController());
        val initConfig = builder.build()
        ASNPAdSDK.getInstance().init(mContext, initConfig, object : IInitCallback{
            override fun initSuccess() {
                requestNewSplashAd()
            }

            override fun initializing() {
            }

            override fun alreadyInit() {
            }

            override fun initFailed(code: Int, msg: String?) {
            }


        })
    }

    class CustomController : IASNPCustomController() {

    }
    override fun getView(): View {
        return frameLayout // Return the actual Android View instance
    }

    override fun dispose() {
        // Cleanup, if needed, when the view is removed from Flutter
        frameLayout.removeAllViews()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "AMPSSplashAd_load" -> {

            }
        }
    }

    private fun requestNewSplashAd() {
        val builder = ISplashAdConfig.Builder()
        builder.setTimeoutMillion(5000)
        val config = builder.build("15288")
        splashAd = SplashAd(mContext, config)
        splashAd?.loadAd(object : IAdListener {
            override fun onAdLoaded() {
                Log.e("mikoto", "ad loaded")
            }

            override fun onRenderSuccess() {
                splashAd?.showAd(frameLayout);
                Log.e("mikoto", "ad render success")
            }

            override fun onAdShown() {
                Log.e("mikoto", "ad shown")
            }

            override fun onAdExposure() {
                Log.e("mikoto", "ad exposure")
            }

            override fun onAdClicked() {
                Log.e("mikoto", "ad clicked")
                frameLayout.visibility = GONE
            }

            override fun onAdClosed() {
                Log.e("mikoto", "ad closed")
                frameLayout.visibility = GONE
                splashAd?.destroyAd()
                splashAd = null
            }

            override fun onAdLoadFailed(code: Int, error: String?) {
                Log.e("mikoto", "ad load failed " + code + " " + error)
            }
        })
    }
}
    