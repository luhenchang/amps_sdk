package com.example.amps_sdk.data

import biz.beizi.adn.ad.publish.ASNPConstants
import biz.beizi.adn.ad.publish.ASNPInitConfig
import biz.beizi.adn.ad.publish.IASNPCustomController
import biz.beizi.adn.ad.publish.loc.ASNPLocation
import xyz.adscope.common.v2.location.ILocation
import java.util.HashMap

object UiModelConstant {
    const val AUTO = "uiModelAuto"
    const val DARK = "uiModelDark"
    const val LIGHT = "uiModelLight"
}

object CoordinateConstant {
    const val BAIDU = "BAIDU"
    const val WGS84 = "WGS84"
    const val GCJ02 = "GCJ02"
}

object ParamsKey {
    // Core Parameters
    const val TEST_MODEL = "testModel"
    const val APP_ID = "appId"
    const val IS_DEBUG_SETTING = "_isDebugSetting"
    const val IS_USE_HTTPS = "_isUseHttps"
    const val IS_TEST_AD = "isTestAd"

    // Basic Information Parameters
    const val CURRENCY = "currency"
    const val COUNTRY_CN = "countryCN"
    const val USER_ID = "userId"
    const val APP_NAME = "appName"
    const val PROVINCE = "province"
    const val CITY = "city"
    const val REGION = "region"

    // Mediation and UI Parameters
    const val IS_MEDIATION = "isMediation"
    const val IS_MEDIATION_STATIC = "isMediationStatic"
    const val UI_MODEL = "uiModel"
    const val ADAPTER_NAMES = "adapterNames"

    // Extension and Configuration Parameters
    const val EXTENSION_PARAM = "extensionParam"
    const val OPTION_FIELDS = "optionFields"
    const val AD_CONTROLLER = "adController"
    const val ADAPTER_STATUS_BAR_HEIGHT = "adapterStatusBarHeight"
}

object AdControllerPropKey {
    const val IS_CAN_USE_PHONE_STATE = "isCanUsePhoneState"
    const val OAID = "OAID"
    const val AndroidID = "AndroidID"//TODO android特有
    const val GAID = "GAID" //TODO android特有
    const val IS_SUPPORT_PERSONALIZED = "isSupportPersonalized"
    const val IS_CAN_GATHER_OAID = "isCanGatherOAID"//TODO android特有
    const val GET_UNDERAGE_TAG = "getUnderageTag"
    const val USER_AGENT = "userAgent"
    const val IS_CAN_USE_SENSOR = "isCanUseSensor"
    const val IS_LOCATION_ENABLED = "isLocationEnabled"
    const val IS_CAN_USE_ANDROID_ID = "isCanUseAndroidID"
    const val LOCATION = "location"
}

object LocationPropKey {
    const val LATITUDE = "latitude"
    const val LONGITUDE = "longitude"
    const val TIME_STAMP = "timeStamp"
    const val COORDINATE = "coordinate"
}


class AMPSInitConfigConverter {
    companion object {
        @JvmField // Makes it accessible like a static field from Java if needed
        var testModel: Boolean = false
    }
    fun convert(flutterParams: Map<String, Any>?): ASNPInitConfig? {
        if (flutterParams == null) {
            println("AMPSInitConfigConverter: flutterParams are null.")
            return null
        }

        val mAppId = flutterParams[ParamsKey.APP_ID] as? String
        if (mAppId.isNullOrEmpty()) {
            println("AMPSInitConfigConverter: App ID is missing or empty.")
            return null
        }

        val ampsInitConfigBuilder = ASNPInitConfig.Builder(mAppId)
        (flutterParams[ParamsKey.TEST_MODEL] as? Boolean)?.let {
            testModel = it
        }
        (flutterParams[ParamsKey.IS_DEBUG_SETTING] as? Boolean)?.let {
            ampsInitConfigBuilder.setDebugSetting(it)
        }
        (flutterParams[ParamsKey.IS_USE_HTTPS] as? Boolean)?.let {
            ampsInitConfigBuilder.setUseHttps(it)
        }
        (flutterParams[ParamsKey.IS_TEST_AD] as? Boolean)?.let {
            ampsInitConfigBuilder.setIsTestAd(it)
        }

        (flutterParams[ParamsKey.CURRENCY] as? String)?.let { ampsInitConfigBuilder.addCurrency(it) }
        (flutterParams[ParamsKey.COUNTRY_CN] as? Number)?.toInt()?.let { ampsInitConfigBuilder.setCountryCN(it) } // Assuming it's an Int
        (flutterParams[ParamsKey.APP_NAME] as? String)?.let { ampsInitConfigBuilder.setAppName(it) }
        (flutterParams[ParamsKey.USER_ID] as? String)?.let { ampsInitConfigBuilder.setUserId(it) }

        // UI Model Configuration
        (flutterParams[ParamsKey.UI_MODEL] as? String)?.let { uiModelValue ->
            when (uiModelValue) {
                UiModelConstant.AUTO -> ampsInitConfigBuilder.setUiModel(ASNPConstants.UiModel.UI_MODEL_AUTO)
                UiModelConstant.DARK -> ampsInitConfigBuilder.setUiModel(ASNPConstants.UiModel.UI_MODEL_DARK)
                UiModelConstant.LIGHT -> ampsInitConfigBuilder.setUiModel(ASNPConstants.UiModel.UI_MODEL_LIGHT)
            }
        }

        (flutterParams[ParamsKey.ADAPTER_NAMES] as? List<*>)?.let { names ->
            val stringAdapterNames = names.mapNotNull { it as? String }
            if (stringAdapterNames.isNotEmpty()) {
                //TODO 鸿蒙聚合使用
                //ampsInitConfigBuilder.setAdapterNames(stringAdapterNames)
            }
        }


        // Extension Parameters
        (flutterParams[ParamsKey.EXTENSION_PARAM] as? Map<*, *>)?.let { extensionParamMap ->
            extensionParamMap.forEach { (key, value) ->
                if (value is HashMap<*, *>) { // Assuming the inner map is HashMap<String, Any>
                    try {
                        //TODO 鸿蒙聚合使用
                        //ampsInitConfigBuilder.setExtensionParamItems(key, value as HashMap<String, Any?>)
                    } catch (e: ClassCastException) {
                        println("AMPSInitConfigConverter: Error casting extensionParam value for key $key - $e")
                    }
                }
            }
        }


        (flutterParams[ParamsKey.OPTION_FIELDS] as? Map<*, *>)?.let { optionFieldsMap ->
            // 仅针对此行代码抑制警告，表明您确认这是安全的
            @Suppress("UNCHECKED_CAST")
            //TODO 鸿蒙中Map的value 可能为任何类型，但是android端只需要String，所以这里需要过滤，避免崩溃。
            val anyMap = optionFieldsMap as? Map<String, Any?> ?: emptyMap()
            val safeStringMap: Map<String, String> = anyMap
                .filterValues { it is String }
                .mapValues { it.value as String }
            if (safeStringMap.isNotEmpty()) {
                ampsInitConfigBuilder.setOptionFields(safeStringMap)
            }
        }


        (flutterParams[ParamsKey.ADAPTER_STATUS_BAR_HEIGHT] as? Boolean)?.let {
            //TODO 鸿蒙特有
            //ampsInitConfigBuilder.setLandStatusBarHeight(it) // Assuming this method exists
        }
        (flutterParams[ParamsKey.AD_CONTROLLER] as? Map<*, *>)?.let { adControllerMap ->
            val ampsCustomController: IASNPCustomController = object : IASNPCustomController() {
                override fun getOAID(): String? {
                    val oAID = adControllerMap[AdControllerPropKey.OAID] as? String
                    return oAID ?: ""
                }

                override fun getAndroidID(): String? {
                    val androidID = adControllerMap[AdControllerPropKey.AndroidID] as? String
                    return androidID ?: ""
                }

                override fun getGAID(): String? {
                    val androidGAID = adControllerMap[AdControllerPropKey.GAID] as? String
                    return androidGAID ?: ""
                }

                override fun getUnderageTag(): UnderageTag? {
                    val underageTag = adControllerMap[AdControllerPropKey.USER_AGENT] as? Int
                    return when (underageTag) {
                        UnderageTag.ADULT.code -> UnderageTag.ADULT
                        UnderageTag.UNDERAGE.code -> UnderageTag.UNDERAGE
                        else -> UnderageTag.UNKNOWN
                    }
                }

                override fun getUserAgent(): String? {
                    val useAgent = adControllerMap[AdControllerPropKey.USER_AGENT] as? String
                    return useAgent ?: ""
                }

                override fun isSupportPersonalized(): Boolean {
                    val isSupportPersonalized = adControllerMap[AdControllerPropKey.IS_SUPPORT_PERSONALIZED] as? Boolean
                    return isSupportPersonalized?: true
                }

                override fun isCanGatherOAID(): Boolean {
                    val isCanGatherOAID = adControllerMap[AdControllerPropKey.IS_CAN_GATHER_OAID] as? Boolean
                    return isCanGatherOAID?: true
                }

                override fun isCanUseSensor(): Boolean {
                    val isCanUseSensor = adControllerMap[AdControllerPropKey.IS_CAN_USE_SENSOR] as? Boolean
                    return isCanUseSensor?: true
                }

                override fun isCanUpdateLocation(): Boolean {
                    val isCanUpdateLocation = adControllerMap[AdControllerPropKey.IS_LOCATION_ENABLED] as? Boolean
                    return isCanUpdateLocation ?: true
                }

                override fun isCanUseAndroidID(): Boolean {
                    val isCanUseAndroidID = adControllerMap[AdControllerPropKey.IS_CAN_USE_ANDROID_ID] as? Boolean
                    return isCanUseAndroidID ?: true
                }

                override fun getASNPLocation(): ASNPLocation? {
                    val locationMap = adControllerMap[AdControllerPropKey.LOCATION] as? Map<*, *>
                    if (locationMap == null) {
                        return null
                    }
                    return object : ASNPLocation {
                        override fun getLatitude(): Double {
                            val latitude =
                                (locationMap[LocationPropKey.LATITUDE] as? Number)?.toDouble()
                            return latitude ?: 0.0
                        }

                        override fun getLongitude(): Double {
                            val longitude =
                                (locationMap[LocationPropKey.LONGITUDE] as? Number)?.toDouble()
                            return longitude ?: 0.0
                        }

                        override fun getLocationTimestamp(): Long {
                            val timeStamp =
                                (locationMap[LocationPropKey.TIME_STAMP] as? Number)?.toLong()
                            return timeStamp ?: 0L
                        }

                        override fun getCoordinateType(): ILocation.CoordinateType? {
                            return (locationMap[LocationPropKey.COORDINATE] as? String)?.let { coordinateValue ->
                                when (coordinateValue) {
                                    CoordinateConstant.BAIDU -> ILocation.CoordinateType.BD_09
                                    CoordinateConstant.WGS84 -> ILocation.CoordinateType.WGS_84
                                    CoordinateConstant.GCJ02 -> ILocation.CoordinateType.GCJ_02
                                    else -> null
                                }
                            }
                        }
                    }
                }
            }
            ampsInitConfigBuilder.setAdCustomController(ampsCustomController)
        }


        return ampsInitConfigBuilder.build()
    }
}
