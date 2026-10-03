import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../prayer_times/data/prayer_calculator.dart';
import '../../prayer_times/domain/city_model.dart';
import '../domain/settings_model.dart';
import 'native_notification_bridge.dart';

/// Ezan bildirimi ve vakit öncesi hatırlatma zamanlayıcısı.
///
/// Çalışma şekli (pil dostu, offline):
/// 1. Önümüzdeki 7 günün vakitleri hesaplanır (widget köprüsüyle aynı veri kaynağı).
/// 2. Ezan vakitleri ve (açıksa) vakit-öncesi hatırlatma zamanları JSON'a yazılır
///    (`notif_events_json`, HomeWidgetPreferences).
/// 3. Kotlin tarafındaki [NotificationAlarmReceiver] bu JSON'u okuyup yakın gelecekteki
///    ilk olay için kesin alarm kurar; her tetiklenmede bir sonrakini kurar.
///
/// Ayar değişikliği, şehir değişikliği veya uygulama açılışında yeniden zamanlanır;
/// cihaz yeniden başlatınca BootReceiver Kotlin tarafında alarmları yeniden kurar.
class NotificationSchedulerService {
  NotificationSchedulerService._();

  static final NotificationSchedulerService instance =
      NotificationSchedulerService._();

  static const _prefsNotificationFlags = 'notif_flags_json';

  /// Son zamanlamanın zamanı (hata ayıklama/test için).
  static DateTime? lastScheduledAt;

  /// Şehir + ayarlara göre önümüzdeki 7 günün bildirim olaylarını üretip kaydeder.
  Future<void> scheduleFromCity(
    CityModel city, {
    AppSettingsModel? settings,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = settings ?? await const _SimpleSettingsReader().read();

      await prefs.setString(
        _prefsNotificationFlags,
        jsonEncode(NotificationFlags(
          adhanEnabled: s.adhanNotificationEnabled,
          preAlertEnabled: s.preAlertEnabled,
          preAlertMinutes: s.preAlertMinutes,
          silent: s.adhanSilentMode,
        ).toJson()),
      );

      // Kotlin tarafı için ses/titreşim ve kalıcı çubuk yapılandırması.
      // (notif_flags_json yalnızca Flutter tarafında; Kotlin bunu okur.)
      await HomeWidget.saveWidgetData<String>(
        'notif_sound_json',
        jsonEncode(<String, Object?>{
          'uri': s.notificationSoundUri ?? '',
          'silent': s.adhanSilentMode,
          'vibration': s.notificationVibration,
        }),
      );
      await HomeWidget.saveWidgetData<bool>('prayer_bar_enabled', s.prayerBarEnabled);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final days = PrayerCalculator.calculateRange(
        city: city,
        startDate: today,
        days: 7,
        method: s.calculationMethod,
        madhab: s.madhab,
      );

      final events = <Map<String, Object?>>[];
      for (final day in days) {
        final items = <(DateTime, String)>[
          (day.imsak, 'İmsak'),
          (day.gunes, 'Güneş'),
          (day.ogle, 'Öğle'),
          (day.ikindi, 'İkindi'),
          (day.aksam, 'Akşam'),
          (day.yatsi, 'Yatsı'),
        ];

        for (final (time, name) in items) {
          final timeStr =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

          if (s.adhanNotificationEnabled && time.isAfter(now)) {
            events.add({
              'epochMs': time.millisecondsSinceEpoch,
              'title': '$name vakti girdi',
              'body': '$name vakti $timeStr — ${city.displayName}',
              'kind': 'adhan',
              'prayerName': name,
              'silent': s.adhanSilentMode,
            });
          }

          if (s.preAlertEnabled) {
            final pre = time.subtract(Duration(minutes: s.preAlertMinutes));
            if (pre.isAfter(now)) {
              events.add({
                'epochMs': pre.millisecondsSinceEpoch,
                'title': '$name vaktine ${s.preAlertMinutes} dakika kaldı',
                'body': '$name vakti $timeStr — ${city.displayName}',
                'kind': 'pre',
                'prayerName': name,
                'silent': s.adhanSilentMode,
              });
            }
          }
        }
      }

      await HomeWidget.saveWidgetData<String>(
        'notif_events_json',
        jsonEncode(events),
      );

      lastScheduledAt = DateTime.now();
      debugPrint('NotificationScheduler: ${events.length} olay yazıldı.');

      // Alarm sayacını hemen tazeler ve kalıcı namaz çubuğunu günceller.
      await NativeNotificationBridge.schedule();
      await NativeNotificationBridge.updatePrayerBar();
    } catch (e) {
      debugPrint('NotificationScheduler hatası: $e');
    }
  }
}

/// SharedPreferences'tan bildirimle ilgili ayarları okuyan minimal yardımcı.
/// SettingsRepository ile aynı anahtarları kullanır (döngüsel importu önler).
class _SimpleSettingsReader {
  const _SimpleSettingsReader();

  Future<AppSettingsModel> read() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsModel(
      adhanNotificationEnabled:
          prefs.getBool('adhan_notification_enabled') ?? true,
      preAlertEnabled: prefs.getBool('pre_alert_enabled') ?? false,
      preAlertMinutes: prefs.getInt('pre_alert_minutes') ?? 15,
      adhanSilentMode: prefs.getBool('adhan_silent_mode') ?? true,
      notificationSoundUri: prefs.getString('notification_sound_uri'),
      notificationVibration: prefs.getBool('notification_vibration') ?? true,
      prayerBarEnabled: prefs.getBool('prayer_bar_notification_enabled') ?? true,
    );
  }
}

/// Kotlin tarafına iletilen bildirim davranış bayrakları.
class NotificationFlags {
  final bool adhanEnabled;
  final bool preAlertEnabled;
  final int preAlertMinutes;
  final bool silent;

  const NotificationFlags({
    required this.adhanEnabled,
    required this.preAlertEnabled,
    required this.preAlertMinutes,
    required this.silent,
  });

  Map<String, Object?> toJson() => {
        'adhanEnabled': adhanEnabled,
        'preAlertEnabled': preAlertEnabled,
        'preAlertMinutes': preAlertMinutes,
        'silent': silent,
      };
}
