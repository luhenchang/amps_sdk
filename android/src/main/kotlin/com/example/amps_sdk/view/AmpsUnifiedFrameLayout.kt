package com.example.amps_sdk.view

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.graphics.toColorInt
import biz.beizi.adn.amps.ad.unified.AMPSUnifiedNativeAdError
import biz.beizi.adn.amps.ad.unified.inter.AMPSAppDetail
import biz.beizi.adn.amps.ad.unified.inter.AMPSUnifiedDownloadListener
import biz.beizi.adn.amps.ad.unified.inter.AMPSUnifiedNativeItem
import biz.beizi.adn.amps.ad.unified.inter.AMPSUnifiedVideoListener
import biz.beizi.adn.amps.ad.unified.view.AMPSUnifiedMediaViewStub
import com.example.amps_sdk.UnionDownloadAppInfoActivity
import com.example.amps_sdk.data.AMPSNativeCallBackChannelMethod
import com.example.amps_sdk.data.AppDetailKeys
import com.example.amps_sdk.data.DownLoadCallBackChannelMethod
import com.example.amps_sdk.data.NativeUnifiedChild
import com.example.amps_sdk.data.NativeUnifiedModule
import com.example.amps_sdk.manager.AMPSEventManager
import com.example.amps_sdk.utils.asActivity
import com.example.amps_sdk.utils.dpToPx
import xyz.adscope.common.imageloader.ImageLoader


// 定义点击事件类型，与 Flutter 端和数据模型保持一致
object AdClickType {
    const val NONE = -1
    const val CLICK = 0
    const val COMPLAIN = 2000
    const val CLOSE = 2001
    const val LOGO = 2002
}

// 1. 定义用于封装返回结果的数据类
data class AdRenderResult(
    val clickableViews: List<View>,
    val creativeViews: List<View>
)

/**
 * 一个自定义 View，负责根据数据模型动态构建原生广告 UI
 */
class AmpsUnifiedFrameLayout(context: Context) : FrameLayout(context) {
    private val TAG = "AmpsUnifiedFrameLayout"

    // 用来记录可点击的视图和需要上报的视图
    private val clickableViews = mutableListOf<View>()
    private val creativeViews = mutableListOf<View>()

    /**
     * 主构建方法，接收数据模型和广告数据，并生成 UI
     *
     * @param module 解析好的 UI 布局模型
     * @param unifiedItem 包含具体广告内容的包装器
     */
    fun render(
        module: NativeUnifiedModule?,
        unifiedItem: AMPSUnifiedNativeItem,
        params: LayoutParams,
        adId: String
    ): AdRenderResult? {
        // 清理旧的视图，以便重用
        removeAllViews()
        clickableViews.clear()
        creativeViews.clear()
        if (module == null) {
            Log.e(TAG, "render module is null")
            return null
        }
        // 1. 设置根容器的属性
        applyRootProperties(module, params)
        // 2. 根据模型和数据，按顺序创建并添加子视图
        module.mainImageChild?.let { child ->
            createMainImageView(child, unifiedItem)?.let { view ->
                addView(view)
            }
        }

        module.videoChild?.let { child ->
            createVideoChild(child, unifiedItem, adId)?.let { view ->
                addView(view)
            }
        }

        module.titleChild?.let { child ->
            unifiedItem.title?.let { titleText ->
                createTitleView(child, titleText)?.let { titleView ->
                    clickableViews.add(titleView)
                    addView(titleView)
                }
            }
        }

        module.descriptionChild?.let { child ->
            unifiedItem.desc?.let { descText ->
                createDescriptionView(child, descText)?.let { dspView ->
                    clickableViews.add(dspView)
                    addView(dspView)
                }
            }
        }

        module.adSourceLogoChild?.let { child ->
            createAdSourceLogoView(child, unifiedItem)?.let { view ->
                addView(view)
            }
        }

        module.appIconChild?.let { child ->
            createAppIconView(child, unifiedItem)?.let { view ->
                addView(view)
            }
        }

        //下载六要素
        module.downloadInfoChild?.let { child ->
            createDownloadInfoView(child, unifiedItem, adId)?.let { view ->
                addView(view)
            }
        }

        //渲染操作按钮,需支持文本和图片两种情况
        module.actionButtonChild?.let { child ->
            createActionView(child, unifiedItem)?.let { actionView ->
                creativeViews.add(actionView)
                addView(actionView)
            }
        }

        //添加摇一摇交互View
        module.shakeChild?.let { child ->
            createShakeView(child, unifiedItem)?.let { view ->
                addView(view)
            }
        }

        module.closeIconChild?.let { child ->
            // 关闭按钮的图片通常是本地资源
            createCloseIconView(child, adId)?.let { view ->
                addView(view)
            }
        }

        //在方法末尾，创建并返回 AdRenderResult 实例
        return AdRenderResult(clickableViews, creativeViews)
    }


    private fun applyRootProperties(
        module: NativeUnifiedModule,
        params: LayoutParams
    ) {
        params.gravity = Gravity.CENTER_HORIZONTAL
        layoutParams = params
        module.backgroundColor?.let { bgColor ->
            try {
                setBackgroundColor(bgColor.toColorInt())
            } catch (_: IllegalArgumentException) {
            }
        }
    }

    /**
     * 创建主图视图的核心方法，封装了所有逻辑。
     * - 根据 unifiedItem 的类型（isViewObject），决定是返回渠道提供的 View 还是自己创建 ImageView。
     * - 如果无法创建，则返回 null。
     *
     * @return 返回配置好的 View，如果无法创建则返回 null。
     */
    private fun createMainImageView(
        child: NativeUnifiedChild.MainImage,
        unifiedItem: AMPSUnifiedNativeItem
    ): View? {
        val view = if (unifiedItem.isViewObject) {
            unifiedItem.mainImageViews?.firstOrNull()?.view
        } else {
            unifiedItem.mainImageUrl?.let { imageUrl ->
                AppCompatImageView(context).apply {
                    layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
                    scaleType = ImageView.ScaleType.FIT_XY//目前用户设置多大就多大。
                    ImageLoader().loadImage(this, imageUrl)
                    // 为我们自己创建的视图设置点击监听
                    setupClickListener(this, child.clickType, child.clickIdType)
                }
            }
        }

        return view?.apply {
            layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
            child.backgroundColor?.let { bgColor ->
                try {
                    setBackgroundColor(bgColor.toColorInt())
                } catch (_: IllegalArgumentException) { /* 忽略错误 */
                }
            }
        }
    }


    private fun createVideoChild(
        child: NativeUnifiedChild.Video,
        unifiedItem: AMPSUnifiedNativeItem,
        adId: String
    ): View? {
        val mediaView = AMPSUnifiedMediaViewStub(context)
        mediaView.layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
        unifiedItem.bindAdToMediaView(
            context.asActivity(),
            mediaView,
            object : AMPSUnifiedVideoListener {
                override fun onVideoInit() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_INIT, adId)
                }

                override fun onVideoLoading() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_LOADING, adId)
                }

                override fun onVideoReady() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_READY, adId)
                }

                override fun onVideoLoaded(p0: Int) {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_LOADED, adId)
                }

                override fun onVideoStart() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_PLAY_START, adId)
                }

                override fun onVideoPause() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_PAUSE, adId)
                }

                override fun onVideoResume() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_RESUME, adId)
                }

                override fun onVideoCompleted() {
                    sendMessageToFlutter(
                        AMPSNativeCallBackChannelMethod.ON_VIDEO_PLAY_COMPLETE,
                        adId
                    )
                }

                override fun onVideoError(p0: AMPSUnifiedNativeAdError?) {
                    sendMessageToFlutter(
                        AMPSNativeCallBackChannelMethod.ON_VIDEO_PLAY_ERROR,
                        mapOf("adId" to adId,"code" to p0?.code, "message" to p0?.msg)
                    )
                }

                override fun onVideoStop() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_STOP, adId)
                }

                override fun onVideoClicked() {
                    sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_VIDEO_CLICKED, adId)
                }

            })
        return mediaView
    }

    //--主题添加--
    private fun createTitleView(
        child: NativeUnifiedChild.Title,
        text: String
    ): View? {
        return AppCompatTextView(context).apply {
            this.text = text
            layoutParams = createLayoutParams(null, null, child.x, child.y)
            child.fontSize?.let { textSize = it.toFloat() }
            child.color?.let {
                try {
                    setTextColor(it.toColorInt())
                } catch (_: Exception) {
                }
            }
            setupClickListener(this, child.clickType, child.clickIdType)
        }
    }

    //描述
    private fun createDescriptionView(child: NativeUnifiedChild.Description, text: String): View? {
        return AppCompatTextView(context).apply {
            this.text = text
            layoutParams = createLayoutParams(child.width, null, child.x, child.y)
            child.fontSize?.let { textSize = it.toFloat() }
            child.color?.let {
                try {
                    setTextColor(it.toColorInt())
                } catch (_: Exception) {
                }
            }
            setupClickListener(this, child.clickType, child.clickIdType)
        }
    }

    private fun createDownloadInfoView(
        child: NativeUnifiedChild.DownLoadInfo,
        unifiedItem: AMPSUnifiedNativeItem,
        adId: String
    ): View? {
        //渲染六要素信息
        val appDetail = unifiedItem.appDetail
        if (isDownloadAd(appDetail) && child.content != null) {
            var result = child.content
            val layoutParams = createLayoutParams(child.width, null, child.x, child.y)
            val adDownInfoTv = TextView(context)
            adDownInfoTv.layoutParams = layoutParams
            val keyMappings = mapOf(
                AppDetailKeys.appName to appDetail.appName,
                AppDetailKeys.appDeveloper to appDetail.appDeveloper,
                AppDetailKeys.appVersion to appDetail.appVersion,
                AppDetailKeys.appPermissionInfo to appDetail.appPermissionInfo,
                AppDetailKeys.appPrivacyPolicy to appDetail.appPrivacyPolicy,
                AppDetailKeys.appDescription to appDetail.appDescription
            )
            keyMappings.forEach { (propertyName, keyValue) ->
                val placeholder = propertyName // 转义正则特殊字符
                result = result?.replace(placeholder, keyValue, ignoreCase = false)
            }
            adDownInfoTv.text = result
            child.fontColor?.let {
                adDownInfoTv.setTextColor(it.toColorInt())
            }
            adDownInfoTv.setOnClickListener { //app层面处理点击权限，隐私、功能介绍显示页面，需要兼容处理文本和url地址两种情况
                val intent = Intent()
                intent.setClass(
                    context,
                    UnionDownloadAppInfoActivity::class.java
                )
                intent.putExtra("title_content_key", appDetail.appName)
                intent.putExtra("permission_content_key", appDetail.appPermissionInfo)
                intent.putExtra("privacy_content_key", appDetail.appPrivacyPolicy)
                intent.putExtra("intro_content_key", appDetail.appDescription)
                context.startActivity(intent)
            }
            unifiedItem.setDownloadListener(object : AMPSUnifiedDownloadListener {
                override fun onDownloadPaused(position: Int) {
                    sendMessageToFlutter(
                        DownLoadCallBackChannelMethod.onDownloadPaused,
                        mapOf("position" to position, "adId" to adId)
                    )
                }

                override fun onDownloadStarted() {
                    sendMessageToFlutter(DownLoadCallBackChannelMethod.onDownloadStarted, adId)
                }

                override fun onDownloadProgressUpdate(position: Int) {
                    sendMessageToFlutter(
                        DownLoadCallBackChannelMethod.onDownloadProgressUpdate,
                        mapOf("position" to position, "adId" to adId)
                    )
                }

                override fun onDownloadFinished() {
                    sendMessageToFlutter(DownLoadCallBackChannelMethod.onDownloadFinished, adId)
                }

                override fun onDownloadFailed() {
                    sendMessageToFlutter(DownLoadCallBackChannelMethod.onDownloadFailed, adId)
                }

                override fun onInstalled() {
                    sendMessageToFlutter(DownLoadCallBackChannelMethod.onInstalled, adId)
                }
            })
            return adDownInfoTv
        }
        return null
    }

    //操作按钮
    private fun createActionView(
        child: NativeUnifiedChild.ActionButton,
        unifiedItem: AMPSUnifiedNativeItem
    ): View? {
        val layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)

        val actionButtonText = unifiedItem.actionButtonText
        if (actionButtonText == null || actionButtonText.isEmpty()) {
            return null
        }
        if (actionButtonText.startsWith("http")) {
            val actionIv = ImageView(context)
            actionIv.scaleType = ImageView.ScaleType.FIT_CENTER
            actionIv.layoutParams = layoutParams
            ImageLoader().loadImage(actionIv, actionButtonText)
            return actionIv
        } else {
            val textView = TextView(context)
            textView.text = actionButtonText
            child.fontColor?.let {
                try {
                    textView.setTextColor(it.toColorInt())
                } catch (_: Exception) {
                }
            }
            child.backgroundColor?.let {
                try {
                    textView.setBackgroundColor(it.toColorInt())
                } catch (_: Exception) {
                }
            }
            child.fontSize?.let {
                textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, it.toFloat())
            }
            textView.layoutParams = layoutParams
            return textView
        }
    }

    //构建摇一摇
    private fun createShakeView(
        child: NativeUnifiedChild.ShakeView,
        unifiedItem: AMPSUnifiedNativeItem
    ): View? {
        val layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
        if (unifiedItem.optimizeController != null) {
            val shakeView = unifiedItem.optimizeController.getOptimizeShakeView(
                child.width?.toInt() ?: 0,
                child.height?.toInt() ?: 0
            )
            if (shakeView != null) {
                shakeView.layoutParams = layoutParams
                return shakeView
            }
        }
        return null
    }

    //---adSourceIcon创建--
    private fun createAdSourceLogoView(
        child: NativeUnifiedChild.AdSourceLogo,
        unifiedItem: AMPSUnifiedNativeItem
    ): View? {
        return if (unifiedItem.adSourceLogo != null) {
            unifiedItem.adSourceLogo.apply {
                layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
                setupClickListener(this, child.clickType, child.clickIdType)
            }
        } else if (!TextUtils.isEmpty(unifiedItem.adSourceLogoUrl)) {
            AppCompatImageView(context).apply {
                layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
                ImageLoader().loadImage(this, unifiedItem.adSourceLogoUrl)
                setupClickListener(this, child.clickType, child.clickIdType)
            }
        } else {
            null
        }
    }

    //---appIcon创建--
    private fun createAppIconView(
        child: NativeUnifiedChild.AppIcon,
        unifiedItem: AMPSUnifiedNativeItem
    ): View? {
        return if (unifiedItem.iconUrl != null) {
            AppCompatImageView(context).apply {
                layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
                ImageLoader().loadImage(this, unifiedItem.iconUrl)
                setupClickListener(this, child.clickType, child.clickIdType)
            }
        } else {
            null
        }
    }


    private fun createCloseIconView(
        child: NativeUnifiedChild.CloseIcon,
        adId: String
    ): View? {
        if (child.imagePath == null) {
            return null
        }
        return AppCompatImageView(context).apply {
            layoutParams = createLayoutParams(child.width, child.height, child.x, child.y)
            // 从 Flutter assets 加载图片（这是一个简化的例子）
            // 在实际项目中，你可能需要一个更稳健的方法来获取资源 ID
            val flutterAssetPath = "flutter_assets/${child.imagePath}"
            val inputStream = context.assets.open(flutterAssetPath)
            // 将文件流解码为 Bitmap 对象
            val bitmap: Bitmap = BitmapFactory.decodeStream(inputStream)
            scaleType = ImageView.ScaleType.FIT_CENTER
            setImageBitmap(bitmap)
            // 关闭按钮通常有固定的点击行为
            setOnClickListener {
                sendMessageToFlutter(AMPSNativeCallBackChannelMethod.ON_AD_CLOSED, adId)
            }
        }
    }

    private fun sendMessageToFlutter(method: String, args: Any?) {
        AMPSEventManager.getInstance()
            .sendMessageToFlutter(method, args)
    }

    private fun createLayoutParams(
        width: Double?,
        height: Double?,
        x: Double?,
        y: Double?
    ): LayoutParams {
        val params = LayoutParams(
            width?.dpToPx(context) ?: LayoutParams.WRAP_CONTENT,
            height?.dpToPx(context) ?: LayoutParams.WRAP_CONTENT
        )
        // 在 FrameLayout 中，通过 margins 来模拟 offset (x, y)
        params.leftMargin = x?.dpToPx(context) ?: 0
        params.topMargin = y?.dpToPx(context) ?: 0
        return params
    }

    //
    private fun setupClickListener(
        view: View,
        clickType: Int?,
        clickIdType: Int?
    ) {
        val finalClickType = clickType ?: AdClickType.NONE
        if (finalClickType == AdClickType.NONE) {
            return
        }
        // 根据 clickIdType 将视图添加到对应的列表中，用于后续的曝光和点击上报
        if (clickIdType == 0) { // 假设 0 代表 CLICK
            clickableViews.add(view)
        } else if (clickIdType == 1) { // 假设 1 代表 CREATE
            creativeViews.add(view)
        }
    }
}

fun isDownloadAd(appDetail: AMPSAppDetail?): Boolean {
    if (appDetail == null) {
        return false
    }
    if (TextUtils.isEmpty(appDetail.appName)) {
        return false
    }
    if (TextUtils.isEmpty(appDetail.appVersion)) {
        return false
    }
    if (TextUtils.isEmpty(appDetail.appDeveloper)) {
        return false
    }
    if (TextUtils.isEmpty(appDetail.appPermissionInfo)) {
        return false
    }
    if (TextUtils.isEmpty(appDetail.appPrivacyPolicy)) {
        return false
    }
    if (TextUtils.isEmpty(appDetail.appDescription)) {
        return false
    }
    return true
}