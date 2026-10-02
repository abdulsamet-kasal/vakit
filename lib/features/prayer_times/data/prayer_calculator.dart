import 'package:adhan/adhan.dart';
import '../../../../core/config/kerahat_config.dart';
import '../domain/city_model.dart';
import '../domain/prayer_times_model.dart';

/// Cihaz üstünde, internetsiz (offline) Diyanet uyumlu namaz vakti hesaplayıcısı.
class PrayerCalculator {
  /// Tek bir gün için namaz vakitlerini ve kerahat aralıklarını hesaplar
  static PrayerTimesModel calculate({
    required CityModel city,
    required DateTime date,
    CalculationMethod method = CalculationMethod.turkey,
    Madhab madhab = Madhab.shafi,
    KerahatConfig kerahatConfig = KerahatConfig.defaults,
  }) {
    final coordinates = Coordinates(city.latitude, city.longitude);
    final dateComponents = DateComponents(date.year, date.month, date.day);
    final params = method.getParameters();
    params.madhab = madhab;

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    return PrayerTimesModel(
      date: DateTime(date.year, date.month, date.day),
      cityName: city.displayName,
      imsak: prayerTimes.fajr,
      gunes: prayerTimes.sunrise,
      ogle: prayerTimes.dhuhr,
      ikindi: prayerTimes.asr,
      aksam: prayerTimes.maghrib,
      yatsi: prayerTimes.isha,
      kerahatConfig: kerahatConfig,
    );
  }

  /// Önümüzdeki N gün (örn: widget senkronizasyonu için 7 gün) hesaplar
  static List<PrayerTimesModel> calculateRange({
    required CityModel city,
    required DateTime startDate,
    int days = 7,
    CalculationMethod method = CalculationMethod.turkey,
    Madhab madhab = Madhab.shafi,
    KerahatConfig kerahatConfig = KerahatConfig.defaults,
  }) {
    final list = <PrayerTimesModel>[];
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      list.add(calculate(
        city: city,
        date: date,
        method: method,
        madhab: madhab,
        kerahatConfig: kerahatConfig,
      ));
    }
    return list;
  }
}
