package com.example.todointernship

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class NotificationsPlatformChannel(engine: FlutterEngine, context: Context) {
    private val channelName = "notifications"
    private val setNotificationMethodName = "setNotification"

    private val channel: MethodChannel
    private val notificationCreator: LocalNotificationCreator = LocalNotificationCreator(context)

    init {
        channel = MethodChannel(engine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            if (call.method == setNotificationMethodName) {
                handleSetNotificationMethod(call, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun handleSetNotificationMethod(call: MethodCall, result: MethodChannel.Result) {
        try {
            val notificationTime = call.argument<Long>("timeSince")
            if (notificationTime != null) {
                val title = call.argument<String>("title")
                val id = call.argument<Integer>("id") ?: 0
                notificationCreator.sendDelayedNotification(id.hashCode(), title, notificationTime)
                result.success("Получилось!1!")
            }
        } catch (exception: Exception) {
            print(exception)
        }
    }
}