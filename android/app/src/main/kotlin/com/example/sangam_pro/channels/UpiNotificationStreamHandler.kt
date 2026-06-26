package com.example.sangam_pro.channels

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import com.example.sangam_pro.models.UpiPayment

object UpiNotificationStreamHandler : EventChannel.StreamHandler {
    private const val CHANNEL = "sangam/upi_notifications"
    private var sink: EventChannel.EventSink? = null

    fun register(messenger: BinaryMessenger) {
        EventChannel(messenger, CHANNEL).setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(payment: UpiPayment) {
        sink?.success(payment.toMap())
    }
}
