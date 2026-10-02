import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

/// Tarih ve saat biçimlendirme yardımcı sınıfı (tr_TR uyumlu).
abstract final class DateTimeUtils {
  static const List<String> _hijriMonthsTurkish = [
    '',
    'Muharrem',
    'Safer',
    'Rebîülevvel',
    'Rebîülâhir',
    'Cemâziyelevvel',
    'Cemâziyelâhir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  /// Miladi tarihi Türkçe formatlar. Örn: "2 Ekim 2026, Cuma"
  static String formatMiladiFull(DateTime date) {
    return DateFormat('d MMMM y, EEEE', 'tr_TR').format(date);
  }

  /// Kısa Miladi tarih. Örn: "2 Ekim Cuma"
  static String formatMiladiShort(DateTime date) {
    return DateFormat('d MMMM EEEE', 'tr_TR').format(date);
  }

  /// Hicri tarihi Türkçe ay ismiyle formatlar. Örn: "21 Rebîülâhir 1448"
  static String formatHijri(DateTime date) {
    final h = HijriCalendar.fromDate(date);
    final monthName = (h.hMonth >= 1 && h.hMonth <= 12)
        ? _hijriMonthsTurkish[h.hMonth]
        : 'Ay ${h.hMonth}';
    return '${h.hDay} $monthName ${h.hYear}';
  }

  /// Saat ve dakikayı formatlar. Örn: "05:30"
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Kalan süreyi "SS:DD:ss" (saat:dakika:saniye) şeklinde formatlar.
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) {
      return '00:00:00';
    }
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
