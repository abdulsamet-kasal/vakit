package com.vakit.vakit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                VakitWidgetHelper.updateAllWidgets(context)
                // Ezan bildirimi alarmlarını da yeniden kur (boot sonrası kaybolur)
                NotificationAlarmReceiver().scheduleNext(context)
                // Kalıcı namaz çubuğu bildirimi de tazelenir (boot sonrası kaybolur)
                PrayerBarNotification.refresh(context)
            }
        }
    }
}
