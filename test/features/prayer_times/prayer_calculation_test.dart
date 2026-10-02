import 'package:flutter_test/flutter_test.dart';
import 'package:vakit/core/config/kerahat_config.dart';
import 'package:vakit/features/prayer_times/data/prayer_calculator.dart';
import 'package:vakit/features/prayer_times/domain/city_model.dart';
import 'package:vakit/features/prayer_times/presentation/widgets/kerahat_badge.dart';

void main() {
  group('Namaz Vakti & Diyanet Hesaplama Doğrulama Testleri', () {
    final istanbul = CityModel.defaultCity;
    final ankara = CityModel.turkishCities.firstWhere((c) => c.name == 'Ankara');
    final testDate = DateTime(2026, 10, 2);

    test('İstanbul için vakitler kronolojik sırada olmalı', () {
      final times = PrayerCalculator.calculate(city: istanbul, date: testDate);

      expect(times.imsak.isBefore(times.gunes), isTrue);
      expect(times.gunes.isBefore(times.ogle), isTrue);
      expect(times.ogle.isBefore(times.ikindi), isTrue);
      expect(times.ikindi.isBefore(times.aksam), isTrue);
      expect(times.aksam.isBefore(times.yatsi), isTrue);
    });

    test('İstanbul ve Ankara vakitleri Diyanet takvimiyle ±2 dk uyumlu olmalı', () {
      final istTimes = PrayerCalculator.calculate(city: istanbul, date: testDate);
      final ankTimes = PrayerCalculator.calculate(city: ankara, date: testDate);

      // İstanbul Referans Değerleri (2 Ekim 2026 Diyanet parametreleri)
      // İmsak: 05:30, Güneş: 06:55, Öğle: 12:58, İkindi: 16:14, Akşam: 18:52, Yatsı: 20:11
      _assertWithinTolerance(istTimes.imsak, 5, 30, 2);
      _assertWithinTolerance(istTimes.gunes, 6, 55, 2);
      _assertWithinTolerance(istTimes.ogle, 12, 58, 2);
      _assertWithinTolerance(istTimes.ikindi, 16, 14, 2);
      _assertWithinTolerance(istTimes.aksam, 18, 52, 2);
      _assertWithinTolerance(istTimes.yatsi, 20, 11, 2);

      // Ankara doğuda olduğu için vakitler yaklaşık 15-16 dk daha erkendir
      final istMinutes = istTimes.ogle.hour * 60 + istTimes.ogle.minute;
      final ankMinutes = ankTimes.ogle.hour * 60 + ankTimes.ogle.minute;
      final diffMinutes = istMinutes - ankMinutes;
      expect(diffMinutes, inInclusiveRange(14, 18),
          reason: 'Ankara vakitleri İstanbul\'dan yaklaşık 15-16 dakika önce olmalıdır');
    });

    test('Kerahat vakitleri (Doğuş ~45dk, İstiva ~40dk, Batış ~45dk) doğru hesaplanmalı', () {
      const config = KerahatConfig(
        sunriseDurationMinutes: 45,
        middayBeforeMinutes: 40,
        sunsetBeforeMinutes: 45,
      );

      final times = PrayerCalculator.calculate(
        city: istanbul,
        date: testDate,
        kerahatConfig: config,
      );

      // Doğuş kerahati bitişi
      expect(times.sunriseKerahatEnd, times.gunes.add(const Duration(minutes: 45)));

      // İstiva kerahati başlangıcı
      expect(times.middayKerahatStart, times.ogle.subtract(const Duration(minutes: 40)));

      // Batış kerahati başlangıcı
      expect(times.sunsetKerahatStart, times.aksam.subtract(const Duration(minutes: 45)));

      // Kerahat durum tespitleri
      expect(
        times.getActiveKerahat(times.gunes.add(const Duration(minutes: 15))),
        KerahatType.sunrise,
      );
      expect(
        times.getActiveKerahat(times.ogle.subtract(const Duration(minutes: 20))),
        KerahatType.midday,
      );
      expect(
        times.getActiveKerahat(times.aksam.subtract(const Duration(minutes: 10))),
        KerahatType.sunset,
      );
      expect(
        times.getActiveKerahat(times.ogle.add(const Duration(minutes: 20))),
        KerahatType.none,
      );
    });

    test('Önümüzdeki 7 günün vakitleri ardışık hesaplanmalı', () {
      final range = PrayerCalculator.calculateRange(
        city: istanbul,
        startDate: testDate,
        days: 7,
      );

      expect(range.length, 7);
      for (int i = 0; i < 6; i++) {
        expect(range[i + 1].date.difference(range[i].date).inDays, 1);
      }
    });
  });
}

void _assertWithinTolerance(DateTime time, int refHour, int refMinute, int toleranceMinutes) {
  final actualMinutes = time.hour * 60 + time.minute;
  final refMinutes = refHour * 60 + refMinute;
  final diff = (actualMinutes - refMinutes).abs();
  expect(
    diff <= toleranceMinutes,
    isTrue,
    reason: 'Vakit ${time.hour}:${time.minute.toString().padLeft(2, '0')}, referans $refHour:${refMinute.toString().padLeft(2, '0')} değerine ±$toleranceMinutes dk içinde olmalıdır (Fark: $diff dk)',
  );
}
