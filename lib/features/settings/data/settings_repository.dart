import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/kerahat_config.dart';
import '../domain/settings_model.dart';

/// Ayarların SharedPreferences ile kalıcı depolanması.
class SettingsRepository {
  static const _keyCalcMethod = 'calc_method';
  static const _keyMadhab = 'calc_madhab';
  static const _keySunriseKerahat = 'sunrise_kerahat_min';
  static const _keyMiddayKerahat = 'midday_kerahat_min';
  static const _keySunsetKerahat = 'sunset_kerahat_min';
  static const _keyThemeMode = 'app_theme_mode';

  Future<AppSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final calcMethodStr = prefs.getString(_keyCalcMethod);
    CalculationMethod method = CalculationMethod.turkey;
    if (calcMethodStr != null) {
      for (final m in CalculationMethod.values) {
        if (m.name == calcMethodStr) {
          method = m;
          break;
        }
      }
    }

    final madhabStr = prefs.getString(_keyMadhab);
    Madhab madhab = Madhab.shafi;
    if (madhabStr == 'hanafi') {
      madhab = Madhab.hanafi;
    }

    final sunriseKerahat = prefs.getInt(_keySunriseKerahat) ?? 45;
    final middayKerahat = prefs.getInt(_keyMiddayKerahat) ?? 40;
    final sunsetKerahat = prefs.getInt(_keySunsetKerahat) ?? 45;

    final themeStr = prefs.getString(_keyThemeMode);
    ThemeMode themeMode = ThemeMode.system;
    if (themeStr == 'light') themeMode = ThemeMode.light;
    if (themeStr == 'dark') themeMode = ThemeMode.dark;

    return AppSettingsModel(
      calculationMethod: method,
      madhab: madhab,
      kerahatConfig: KerahatConfig(
        sunriseDurationMinutes: sunriseKerahat,
        middayBeforeMinutes: middayKerahat,
        sunsetBeforeMinutes: sunsetKerahat,
      ),
      themeMode: themeMode,
    );
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCalcMethod, settings.calculationMethod.name);
    await prefs.setString(_keyMadhab, settings.madhab.name);
    await prefs.setInt(_keySunriseKerahat, settings.kerahatConfig.sunriseDurationMinutes);
    await prefs.setInt(_keyMiddayKerahat, settings.kerahatConfig.middayBeforeMinutes);
    await prefs.setInt(_keySunsetKerahat, settings.kerahatConfig.sunsetBeforeMinutes);

    if (settings.themeMode == ThemeMode.light) {
      await prefs.setString(_keyThemeMode, 'light');
    } else if (settings.themeMode == ThemeMode.dark) {
      await prefs.setString(_keyThemeMode, 'dark');
    } else {
      await prefs.remove(_keyThemeMode);
    }
  }
}
