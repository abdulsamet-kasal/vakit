import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routing/app_router.dart';
import '../daily_content/data/daily_content_repository.dart';
import '../daily_content/data/models/hadith_model.dart';
import '../daily_content/data/models/verse_model.dart';
import '../prayer_times/data/prayer_calculator.dart';
import '../prayer_times/domain/city_model.dart';

/// Ana ekran widget'ları (Android AppWidget / iOS WidgetKit) ile veri köprüsü.
class HomeWidgetService {
  static const String appGroupId = 'group.com.vakit.vakit';

  static const String smallWidgetProvider = 'VakitSmallWidgetProvider';
  static const String mediumWidgetProvider = 'VakitMediumWidgetProvider';
  static const String stripWidgetProvider = 'VakitStripWidgetProvider';
  static const String verseWidgetProvider = 'VakitVerseWidgetProvider';
  static const String hadithWidgetProvider = 'VakitHadithWidgetProvider';

  static final DailyContentRepository _contentRepo = DailyContentRepository();

  /// Widget dinleyicilerini ve deep-link yönlendirmesini başlatır
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);

      // Dinle: Uygulama açık/arkaplandayken widget tıklandığında gelen Uri
      HomeWidget.widgetClicked.listen((Uri? uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      });
    } catch (e) {
      debugPrint('HomeWidgetService.initialize hatası: $e');
    }
  }

  /// Uygulama kapalıyken (cold start) widget tıklandıysa kontrol eder
  static Future<void> checkInitialLaunch() async {
    try {
      final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('HomeWidgetService.checkInitialLaunch hatası: $e');
    }
  }

  static void _handleUri(Uri uri) {
    debugPrint('HomeWidget click URI: $uri');
    final uriStr = uri.toString().toLowerCase();
    String target = '/vakitler';
    if (uriStr.contains('ayet')) {
      target = '/ayet';
    } else if (uriStr.contains('hadis')) {
      target = '/hadis';
    } else if (uriStr.contains('kible')) {
      target = '/kible';
    } else if (uriStr.contains('ayarlar')) {
      target = '/ayarlar';
    } else {
      target = '/vakitler';
    }
    try {
      appRouter.go(target);
    } catch (e) {
      debugPrint('appRouter.go hatası: $e');
    }
  }

  /// 7 günlük vakitleri ve günün âyet/hadis verisini kaydeder ve tüm widget'ları günceller
  static Future<void> syncAllWidgets({
    required CityModel city,
    VerseModel? verse,
    HadithModel? hadith,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final days = PrayerCalculator.calculateRange(
        city: city,
        startDate: today,
        days: 7,
      );

      final df = DateFormat('d MMMM EEEE', 'tr_TR');
      final tf = DateFormat('HH:mm');

      final daysPayload = days.map((day) {
        return {
          'dateStr': df.format(day.date),
          'times': {
            'imsak': {
              'epochMs': day.imsak.millisecondsSinceEpoch,
              'timeStr': tf.format(day.imsak),
            },
            'gunes': {
              'epochMs': day.gunes.millisecondsSinceEpoch,
              'timeStr': tf.format(day.gunes),
            },
            'ogle': {
              'epochMs': day.ogle.millisecondsSinceEpoch,
              'timeStr': tf.format(day.ogle),
            },
            'ikindi': {
              'epochMs': day.ikindi.millisecondsSinceEpoch,
              'timeStr': tf.format(day.ikindi),
            },
            'aksam': {
              'epochMs': day.aksam.millisecondsSinceEpoch,
              'timeStr': tf.format(day.aksam),
            },
            'yatsi': {
              'epochMs': day.yatsi.millisecondsSinceEpoch,
              'timeStr': tf.format(day.yatsi),
            },
          },
          'kerahat': {
            'morning_end': day.sunriseKerahatEnd.millisecondsSinceEpoch,
            'midday_start': day.middayKerahatStart.millisecondsSinceEpoch,
            'midday_end': day.ogle.millisecondsSinceEpoch,
            'evening_start': day.sunsetKerahatStart.millisecondsSinceEpoch,
            'evening_end': day.aksam.millisecondsSinceEpoch,
          },
        };
      }).toList();

      final jsonStr = jsonEncode(daysPayload);
      await HomeWidget.saveWidgetData<String>('city_name', city.displayName);
      await HomeWidget.saveWidgetData<String>('days_prayer_json', jsonStr);

      // SharedPreferences yedek depolaması (doğrudan FlutterSharedPreferences fallback için)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('days_prayer_json', jsonStr);
        await prefs.setString('city_name', city.displayName);
      } catch (_) {}

      // Âyet ve hadis sağlanmadıysa bugünün içeriğini getir
      var activeVerse = verse;
      var activeHadith = hadith;
      if (activeVerse == null) {
        try {
          activeVerse = await _contentRepo.getDailyVerse(today);
        } catch (_) {}
      }
      if (activeHadith == null) {
        try {
          activeHadith = await _contentRepo.getDailyHadith(today);
        } catch (_) {}
      }

      if (activeVerse != null) {
        await HomeWidget.saveWidgetData<String>('today_verse_short', activeVerse.shortText);
        await HomeWidget.saveWidgetData<String>(
          'today_verse_source',
          '${activeVerse.sourceName}, ${activeVerse.ayahNo}',
        );
      }

      if (activeHadith != null) {
        await HomeWidget.saveWidgetData<String>('today_hadith_short', activeHadith.shortText);
        await HomeWidget.saveWidgetData<String>('today_hadith_source', activeHadith.fullSource);
        await HomeWidget.saveWidgetData<String>('today_hadith_narrator', activeHadith.narrator);
      }

      // Android Widget'ları tetikle
      await HomeWidget.updateWidget(androidName: smallWidgetProvider);
      await HomeWidget.updateWidget(androidName: mediumWidgetProvider);
      await HomeWidget.updateWidget(androidName: stripWidgetProvider);
      await HomeWidget.updateWidget(androidName: verseWidgetProvider);
      await HomeWidget.updateWidget(androidName: hadithWidgetProvider);
    } catch (e) {
      debugPrint('HomeWidgetService.syncAllWidgets hatası: $e');
    }
  }

  /// Yalnızca günün âyet ve hadis widget'larını günceller
  static Future<void> updateDailyContent({
    required VerseModel verse,
    required HadithModel hadith,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('today_verse_short', verse.shortText);
      await HomeWidget.saveWidgetData<String>(
        'today_verse_source',
        '${verse.sourceName}, ${verse.ayahNo}',
      );
      await HomeWidget.saveWidgetData<String>('today_hadith_short', hadith.shortText);
      await HomeWidget.saveWidgetData<String>('today_hadith_source', hadith.fullSource);
      await HomeWidget.saveWidgetData<String>('today_hadith_narrator', hadith.narrator);

      await HomeWidget.updateWidget(androidName: verseWidgetProvider);
      await HomeWidget.updateWidget(androidName: hadithWidgetProvider);
    } catch (e) {
      debugPrint('HomeWidgetService.updateDailyContent hatası: $e');
    }
  }
}

