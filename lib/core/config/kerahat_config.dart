/// Kerahat vakitleri için ayarlanabilir yapılandırma sabitleri.
/// Fıkhi kaynaklarda güneşin doğuşu, zeval (tepe) ve batışı esnasında mekruh olan vakitler.
class KerahatConfig {
  /// Güneş doğduktan sonraki kerahat süresi (Varsayılan: 45 dakika)
  final int sunriseDurationMinutes;

  /// Öğle ezanından önceki kerahat süresi (İstiva / Güneş tepedeyken, Varsayılan: 40 dakika)
  final int middayBeforeMinutes;

  /// Akşam ezanından önceki kerahat süresi (Güneş batarken, Varsayılan: 45 dakika)
  final int sunsetBeforeMinutes;

  const KerahatConfig({
    this.sunriseDurationMinutes = 45,
    this.middayBeforeMinutes = 40,
    this.sunsetBeforeMinutes = 45,
  });

  static const KerahatConfig defaults = KerahatConfig();

  KerahatConfig copyWith({
    int? sunriseDurationMinutes,
    int? middayBeforeMinutes,
    int? sunsetBeforeMinutes,
  }) {
    return KerahatConfig(
      sunriseDurationMinutes: sunriseDurationMinutes ?? this.sunriseDurationMinutes,
      middayBeforeMinutes: middayBeforeMinutes ?? this.middayBeforeMinutes,
      sunsetBeforeMinutes: sunsetBeforeMinutes ?? this.sunsetBeforeMinutes,
    );
  }
}
