import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/share_card_exporter.dart';
import '../../../../core/widgets/islamic_pattern_painter.dart';
import '../../../../core/widgets/mushaf_card.dart';
import '../controllers/daily_content_controller.dart';

/// Günün Âyeti ekranı.
/// Açık Mushaf sayfası tasarımı, Arapça Amiri metin, meal, kopyalama ve kart görseli paylaşımı.
class DailyVerseScreen extends ConsumerStatefulWidget {
  const DailyVerseScreen({super.key});

  @override
  ConsumerState<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends ConsumerState<DailyVerseScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyContentProvider);
    final notifier = ref.read(dailyContentProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günün Âyeti'),
      ),
      body: IslamicPatternBackground(
        child: state.verse.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.brassGold),
          ),
          error: (err, _) => Center(
            child: Text('Âyet yüklenemedi: $err'),
          ),
          data: (verse) {
            final shareTextContent =
                '${verse.arabic}\n\n"${verse.mealTr}"\n\n— ${verse.sourceName}\n\n(Vakit Uygulaması ile paylaşıldı)';

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Gün Değiştirici
                _buildDateNavigator(context, state, notifier, isDark),
                const SizedBox(height: 16),

                // Paylaşılabilir Mushaf Kartı
                RepaintBoundary(
                  key: _cardKey,
                  child: MushafCard(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Kart Üst Başlığı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.brassGold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'GÜNÜN ÂYETİ',
                                  style: AppTypography.labelSmall(
                                    color: AppColors.brassGold,
                                  ).copyWith(
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              verse.sourceName,
                              style: AppTypography.bodySmall(
                                color: isDark ? AppColors.darkMuted : AppColors.inkMuted,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Arapça Metin (Amiri)
                        Text(
                          verse.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.arabicAyah(
                            color: isDark ? AppColors.darkText : AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Türkçe Meâl
                        Text(
                          '“${verse.mealTr}”',
                          style: AppTypography.bodyLarge(
                            color: isDark ? AppColors.darkText : AppColors.ink,
                          ).copyWith(
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ayet Sonu Rozeti
                        Center(
                          child: AyahEndRosette(
                            ayahNumber: verse.ayahNo,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Alt Filigran
                        Center(
                          child: Text(
                            'Vakit • Sükûnet & Zarafet',
                            style: AppTypography.labelSmall(
                              color: isDark
                                  ? AppColors.darkMuted.withValues(alpha: 0.5)
                                  : AppColors.inkMuted.withValues(alpha: 0.5),
                            ).copyWith(fontSize: 9, letterSpacing: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Eylem Butonları (Kopyala & Paylaş)
                Row(
                  children: [
                    // Kopyala Butonu
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkText : AppColors.ink,
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.mossGreen.withValues(alpha: 0.25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Kopyala'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareTextContent));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Âyet ve meâli panoya kopyalandı.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Görsel Kart Olarak Paylaş Butonu
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          foregroundColor: AppColors.parchment,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.parchment,
                                ),
                              )
                            : const Icon(Icons.share_rounded, size: 18),
                        label: Text(_isSharing ? 'Hazırlanıyor...' : 'Kart Olarak Paylaş'),
                        onPressed: _isSharing
                            ? null
                            : () async {
                                setState(() => _isSharing = true);
                                await ShareCardExporter.shareWidgetAsImage(
                                  repaintBoundaryKey: _cardKey,
                                  shareSubject: 'Günün Âyeti • ${verse.sourceName}',
                                  fallbackText: shareTextContent,
                                );
                                if (mounted) {
                                  setState(() => _isSharing = false);
                                }
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Metin Olarak Paylaş Seçeneği
                Center(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? AppColors.sageGreen : AppColors.mossGreen,
                    ),
                    icon: const Icon(Icons.text_snippet_outlined, size: 16),
                    label: const Text('Yalnızca Metin Olarak Paylaş'),
                    onPressed: () {
                      ShareCardExporter.shareText(
                        text: shareTextContent,
                        subject: 'Günün Âyeti • ${verse.sourceName}',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateNavigator(
    BuildContext context,
    DailyContentState state,
    DailyContentNotifier notifier,
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
                state.isToday
                    ? DateTimeUtils.formatMiladiShort(state.selectedDate)
                    : '${DateTimeUtils.formatMiladiShort(state.selectedDate)} (Bugüne Dön)',
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
}
