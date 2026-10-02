import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/mihrap_container.dart';

/// Mihrap kemeri içerisinde sonraki vakit ve canlı geri sayım gösterge kartı.
class MihrapCountdownCard extends StatelessWidget {
  final String nextPrayerName;
  final String nextPrayerTime;
  final String countdownFormatted; // Örn: "02:45:18"
  final String currentPrayerName;

  const MihrapCountdownCard({
    super.key,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.countdownFormatted,
    this.currentPrayerName = '',
  });

  @override
  Widget build(BuildContext context) {
    return MihrapContainer(
      height: 240,
      width: double.infinity,
      archRatio: 0.38,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Küçük tepe motifi / süsleme
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.brassGold.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),

          // Şu anki vakit veya Sonraki Vakit etiketi
          Text(
            currentPrayerName.isNotEmpty
                ? 'ŞU AN: $currentPrayerName'
                : 'SIRADAKİ VAKİT',
            style: AppTypography.labelSmall(
              color: AppColors.sageGreen.withValues(alpha: 0.85),
            ).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),

          // Sonraki Vakit Adı
          Text(
            nextPrayerName,
            style: AppTypography.headlineLarge(color: AppColors.parchment),
          ),
          const SizedBox(height: 10),

          // Canlı Geri Sayım Rakamları (Mat pirinç & Tabular figures)
          Text(
            countdownFormatted,
            style: AppTypography.countdownTime(
              color: AppColors.brassGold,
            ),
          ),
          const SizedBox(height: 4),

          // Sonraki vakit ezan saati bilgisi
          Text(
            'Ezan: $nextPrayerTime',
            style: AppTypography.bodySmall(
              color: AppColors.sageGreen.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
