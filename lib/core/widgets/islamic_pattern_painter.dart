import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// İslami geometrik doku (Sekizgen Selçuklu Yıldızı ve Girih örgüsü) çizicisi.
/// Ekranda bir dekor gibi değil, taş/kağıt dokusu hissi yaratacak şekilde
/// %4-6 opaklık ile arka planda akar.
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double tileSize;

  const IslamicPatternPainter({
    this.color = AppColors.forestGreen,
    this.opacity = 0.05,
    this.tileSize = 90.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final cols = (size.width / tileSize).ceil() + 1;
    final rows = (size.height / tileSize).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * tileSize;
        final cy = r * tileSize;

        _drawEightPointedStar(canvas, cx, cy, tileSize * 0.35, paint);
        _drawGirihInterlinks(canvas, cx, cy, tileSize, paint);
      }
    }
  }

  /// 8 köşeli Selçuklu yıldızı (Khatam)
  void _drawEightPointedStar(Canvas canvas, double cx, double cy, double radius, Paint paint) {
    final path = Path();
    final innerRadius = radius * 0.54;
    const points = 16; // 8 dış köşe, 8 iç girinti

    for (int i = 0; i < points; i++) {
      final angle = (i * math.pi / 8) - (math.pi / 2);
      final r = (i % 2 == 0) ? radius : innerRadius;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  /// Komşu yıldızları birbirine bağlayan girih çizgileri
  void _drawGirihInterlinks(Canvas canvas, double cx, double cy, double step, Paint paint) {
    final half = step / 2;
    // Çapraz bağlayıcı ince hatlar
    canvas.drawLine(Offset(cx + half, cy), Offset(cx, cy + half), paint);
    canvas.drawLine(Offset(cx + half, cy + step), Offset(cx + step, cy + half), paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.tileSize != tileSize;
  }
}

/// Kolay kullanım için arka plan widget sarmalayıcısı
class IslamicPatternBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double tileSize;
  final Color? color;

  const IslamicPatternBackground({
    super.key,
    required this.child,
    this.opacity = 0.05,
    this.tileSize = 90.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.sageGreen : AppColors.forestGreen;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: IslamicPatternPainter(
            color: color ?? defaultColor,
            opacity: opacity,
            tileSize: tileSize,
          ),
        ),
        child,
      ],
    );
  }
}
