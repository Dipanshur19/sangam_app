package com.example.sangam_pro.channels

import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object NotificationAccessChannel : MethodChannel.MethodCallHandler {
    private const val CHANNEL = "sangam/notification_access"
    private lateinit var activity: FlutterActivity

    fun register(activity: FlutterActivity, messenger: BinaryMessenger) {
        this.activity = activity
        MethodChannel(messenger, CHANNEL).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isEnabled" -> result.success(isNotificationAccessEnabled(activity))
            "openSettings" -> {
                activity.startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun isNotificationAccessEnabled(context: Context): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners"
        ) ?: return false
        return enabled.contains(context.packageName)
    }
}
