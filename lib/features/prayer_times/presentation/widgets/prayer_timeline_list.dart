import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Vakit satırı veri modeli (önizleme ve liste için)
class PrayerTimelineItemData {
  final String name;
  final String time;
  final bool isPast;
  final bool isActive;
  final bool isNext;

  const PrayerTimelineItemData({
    required this.name,
    required this.time,
    this.isPast = false,
    this.isActive = false,
    this.isNext = false,
  });
}

/// Dikey zaman şeridi (timeline).
/// Her vakti ayrı gölgeli kart yerine, zarif ince çizgilerle ayrılmış tek bir şerit halinde sunar.
/// Aktif vakit solunda ince bir pirinç dikey çizgi ve pirinç tonunda vurgu ile öne çıkar.
class PrayerTimelineList extends StatelessWidget {
  final List<PrayerTimelineItemData> items;

  const PrayerTimelineList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? AppColors.darkBorder
        : AppColors.mossGreen.withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _PrayerTimelineRow(item: items[i]),
            if (i < items.length - 1)
              Divider(color: dividerColor, height: 1, thickness: 0.8),
          ],
        ],
      ),
    );
  }
}

class _PrayerTimelineRow extends StatelessWidget {
  final PrayerTimelineItemData item;

  const _PrayerTimelineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Renk hiyerarşisi: Aktif -> Pirinç, Geçmiş -> Soluk, Gelecek -> Normal
    final textColor = item.isActive
        ? AppColors.brassGold
        : item.isPast
            ? (isDark ? AppColors.darkMuted.withValues(alpha: 0.45) : AppColors.inkMuted.withValues(alpha: 0.4))
            : (isDark ? AppColors.darkText : AppColors.ink);

    final rowBg = item.isActive
        ? (isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.paleSage.withValues(alpha: 0.6))
        : Colors.transparent;

    return Container(
      color: rowBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Aktif vakit pirinç dikey gösterge çizgisi
          Container(
            width: 3.5,
            height: 22,
            decoration: BoxDecoration(
              color: item.isActive ? AppColors.brassGold : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          // Vakit Adı
          Expanded(
            child: Row(
              children: [
                Text(
                  item.name,
                  style: AppTypography.bodyLarge(color: textColor).copyWith(
                    fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (item.isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brassGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'ŞU AN',
                      style: AppTypography.labelSmall(color: AppColors.brassGold).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ] else if (item.isNext) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.sageGreen : AppColors.mossGreen).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SIRADAKİ',
                      style: AppTypography.labelSmall(
                        color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Saat Rakamları (Tabular Figures)
          Text(
            item.time,
            style: AppTypography.prayerTimeDigits(
              color: textColor,
              isActive: item.isActive,
            ),
          ),
        ],
      ),
    );
  }
}
