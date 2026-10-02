import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../controllers/settings_controller.dart';
import '../../domain/settings_model.dart';

/// Yerel ayarlar ekranı.
/// Hesaplama yöntemi, ikindi mezhebi, kerahat süreleri, tema ve Supabase bağlantı durumu.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: IslamicPatternBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. HESAPLAMA YÖNTEMİ
            _buildSectionHeader(context, 'HESAPLAMA PARAMETRELERİ'),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Hesap Yöntemi',
                      style: AppTypography.bodyLarge(
                        color: isDark ? AppColors.darkText : AppColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      AppSettingsModel.getCalculationMethodName(settings.calculationMethod),
                      style: AppTypography.bodySmall(
                        color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showCalculationMethodDialog(context, settings, notifier),
                  ),
                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  ListTile(
                    title: Text(
                      'İkindi Vakti Yöntemi',
                      style: AppTypography.bodyLarge(
                        color: isDark ? AppColors.darkText : AppColors.ink,
                      ),
                    ),
                    subtitle: Text(
                      AppSettingsModel.getMadhabName(settings.madhab),
                      style: AppTypography.bodySmall(
                        color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showMadhabDialog(context, settings, notifier),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. KERAHAT VAKİTLERİ (AYARLANABİLİR SÜRELER)
            _buildSectionHeader(context, 'KERAHAT VAKİTLERİ (YAKLAŞIK SÜRELER)'),
            const SizedBox(height: 6),
            Text(
              'Günün zaman çizgisinde sıcak amber tonunda gösterilen kerahat aralıkları.',
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              isDark: isDark,
              child: Column(
                children: [
                  _buildDurationTile(
                    title: 'Gündoğumu Kerahati',
                    subtitle: 'Güneş doğumundan itibaren yaklaşık süre',
                    currentMinutes: settings.kerahatConfig.sunriseDurationMinutes,
                    min: 30,
                    max: 60,
                    onChanged: (val) => notifier.setSunriseKerahat(val),
                    isDark: isDark,
                  ),
                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  _buildDurationTile(
                    title: 'İstiva (Zeval) Kerahati',
                    subtitle: 'Öğle ezanından önceki yaklaşık süre',
                    currentMinutes: settings.kerahatConfig.middayBeforeMinutes,
                    min: 25,
                    max: 55,
                    onChanged: (val) => notifier.setMiddayKerahat(val),
                    isDark: isDark,
                  ),
                  Divider(
                    color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.1),
                    height: 1,
                  ),
                  _buildDurationTile(
                    title: 'Günbatımı Kerahati',
                    subtitle: 'Akşam ezanından önceki yaklaşık süre',
                    currentMinutes: settings.kerahatConfig.sunsetBeforeMinutes,
                    min: 30,
                    max: 60,
                    onChanged: (val) => notifier.setSunsetKerahat(val),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. GÖRÜNÜM & TEMA
            _buildSectionHeader(context, 'GÖRÜNÜM'),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              isDark: isDark,
              child: ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppColors.brassGold,
                ),
                title: Text(
                  'Karanlık Mod',
                  style: AppTypography.bodyLarge(
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: AppColors.brassGold,
                  onChanged: (val) {
                    notifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. SUPABASE & ÇEVRİMİÇİ İÇERİK DURUMU
            _buildSectionHeader(context, 'VERİ & BULUT DURUMU'),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              isDark: isDark,
              child: ListTile(
                leading: Icon(
                  EnvConfig.hasSupabaseConfig ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  color: EnvConfig.hasSupabaseConfig ? AppColors.mossGreen : AppColors.clayAmber,
                ),
                title: Text(
                  'İçerik Sunucusu (Supabase)',
                  style: AppTypography.bodyLarge(
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                subtitle: Text(
                  EnvConfig.hasSupabaseConfig
                      ? 'Bağlantı Aktif (Önbellek & Çevrimiçi)'
                      : 'Offline Mod (Yalnızca Gömülü Varlıklar)',
                  style: AppTypography.bodySmall(
                    color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (EnvConfig.hasSupabaseConfig ? AppColors.mossGreen : AppColors.clayAmber)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    EnvConfig.hasSupabaseConfig ? 'ÇEVRİMİÇİ' : 'GÖMÜLÜ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: EnvConfig.hasSupabaseConfig ? AppColors.mossGreen : AppColors.clayAmber,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. UYGULAMA BİLGİSİ
            _buildSectionHeader(context, 'HAKKINDA'),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              isDark: isDark,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vakit • Sükûnet & Zarafet',
                      style: AppTypography.headlineMedium(
                        color: isDark ? AppColors.darkText : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cihaz üstünde internetsiz Diyanet İşleri yöntemiyle hesaplanan namaz vakitleri, kerahat uyarıları ve İslami zarafete sahip sade tasarım.',
                      style: AppTypography.bodyMedium(
                        color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sürüm 1.0.0 (Aşama 2)',
                      style: AppTypography.labelSmall(color: AppColors.brassGold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppTypography.labelSmall(
        color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
      ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildSettingsContainer({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
        ),
      ),
      child: child,
    );
  }

  Widget _buildDurationTile({
    required String title,
    required String subtitle,
    required int currentMinutes,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge(
                  color: isDark ? AppColors.darkText : AppColors.ink,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '~$currentMinutes dk',
                style: AppTypography.labelLarge(
                  color: AppColors.clayAmber,
                  isBold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
            ),
          ),
          Slider(
            value: currentMinutes.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) ~/ 5,
            activeColor: AppColors.clayAmber,
            onChanged: (val) => onChanged(val.round()),
          ),
        ],
      ),
    );
  }

  void _showCalculationMethodDialog(
    BuildContext context,
    AppSettingsModel settings,
    SettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Hesaplama Yöntemi Seçin'),
          children: [
            for (final method in [
              CalculationMethod.turkey,
              CalculationMethod.muslim_world_league,
              CalculationMethod.egyptian,
              CalculationMethod.karachi,
              CalculationMethod.umm_al_qura,
            ])
              SimpleDialogOption(
                onPressed: () {
                  notifier.setCalculationMethod(method);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      if (settings.calculationMethod == method)
                        const Icon(Icons.check, size: 18, color: AppColors.brassGold)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppSettingsModel.getCalculationMethodName(method),
                          style: TextStyle(
                            fontWeight: settings.calculationMethod == method
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showMadhabDialog(
    BuildContext context,
    AppSettingsModel settings,
    SettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('İkindi Vakti Yöntemi'),
          children: [
            for (final m in Madhab.values)
              SimpleDialogOption(
                onPressed: () {
                  notifier.setMadhab(m);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      if (settings.madhab == m)
                        const Icon(Icons.check, size: 18, color: AppColors.brassGold)
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppSettingsModel.getMadhabName(m),
                          style: TextStyle(
                            fontWeight: settings.madhab == m
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
