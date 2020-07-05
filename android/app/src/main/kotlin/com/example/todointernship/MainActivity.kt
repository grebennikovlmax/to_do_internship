package com.example.todointernship

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private lateinit var notificationsChannel: NotificationsPlatformChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        notificationsChannel = NotificationsPlatformChannel(flutterEngine, this)
    }
}
