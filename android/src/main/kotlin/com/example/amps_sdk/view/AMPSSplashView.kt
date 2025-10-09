package com.example.amps_sdk.view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout // 需要导入
import biz.beizi.adn.amps.ad.splash.AMPSSplashAd
import biz.beizi.adn.amps.ad.splash.AMPSSplashLoadEventListener
import biz.beizi.adn.amps.common.AMPSError
import biz.beizi.adn.amps.config.AMPSRequestParameters
import com.example.amps_sdk.data.AD_LOSS_REASON
import com.example.amps_sdk.data.AD_SEC_PRICE
import com.example.amps_sdk.data.AD_WIN_PRICE
import com.example.amps_sdk.data.AMPSAdCallBackChannelMethod
import com.example.amps_sdk.data.AMPSAdSdkMethodNames
import com.example.amps_sdk.data.AMPSPlatformViewRegistry
import com.example.amps_sdk.data.AdOptionsModule
import com.example.amps_sdk.data.CONFIG // 假设这个常量存在
import com.example.amps_sdk.data.SPLASH_BOTTOM
import com.example.amps_sdk.data.SplashBottomModule
import com.example.amps_sdk.data.StringConstants
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import io.flutter.plugin.platform.PlatformView
import kotlin.math.log
import kotlin.random.Random
import kotlin.random.nextInt
import androidx.core.view.isGone

class AMPSSplashView(
    private val context: Context, // 改为 val 以便在其他地方访问
    viewId: Int,
    binaryMessenger: BinaryMessenger,
    args: Any?
) : PlatformView, MethodChannel.MethodCallHandler {

    private var methodChannel: MethodChannel? = null
    private var mSplashAd: AMPSSplashAd? = null
    // adOption 仍然需要，但从 args 中解析
    // private varQ adOption: AMPSRequestParameters? = null // 将在 init 中赋值

    // 根视图，可以是 RelativeLayout 或 FrameLayout，取决于是否有底部自定义内容
    private val rootPlatformView: ViewGroup
    private var customBottomViewTag: String = "custom_splash_bottom_view_tag"
    // 广告实际渲染的容器，是 rootPlatformView 的一部分
    private val adContainerInPlatformView: FrameLayout

    private val adCallback = object : AMPSSplashLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            sendMessage(AMPSAdCallBackChannelMethod.ON_RENDER_OK)
            // 广告加载成功后，显示在 adContainerInPlatformView 中
            mSplashAd?.show(adContainerInPlatformView)
        }

        override fun onAmpsAdShow() {
            //rootPlatformView.findViewWithTag<ViewGroup>(customBottomViewTag).visibility = View.VISIBLE
            val view = rootPlatformView.findViewWithTag<ViewGroup>(customBottomViewTag)
            print("view tag==="+view.tag)
            if (view !=null && view.isGone){
                //view.visibility = View.VISIBLE
            }
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            adContainerInPlatformView.removeAllViews()
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            adContainerInPlatformView.removeAllViews()
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf("code" to error?.code, "message" to error?.message)
            )
        }
    }

    init {
        //customBottomViewTag = "custom_splash_bottom_view_tag${Random(100).nextInt()}"
        val channelName = "${AMPSPlatformViewRegistry.AMPS_SDK_SPLASH_VIEW_ID}$viewId"
        methodChannel = MethodChannel(binaryMessenger, channelName, StandardMethodCodec.INSTANCE)
        methodChannel?.setMethodCallHandler(this)

        val creationArgsMap = args as? Map<*, *>?

        // 解析广告配置
        val adOptionFromArgs: AMPSRequestParameters? = creationArgsMap?.get(CONFIG)?.let { configMap ->
            AdOptionsModule.getAdOptionFromMap(configMap as? Map<String, Any?>,context)
        }

        if (adOptionFromArgs == null) {
            println("AMPSSplashView Error: AdOptions could not be parsed from arguments.")
            // 创建一个简单的 FrameLayout 作为错误状态的根视图
            adContainerInPlatformView = FrameLayout(context)
            rootPlatformView = adContainerInPlatformView
            // 不加载广告
        } else {
            // 解析底部自定义布局数据
            val splashBottomData = SplashBottomModule.fromMap(creationArgsMap[SPLASH_BOTTOM] as? Map<String, Any>?)
            SplashBottomModule.current = splashBottomData // 更新静态变量，如果需要的话

            var customBottomLayoutView: View? = null
            var customBottomLayoutId: Int = View.NO_ID

            if (splashBottomData!=null && splashBottomData.height > 0) {
                customBottomLayoutView = SplashBottomViewFactory.createSplashBottomLayout(context, splashBottomData)
                if (customBottomLayoutView != null) {
                    customBottomLayoutView.id = View.generateViewId()
                    customBottomLayoutId = customBottomLayoutView.id
                }
            }

            // --- 根据是否有底部自定义内容，决定 rootPlatformView 的类型 ---
            if (splashBottomData!=null && splashBottomData.height > 0 && customBottomLayoutView != null && customBottomLayoutId != View.NO_ID) {
                // 有底部自定义内容，使用 RelativeLayout 作为根
                val relativeRoot = RelativeLayout(context)
                relativeRoot.layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                // 设置底部自定义视图的布局参数并添加到 RelativeLayout
                val bottomLp = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    (splashBottomData.height * context.resources.displayMetrics.density).toInt()
                )
                bottomLp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                customBottomLayoutView.layoutParams = bottomLp
                customBottomLayoutView.visibility = View.GONE
                customBottomLayoutView.tag = customBottomViewTag
                relativeRoot.addView(customBottomLayoutView)

                // 创建广告容器并设置其位于底部视图之上
                adContainerInPlatformView = FrameLayout(context)
                val adContainerParams = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT
                )
                adContainerParams.addRule(RelativeLayout.ABOVE, customBottomLayoutId)
                adContainerInPlatformView.layoutParams = adContainerParams
                relativeRoot.addView(adContainerInPlatformView)

                rootPlatformView = relativeRoot
            } else {
                // 没有有效的底部自定义内容，直接使用 FrameLayout 作为根和广告容器
                adContainerInPlatformView = FrameLayout(context)
                adContainerInPlatformView.layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )
                rootPlatformView = adContainerInPlatformView
            }

            // 初始化并加载广告
            mSplashAd = AMPSSplashAd(context, adOptionFromArgs, adCallback)
            mSplashAd?.loadAd()
        }
    }

    private fun sendMessage(methodName: String, args: Any? = null) {
        methodChannel?.invokeMethod(methodName, args)
    }

    override fun getView(): View {
        return rootPlatformView
    }

    override fun dispose() {
        mSplashAd?.destroy()
        mSplashAd = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        SplashBottomModule.current = null // 清理静态引用
        println("AMPSSplashView disposed for viewId associated with channel: ${methodChannel?.toString()}")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val argsMap = call.arguments<Map<String, Any>?>()
        when (call.method) {
            AMPSAdSdkMethodNames.SPLASH_GET_ECPM -> {
                result.success(mSplashAd?.ecpm ?: 0)
            }
            AMPSAdSdkMethodNames.SPLASH_NOTIFY_RTB_WIN -> {
                val winPrice = argsMap?.get(AD_WIN_PRICE) as? Number ?: 0
                val secPrice = argsMap?.get(AD_SEC_PRICE) as? Number ?: 0
                mSplashAd?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                result.success(null)
            }
            AMPSAdSdkMethodNames.SPLASH_NOTIFY_RTB_LOSS -> {
                val lossWinPrice = argsMap?.get(AD_WIN_PRICE) as? Number ?: 0
                val lossSecPrice = argsMap?.get(AD_SEC_PRICE) as? Number ?: 0
                val lossReason = argsMap?.get(AD_LOSS_REASON) as? String ?: StringConstants.EMPTY_STRING
                mSplashAd?.notifyRTBLoss(lossWinPrice.toInt(), lossSecPrice.toInt(), lossReason)
                result.success(null)
            }
            AMPSAdSdkMethodNames.SPLASH_IS_READY_AD -> {
                result.success(mSplashAd?.isReady ?: false)
            }
            else -> result.notImplemented()
        }
    }
}

