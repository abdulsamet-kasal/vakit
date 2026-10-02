import 'package:flutter_test/flutter_test.dart';
import 'package:vakit/features/prayer_times/domain/city_model.dart';
import 'package:vakit/features/prayer_times/domain/district_data.dart';

void main() {
  group('DistrictData & İlçe Seçimi Testleri', () {
    test('81 ilin tamamı tanımlı olmalı', () {
      expect(DistrictData.districtsByCity.length, 81);
      expect(CityModel.turkishCities.length, 81);
    });

    test('Toplam ilçe sayısı 972 olmalı', () {
      final totalDistricts = DistrictData.districtsByCity.values
          .fold<int>(0, (sum, list) => sum + list.length);
      expect(totalDistricts, 972);
    });

    test('İstanbul 39 ilçe içermeli ve Kadıköy listede bulunmalı', () {
      final istanbulDistricts = DistrictData.getDistricts('İstanbul');
      expect(istanbulDistricts.length, 39);
      expect(istanbulDistricts.contains('Kadıköy'), isTrue);
      expect(istanbulDistricts.contains('Üsküdar'), isTrue);
    });

    test('Arama fonksiyonu ilçe adıyla ili bulmalı', () {
      final resultsKadikoy = DistrictData.search('Kadıköy');
      expect(resultsKadikoy.isNotEmpty, isTrue);
      expect(resultsKadikoy.any((r) => r.cityName == 'İstanbul' && r.districtName == 'Kadıköy'), isTrue);

      final resultsAlanya = DistrictData.search('Alanya');
      expect(resultsAlanya.isNotEmpty, isTrue);
      expect(resultsAlanya.any((r) => r.cityName == 'Antalya' && r.districtName == 'Alanya'), isTrue);

      final resultsCankaya = DistrictData.search('Çankaya');
      expect(resultsCankaya.isNotEmpty, isTrue);
      expect(resultsCankaya.any((r) => r.cityName == 'Ankara' && r.districtName == 'Çankaya'), isTrue);
    });

    test('Arama Türkçe karakter duyarsız çalışmalı', () {
      final res1 = DistrictData.search('kadikoy');
      expect(res1.any((r) => r.districtName == 'Kadıköy'), isTrue);

      final res2 = DistrictData.search('cankaya');
      expect(res2.any((r) => r.districtName == 'Çankaya'), isTrue);

      final res3 = DistrictData.search('eskişehir');
      expect(res3.any((r) => r.cityName == 'Eskişehir'), isTrue);
    });

    test('CityModel displayName ilçe ile doğru biçimlenmeli', () {
      const cityWithoutDistrict = CityModel(
        id: 34,
        name: 'İstanbul',
        latitude: 41.0082,
        longitude: 28.9784,
      );
      expect(cityWithoutDistrict.displayName, 'İstanbul');

      final cityWithDistrict = cityWithoutDistrict.copyWith(district: 'Kadıköy');
      expect(cityWithDistrict.displayName, 'İstanbul, Kadıköy');

      final cityWithMerkez = cityWithoutDistrict.copyWith(district: 'Merkez');
      expect(cityWithMerkez.displayName, 'İstanbul');
    });

    test('CityModel findByName doğru şehri getirmeli', () {
      final ankara = CityModel.findByName('Ankara');
      expect(ankara, isNotNull);
      expect(ankara!.id, 6);
      expect(ankara.name, 'Ankara');

      final unknown = CityModel.findByName('BilinmeyenŞehir');
      expect(unknown, isNull);
    });
  });
}
