package com.example.todointernship

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.nfc.Tag
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class LocalNotificationPublisher : BroadcastReceiver() {
    companion object {
        const val NOTIFICATION_EXTRA = "notificationExtra"
        const val NOTIFICATION_ID = "notificationId"
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        val notification = intent?.extras?.get(NOTIFICATION_EXTRA)
        if (context != null && notification != null) {
            val id = intent.getIntExtra(NOTIFICATION_ID, 0) as Int
            val notificationManager = NotificationManagerCompat.from(context)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = LocalNotificationCreator.createChannel()
                notificationManager.createNotificationChannel(channel)
            }
            NotificationManagerCompat
                    .from(context)
                    .notify("TodoNotification_$id", id, notification as Notification)
        }
    }
}