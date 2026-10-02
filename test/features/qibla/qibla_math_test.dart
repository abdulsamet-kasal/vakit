import 'package:flutter_test/flutter_test.dart';
import 'package:vakit/core/utils/math_utils.dart';
import 'package:vakit/features/prayer_times/domain/city_model.dart';

void main() {
  group('Kıble & Küresel Matematik Testleri', () {
    test('İstanbul için Kıble açısı ve mesafesi doğrulanmalı', () {
      final istanbul = CityModel.defaultCity;
      final bearing = MathUtils.calculateQiblaBearing(
        istanbul.latitude,
        istanbul.longitude,
      );
      final distance = MathUtils.calculateKaabaDistanceKm(
        istanbul.latitude,
        istanbul.longitude,
      );

      // İstanbul için Kıble yön açısı yaklaşık 151.7°
      expect(bearing, inInclusiveRange(150.0, 153.0));

      // İstanbul - Mekke arası kuş uçuşu mesafe yaklaşık 2415 km
      expect(distance, inInclusiveRange(2380.0, 2450.0));
    });

    test('Ankara için Kıble açısı ve mesafesi doğrulanmalı', () {
      final ankara = CityModel.turkishCities.firstWhere((c) => c.name == 'Ankara');
      final bearing = MathUtils.calculateQiblaBearing(
        ankara.latitude,
        ankara.longitude,
      );
      final distance = MathUtils.calculateKaabaDistanceKm(
        ankara.latitude,
        ankara.longitude,
      );

      // Ankara için Kıble yön açısı yaklaşık 160.2°
      expect(bearing, inInclusiveRange(159.0, 161.5));

      // Ankara - Mekke arası mesafe yaklaşık 2162 km
      expect(distance, inInclusiveRange(2140.0, 2180.0));
    });

    test('Dairesel Düşük Geçiren Filtre (Low-Pass) 0°/360° sınırında yumuşak geçmeli', () {
      // 358° den 2° ye geçiş (saat yönünde 4° lik küçük bir hareket)
      const prev = 358.0;
      const current = 2.0;

      final filtered = MathUtils.filterHeading(prev, current, alpha: 0.25);

      // Filtrelenmiş açı 359° civarında olmalı, asla 180° ters yöne sıçramamalı!
      expect(filtered, inInclusiveRange(358.5, 359.5));
    });

    test('Kıble hizalanma toleransı doğru çalışmalı', () {
      const qiblaAngle = 151.5;

      // ±3.5° tolerans içinde
      expect(MathUtils.isQiblaAligned(151.5, qiblaAngle), isTrue);
      expect(MathUtils.isQiblaAligned(153.0, qiblaAngle), isTrue);
      expect(MathUtils.isQiblaAligned(149.0, qiblaAngle), isTrue);

      // Tolerans dışında
      expect(MathUtils.isQiblaAligned(160.0, qiblaAngle), isFalse);
      expect(MathUtils.isQiblaAligned(140.0, qiblaAngle), isFalse);
    });
  });
}
