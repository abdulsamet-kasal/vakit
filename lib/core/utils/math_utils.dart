import 'dart:math' as math;

/// Kıble açısı, Kâbe mesafesi ve sensör yumuşatma (low-pass filter) matematik fonksiyonları.
abstract final class MathUtils {
  /// Kâbe koordinatları (Mekke)
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Dünya ortalama yarıçapı (km)
  static const double earthRadiusKm = 6371.0;

  static double _toRadians(double degree) => degree * (math.pi / 180.0);
  static double _toDegrees(double radian) => radian * (180.0 / math.pi);

  /// Büyük Daire (Great-Circle / Forward Azimuth) Kıble yön açısını hesaplar (Kuzeyden saat yönünde derece)
  static double calculateQiblaBearing(double latitude, double longitude) {
    final phi1 = _toRadians(latitude);
    final phi2 = _toRadians(kaabaLatitude);
    final deltaLambda = _toRadians(kaabaLongitude - longitude);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final initialBearing = math.atan2(y, x);
    final degrees = _toDegrees(initialBearing);

    return (degrees + 360.0) % 360.0;
  }

  /// Haversine formülü ile Kâbe'ye olan kuş uçuşu mesafeyi hesaplar (km)
  static double calculateKaabaDistanceKm(double latitude, double longitude) {
    final phi1 = _toRadians(latitude);
    final phi2 = _toRadians(kaabaLatitude);
    final deltaPhi = _toRadians(kaabaLatitude - latitude);
    final deltaLambda = _toRadians(kaabaLongitude - longitude);

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) * math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Sensör titremesini azaltmak için dairesel Düşük Geçiren Filtre (Circular Low-Pass Filter).
  /// 0° ile 360° arasındaki dairesel geçişlerde ani zıplamaları önler.
  static double filterHeading(double previous, double current, {double alpha = 0.22}) {
    final diff = ((current - previous + 540) % 360) - 180;
    final smoothed = previous + (alpha * diff);
    return (smoothed + 360) % 360;
  }

  /// Cihaz pusula yönünün Kıble ile hizalanıp hizalanmadığını test eder
  static bool isQiblaAligned(
    double heading,
    double qiblaBearing, {
    double toleranceDegrees = 3.5,
  }) {
    final diff = ((heading - qiblaBearing + 540) % 360) - 180;
    return diff.abs() <= toleranceDegrees;
  }
}
