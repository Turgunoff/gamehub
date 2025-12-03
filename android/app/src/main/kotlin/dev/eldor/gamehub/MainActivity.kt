package dev.eldor.gamehub

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            // High Priority Channel - Telegram style heads-up
            val highPriorityChannel = NotificationChannel(
                "high_priority_channel",
                "Muhim Xabarlar",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Muhim xabarlar - yuqoridan ko'rinadi"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                enableLights(true)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }

            // Challenge notification channel
            val challengeChannel = NotificationChannel(
                "challenge_channel",
                "O'yin Takliflari",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "O'yinga taklif qilinganingizda xabar olasiz"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500)
                enableLights(true)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                val soundUri = Uri.parse("android.resource://${packageName}/raw/challenge")
                setSound(soundUri, AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build())
            }

            // Friend request notification channel
            val friendChannel = NotificationChannel(
                "friend_request_channel",
                "Do'stlik So'rovlari",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Yangi do'stlik so'rovlari haqida xabar olasiz"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 100, 300)
                enableLights(true)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                val soundUri = Uri.parse("android.resource://${packageName}/raw/friend_request")
                setSound(soundUri, AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build())
            }

            // Default channel
            val defaultChannel = NotificationChannel(
                "default_channel",
                "Umumiy Xabarlar",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Umumiy xabarlar"
                enableVibration(true)
            }

            notificationManager.createNotificationChannels(
                listOf(highPriorityChannel, challengeChannel, friendChannel, defaultChannel)
            )
        }
    }
}
