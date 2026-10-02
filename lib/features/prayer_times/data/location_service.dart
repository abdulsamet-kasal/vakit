import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../domain/city_model.dart';

/// Konum tespit servisi (geolocator + geocoding).
/// İzin verilmezse, GPS kapalıysa veya internet yoksa asla çökmez;
/// güvenle null döner ve manuel şehir seçimine yönlendirir.
abstract final class LocationService {
  /// Cihazın anlık GPS konumunu alır ve en yakın şehir modeline dönüştürür.
  static Future<CityModel?> getCurrentCity() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Konum servisi devre dışı.');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Konum izni kullanıcı tarafından reddedildi.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Konum izni kalıcı olarak reddedildi.');
        return null;
      }

      // Hızlı ve düşük pil tüketimi için orta doğrulukta konum al
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Ters geocoding ile il/ilçe adını bulmayı dene
      String cityName = 'Konum';
      String? district;

      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          cityName = place.administrativeArea ?? place.locality ?? 'Konum';
          district = place.subAdministrativeArea ?? place.subLocality;

          // 81 il listemizdeki Türkçe karakter eşleşmesini kontrol et
          for (final city in CityModel.turkishCities) {
            if (_normalizeString(city.name) == _normalizeString(cityName)) {
              return CityModel(
                id: city.id,
                name: city.name,
                latitude: position.latitude,
                longitude: position.longitude,
                district: district,
              );
            }
          }
        }
      } catch (geoError) {
        debugPrint('Ters geocoding başarısız oldu (internet olmayabilir): $geoError');
      }

      // En yakın ili koordinat mesafesine göre bul
      CityModel nearestCity = CityModel.defaultCity;
      double minDistance = double.infinity;

      for (final city in CityModel.turkishCities) {
        final dist = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          city.latitude,
          city.longitude,
        );
        if (dist < minDistance) {
          minDistance = dist;
          nearestCity = city;
        }
      }

      return CityModel(
        id: nearestCity.id,
        name: cityName != 'Konum' ? cityName : nearestCity.name,
        latitude: position.latitude,
        longitude: position.longitude,
        district: district,
      );
    } catch (e) {
      debugPrint('Konum alınırken genel hata: $e');
      return null;
    }
  }

  static String _normalizeString(String str) {
    return str
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .trim();
  }
}
