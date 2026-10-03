package com.vakit.vakit

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

/**
 * Ezan vakitleri ve vakit-öncesi hatırlatmalar için alarm alıcısı.
 *
 * Flutter tarafı (NotificationSchedulerService) önümüzdeki 7 günün olaylarını
 * HomeWidgetPreferences içindeki "notif_events_json" anahtarına yazar; bu receiver
 * her tetiklendiğinde:
 *  1. Vakti gelen olay için bildirim gösterir,
 *  2. Kalan olaylardan bir sonraki için yeni alarm kurar.
 *
 * Not: androidx.core bağımlılığı olmadan yalnızca platform API'leriyle yazıldı.
 */
class NotificationAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_NOTIFICATION_ALARM = "com.vakit.vakit.ACTION_NOTIFICATION_ALARM"
        const val CHANNEL_ADHAN = "vakit_adhan"
        const val CHANNEL_PRE = "vakit_pre_alert"
        private const val REQUEST_CODE = 2001
    }

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION_NOTIFICATION_ALARM) return
        showNotificationForDueEvent(context)
        scheduleNext(context)
    }

    /** epochMs değeri şu anı geçmiş ilk olay için bildirim gösterir. */
    private fun showNotificationForDueEvent(context: Context) {
        val events = readEvents(context)
        val now = System.currentTimeMillis()
        val due = events
            .filter { val t = it.optLong("epochMs"); t in 1 until now && (now - t) < 10 * 60_000L }
            .minByOrNull { it.optLong("epochMs") } ?: return

        val kind = due.optString("kind", "adhan")
        val silent = due.optBoolean("silent", true)
        val title = due.optString("title", "Vakit")
        val body = due.optString("body", "")
        val channelId = if (kind == "pre") CHANNEL_PRE else CHANNEL_ADHAN

        ensureChannels(context)

        // Android 13+ bildirim izni kontrolü
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = context.checkSelfPermission(
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) return
        }

        val bigText = Notification.BigTextStyle().bigText(body)
        val builder = Notification.Builder(context, channelId)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(bigText)
            .setCategory(Notification.CATEGORY_ALARM)
            .setAutoCancel(true)

        if (!silent) {
            val sound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            builder.setSound(sound)
        }

        val notification = builder.build()
        applyVibrationIfAllowed(context, silent)

        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(due.optLong("epochMs").toInt(), notification)
        } catch (_: SecurityException) {
            // İzin yoksa sessizce geç
        }
    }

    private fun applyVibrationIfAllowed(context: Context, silent: Boolean) {
        if (!silent) return // sesli bildirimde ayrıca titreşim yok
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vm?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }
            val effect = VibrationEffect.createWaveform(longArrayOf(0, 220, 120, 220), -1)
            vibrator?.vibrate(effect)
        } catch (_: Exception) {
        }
    }

    /** Kalan olaylardan bir sonraki için alarm kurar. */
    fun scheduleNext(context: Context) {
        val events = readEvents(context)
        val now = System.currentTimeMillis()
        val next = events
            .mapNotNull { if (it.optLong("epochMs") > now) it.optLong("epochMs") else null }
            .minOrNull() ?: return

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, NotificationAlarmReceiver::class.java).apply {
            action = ACTION_NOTIFICATION_ALARM
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        try {
            when {
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && alarmManager.canScheduleExactAlarms() ->
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pendingIntent)
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ->
                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pendingIntent)
                else ->
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pendingIntent)
            }
        } catch (_: SecurityException) {
            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pendingIntent)
        }
    }

    private fun readEvents(context: Context): List<JSONObject> {
        val jsonStr = try {
            HomeWidgetPlugin.getData(context).getString("notif_events_json", null)
        } catch (_: Exception) {
            null
        } ?: return emptyList()

        return try {
            val array = JSONArray(jsonStr)
            (0 until array.length()).map { array.getJSONObject(it) }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun ensureChannels(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        val adhanChannel = NotificationChannel(
            CHANNEL_ADHAN,
            "Ezan Vakitleri",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Namaz vakti girdiğinde gösterilen bildirimler"
            enableVibration(true)
        }

        val preChannel = NotificationChannel(
            CHANNEL_PRE,
            "Vakit Öncesi Hatırlatma",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Namaz vaktinden önce gösterilen hatırlatmalar"
            enableVibration(true)
        }

        nm.createNotificationChannel(adhanChannel)
        nm.createNotificationChannel(preChannel)
    }
}
