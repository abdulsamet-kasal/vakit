import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/islamic_pattern_painter.dart';
import '../../core/widgets/mushaf_card.dart';
import '../prayer_times/presentation/widgets/kerahat_badge.dart';
import '../prayer_times/presentation/widgets/mihrap_countdown_card.dart';
import '../prayer_times/presentation/widgets/prayer_timeline_list.dart';
import '../prayer_times/presentation/widgets/sun_arc_painter.dart';

/// Aşama 0: Tasarım Dili, Renk Paleti, Tipografi ve Özel Bileşenler Önizleme Ekranı.
/// Uygulamanın sakin, mushaf ve cami mermeri hissini doğrulamak için kullanılır.
class DesignPreviewScreen extends ConsumerWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vakit • Tasarım Önizleme'),
        actions: [
          IconButton(
            tooltip: 'Tema Değiştir',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? AppColors.brassGold : AppColors.forestGreen,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IslamicPatternBackground(
        opacity: isDark ? 0.04 : 0.05,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Giriş Başlığı
            Text(
              'AŞAMA 0: MİMARİ VE TASARIM DİLİ',
              style: AppTypography.labelSmall(
                color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
              ).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Vakit Tasarım Sistemi',
              style: AppTypography.headlineLarge(
                color: isDark ? AppColors.darkText : AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bir cami avlusunun sükûneti, el yazması mushaf yaprağının dokusu ve mat pirinç zarafeti.',
              style: AppTypography.bodyMedium(
                color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: 24),

            // 1. İMZA BİLEŞEN: MİHRAP GERİ SAYIM PANELİ
            _buildSectionHeader(context, '1. İMZA ŞEKİL: MİHRAP KEMERİ & GERİ SAYIM'),
            const SizedBox(height: 12),
            const MihrapCountdownCard(
              currentPrayerName: 'Öğle',
              nextPrayerName: 'İkindi',
              nextPrayerTime: '16:48',
              countdownFormatted: '01:42:19',
            ),
            const SizedBox(height: 28),

            // 2. KERAHAT UYARI ETİKETİ
            _buildSectionHeader(context, '2. KERAHAT VAKTİ ETİKETİ (Sakin Amber Tonu)'),
            const SizedBox(height: 10),
            const Center(
              child: KerahatBadge(type: KerahatType.midday),
            ),
            const SizedBox(height: 28),

            // 3. GÜNEŞ YAYI (SUN ARC) ÇİZİMİ
            _buildSectionHeader(context, '3. GÜNEŞ YAYI & KERAHAT BANTLARI'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.paleSage.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
                ),
              ),
              child: const SunArcWidget(
                sunProgress: 0.62, // Güneş öğle ile ikindi arasında
                sunriseKerahatRatio: 0.08,
                middayKerahatRange: (0.44, 0.50),
                sunsetKerahatRange: (0.92, 1.0),
                dhuhrProgress: 0.50,
                asrProgress: 0.72,
              ),
            ),
            const SizedBox(height: 28),

            // 4. DİKEY VAKİT ZAMAN ŞERİDİ
            _buildSectionHeader(context, '4. DİKEY ZAMAN ŞERİDİ (Pirinç Vurgu & Eşit Genişlikli Rakamlar)'),
            const SizedBox(height: 12),
            const PrayerTimelineList(
              items: [
                PrayerTimelineItemData(name: 'İmsak', time: '05:22', isPast: true),
                PrayerTimelineItemData(name: 'Güneş', time: '06:48', isPast: true),
                PrayerTimelineItemData(name: 'Öğle', time: '13:06', isActive: true),
                PrayerTimelineItemData(name: 'İkindi', time: '16:24', isNext: true),
                PrayerTimelineItemData(name: 'Akşam', time: '19:12'),
                PrayerTimelineItemData(name: 'Yatsı', time: '20:31'),
              ],
            ),
            const SizedBox(height: 28),

            // 5. MUSHAF SAYFASI KARTI & AYET/HADİS
            _buildSectionHeader(context, '5. AÇIK MUSHAF KARTI & KÖŞE ROZETLERİ'),
            const SizedBox(height: 12),
            MushafCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GÜNÜN ÂYETİ',
                        style: AppTypography.labelSmall(
                          color: AppColors.brassGold,
                        ).copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Bakara Sûresi • 152',
                        style: AppTypography.bodySmall(
                          color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Arapça Metin (Amiri)
                  Text(
                    'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.arabicAyah(
                      color: isDark ? AppColors.darkText : AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Türkçe Meâl
                  Text(
                    '“Öyleyse yalnız beni anın ki ben de sizi anayım. Bana şükredin ve nankörlük etmeyin.”',
                    style: AppTypography.bodyLarge(
                      color: isDark ? AppColors.darkText : AppColors.ink,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.center,
                    child: AyahEndRosette(ayahNumber: 152),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 6. RENK PALETİ VE TASARIM TOKENLARI
            _buildSectionHeader(context, '6. TASARIM TOKENLARI (Doğal Renk Paleti)'),
            const SizedBox(height: 12),
            _buildColorSwatchGrid(),
            const SizedBox(height: 28),

            // 7. TÜRKÇE VE ARAPÇA TİPOGRAFİ TESTİ
            _buildSectionHeader(context, '7. TİPOGRAFİ & TÜRKÇE KARAKTER DOĞRULAMA'),
            const SizedBox(height: 12),
            _buildTypographyVerification(context, isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppTypography.labelSmall(
        color: isDark ? AppColors.sageGreen : AppColors.mossGreen,
      ).copyWith(letterSpacing: 1.0, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildColorSwatchGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _ColorChip(name: 'Orman Yeşili', color: AppColors.forestGreen, textColor: Colors.white),
        _ColorChip(name: 'Yosun Yeşili', color: AppColors.mossGreen, textColor: Colors.white),
        _ColorChip(name: 'Adaçayı', color: AppColors.sageGreen, textColor: AppColors.ink),
        _ColorChip(name: 'Parşömen', color: AppColors.parchment, textColor: AppColors.ink),
        _ColorChip(name: 'Mat Pirinç', color: AppColors.brassGold, textColor: Colors.white),
        _ColorChip(name: 'Kerahat Kili', color: AppColors.clayAmber, textColor: Colors.white),
        _ColorChip(name: 'Koyu Zemin', color: AppColors.darkBg, textColor: Colors.white),
        _ColorChip(name: 'Koyu Yüzey', color: AppColors.darkSurface, textColor: Colors.white),
      ],
    );
  }

  Widget _buildTypographyVerification(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.paleSage.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Newsreader Başlık: Çğışöü İI 0123456789',
            style: AppTypography.headlineMedium(
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Source Sans 3 Gövde: Türkçe karakterler ç, ğ, ı, ö, ş, ü tam uyumlu ve okunaklıdır.',
            style: AppTypography.bodyMedium(
              color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tabular Rakamlar (Geri Sayım Saati): 00:00:00 - 11:11:11 - 88:88:88',
            style: AppTypography.prayerTimeDigits(
              color: AppColors.brassGold,
              isActive: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  final String name;
  final Color color;
  final Color textColor;

  const _ColorChip({
    required this.name,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
