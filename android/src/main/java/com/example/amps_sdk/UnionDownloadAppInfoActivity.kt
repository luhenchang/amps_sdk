package com.example.amps_sdk

import android.annotation.SuppressLint
import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.webkit.*
import androidx.core.graphics.toColorInt
import com.example.amps_sdk.databinding.ActivityUnionDownloadAppInfoBinding

class UnionDownloadAppInfoActivity : Activity() {
    companion object {
        private const val EXTRA_TITLE = "title_content_key"
        private const val EXTRA_PERMISSION = "permission_content_key"
        private const val EXTRA_PRIVACY = "privacy_content_key"
        private const val EXTRA_INTRO = "intro_content_key"
        private const val COLOR_SELECTED = "#3D7BF9"
        private const val COLOR_UNSELECTED = "#C2C3C5"
    }

    private lateinit var binding: ActivityUnionDownloadAppInfoBinding
    private var titleContent: String? = ""
    private var permissionContent: String? = ""
    private var privacyContent: String? = ""
    private var introContent: String? = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 初始化ViewBinding
        binding = ActivityUnionDownloadAppInfoBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // 读取传递的数据
        readExtras()

        // 初始化UI
        initUI()

        // 设置事件监听
        setupListeners()

        // 初始化WebView
        initWebView()

        // 显示初始内容
        showPermissionContent()
    }

    /**
     * 读取从其他页面传递过来的数据
     */
    private fun readExtras() {
        intent.extras?.let { bundle ->
            titleContent = bundle.getString(EXTRA_TITLE)
            permissionContent = bundle.getString(EXTRA_PERMISSION)
            privacyContent = bundle.getString(EXTRA_PRIVACY)
            introContent = bundle.getString(EXTRA_INTRO)
        }
    }

    /**
     * 初始化UI组件
     */
    private fun initUI() {
        // 设置标题
        titleContent?.takeIf { it.isNotEmpty() }?.let {
            binding.downloadTitle.text = it
        }
    }

    /**
     * 设置所有点击事件监听
     */
    private fun setupListeners() {
        // 返回按钮
        binding.downloadBack.setOnClickListener { finish() }

        // 权限标签
        binding.downloadPermissionTv.setOnClickListener { showPermissionContent() }

        // 隐私标签
        binding.downloadPrivacyTv.setOnClickListener { showPrivacyContent() }
        binding.downloadPrivacyTv.setOnClickListener { showPrivacyContent() }

        // 介绍标签
        binding.downloadIntroTv.setOnClickListener { showIntroContent() }
    }

    /**
     * 初始化WebView配置
     */
    @SuppressLint("SetJavaScriptEnabled")
    private fun initWebView() {
        with(binding.downloadWv.settings) {
            // 基础设置
            javaScriptEnabled = true
            domStorageEnabled = true
            javaScriptCanOpenWindowsAutomatically = true
            builtInZoomControls = false
            loadsImagesAutomatically = true
            savePassword = false
            setSupportZoom(false)
            useWideViewPort = false
            allowFileAccess = false
            allowContentAccess = false
            setGeolocationEnabled(false)

            // 根据API级别设置特定属性
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                mediaPlaybackRequiresUserGesture = false
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
                CookieManager.getInstance().setAcceptThirdPartyCookies(binding.downloadWv, true)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                WebView.setWebContentsDebuggingEnabled(false)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                allowFileAccessFromFileURLs = false
                allowUniversalAccessFromFileURLs = false
            }

            // 移除可能的安全隐患
            if (Build.VERSION.SDK_INT in Build.VERSION_CODES.HONEYCOMB until Build.VERSION_CODES.KITKAT) {
                binding.downloadWv.removeJavascriptInterface("searchBoxJavaBridge_")
                binding.downloadWv.removeJavascriptInterface("accessibility")
                binding.downloadWv.removeJavascriptInterface("accessibilityTraversal")
            }

            // 缓存设置
            cacheMode = WebSettings.LOAD_DEFAULT
        }

        // 滚动条设置
        with(binding.downloadWv) {
            isHorizontalScrollBarEnabled = false
            isVerticalScrollBarEnabled = false
            scrollBarStyle = WebView.SCROLLBARS_INSIDE_OVERLAY
        }
    }

    /**
     * 显示权限内容
     */
    private fun showPermissionContent() {
        updateTabStyles(
            permissionSelected = true,
            privacySelected = false,
            introSelected = false
        )
        showTabContent(permissionContent)
    }

    /**
     * 显示隐私内容
     */
    private fun showPrivacyContent() {
        updateTabStyles(
            permissionSelected = false,
            privacySelected = true,
            introSelected = false
        )
        showTabContent(privacyContent)
    }

    /**
     * 显示介绍内容
     */
    private fun showIntroContent() {
        updateTabStyles(
            permissionSelected = false,
            privacySelected = false,
            introSelected = true
        )
        showTabContent(introContent)
    }

    /**
     * 更新标签样式
     */
    private fun updateTabStyles(
        permissionSelected: Boolean,
        privacySelected: Boolean,
        introSelected: Boolean
    ) {
        binding.downloadPermissionTv.setTextColor(getColor(permissionSelected))
        binding.downloadPrivacyTv.setTextColor(getColor(privacySelected))
        binding.downloadIntroTv.setTextColor(getColor(introSelected))
    }

    /**
     * 根据选中状态获取颜色
     */
    private fun getColor(isSelected: Boolean): Int {
        return (if (isSelected) COLOR_SELECTED else COLOR_UNSELECTED).toColorInt()
    }

    /**
     * 显示标签内容
     */
    private fun showTabContent(content: String?) {
        if (TextUtils.isEmpty(content)) return

        val displayContent = if (content!!.startsWith("http")) content
        else "<html><body>$content</body></html>"

        if (displayContent.startsWith("http")) {
            binding.downloadWv.loadUrl(displayContent)
        } else {
            binding.downloadWv.loadData(displayContent, "text/html", "utf-8")
        }
    }
}
