package com.example.amps_sdk.data

import com.example.amps_sdk.manager.AMPSEventManager

object InstanceChannelHelper {
    const val KEY_INSTANCE_ID = "instanceId"
    const val KEY_DATA = "data"

    fun instanceId(args: Any?): String? {
        val map = args as? Map<*, *> ?: return null
        return map[KEY_INSTANCE_ID] as? String
    }

    fun data(args: Any?): Any? {
        val map = args as? Map<*, *> ?: return null
        return map[KEY_DATA]
    }

    fun payload(instanceId: String, data: Any? = null): Map<String, Any?> {
        return mapOf(
            KEY_INSTANCE_ID to instanceId,
            KEY_DATA to data,
        )
    }

    fun send(method: String, instanceId: String, data: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, payload(instanceId, data))
    }
}
