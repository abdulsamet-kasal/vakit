package com.vakit.vakit

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val COMPASS_CHANNEL = "com.vakit.vakit/compass"
    private val NOTIF_CHANNEL = "com.vakit.vakit/notifications"
    private var compassHandler: CompassStreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        compassHandler = CompassStreamHandler(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, COMPASS_CHANNEL)
            .setStreamHandler(compassHandler)

        // Flutter'dan bildirim alarmlarını yeniden kurma isteği
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIF_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleNotifications" -> {
                        NotificationAlarmReceiver().scheduleNext(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensureNotificationChannels()
        requestNotificationPermissionIfNeeded()
        // Uygulama açılışında yakın gelecek için bildirim alarmını tazele
        NotificationAlarmReceiver().scheduleNext(this)
    }

    private fun ensureNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as android.app.NotificationManager
            nm.createNotificationChannel(
                android.app.NotificationChannel(
                    NotificationAlarmReceiver.CHANNEL_ADHAN,
                    "Ezan Vakitleri",
                    android.app.NotificationManager.IMPORTANCE_HIGH,
                ).apply { description = "Namaz vakti girdiğinde gösterilen bildirimler" }
            )
            nm.createNotificationChannel(
                android.app.NotificationChannel(
                    NotificationAlarmReceiver.CHANNEL_PRE,
                    "Vakit Öncesi Hatırlatma",
                    android.app.NotificationManager.IMPORTANCE_DEFAULT,
                ).apply { description = "Namaz vaktinden önce gösterilen hatırlatmalar" }
            )
        }
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                PackageManager.PERMISSION_GRANTED
            ) {
                requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 5001)
            }
        }
    }
}
