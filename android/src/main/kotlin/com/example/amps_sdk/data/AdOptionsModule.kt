package com.example.amps_sdk.data

import android.content.Context
import androidx.window.layout.WindowMetricsCalculator
import biz.beizi.adn.amps.config.AMPSRequestParameters
import com.example.amps_sdk.utils.dpToPx
import java.util.ArrayList

// 定义键名常量
object AdOptionKeys {
    const val KEY_SPACE_ID = "spaceId"
    const val KEY_AD_COUNT = "adCount"
    const val KEY_S2S_IMPL = "s2sImpl"
    const val KEY_TIMEOUT_INTERVAL = "timeoutInterval"
    const val KEY_EXPRESS_SIZE = "expressSize"
    const val KEY_SPLASH_BOTTOM_HEIGHT = "splashAdBottomBuilderHeight"
    const val KEY_USER_ID = "userId"
    const val KEY_EXTRA = "extra"
    const val KEY_IP_ADDRESS = "ipAddress"
}

object AdOptionsModule {

    @Suppress("UNCHECKED_CAST")
    fun getAdOptionFromMap(map: Map<String, Any?>?, context: Context): AMPSRequestParameters {
        val builder = AMPSRequestParameters.Builder()
        if (map == null) {
            return builder.build()
        }

        val spaceId = map[AdOptionKeys.KEY_SPACE_ID] as? String ?: ""
        val s2sImpl = map[AdOptionKeys.KEY_S2S_IMPL] as? String
        val timeoutInterval = map[AdOptionKeys.KEY_TIMEOUT_INTERVAL] as? Number
        val splashBottomHeight = map[AdOptionKeys.KEY_SPLASH_BOTTOM_HEIGHT] as? Int
        val userId = map[AdOptionKeys.KEY_USER_ID] as? String
        val extra = map[AdOptionKeys.KEY_EXTRA] as? String
        val expressSize = map[AdOptionKeys.KEY_EXPRESS_SIZE] as? ArrayList<Int>


        builder.setSpaceId(spaceId)
        if (userId != null) {
            builder.setUserId(userId)
        }
        if (extra != null) {
            builder.setExtraData(extra)
        }
        if (timeoutInterval != null) {
            builder.setTimeOut(timeoutInterval.toInt())
        }
        if (s2sImpl != null) {
            builder.setS2SImpl(s2sImpl)
        }
        if (expressSize != null && expressSize.isNotEmpty()) {
            if (expressSize[0] > 0) {
                builder.setWidth(expressSize[0].dpToPx(context))
            }
        }
        if (splashBottomHeight != null && splashBottomHeight > 0) {
            val windowMetrics = WindowMetricsCalculator.getOrCreate().computeCurrentWindowMetrics(context)
            var screenHeightPx = windowMetrics.bounds.height()

            if (expressSize != null && expressSize.size > 1) {
                if (expressSize[1] > splashBottomHeight) {
                    screenHeightPx = expressSize[1].dpToPx(context)
                }
            }
            builder.setHeight(screenHeightPx - splashBottomHeight.dpToPx(context))
        } else {
            if (expressSize != null && expressSize.size > 1) {
                if (expressSize[1] > 0) {
                    builder.setHeight(expressSize[1].dpToPx(context))
                }
            }
        }
        return builder.build()
    }
    @Suppress("UNCHECKED_CAST")
    fun getNativeAdOptionFromMap(map: Map<String, Any?>?, context: Context): AMPSRequestParameters {
        val builder = AMPSRequestParameters.Builder()
        if (map == null) {
            return builder.build()
        }

        val spaceId = map[AdOptionKeys.KEY_SPACE_ID] as? String ?: ""
        val s2sImpl = map[AdOptionKeys.KEY_S2S_IMPL] as? String
        val timeoutInterval = map[AdOptionKeys.KEY_TIMEOUT_INTERVAL] as? Number
        val splashBottomHeight = map[AdOptionKeys.KEY_SPLASH_BOTTOM_HEIGHT] as? Int
        val express = map[AdOptionKeys.KEY_EXPRESS_SIZE] as? ArrayList<Double>
        val userId = map[AdOptionKeys.KEY_USER_ID] as? String
        val extra = map[AdOptionKeys.KEY_EXTRA] as? String


        builder.setSpaceId(spaceId)
        if (userId != null) {
            builder.setUserId(userId)
        }
        if (extra != null) {
            builder.setExtraData(extra)
        }
        if (timeoutInterval != null) {
            builder.setTimeOut(timeoutInterval.toInt())
        }
        if (s2sImpl != null) {
            builder.setS2SImpl(s2sImpl)
        }
        if (express != null && express.isNotEmpty()) {
            builder.setWidth(express[0].dpToPx(context))
        }
        if (express != null && express.size > 1) {
            builder.setHeight(express[1].dpToPx(context))
        }
        return builder.build()
    }
}
