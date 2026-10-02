import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../controllers/prayer_times_controller.dart';
import '../widgets/city_selector_sheet.dart';
import '../widgets/kerahat_badge.dart';
import '../widgets/mihrap_countdown_card.dart';
import '../widgets/prayer_timeline_list.dart';
import '../widgets/sun_arc_painter.dart';

/// Vakit uygulamasının ana ekranı.
/// Mihrap kemeri geri sayımı, güneş yayı, kerahat uyarısı ve dikey zaman şeridini birleştirir.
class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);
    final notifier = ref.read(prayerTimesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timelineItems = state.times.toTimelineItems(
      state.isToday ? state.currentTime : state.times.imsak,
      tomorrowTimes: state.tomorrowTimes,
    );

    return Scaffold(
      body: IslamicPatternBackground(
        opacity: isDark ? 0.04 : 0.05,
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.brassGold,
            onRefresh: () async {
              notifier.goToToday();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 1. Üst Başlık: Şehir Seçimi & Tarihler
                _buildHeader(context, ref, state, notifier, isDark),
                const SizedBox(height: 16),

                // 2. Gün Değiştirme Çubuğu (< Önceki Gün | Bugün | Sonraki Gün >)
                _buildDateNavigator(context, state, notifier, isDark),
                const SizedBox(height: 16),

                // 3. İMZA BİLEŞEN: Mihrap Kemeri & Canlı Geri Sayım
                MihrapCountdownCard(
                  currentPrayerName: state.currentPrayer.displayName,
                  nextPrayerName: state.nextPrayer.displayName,
                  nextPrayerTime: state.nextPrayerTimeFormatted,
                  countdownFormatted: state.countdownString,
                ),
                const SizedBox(height: 16),

                // 4. Kerahat Vakti Uyarısı (Aktifse sakin amber etiketi)
                if (state.activeKerahat != KerahatType.none) ...[
                  Center(child: KerahatBadge(type: state.activeKerahat)),
                  const SizedBox(height: 16),
                ],

                // 5. Güneşin Gökyüzü Seyri Yayı (Sun Arc)
                Container(
                  padding: const EdgeInsets.only(top: 18, bottom: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.paleSage.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.mossGreen.withValues(alpha: 0.12),
                    ),
                  ),
                  child: SunArcWidget(
                    sunProgress: state.sunProgress,
                    sunriseKerahatRatio: state.times.sunriseKerahatRatio,
                    middayKerahatRange: state.times.middayKerahatRange,
                    sunsetKerahatRange: state.times.sunsetKerahatRange,
                    dhuhrProgress: state.times.dhuhrRatio,
                    asrProgress: state.times.asrRatio,
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Dikey Vakit Zaman Şeridi (Timeline)
                PrayerTimelineList(items: timelineItems),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    PrayerTimesState state,
    PrayerTimesNotifier notifier,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Şehir Seçici (Dokunulabilir Buton)
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _openCitySelector(context, state, notifier),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: isDark ? AppColors.sageGreen : AppColors.forestGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  state.selectedCity.name,
                  style: AppTypography.headlineMedium(
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),

        // Tarih Bilgisi (Miladi ve Hicri)
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateTimeUtils.formatMiladiShort(state.selectedDate),
              style: AppTypography.labelLarge(
                color: isDark ? AppColors.darkText : AppColors.ink,
                isBold: true,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateTimeUtils.formatHijri(state.selectedDate),
              style: AppTypography.bodySmall(
                color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateNavigator(
    BuildContext context,
    PrayerTimesState state,
    PrayerTimesNotifier notifier,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.paleSage.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.mossGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Önceki Gün',
            onPressed: notifier.previousDay,
          ),
          InkWell(
            onTap: state.isToday ? null : notifier.goToToday,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                state.isToday ? 'Bugün' : 'Bugüne Dön',
                style: AppTypography.labelSmall(
                  color: state.isToday
                      ? (isDark ? AppColors.sageGreen : AppColors.forestGreen)
                      : AppColors.brassGold,
                ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Sonraki Gün',
            onPressed: notifier.nextDay,
          ),
        ],
      ),
    );
  }

  void _openCitySelector(
    BuildContext context,
    PrayerTimesState state,
    PrayerTimesNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CitySelectorSheet(
          currentCity: state.selectedCity,
          onCitySelected: (city) => notifier.changeCity(city),
          onDetectGps: () => notifier.detectGpsLocation(),
        );
      },
    );
  }
}
