import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../prayer_times/presentation/controllers/prayer_times_controller.dart';
import '../controllers/qibla_controller.dart';
import '../widgets/qibla_compass_dial.dart';

/// Kıble Bulucu tam ekranı.
/// Düşük geçiren filtreli pusula kadranı, Kâbe yön işareti, hizalanma titreşimi,
/// sensörsüz cihazlar için statik yön rehberi ve izin akışları.
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
                '${prayerState.selectedCity.displayName} • Kâbe\'ye Mesafe: $distanceRounded km',
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

              // Durumlar: İzin Gerekli | Yükleniyor | Canlı Pusula | Sensörsüz Statik Rehber
              if (qiblaState.permissionDenied) ...[
                _buildPermissionCard(context, ref, isDark),
              ] else if (qiblaState.isLoading) ...[
                _buildLoadingState(isDark),
              ] else if (qiblaState.hasSensor) ...[
                Center(
                  child: QiblaCompassDial(
                    heading: qiblaState.heading,
                    qiblaBearing: qiblaState.qiblaBearing,
                    isAligned: qiblaState.isAligned,
                    size: 290,
                  ),
                ),
              ] else ...[
                _buildNoSensorFallback(context, ref, qiblaDegreesRounded, isDark),
              ],

              const Spacer(),

              // Hizalanma Durumu Etiketi (Yalnızca aktif sensör varken)
              if (qiblaState.hasSensor && !qiblaState.isLoading && !qiblaState.permissionDenied) ...[
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

  Widget _buildLoadingState(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.brassGold),
        const SizedBox(height: 16),
        Text(
          'Pusula sensörü başlatılıyor...',
          style: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionCard(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_disabled_rounded,
            size: 44,
            color: AppColors.clayAmber,
          ),
          const SizedBox(height: 14),
          Text(
            'Konum İzni Gerekli',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium(
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Android işletim sistemi manyetik pusula sensörünü çalıştırabilmek için konum erişimine ihtiyaç duyar.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(qiblaProvider.notifier).retryOrRequestPermission();
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('İzin Ver ve Başlat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: AppColors.parchment,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSensorFallback(
    BuildContext context,
    WidgetRef ref,
    int qiblaDegrees,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Statik Kadran Önizlemesi
          Center(
            child: QiblaCompassDial(
              heading: 0.0,
              qiblaBearing: qiblaDegrees.toDouble(),
              isAligned: false,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manyetik Pusula Sensörü Algılanamadı',
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium(
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cihazınızda donanımsal manyetik pusula bulunmuyor veya kalibrasyon gerekiyor. Bulunduğunuz konum için Kâbe yönü Kuzey\'den saat yönünde $qiblaDegrees° derecedir.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ref.read(qiblaProvider.notifier).retryOrRequestPermission();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Sensörü Tekrar Dene'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.sageGreen : AppColors.forestGreen,
              side: BorderSide(
                color: isDark ? AppColors.sageGreen : AppColors.forestGreen,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
