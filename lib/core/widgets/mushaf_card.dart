import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Açık mushaf sayfası hissi veren çerçeveli ve köşe tezyinatlı kart.
/// Kenarlarda ince pirinç kılcal çerçeve ve dört köşede minyatür İslami rozet motifi barındırır.
class MushafCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color borderColor;

  const MushafCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.backgroundColor,
    this.borderColor = AppColors.brassGold,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.parchmentWarm);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
      child: CustomPaint(
        painter: _MushafFramePainter(
          borderColor: borderColor.withValues(alpha: 0.6),
          cornerMargin: 8.0,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Mushaf iç çerçevesi ve 4 köşe rozeti çizicisi
class _MushafFramePainter extends CustomPainter {
  final Color borderColor;
  final double cornerMargin;

  const _MushafFramePainter({
    required this.borderColor,
    required this.cornerMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final m = cornerMargin;
    final w = size.width;
    final h = size.height;

    // İç kılcal dikdörtgen çerçeve
    final rect = Rect.fromLTWH(m, m, w - (2 * m), h - (2 * m));
    canvas.drawRect(rect, paint);

    // 4 köşe rozeti
    const rosetteRadius = 5.0;
    _drawCornerRosette(canvas, m, m, rosetteRadius, paint);
    _drawCornerRosette(canvas, w - m, m, rosetteRadius, paint);
    _drawCornerRosette(canvas, m, h - m, rosetteRadius, paint);
    _drawCornerRosette(canvas, w - m, h - m, rosetteRadius, paint);
  }

  void _drawCornerRosette(Canvas canvas, double cx, double cy, double r, Paint paint) {
    // Küçük 8 köşeli yıldız rozet
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final rad = (i % 2 == 0) ? r : r * 0.55;
      final x = cx + rad * math.cos(angle);
      final y = cy + rad * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MushafFramePainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerMargin != cornerMargin;
  }
}

/// Ayet sonu rozet simgesi (۝ / Khatam motifi)
class AyahEndRosette extends StatelessWidget {
  final int? ayahNumber;
  final double size;
  final Color color;

  const AyahEndRosette({
    super.key,
    this.ayahNumber,
    this.size = 28,
    this.color = AppColors.brassGold,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _AyahRosettePainter(color: color),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            ayahNumber != null ? '$ayahNumber' : '۝',
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'serif',
            ),
          ),
        ),
      ),
    );
  }
}

class _AyahRosettePainter extends CustomPainter {
  final Color color;

  const _AyahRosettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final outerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Dış sekizgen
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - (math.pi / 8);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, outerPaint);

    // İç daire
    canvas.drawCircle(Offset(cx, cy), r * 0.72, outerPaint);
  }

  @override
  bool shouldRepaint(covariant _AyahRosettePainter oldDelegate) =>
      oldDelegate.color != color;
}
