import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Güneşin gündoğumundan günbatımına gökyüzündeki seyrini gösteren yay çizimi.
/// Kerahat aralıkları taralı kil/amber rengi bantlarla gösterilir.
/// Güneş noktası şimdiki zamana göre yay üzerinde ilerler.
class SunArcPainter extends CustomPainter {
  /// Güneşin yay üzerindeki konumu (0.0 = Gündoğumu, 0.5 = Tepe/Öğle, 1.0 = Günbatımı/Akşam).
  /// Gündüz değilse null olabilir.
  final double? sunProgress;

  /// Güneş doğuş kerahat oranı (örn: 0.0 - 0.08)
  final double sunriseKerahatRatio;

  /// İstiva kerahat aralığı (örn: [0.45, 0.50])
  final (double, double) middayKerahatRange;

  /// Güneş batış kerahat oranı (örn: [0.92, 1.0])
  final (double, double) sunsetKerahatRange;

  /// Öğle vaktinin yaydaki konumu (yaklaşık 0.50)
  final double dhuhrProgress;

  /// İkindi vaktinin yaydaki konumu (yaklaşık 0.72)
  final double asrProgress;

  final Color arcColor;
  final Color kerahatColor;
  final Color sunColor;
  final Color textColor;

  const SunArcPainter({
    required this.sunProgress,
    this.sunriseKerahatRatio = 0.08,
    this.middayKerahatRange = (0.44, 0.50),
    this.sunsetKerahatRange = (0.92, 1.0),
    this.dhuhrProgress = 0.50,
    this.asrProgress = 0.72,
    this.arcColor = AppColors.mossGreen,
    this.kerahatColor = AppColors.clayAmber,
    this.sunColor = AppColors.brassGold,
    this.textColor = AppColors.inkMuted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Yayın merkezi ve yarıçapı
    final cx = w / 2;
    final cy = h * 0.92;
    final r = math.min(w * 0.44, h * 0.85);

    // Ufuk çizgisi (taban)
    final horizonPaint = Paint()
      ..color = arcColor.withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - r - 16, cy), Offset(cx + r + 16, cy), horizonPaint);

    // Ana yay yolu: π'den 0'a (saat yönünde, sol ufuktan sağ ufka)
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final baseArcPaint = Paint()
      ..color = arcColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(arcRect, math.pi, math.pi, false, baseArcPaint);

    // Kerahat bantları (Taralı amber/kil çizgi)
    _drawKerahatBand(canvas, arcRect, 0.0, sunriseKerahatRatio, kerahatColor);
    _drawKerahatBand(canvas, arcRect, middayKerahatRange.$1, middayKerahatRange.$2, kerahatColor);
    _drawKerahatBand(canvas, arcRect, sunsetKerahatRange.$1, sunsetKerahatRange.$2, kerahatColor);

    // Vakit işaretleri (Noktalar: Gündoğumu, Öğle, İkindi, Akşam)
    _drawTimePoint(canvas, cx, cy, r, 0.0, 'Güneş');
    _drawTimePoint(canvas, cx, cy, r, dhuhrProgress, 'Öğle');
    _drawTimePoint(canvas, cx, cy, r, asrProgress, 'İkindi');
    _drawTimePoint(canvas, cx, cy, r, 1.0, 'Akşam');

    // Güneş konumu (varsa)
    if (sunProgress != null && sunProgress! >= 0.0 && sunProgress! <= 1.0) {
      final angle = math.pi - (sunProgress! * math.pi);
      final sx = cx + r * math.cos(angle);
      final sy = cy - r * math.sin(angle);

      // Güneş hare / parıltı dairesi
      final glowPaint = Paint()
        ..color = sunColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 14, glowPaint);

      // Güneş göbeği
      final corePaint = Paint()
        ..color = sunColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 6, corePaint);
    }
  }

  /// Belirli bir ilerleme aralığını taralı / amber bant olarak çizer
  void _drawKerahatBand(
    Canvas canvas,
    Rect arcRect,
    double startRatio,
    double endRatio,
    Color color,
  ) {
    final startAngle = math.pi + (startRatio * math.pi);
    final sweepAngle = (endRatio - startRatio) * math.pi;

    final bandPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, bandPaint);
  }

  void _drawTimePoint(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double ratio,
    String label,
  ) {
    final angle = math.pi - (ratio * math.pi);
    final px = cx + r * math.cos(angle);
    final py = cy - r * math.sin(angle);

    final dotPaint = Paint()
      ..color = arcColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(px, py), 3.5, dotPaint);

    // Küçük etiket
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelOffset = Offset(
      px - (textPainter.width / 2),
      py > cy - 20 ? py + 6 : py - 18,
    );
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant SunArcPainter oldDelegate) {
    return oldDelegate.sunProgress != sunProgress ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.kerahatColor != kerahatColor;
  }
}

/// Kolay kullanım için SunArc widget'ı
class SunArcWidget extends StatelessWidget {
  final double? sunProgress;
  final double sunriseKerahatRatio;
  final (double, double) middayKerahatRange;
  final (double, double) sunsetKerahatRange;
  final double dhuhrProgress;
  final double asrProgress;
  final double height;

  const SunArcWidget({
    super.key,
    required this.sunProgress,
    this.sunriseKerahatRatio = 0.09,
    this.middayKerahatRange = (0.44, 0.50),
    this.sunsetKerahatRange = (0.91, 1.0),
    this.dhuhrProgress = 0.50,
    this.asrProgress = 0.72,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: SunArcPainter(
          sunProgress: sunProgress,
          sunriseKerahatRatio: sunriseKerahatRatio,
          middayKerahatRange: middayKerahatRange,
          sunsetKerahatRange: sunsetKerahatRange,
          dhuhrProgress: dhuhrProgress,
          asrProgress: asrProgress,
          arcColor: isDark ? AppColors.sageGreen : AppColors.mossGreen,
          kerahatColor: AppColors.clayAmber,
          sunColor: AppColors.brassGold,
          textColor: isDark ? AppColors.darkMuted : AppColors.inkMuted,
        ),
      ),
    );
  }
}
