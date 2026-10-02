import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../controllers/qibla_controller.dart';
import '../widgets/qibla_compass_dial.dart';

/// Kıble Bulucu tam ekranı.
/// Düşük geçiren filtreli pusula kadranı, Kâbe yön işareti, hizalanma titreşimi ve Kâbe mesafesi.
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaState = ref.watch(qiblaProvider);
    final prayerState = ref.watch(prayerTimesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final qiblaDegreesRounded = qiblaState.qiblaBearing.round();
    final distanceRounded = qiblaState.distanceKm.round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Yönü'),
      ),
      body: IslamicPatternBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Şehir ve Kâbe Mesafesi
              Text(
                '${prayerState.selectedCity.name} • Kâbe\'ye Mesafe: $distanceRounded km',
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Kıble Açısı Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.sageGreen : AppColors.mossGreen)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? AppColors.sageGreen : AppColors.mossGreen)
                        .withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  'Kıble Açısı: $qiblaDegreesRounded°',
                  style: AppTypography.labelLarge(
                    color: isDark ? AppColors.sageGreen : AppColors.forestGreen,
                    isBold: true,
                  ),
                ),
              ),
              const Spacer(),

              // Pusula Kadranı veya Sensör Yok Durumu
              if (qiblaState.hasSensor) ...[
                Center(
                  child: QiblaCompassDial(
                    heading: qiblaState.heading,
                    qiblaBearing: qiblaState.qiblaBearing,
                    isAligned: qiblaState.isAligned,
                    size: 290,
                  ),
                ),
              ] else ...[
                _buildNoSensorFallback(context, qiblaDegreesRounded, isDark),
              ],

              const Spacer(),

              // Hizalanma Durumu Etiketi
              if (qiblaState.hasSensor) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: qiblaState.isAligned
                        ? AppColors.brassGold
                        : (isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.paleSage.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: qiblaState.isAligned
                          ? AppColors.brassGlow
                          : (isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        qiblaState.isAligned
                            ? Icons.check_circle_rounded
                            : Icons.explore_outlined,
                        size: 20,
                        color: qiblaState.isAligned
                            ? AppColors.darkBg
                            : (isDark ? AppColors.sageGreen : AppColors.forestGreen),
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
                const SizedBox(height: 16),
              ],

              // Kalibrasyon Uyarısı (Sensör doğruluğu düşükse)
              if (qiblaState.needsCalibration) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.clayAmber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pusula doğruluğu düşük. Lütfen cihazınızı havada 8 çizerek kalibre ediniz.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(color: AppColors.clayAmber),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSensorFallback(BuildContext context, int qiblaDegrees, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sensors_off_rounded,
            size: 48,
            color: AppColors.clayAmber,
          ),
          const SizedBox(height: 14),
          Text(
            'Manyetik Pusula Sensörü Bulunamadı',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium(
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cihazınızda pusula sensörü bulunmuyor veya emülatör ortamındasınız. Bulunduğunuz konum için Kâbe yön açısı Kuzey\'den saat yönünde $qiblaDegrees° derecedir.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
