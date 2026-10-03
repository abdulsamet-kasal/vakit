import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../../data/settings_repository.dart';
import '../../domain/settings_model.dart';
import '../../notification/notification_scheduler_service.dart';
import '../../notification/native_notification_bridge.dart';

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

  // --- Ezan bildirimi ayarları ---

  Future<void> setAdhanNotification(bool enabled) async {
    state = state.copyWith(adhanNotificationEnabled: enabled);
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  Future<void> setPreAlert(bool enabled) async {
    state = state.copyWith(preAlertEnabled: enabled);
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  Future<void> setPreAlertMinutes(int minutes) async {
    state = state.copyWith(preAlertMinutes: minutes);
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  /// Bildirim sesini seçer.
  /// [uri] null → sistem varsayılanı, boş dize → sessiz (sistemin zil
  /// seçicisinden "Sessiz" seçilmesi), dolu → cihazdaki ses.
  Future<void> setNotificationSound(String? uri) async {
    final silent = uri != null && uri.isEmpty;
    state = state.copyWith(
      adhanSilentMode: silent,
      notificationSoundUri: uri,
      clearNotificationSoundUri: uri == null || uri.isEmpty,
    );
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  /// Sessiz (titreşim) moda geçer; ses seçimi korunur ama kullanılmaz.
  Future<void> setNotificationSilent(bool silent) async {
    state = state.copyWith(adhanSilentMode: silent);
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  Future<void> setNotificationVibration(bool enabled) async {
    state = state.copyWith(notificationVibration: enabled);
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  /// Bildirim çubuğundaki kalıcı vakit bildirimini açar/kapatır.
  Future<void> setPrayerBarEnabled(bool enabled) async {
    state = state.copyWith(prayerBarEnabled: enabled);
    await _repo.saveSettings(state);
    await _resyncNotificationAlarms();
  }

  /// Ayarlar ekranındaki "Test bildirimi" düğmesi.
  Future<void> sendTestNotification() async {
    await NativeNotificationBridge.sendTestNotification();
  }

  /// Sistem zil seçicisini açar; seçilen URI kaydedilir.
  /// İptal edilirse hiçbir şey değişmez.
  Future<void> pickNotificationSound() async {
    final picked =
        await NativeNotificationBridge.pickSound(currentUri: state.notificationSoundUri);
    if (picked == null) return; // iptal
    await setNotificationSound(picked.isEmpty ? '' : picked);
  }

  /// Bildirim ayarları değişince widget köprüsündeki bildirim alarmlarını
  /// yeniden zamanla (hemen ve gelecek 7 gün için).
  Future<void> _resyncNotificationAlarms() async {
    try {
      final prayerState = ref.read(prayerTimesProvider);
      // ignore: avoid_dynamic_calls
      final svc = NotificationSchedulerService.instance;
      await svc.scheduleFromCity(prayerState.selectedCity, settings: state);
      // Alarm sayacını ve kalıcı çubuğu da hemen tazeler
      // (scheduleFromCity bunları kendi içinde tetikler).
    } catch (e) {
      debugPrint('Bildirim alarmları yeniden zamanlanamadı: $e');
    }
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
