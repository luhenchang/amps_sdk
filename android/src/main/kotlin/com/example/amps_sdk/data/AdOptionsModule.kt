package com.example.amps_sdk.data
import biz.beizi.adn.amps.config.AMPSRequestParameters

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
    fun getAdOptionFromMap(map: Map<String, Any?>?): AMPSRequestParameters {
        val builder = AMPSRequestParameters.Builder()
        if (map == null) {
            return builder.build()
        }

        val spaceId = map[AdOptionKeys.KEY_SPACE_ID] as? String ?: ""
        val s2sImpl = map[AdOptionKeys.KEY_S2S_IMPL] as? String
        val timeoutInterval = map[AdOptionKeys.KEY_TIMEOUT_INTERVAL] as? Number
        val expressSizeList = map[AdOptionKeys.KEY_EXPRESS_SIZE] as? List<*>
        val userId = map[AdOptionKeys.KEY_USER_ID] as? String
        val extra = map[AdOptionKeys.KEY_EXTRA] as? String


        builder.setSpaceId(spaceId)
        if (userId!=null) {
            builder.setUserId(userId)
        }
        if (extra!=null) {
            builder.setExtraData(extra)
        }
        if (timeoutInterval!=null) {
            builder.setTimeOut(timeoutInterval.toInt())
        }
        if (s2sImpl != null) {
            builder.setS2SImpl(s2sImpl)
        }
        //TODO 补全即可
        expressSizeList?.let { list ->
            if (list.size == 2) {
                val width = list.getOrNull(0) as? Number
                val height = list.getOrNull(1) as? Number
                if (width!=null && height!=null) {
                    builder.setWidth(width.toInt())
                    builder.setHeight(height.toInt())
                }
            }
        }
        return builder.build()

    }
}
