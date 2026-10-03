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
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
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
        private const val TEST_NOTIFICATION_ID = 4142
        private val VIBRATION_PATTERN = longArrayOf(0, 220, 120, 220)
    }

    /** Bildirim sesi ve titreşimi tercihleri (Flutter tarafından yazılır). */
    data class SoundConfig(
        val uri: String,
        val silent: Boolean,
        val vibration: Boolean,
    ) {
        companion object {
            val DEFAULT = SoundConfig(uri = "", silent = true, vibration = true)
        }
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
        val cfg = readSoundConfig(context)
        // Olayın kendi sessizlik bayrağı + güncellenmiş kullanıcı tercihi
        val silent = due.optBoolean("silent", true) || cfg.silent
        val title = due.optString("title", "Vakit")
        val body = due.optString("body", "")
        val channelId = if (kind == "pre") CHANNEL_PRE else CHANNEL_ADHAN

        ensureChannels(context, cfg)

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

        // Android 8.0 altı: ses ve titreşim bildirim üzerinde ayarlanır
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            val soundUri = if (silent) null else resolveSoundUri(cfg)
            if (soundUri != null) builder.setSound(soundUri)
            if (cfg.vibration) builder.setVibrate(VIBRATION_PATTERN)
        }

        val notification = builder.build()

        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(due.optLong("epochMs").toInt(), notification)
        } catch (_: SecurityException) {
            // İzin yoksa sessizce geç
        }

        // Kalıcı namaz çubuğundaki "sonraki vakit" satırı tazelenir
        PrayerBarNotification.refresh(context)
    }

    /** Ayarlardaki ses/ titreşim tercihlerini (Flutter'ın yazdığı JSON) okur. */
    fun readSoundConfig(context: Context): SoundConfig {
        val jsonStr = try {
            HomeWidgetPlugin.getData(context).getString("notif_sound_json", null)
        } catch (_: Exception) {
            null
        } ?: return SoundConfig.DEFAULT

        return try {
            val obj = JSONObject(jsonStr)
            SoundConfig(
                uri = obj.optString("uri", ""),
                silent = obj.optBoolean("silent", true),
                vibration = obj.optBoolean("vibration", true),
            )
        } catch (_: Exception) {
            SoundConfig.DEFAULT
        }
    }

    /** Sessizse null, seçili ses varsa o URI, değilse sistem varsayılanı. */
    private fun resolveSoundUri(cfg: SoundConfig): Uri? {
        if (cfg.silent) return null
        if (cfg.uri.isNotEmpty()) {
            return try {
                Uri.parse(cfg.uri)
            } catch (_: Exception) {
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            }
        }
        return RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
    }

    /** Ayarlar ekranındaki "Test Bildirimi Gönder" düğmesi için. */
    fun showTestNotification(context: Context) {
        val cfg = readSoundConfig(context)
        ensureChannels(context, cfg)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = context.checkSelfPermission(
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!granted) return
        }

        val builder = Notification.Builder(context, CHANNEL_ADHAN)
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle("Test bildirimi")
            .setContentText("Ezan bildirimi böyle görünür")
            .setStyle(Notification.BigTextStyle().bigText("Ezan bildirimi böyle görünür. Ses ve titreşim ayarlarını deneyebilirsin."))
            .setCategory(Notification.CATEGORY_ALARM)
            .setAutoCancel(true)

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            val soundUri = if (cfg.silent) null else resolveSoundUri(cfg)
            if (soundUri != null) builder.setSound(soundUri)
            if (cfg.vibration) builder.setVibrate(VIBRATION_PATTERN)
        }

        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(TEST_NOTIFICATION_ID, builder.build())
        } catch (_: SecurityException) {
            // İzin yoksa sessizce geç
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

    /**
     * Kanalları açar ve kullanıcının seçtiği ses/titreşim ayarını uygular.
     * Kanal zaten varsa createNotificationChannel güncellemeyi uygular
     * (ses ve titreşim programatik olarak değiştirilebilir).
     */
    fun ensureChannels(context: Context, cfg: SoundConfig) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        val soundUri = if (cfg.silent) null else resolveSoundUri(cfg)
        val audioAttributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        val adhanChannel = NotificationChannel(
            CHANNEL_ADHAN,
            "Ezan Vakitleri",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Namaz vakti girdiğinde gösterilen bildirimler"
            enableVibration(cfg.vibration)
            if (cfg.vibration) vibrationPattern = VIBRATION_PATTERN
            setSound(soundUri, audioAttributes)
        }

        val preChannel = NotificationChannel(
            CHANNEL_PRE,
            "Vakit Öncesi Hatırlatma",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Namaz vaktinden önce gösterilen hatırlatmalar"
            enableVibration(cfg.vibration)
            if (cfg.vibration) vibrationPattern = VIBRATION_PATTERN
            setSound(soundUri, audioAttributes)
        }

        nm.createNotificationChannel(adhanChannel)
        nm.createNotificationChannel(preChannel)
    }
}
