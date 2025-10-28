package com.example.amps_sdk.view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import biz.beizi.adn.amps.ad.splash.AMPSSplashAd
import biz.beizi.adn.amps.ad.splash.AMPSSplashLoadEventListener
import biz.beizi.adn.amps.common.AMPSError
import com.example.amps_sdk.data.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import io.flutter.plugin.platform.PlatformView

class AMPSSplashView(
    private val context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger,
    args: Any?
) : PlatformView, MethodChannel.MethodCallHandler {

    private var methodChannel: MethodChannel?
    private var mSplashAd: AMPSSplashAd? = null
    private var customBottomLayoutView: View? = null

    // 根视图，根据逻辑动态构建
    private val rootPlatformView: ViewGroup

    // 广告容器
    private val adContainerInPlatformView: FrameLayout = FrameLayout(context)

    private val adCallback = object : AMPSSplashLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            sendMessage(AMPSAdCallBackChannelMethod.ON_RENDER_OK)
            mSplashAd?.show(adContainerInPlatformView)
        }

        override fun onAmpsAdShow() {
            // 在广告展示时，于UI线程安全地显示底部自定义视图
            rootPlatformView.post { customBottomLayoutView?.visibility = View.VISIBLE }
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            // 广告关闭时，清理视图和广告资源
            cleanupAdResources()
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
        methodChannel = MethodChannel(
            binaryMessenger,
            "${AMPSPlatformViewRegistry.AMPS_SDK_SPLASH_VIEW_ID}$viewId",
            StandardMethodCodec.INSTANCE
        ).also { it.setMethodCallHandler(this) }

        val creationArgsMap = args as? Map<*, *>?
        val adOptionFromArgs = creationArgsMap?.get(CONFIG)
            ?.let { AdOptionsModule.getAdOptionFromMap(it as? Map<String, Any?>, context) }

        if (adOptionFromArgs == null) {
            println("AMPSSplashView Error: AdOptions are null. Aborting ad load.")
            // 初始状态下，根视图就是空的广告容器
            rootPlatformView = adContainerInPlatformView
        } else {
            // 优先构建视图层级，然后加载广告
            rootPlatformView = setupViews(creationArgsMap)
            mSplashAd = AMPSSplashAd(context, adOptionFromArgs, adCallback).also { it.loadAd() }
        }
    }

    /**
     * 根据参数构建根视图 (rootPlatformView) 的层级结构。
     */
    private fun setupViews(args: Map<*, *>?): ViewGroup {
        val splashBottomData = args?.get(SPLASH_BOTTOM)?.let { SplashBottomModule.fromMap(it as? Map<String, Any>?) }
        SplashBottomModule.current = splashBottomData // 如需全局访问，则更新

        // 尝试创建底部自定义视图
        customBottomLayoutView = splashBottomData?.takeIf { it.height > 0 }?.let { data ->
            SplashBottomViewFactory.createSplashBottomLayout(context, data)?.apply {
                id = View.generateViewId()
                visibility = View.GONE // 初始隐藏
                layoutParams = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    (data.height * context.resources.displayMetrics.density).toInt()
                ).apply {
                    addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                }
            }
        }

        // 如果成功创建了底部视图，则使用 RelativeLayout 作为根布局
        return customBottomLayoutView?.let { bottomView ->
            RelativeLayout(context).apply {
                layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)

                // 设置广告容器，使其位于底部视图之上
                adContainerInPlatformView.layoutParams = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT
                ).apply {
                    addRule(RelativeLayout.ABOVE, bottomView.id)
                }

                addView(adContainerInPlatformView)
                addView(bottomView)
            }
        } ?: adContainerInPlatformView // 否则，直接使用广告容器作为根视图
    }

    private fun sendMessage(methodName: String, args: Any? = null) {
        // 在UI线程调用，确保Flutter侧能正确接收
        rootPlatformView.post { methodChannel?.invokeMethod(methodName, args) }
    }

    /**
     * 清理广告相关资源，用于 onDismiss 和 dispose。
     */
    private fun cleanupAdResources() {
        // 移除所有子视图，特别是广告视图
        adContainerInPlatformView.removeAllViews()
        // 销毁广告对象
        mSplashAd?.destroy()
        mSplashAd = null
    }

    override fun getView(): View = rootPlatformView

    override fun dispose() {
        cleanupAdResources()
        // 清理静态变量和方法通道
        SplashBottomModule.current = null
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        println("AMPSSplashView disposed.")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val argsMap = call.arguments<Map<String, Any>?>()
        when (call.method) {
            AMPSAdSdkMethodNames.SPLASH_GET_ECPM -> result.success(mSplashAd?.ecpm ?: 0)
            AMPSAdSdkMethodNames.SPLASH_IS_READY_AD -> result.success(mSplashAd?.isReady ?: false)
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
            else -> result.notImplemented()
        }
    }
}
