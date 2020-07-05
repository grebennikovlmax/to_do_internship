package com.example.todointernship

import android.annotation.TargetApi
import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat


class LocalNotificationCreator(private val context: Context) {
    companion object {
        const val channelId = "taskShouldBeDoneChannel"
        const val alarmAction = "todo.internship.alarm.action.trigger"

        @TargetApi(Build.VERSION_CODES.O)
        fun createChannel() = NotificationChannel(
                channelId,
                "Напоминания о выполнении задания",
                NotificationManager.IMPORTANCE_HIGH)
    }

    fun sendDelayedNotification(id: Int, title: String?, triggerTimeMs: Long) {
        val notification = createNotification(title)
        registerDelayedNotification(notification, id.hashCode(), triggerTimeMs)
    }

    private fun registerDelayedNotification(notification: Notification, id: Int, notificationTimeMs: Long) {
        val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                createNotificationIntent(notification, id),
                PendingIntent.FLAG_UPDATE_CURRENT)
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
                .set(AlarmManager.RTC_WAKEUP, notificationTimeMs, pendingIntent)
    }

    private fun createNotification(text: String?): Notification =
            NotificationCompat.Builder(context, channelId)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setContentTitle("Новое уведомление!")
                    .setContentText(text)
                    .setAutoCancel(true)
                    .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                    .setContentIntent(createOnNotificationTapAction())
                    .build()

    private fun createNotificationIntent(notification: Notification, id: Int): Intent =
            Intent(alarmAction).apply {
                this.putExtra(LocalNotificationPublisher.NOTIFICATION_EXTRA, notification)
                this.putExtra(LocalNotificationPublisher.NOTIFICATION_ID, id)
                this.setClass(context, LocalNotificationPublisher::class.java)
            }

    private fun createOnNotificationTapAction(): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(context, 1, intent,
                PendingIntent.FLAG_ONE_SHOT)
    }
}