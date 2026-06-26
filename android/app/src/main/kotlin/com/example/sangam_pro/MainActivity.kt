package com.example.sangam_pro

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.example.sangam_pro.channels.NotificationAccessChannel
import com.example.sangam_pro.channels.UpiNotificationStreamHandler

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NotificationAccessChannel.register(this, flutterEngine.dartExecutor.binaryMessenger)
        UpiNotificationStreamHandler.register(flutterEngine.dartExecutor.binaryMessenger)
    }
}
