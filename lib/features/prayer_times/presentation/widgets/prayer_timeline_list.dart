import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Vakit satırı veri modeli
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

/// Ultra modern dikey namaz vakitleri tablosu.
/// Kaba çizgilerden uzak, minimalist ve lüks saat çizelgesi estetiği.
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
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.mossGreen.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              _PrayerTimelineRow(item: items[i]),
              if (i < items.length - 1)
                Divider(color: dividerColor, height: 1, thickness: 0.8),
            ],
          ],
        ),
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

    final textColor = item.isActive
        ? (isDark ? const Color(0xFFF3D079) : const Color(0xFF9E7728))
        : item.isPast
            ? (isDark ? AppColors.darkMuted.withValues(alpha: 0.4) : AppColors.inkMuted.withValues(alpha: 0.45))
            : (isDark ? AppColors.darkText : AppColors.ink);

    final rowBg = item.isActive
        ? (isDark
            ? AppColors.brassGold.withValues(alpha: 0.1)
            : const Color(0xFFB8934A).withValues(alpha: 0.08))
        : Colors.transparent;

    return Container(
      color: rowBg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Aktif vakit sol göstergesi
          Container(
            width: 3.5,
            height: 22,
            decoration: BoxDecoration(
              color: item.isActive
                  ? const Color(0xFFF3D079)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),

          // Vakit Adı
          Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: item.isActive ? FontWeight.w700 : (item.isPast ? FontWeight.w400 : FontWeight.w500),
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),

          if (item.isActive) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.brassGold : const Color(0xFF9E7728)).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Şu An',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF3D079) : const Color(0xFF9E7728),
                ),
              ),
            ),
          ],

          const Spacer(),

          // Ezan Saati (Newsreader font, tabularFigures)
          Text(
            item.time,
            style: TextStyle(
              fontFamily: 'Newsreader',
              fontSize: 19,
              fontWeight: item.isActive ? FontWeight.w700 : FontWeight.w600,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
