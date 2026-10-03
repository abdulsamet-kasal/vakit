import 'package:flutter_test/flutter_test.dart';
import 'package:vakit/features/prayer_times/data/prayer_calculator.dart';
import 'package:vakit/features/prayer_times/domain/city_model.dart';

/// Diyanet hesaplama yöntemiyle Türkiye'nin farklı enlem-boylamlarındaki illerde
/// bağımsız referans (AlAdhan API, method=13 — Diyanet İşleri Başkanlığı) ile
/// karşılaştırma testi. Referans veriler 02.10.2026 tarihi için alınmıştır.
///
/// Not: AlAdhan method=13, Diyanet İşleri Başkanlığı resmi hesaplama yöntemini
/// uygular; resmi takvimin gösterdiği değerlerle aynıdır. Tolerans ±2 dakikadır.
void main() {
  group('Diyanet yöntemi uyumu — farklı enlem ve boylamlar (02.10.2026)', () {
    // AlAdhan API (method=13) referansları — 02.10.2026
    const refs = <String, Map<String, String>>{
      'İstanbul':  {'imsak': '05:30', 'gunes': '06:54', 'ogle': '12:58', 'ikindi': '16:16', 'aksam': '18:52', 'yatsi': '20:11'},
      'Ankara':    {'imsak': '05:16', 'gunes': '06:39', 'ogle': '12:43', 'ikindi': '16:01', 'aksam': '18:37', 'yatsi': '19:54'},
      'Erzurum':   {'imsak': '04:42', 'gunes': '06:05', 'ogle': '12:09', 'ikindi': '15:28', 'aksam': '18:03', 'yatsi': '19:21'},
      'İzmir':     {'imsak': '05:40', 'gunes': '07:01', 'ogle': '13:06', 'ikindi': '16:25', 'aksam': '19:00', 'yatsi': '20:16'},
      'Diyarbakır': {'imsak': '04:48', 'gunes': '06:08', 'ogle': '12:14', 'ikindi': '15:33', 'aksam': '18:08', 'yatsi': '19:23'},
      'Hakkâri':   {'imsak': '04:34', 'gunes': '05:54', 'ogle': '11:59', 'ikindi': '15:19', 'aksam': '17:54', 'yatsi': '19:09'},
      'Edirne':    {'imsak': '05:39', 'gunes': '07:04', 'ogle': '13:08', 'ikindi': '16:25', 'aksam': '19:01', 'yatsi': '20:21'},
    };

    for (final entry in refs.entries) {
      test('${entry.key} vakitleri referansla ±2 dk uyumlu olmalı', () {
        final city = CityModel.turkishCities.firstWhere((c) => c.name == entry.key);
        final t = PrayerCalculator.calculate(
          city: city,
          date: DateTime(2026, 10, 2),
        );
        final r = entry.value;
        _check(t.imsak, r['imsak']!, '${entry.key} İmsak');
        _check(t.gunes, r['gunes']!, '${entry.key} Güneş');
        _check(t.ogle, r['ogle']!, '${entry.key} Öğle');
        _check(t.ikindi, r['ikindi']!, '${entry.key} İkindi (Şâfiî)');
        _check(t.aksam, r['aksam']!, '${entry.key} Akşam');
        _check(t.yatsi, r['yatsi']!, '${entry.key} Yatsı');
      });
    }

    test('Doğu-batı vakit farkı makul aralıkta (DST/tuz hatalarına karşı)', () {
      final ist = CityModel.turkishCities.firstWhere((c) => c.name == 'İstanbul');
      final hak = CityModel.turkishCities.firstWhere((c) => c.name == 'Hakkâri');
      final istAk = PrayerCalculator.calculate(city: ist, date: DateTime(2026, 10, 2)).aksam;
      final hakAk = PrayerCalculator.calculate(city: hak, date: DateTime(2026, 10, 2)).aksam;
      final diff = istAk.difference(hakAk).inMinutes;
      expect(diff, inInclusiveRange(55, 63),
          reason: 'İstanbul-Hakkâri akşam farkı ~58 dk olmalı (boylam farkı ~15.2°)');
    });
  });
}

void _check(DateTime actual, String expected, String label) {
  final p = expected.split(':');
  final exp = DateTime(2026, 10, 2, int.parse(p[0]), int.parse(p[1]));
  final diff = actual.difference(exp).inMinutes.abs();
  expect(diff, lessThanOrEqualTo(2),
      reason: '$label: hesaplanan '
          '${actual.hour.toString().padLeft(2, '0')}:${actual.minute.toString().padLeft(2, '0')}, '
          'referans: $expected (fark $diff dk)');
}
