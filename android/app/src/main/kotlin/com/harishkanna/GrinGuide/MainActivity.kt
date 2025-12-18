package com.harishkanna.GrinGuide

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.content.Context

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val sounds = listOf(
                "sound_chime",
                "sound_magic",
                "sound_pop",
                "sound_bird",
                "sound_power"
            )

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            sounds.forEach { soundName ->
                val soundUri = Uri.parse("android.resource://${packageName}/raw/${soundName}")
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()

                val channelId = soundName
                val channelName = soundName.replace("_", " ").capitalize()
                val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH)
                channel.setSound(soundUri, audioAttributes)
                
                notificationManager.createNotificationChannel(channel)
            }
        }
    }
}
