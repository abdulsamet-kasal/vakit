package com.vakit.vakit

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.media.RingtoneManager
import android.net.Uri
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

    /// Sistem zil seçicisi sonucunu bekleyen MethodChannel sonucu
    private var soundPickerResult: MethodChannel.Result? = null

    /// Bildirim alıcısı örnekleri (kanal/ses yapılandırması ve test bildirimi için)
    private val notificationReceiver by lazy { NotificationAlarmReceiver() }

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
                    "updatePrayerBar" -> {
                        PrayerBarNotification.refresh(this)
                        result.success(true)
                    }
                    "sendTestNotification" -> {
                        notificationReceiver.showTestNotification(this)
                        result.success(true)
                    }
                    "pickNotificationSound" -> {
                        openSoundPicker(call.argument<String>("uri"), result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }

    /// Sistem zil seçicisini (notification tone) açar.
    /// Dönüş: null = iptal, "" = sessiz, diğer = seçilen ses URI'si.
    private fun openSoundPicker(currentUri: String?, result: MethodChannel.Result) {
        if (soundPickerResult != null) {
            result.error("busy", "Zil seçici zaten açık", null)
            return
        }
        val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Bildirim sesi seçin")
            if (!currentUri.isNullOrEmpty()) {
                putExtra(RingtoneManager.EXTRA_RINGTONE_EXISTING_URI, Uri.parse(currentUri))
            }
        }
        soundPickerResult = result
        try {
            @Suppress("DEPRECATION")
            startActivityForResult(intent, REQUEST_PICK_SOUND)
        } catch (e: Exception) {
            soundPickerResult = null
            result.error("unavailable", "Zil seçici açılamadı", e.message)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_PICK_SOUND) return

        val pending = soundPickerResult
        soundPickerResult = null
        if (pending == null) return

        if (resultCode != Activity.RESULT_OK) {
            pending.success(null) // iptal
            return
        }
        val uri: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            data?.getParcelableExtra(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        }
        // "Sessiz" seçildiğinde URI null döner → boş dize olarak bildirilir
        pending.success(uri?.toString() ?: "")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensureNotificationChannels()
        requestNotificationPermissionIfNeeded()
        // Uygulama açılışında yakın gelecek için bildirim alarmını tazele
        notificationReceiver.scheduleNext(this)
        // Kalıcı namaz çubuğu bildirimini tazeler (kapalıysa zaten kaldırılır)
        PrayerBarNotification.refresh(this)
    }

    companion object {
        private const val REQUEST_PICK_SOUND = 6001
    }

    private fun ensureNotificationChannels() {
        // Kanalları kullanıcının seçtiği ses/titreşim ayarıyla oluştur/güncelle
        notificationReceiver.ensureChannels(
            this,
            notificationReceiver.readSoundConfig(this),
        )
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
