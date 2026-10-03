package com.vakit.vakit

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Bildirim çubuğunda (öne ekranı) günün namaz vakitlerini **kalıcı** gösteren bildirim.
 *
 *  - ongoing bildirimdir: kullanıcı kaydırarak kapatamaz; yalnızca ayar kapatılınca
 *    veya uygulama verisi sıfırlanınca kaldırılır.
 *  - Veri widget köprüsünden gelir: `days_prayer_json` + `city_name` (HomeWidgetPreferences).
 *  - Açma/kapatma Flutter tarafındaki `prayer_bar_enabled` anahtarından okunur.
 *  - Yenilendiği anlar: veri senkronu (Flutter), uygulama açılışı, cihaz yeniden
 *    başlatma, vakit/kerahat alarmları ve her ezan bildiriminden sonra.
 *
 * Not: androidx.core bağımlılığı olmadan yalnızca platform API'leriyle yazıldı.
 */
object PrayerBarNotification {

    const val CHANNEL_BAR = "vakit_prayer_bar"
    private const val NOTIF_ID = 4141
    private const val REQUEST_OPEN = 3001

    /** Kalıcı çubuğu güncel verilerle tazeler; ayar kapalıysa kaldırır. */
    fun refresh(context: Context) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE)
                as? NotificationManager ?: return

            if (!isEnabled(context)) {
                nm.cancel(NOTIF_ID)
                return
            }

            val prefs = VakitWidgetHelper.getPrefs(context)
            val days = VakitWidgetHelper.parsePrayerData(context, prefs)
            if (days.isEmpty()) return

            val now = System.currentTimeMillis()
            val today = VakitWidgetHelper.findTodayDayData(days) ?: return
            val city = VakitWidgetHelper.getStringValue(context, prefs, "city_name", "")

            // Sıradaki vakit: tüm günlerin vakitlerinden ilk geçerli olan
            val next = days.asSequence()
                .flatMap { it.events.asSequence() }
                .firstOrNull { it.epochMs > now }

            val timesLine = today.events
                .filter { it.timeStr.isNotEmpty() }
                .joinToString("  •  ") { "${it.name} ${it.timeStr}" }
            val nextLine = next?.let { "Sonraki: ${it.name} ${it.timeStr}" }
            val kerahat = VakitWidgetHelper.isKerahatActive(now, today)

            val bigText = buildString {
                append(timesLine)
                if (nextLine != null) {
                    append('\n')
                    append(nextLine)
                }
                if (kerahat) {
                    append('\n')
                    append("Şu an kerahat vakti")
                }
            }

            ensureChannel(context)

            val builder = Notification.Builder(context, CHANNEL_BAR)
                .setSmallIcon(context.applicationInfo.icon)
                .setContentTitle(
                    if (city.isEmpty()) "Bugünün vakitleri" else "Bugün • $city"
                )
                .setContentText(nextLine ?: "Bugünün tüm vakitleri geçti")
                .setStyle(Notification.BigTextStyle().bigText(bigText))
                .setCategory(Notification.CATEGORY_REMINDER)
                .setPriority(Notification.PRIORITY_LOW)
                .setOngoing(true)
                .setAutoCancel(false)
                .setOnlyAlertOnce(true)

            openAppIntent(context)?.let { builder.setContentIntent(it) }

            nm.notify(NOTIF_ID, builder.build())
        } catch (_: Exception) {
            // İzin yok veya bildirim engelli: sessizce geç
        }
    }

    /** Kalıcı çubuğu kaldırır (ayar kapatıldığında). */
    fun cancel(context: Context) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE)
                as? NotificationManager ?: return
            nm.cancel(NOTIF_ID)
        } catch (_: Exception) {
        }
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as? NotificationManager ?: return
        if (nm.getNotificationChannel(CHANNEL_BAR) != null) return

        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_BAR,
                "Namaz Çubuğu",
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = "Bildirim çubuğunda günün namaz vakitleri (kalıcı)"
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            }
        )
    }

    private fun openAppIntent(context: Context): PendingIntent? {
        val base = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: return null
        base.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getActivity(context, REQUEST_OPEN, base, flags)
    }

    /** Flutter'ın yazdığı açma/kapatma anahtarı; yoksa varsayılan açık. */
    private fun isEnabled(context: Context): Boolean {
        return try {
            val hw = HomeWidgetPlugin.getData(context)
            if (hw.contains("prayer_bar_enabled")) {
                hw.getBoolean("prayer_bar_enabled", true)
            } else {
                val flt = context.getSharedPreferences(
                    "FlutterSharedPreferences",
                    Context.MODE_PRIVATE,
                )
                if (flt.contains("flutter.prayer_bar_notification_enabled")) {
                    flt.getBoolean("flutter.prayer_bar_notification_enabled", true)
                } else {
                    true
                }
            }
        } catch (_: Exception) {
            true
        }
    }
}
