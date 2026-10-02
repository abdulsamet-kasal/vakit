import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: IslamicPatternBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'GÖRÜNÜM',
              style: AppTypography.labelSmall(
                color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
              ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
                ),
              ),
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
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'HAKKINDA',
              style: AppTypography.labelSmall(
                color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
              ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
                ),
              ),
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
                    'Sürüm 1.0.0 (Aşama 1)',
                    style: AppTypography.labelSmall(color: AppColors.brassGold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
