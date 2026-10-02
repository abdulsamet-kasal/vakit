import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';

class DailyVerseScreen extends StatelessWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günün Âyeti'),
      ),
      body: IslamicPatternBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 72,
                color: isDark ? AppColors.sageGreen : AppColors.forestGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'Günün Âyeti',
                style: AppTypography.headlineLarge(
                  color: isDark ? AppColors.darkText : AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aşama 3 kapsamında entegre edilecek.',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
