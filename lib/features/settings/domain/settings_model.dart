import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import '../../../core/config/kerahat_config.dart';

/// Kullanıcı yerel ayarları veri modeli.
/// Giriş (auth) olmadığı için tamamen cihazda (shared_preferences) tutulur.
class AppSettingsModel {
  final CalculationMethod calculationMethod;
  final Madhab madhab;
  final KerahatConfig kerahatConfig;
  final ThemeMode themeMode;

  // --- Ezan bildirimi ayarları ---
  /// Vakit girdiğinde ezan bildirimi gösterilsin mi?
  final bool adhanNotificationEnabled;

  /// Vakit öncesi hatırlatma gösterilsin mi?
  final bool preAlertEnabled;

  /// Vakit öncesi hatırlatma süresi (dakika).
  final int preAlertMinutes;

  /// Bildirim sessiz mi (titreşim) yoksa cihaz sesiyle mi gelsin?
  final bool adhanSilentMode;

  const AppSettingsModel({
    this.calculationMethod = CalculationMethod.turkey,
    this.madhab = Madhab.shafi,
    this.kerahatConfig = KerahatConfig.defaults,
    this.themeMode = ThemeMode.system,
    this.adhanNotificationEnabled = true,
    this.preAlertEnabled = false,
    this.preAlertMinutes = 15,
    this.adhanSilentMode = true,
  });

  AppSettingsModel copyWith({
    CalculationMethod? calculationMethod,
    Madhab? madhab,
    KerahatConfig? kerahatConfig,
    ThemeMode? themeMode,
    bool? adhanNotificationEnabled,
    bool? preAlertEnabled,
    int? preAlertMinutes,
    bool? adhanSilentMode,
  }) {
    return AppSettingsModel(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      kerahatConfig: kerahatConfig ?? this.kerahatConfig,
      themeMode: themeMode ?? this.themeMode,
      adhanNotificationEnabled:
          adhanNotificationEnabled ?? this.adhanNotificationEnabled,
      preAlertEnabled: preAlertEnabled ?? this.preAlertEnabled,
      preAlertMinutes: preAlertMinutes ?? this.preAlertMinutes,
      adhanSilentMode: adhanSilentMode ?? this.adhanSilentMode,
    );
  }

  static String getCalculationMethodName(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.turkey:
        return 'Diyanet İşleri Başkanlığı (Türkiye)';
      case CalculationMethod.muslim_world_league:
        return 'Muslim World League (MWL)';
      case CalculationMethod.egyptian:
        return 'Mısır Genel Fetva Heyeti';
      case CalculationMethod.karachi:
        return 'Karaçi İslam İlimleri Üniversitesi';
      case CalculationMethod.umm_al_qura:
        return 'Ümmü\'l-Kurâ (Mekke)';
      case CalculationMethod.dubai:
        return 'Dubai (Birleşik Arap Emirlikleri)';
      case CalculationMethod.north_america:
        return 'ISNA (Kuzey Amerika)';
      default:
        return method.name;
    }
  }

  static String getMadhabName(Madhab m) {
    switch (m) {
      case Madhab.shafi:
        return 'Standart / Şâfiî, Mâlikî, Hanbelî (Tek gölge)';
      case Madhab.hanafi:
        return 'Hanefî (Çift gölge)';
    }
  }
}
