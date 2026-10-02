import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Ultra modern, mimari zarafete sahip canlı namaz vakti ve geri sayım kartı.
/// Yapay zeka klişelerinden uzak, İsviçre tipografisi ve derin orman dokusuyla harmanlanmış lüks tasarım.
class MihrapCountdownCard extends StatelessWidget {
  final String nextPrayerName;
  final String nextPrayerTime;
  final String countdownFormatted;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF143024), const Color(0xFF0B1F17)]
              : [const Color(0xFF123F30), const Color(0xFF0A281E)],
        ),
        border: Border.all(
          color: AppColors.brassGold.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A281E).withValues(alpha: 0.35),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Üst Durum Rozeti (Şu Anki Vakit & Sıradaki Hedef)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 0.6,
                  ),
                ),
                child: Text(
                  currentPrayerName.isNotEmpty
                      ? 'ŞU AN: $currentPrayerName'
                      : 'VAKİT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.sageGreen.withValues(alpha: 0.9),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brassGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brassGold.withValues(alpha: 0.35),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: AppColors.brassGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ezan: $nextPrayerTime',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.brassGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Sıradaki Vakit Adı
          Text(
            nextPrayerName,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.parchment,
            ),
          ),
          const SizedBox(height: 4),

          // 3. Canlı Devasa Geri Sayım Rakamları
          Text(
            countdownFormatted,
            style: const TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 44,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFFF3D079),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Alt Minimalist İnce Durum Göstergesi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3D079),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'vaktin çıkmasına kalan süre',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: AppColors.sageGreen.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
