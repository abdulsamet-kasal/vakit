/// Türkiye'deki illerin koordinat ve isim modeli.
/// İnternet ve GPS olmasa dahi kullanıcının 81 ili seçebilmesini sağlar (Offline-first).
class CityModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? district;

  const CityModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.district,
  });

  String get displayName => (district != null && district!.isNotEmpty && district != 'Merkez')
      ? '$name, $district'
      : name;

  CityModel copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? district,
  }) {
    return CityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      district: district ?? this.district,
    );
  }

  static CityModel? findByName(String name) {
    for (final city in turkishCities) {
      if (city.name.toLowerCase() == name.toLowerCase()) {
        return city;
      }
    }
    return null;
  }

  static const CityModel defaultCity = CityModel(
    id: 34,
    name: 'İstanbul',
    latitude: 41.0082,
    longitude: 28.9784,
  );

  static const List<CityModel> turkishCities = [
    CityModel(id: 1, name: 'Adana', latitude: 37.0000, longitude: 35.3213),
    CityModel(id: 2, name: 'Adıyaman', latitude: 37.7648, longitude: 38.2786),
    CityModel(id: 3, name: 'Afyonkarahisar', latitude: 38.7507, longitude: 30.5567),
    CityModel(id: 4, name: 'Ağrı', latitude: 39.7191, longitude: 43.0503),
    CityModel(id: 5, name: 'Amasya', latitude: 40.6534, longitude: 35.8331),
    CityModel(id: 6, name: 'Ankara', latitude: 39.9334, longitude: 32.8597),
    CityModel(id: 7, name: 'Antalya', latitude: 36.8969, longitude: 30.7133),
    CityModel(id: 8, name: 'Artvin', latitude: 41.1828, longitude: 41.8183),
    CityModel(id: 9, name: 'Aydın', latitude: 37.8560, longitude: 27.8416),
    CityModel(id: 10, name: 'Balıkesir', latitude: 39.6484, longitude: 27.8826),
    CityModel(id: 11, name: 'Bilecik', latitude: 40.1451, longitude: 29.9799),
    CityModel(id: 12, name: 'Bingöl', latitude: 38.8847, longitude: 40.4939),
    CityModel(id: 13, name: 'Bitlis', latitude: 38.4006, longitude: 42.1095),
    CityModel(id: 14, name: 'Bolu', latitude: 40.7358, longitude: 31.6061),
    CityModel(id: 15, name: 'Burdur', latitude: 37.7203, longitude: 30.2908),
    CityModel(id: 16, name: 'Bursa', latitude: 40.1885, longitude: 29.0610),
    CityModel(id: 17, name: 'Çanakkale', latitude: 40.1553, longitude: 26.4142),
    CityModel(id: 18, name: 'Çankırı', latitude: 40.6013, longitude: 33.6134),
    CityModel(id: 19, name: 'Çorum', latitude: 40.5506, longitude: 34.9556),
    CityModel(id: 20, name: 'Denizli', latitude: 37.7765, longitude: 29.0864),
    CityModel(id: 21, name: 'Diyarbakır', latitude: 37.9144, longitude: 40.2306),
    CityModel(id: 22, name: 'Edirne', latitude: 41.6772, longitude: 26.5557),
    CityModel(id: 23, name: 'Elazığ', latitude: 38.6810, longitude: 39.2264),
    CityModel(id: 24, name: 'Erzincan', latitude: 39.7500, longitude: 39.5000),
    CityModel(id: 25, name: 'Erzurum', latitude: 39.9043, longitude: 41.2678),
    CityModel(id: 26, name: 'Eskişehir', latitude: 39.7767, longitude: 30.5206),
    CityModel(id: 27, name: 'Gaziantep', latitude: 37.0662, longitude: 37.3833),
    CityModel(id: 28, name: 'Giresun', latitude: 40.9128, longitude: 38.3895),
    CityModel(id: 29, name: 'Gümüşhane', latitude: 40.4600, longitude: 39.4814),
    CityModel(id: 30, name: 'Hakkâri', latitude: 37.5833, longitude: 43.7333),
    CityModel(id: 31, name: 'Hatay', latitude: 36.4018, longitude: 36.3498),
    CityModel(id: 32, name: 'Isparta', latitude: 37.7648, longitude: 30.5566),
    CityModel(id: 33, name: 'Mersin', latitude: 36.8121, longitude: 34.6415),
    CityModel(id: 34, name: 'İstanbul', latitude: 41.0082, longitude: 28.9784),
    CityModel(id: 35, name: 'İzmir', latitude: 38.4237, longitude: 27.1428),
    CityModel(id: 36, name: 'Kars', latitude: 40.6167, longitude: 43.1000),
    CityModel(id: 37, name: 'Kastamonu', latitude: 41.3887, longitude: 33.7827),
    CityModel(id: 38, name: 'Kayseri', latitude: 38.7312, longitude: 35.4787),
    CityModel(id: 39, name: 'Kırklareli', latitude: 41.7333, longitude: 27.2167),
    CityModel(id: 40, name: 'Kırşehir', latitude: 39.1425, longitude: 34.1709),
    CityModel(id: 41, name: 'Kocaeli', latitude: 40.8533, longitude: 29.8815),
    CityModel(id: 42, name: 'Konya', latitude: 37.8667, longitude: 32.4833),
    CityModel(id: 43, name: 'Kütahya', latitude: 39.4167, longitude: 29.9833),
    CityModel(id: 44, name: 'Malatya', latitude: 38.3552, longitude: 38.3095),
    CityModel(id: 45, name: 'Manisa', latitude: 38.6191, longitude: 27.4289),
    CityModel(id: 46, name: 'Kahramanmaraş', latitude: 37.5858, longitude: 36.9371),
    CityModel(id: 47, name: 'Mardin', latitude: 37.3212, longitude: 40.7245),
    CityModel(id: 48, name: 'Muğla', latitude: 37.2153, longitude: 28.3636),
    CityModel(id: 49, name: 'Muş', latitude: 38.7432, longitude: 41.5064),
    CityModel(id: 50, name: 'Nevşehir', latitude: 38.6244, longitude: 34.7144),
    CityModel(id: 51, name: 'Niğde', latitude: 37.9667, longitude: 34.6833),
    CityModel(id: 52, name: 'Ordu', latitude: 40.9839, longitude: 37.8764),
    CityModel(id: 53, name: 'Rize', latitude: 41.0201, longitude: 40.5234),
    CityModel(id: 54, name: 'Sakarya', latitude: 40.7569, longitude: 30.3783),
    CityModel(id: 55, name: 'Samsun', latitude: 41.2928, longitude: 36.3313),
    CityModel(id: 56, name: 'Siirt', latitude: 37.9333, longitude: 41.9500),
    CityModel(id: 57, name: 'Sinop', latitude: 42.0231, longitude: 35.1531),
    CityModel(id: 58, name: 'Sivas', latitude: 39.7477, longitude: 37.0179),
    CityModel(id: 59, name: 'Tekirdağ', latitude: 40.9833, longitude: 27.5167),
    CityModel(id: 60, name: 'Tokat', latitude: 40.3167, longitude: 36.5500),
    CityModel(id: 61, name: 'Trabzon', latitude: 41.0015, longitude: 39.7178),
    CityModel(id: 62, name: 'Tunceli', latitude: 39.1079, longitude: 39.5401),
    CityModel(id: 63, name: 'Şanlıurfa', latitude: 37.1591, longitude: 38.7969),
    CityModel(id: 64, name: 'Uşak', latitude: 38.6823, longitude: 29.4082),
    CityModel(id: 65, name: 'Van', latitude: 38.4891, longitude: 43.4089),
    CityModel(id: 66, name: 'Yozgat', latitude: 39.8181, longitude: 34.8147),
    CityModel(id: 67, name: 'Zonguldak', latitude: 41.4564, longitude: 31.7987),
    CityModel(id: 68, name: 'Aksaray', latitude: 38.3687, longitude: 34.0370),
    CityModel(id: 69, name: 'Bayburt', latitude: 40.2552, longitude: 40.2249),
    CityModel(id: 70, name: 'Karaman', latitude: 37.1759, longitude: 33.2287),
    CityModel(id: 71, name: 'Kırıkkale', latitude: 39.8468, longitude: 33.5153),
    CityModel(id: 72, name: 'Batman', latitude: 37.8812, longitude: 41.1351),
    CityModel(id: 73, name: 'Şırnak', latitude: 37.5164, longitude: 42.4611),
    CityModel(id: 74, name: 'Bartın', latitude: 41.6344, longitude: 32.3375),
    CityModel(id: 75, name: 'Ardahan', latitude: 41.1105, longitude: 42.7022),
    CityModel(id: 76, name: 'Iğdır', latitude: 39.9196, longitude: 44.0454),
    CityModel(id: 77, name: 'Yalova', latitude: 40.6500, longitude: 29.2667),
    CityModel(id: 78, name: 'Karabük', latitude: 41.2061, longitude: 32.6204),
    CityModel(id: 79, name: 'Kilis', latitude: 36.7184, longitude: 37.1212),
    CityModel(id: 80, name: 'Osmaniye', latitude: 37.0742, longitude: 36.2472),
    CityModel(id: 81, name: 'Düzce', latitude: 40.8438, longitude: 31.1565),
  ];
}
