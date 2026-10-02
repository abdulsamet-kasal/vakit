import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../controllers/qibla_controller.dart';
import '../widgets/qibla_compass_dial.dart';

/// Ultra modern, minimalist ve insan işi lüks Kıble Bulucu ekranı.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  String _cardinalDirectionName(double deg) {
    final d = (deg % 360 + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'KUZEY';
    if (d >= 22.5 && d < 67.5) return 'KUZEYDOĞU';
    if (d >= 67.5 && d < 112.5) return 'DOĞU';
    if (d >= 112.5 && d < 157.5) return 'GÜNEYDOĞU';
    if (d >= 157.5 && d < 202.5) return 'GÜNEY';
    if (d >= 202.5 && d < 247.5) return 'GÜNEYBATI';
    if (d >= 247.5 && d < 292.5) return 'BATI';
    return 'KUZEYBATI';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaProvider);
    final prayerState = ref.watch(prayerTimesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final qiblaDegreesRounded = qiblaState.qiblaBearing.round();
    final headingRounded = qiblaState.heading.round();
    final distanceRounded = qiblaState.distanceKm.round();
    final currentDirectionName = _cardinalDirectionName(qiblaState.heading);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.parchment,
      appBar: AppBar(
        title: const Text('Kıble Pusulası'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Pusulayı Sıfırla',
            onPressed: () => ref.read(qiblaProvider.notifier).retrySensors(),
          ),
        ],
      ),
      body: IslamicPatternBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 1. Üst Konum & Kâbe Mesafesi Hapı (Modern Pill Bar)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        prayerState.selectedCity.displayName,
                        style: AppTypography.bodyMedium(
                          color: isDark ? AppColors.darkText : AppColors.ink,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                          ),
                        ),
                      ),
                      Text(
                        'Kâbe: $distanceRounded km',
                        style: AppTypography.bodySmall(
                          color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Anlık Yön ve Kıble Hedef Açısı Kartları (Devasa & Net Tipografi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Anlık Yön
                    _buildStatCard(
                      label: 'MEVCUT YÖN',
                      value: '$headingRounded°',
                      subtext: currentDirectionName,
                      isDark: isDark,
                      isPrimary: false,
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: (isDark ? Colors.white : AppColors.ink).withValues(alpha: 0.08),
                    ),
                    // Hedef Kıble Açısı
                    _buildStatCard(
                      label: 'KIBLE AÇISI',
                      value: '$qiblaDegreesRounded°',
                      subtext: 'KÂBE HEDEFİ',
                      isDark: isDark,
                      isPrimary: true,
                    ),
                  ],
                ),

                const Spacer(),

                // 3. Ultra Modern Saatçilik Pusula Kadranı
                Center(
                  child: QiblaCompassDial(
                    heading: qiblaState.heading,
                    qiblaBearing: qiblaState.qiblaBearing,
                    isAligned: qiblaState.isAligned,
                    size: 295,
                  ),
                ),

                const Spacer(),

                // 4. Hizalanma Durumu veya Canlı Kalibrasyon Rehberi
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                    color: qiblaState.isAligned
                        ? AppColors.brassGold
                        : (isDark
                            ? AppColors.darkSurfaceElevated
                            : Colors.white.withValues(alpha: 0.9)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: qiblaState.isAligned
                          ? const Color(0xFFF3D079)
                          : (isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15)),
                      width: qiblaState.isAligned ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: qiblaState.isAligned
                            ? AppColors.brassGold.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        qiblaState.isAligned
                            ? Icons.check_circle_rounded
                            : Icons.navigation_rounded,
                        size: 20,
                        color: qiblaState.isAligned
                            ? AppColors.darkBg
                            : (isDark ? AppColors.sageGreen : AppColors.mossGreen),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        qiblaState.isAligned
                            ? 'Kıbleye Doğru Hizalandınız'
                            : 'Cihazı Kâbe yönüne çevirin',
                        style: AppTypography.labelLarge(
                          color: qiblaState.isAligned
                              ? AppColors.darkBg
                              : (isDark ? AppColors.darkText : AppColors.ink),
                          isBold: true,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Kalibrasyon Rehberi (8 Çizme İpucu)
                if (qiblaState.needsCalibration)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.clayAmber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, size: 14, color: AppColors.clayAmber),
                        const SizedBox(width: 6),
                        Text(
                          'Pusulayı kalibre etmek için cihazı havada 8 çizecek şekilde çevirin',
                          style: AppTypography.bodySmall(
                            color: isDark ? const Color(0xFFE8A87C) : AppColors.clayAmber,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtext,
    required bool isDark,
    required bool isPrimary,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall(
            color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
          ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Newsreader',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: isPrimary
                ? (isDark ? AppColors.brassGold : const Color(0xFF9E7728))
                : (isDark ? AppColors.darkText : AppColors.ink),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          subtext,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isPrimary
                ? (isDark ? AppColors.sageGreen : AppColors.forestGreen)
                : (isDark ? AppColors.darkMuted : AppColors.inkMuted),
          ),
        ),
      ],
    );
  }
}
