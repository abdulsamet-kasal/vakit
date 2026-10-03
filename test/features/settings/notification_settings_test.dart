import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vakit/features/settings/data/settings_repository.dart';
import 'package:vakit/features/settings/domain/settings_model.dart';

/// Yeni bildirim ayarlarının (ses seçimi, titreşim, kalıcı namaz çubuğu)
/// model varsayılanları ve SharedPreferences kalıcılığı.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettingsModel bildirim varsayılanları', () {
    test('varsayılan olarak sessiz ses, titreşim açık ve çubuk açık olmalı', () {
      const s = AppSettingsModel();
      expect(s.adhanSilentMode, isTrue);
      expect(s.notificationSoundUri, isNull);
      expect(s.notificationVibration, isTrue);
      expect(s.prayerBarEnabled, isTrue);
      expect(s.notificationSoundLabel, 'Sessiz (titreşim)');
    });

    test('sesli modda URI yoksa "Sistem varsayılanı", varsa "Seçilen ses" olmalı', () {
      const defaultSound = AppSettingsModel(adhanSilentMode: false);
      expect(defaultSound.notificationSoundLabel, 'Sistem varsayılanı');

      const custom = AppSettingsModel(
        adhanSilentMode: false,
        notificationSoundUri: 'content://media/internal/audio/media/7',
      );
      expect(custom.notificationSoundLabel, 'Seçilen ses');
    });

    test('clearNotificationSoundUri ses seçimini null yapabilmeli', () {
      const base = AppSettingsModel(
        adhanSilentMode: false,
        notificationSoundUri: 'content://media/audio/7',
      );
      final cleared = base.copyWith(clearNotificationSoundUri: true);
      expect(cleared.notificationSoundUri, isNull);
      expect(cleared.adhanSilentMode, isFalse);
      // Diğer alanlar korunur
      expect(cleared.notificationVibration, base.notificationVibration);
      expect(cleared.prayerBarEnabled, base.prayerBarEnabled);
    });
  });

  group('SettingsRepository kalıcılığı', () {
    test('ses URI, titreşim ve çubuk ayarı kaydedilip geri yüklenmeli', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository();

      await repo.saveSettings(const AppSettingsModel(
        adhanSilentMode: false,
        notificationSoundUri: 'content://media/audio/7',
        notificationVibration: false,
        prayerBarEnabled: false,
      ));

      final loaded = await repo.loadSettings();
      expect(loaded.notificationSoundUri, 'content://media/audio/7');
      expect(loaded.notificationVibration, isFalse);
      expect(loaded.prayerBarEnabled, isFalse);
      expect(loaded.adhanSilentMode, isFalse);
    });

    test('ses seçimi temizlenince anahtar silinmeli (null geri yüklenmeli)', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository();

      await repo.saveSettings(const AppSettingsModel(
        adhanSilentMode: false,
        notificationSoundUri: 'content://media/audio/7',
      ));
      await repo.saveSettings(const AppSettingsModel(adhanSilentMode: false));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('notification_sound_uri'), isNull);

      final loaded = await repo.loadSettings();
      expect(loaded.notificationSoundUri, isNull);
    });

    test('varsayılan değerler yazılmadan da okunabilmeli', () async {
      SharedPreferences.setMockInitialValues({});
      final loaded = await SettingsRepository().loadSettings();
      expect(loaded.notificationVibration, isTrue);
      expect(loaded.prayerBarEnabled, isTrue);
      expect(loaded.adhanSilentMode, isTrue);
      expect(loaded.notificationSoundUri, isNull);
    });
  });
}
