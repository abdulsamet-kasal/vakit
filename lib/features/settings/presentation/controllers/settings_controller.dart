import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../../data/settings_repository.dart';
import '../../domain/settings_model.dart';

class SettingsNotifier extends Notifier<AppSettingsModel> {
  final _repo = SettingsRepository();

  @override
  AppSettingsModel build() {
    _load();
    return const AppSettingsModel();
  }

  Future<void> _load() async {
    final loaded = await _repo.loadSettings();
    state = loaded;
  }

  Future<void> setCalculationMethod(CalculationMethod method) async {
    state = state.copyWith(calculationMethod: method);
    await _repo.saveSettings(state);
    _recalculateTimes();
  }

  Future<void> setMadhab(Madhab madhab) async {
    state = state.copyWith(madhab: madhab);
    await _repo.saveSettings(state);
    _recalculateTimes();
  }

  Future<void> setSunriseKerahat(int minutes) async {
    final updated = state.kerahatConfig.copyWith(sunriseDurationMinutes: minutes);
    state = state.copyWith(kerahatConfig: updated);
    await _repo.saveSettings(state);
    _recalculateTimes();
  }

  Future<void> setMiddayKerahat(int minutes) async {
    final updated = state.kerahatConfig.copyWith(middayBeforeMinutes: minutes);
    state = state.copyWith(kerahatConfig: updated);
    await _repo.saveSettings(state);
    _recalculateTimes();
  }

  Future<void> setSunsetKerahat(int minutes) async {
    final updated = state.kerahatConfig.copyWith(sunsetBeforeMinutes: minutes);
    state = state.copyWith(kerahatConfig: updated);
    await _repo.saveSettings(state);
    _recalculateTimes();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.saveSettings(state);
    ref.read(themeModeProvider.notifier).setThemeMode(mode);
  }

  void _recalculateTimes() {
    // Namaz vakitleri kontrolcüsünü güncel ayarlarla yeniden tetikle
    final prayerTimesNotifier = ref.read(prayerTimesProvider.notifier);
    final prayerTimesState = ref.read(prayerTimesProvider);
    prayerTimesNotifier.changeCity(prayerTimesState.selectedCity, saveToPrefs: false);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettingsModel>(
  SettingsNotifier.new,
);
