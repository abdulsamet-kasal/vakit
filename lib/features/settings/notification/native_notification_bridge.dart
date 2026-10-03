import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Kotlin tarafındaki bildirim servislerine erişen ince MethodChannel sarmalayıcısı.
///
/// Kanal: `com.vakit.vakit/notifications` (MainActivity).
/// Tüm çağrılar sessizce yutulur; Android dışı platformlarda ve kanal yokken
/// uygulama akışı bozulmamalıdır.
class NativeNotificationBridge {
  NativeNotificationBridge._();

  static const MethodChannel _channel =
      MethodChannel('com.vakit.vakit/notifications');

  static Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } catch (e) {
      debugPrint('NativeNotificationBridge.$method hatası: $e');
      return null;
    }
  }

  /// Kaydedilmiş olaylardan en yakın bildirim alarmını (yeniden) kurar.
  static Future<void> schedule() => _invoke<void>('scheduleNotifications');

  /// Kalıcı namaz çubuğu bildirimini tazeler (kapalıysa kaldırır).
  static Future<void> updatePrayerBar() => _invoke<void>('updatePrayerBar');

  /// Ayarlardaki ses/titreşim ayarlarıyla bir test bildirimi gösterir.
  static Future<void> sendTestNotification() =>
      _invoke<void>('sendTestNotification');

  /// Sistem zil seçicisini açar.
  ///
  /// Dönüş: `null` = vazgeçildi/iptal, `''` = sessiz, diğer = seçilen ses URI'si.
  static Future<String?> pickSound({String? currentUri}) =>
      _invoke<String>('pickNotificationSound', <String, Object?>{
        'uri': currentUri ?? '',
      });
}
