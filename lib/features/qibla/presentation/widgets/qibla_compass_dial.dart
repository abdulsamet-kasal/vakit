import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Özel İslami pusula kadranı ve Kâbe yön ibresi.
/// Kıbleye hizalandığında yumuşak pirinç altın parıltı (glow) yayar.
class QiblaCompassDial extends StatelessWidget {
  final double heading;
  final double qiblaBearing;
  final bool isAligned;
  final double size;

  const QiblaCompassDial({
    super.key,
    required this.heading,
    required this.qiblaBearing,
    required this.isAligned,
    this.size = 290.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kadran cihazın heading açısına göre ters yönde döner (Kuzey yukarıda kalsın diye)
    final dialAngleRadian = (360.0 - heading) * (math.pi / 180.0);
    // Kâbe ibresinin mutlak açısı
    final qiblaAngleRadian = (qiblaBearing - heading) * (math.pi / 180.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.darkSurface : AppColors.parchmentWarm.withValues(alpha: 0.6),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: AppColors.brassGold.withValues(alpha: 0.35),
                  blurRadius: 36,
                  spreadRadius: 8,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Dönen Dış Pusula Kadranı (K, D, G, B ve dereceler)
          Transform.rotate(
            angle: dialAngleRadian,
            child: CustomPaint(
              size: Size(size, size),
              painter: _CompassDialPainter(
                isDark: isDark,
                isAligned: isAligned,
              ),
            ),
          ),

          // 2. Kâbe Yönü İbresi (Kâbe Açısına Döner)
          Transform.rotate(
            angle: qiblaAngleRadian,
            child: CustomPaint(
              size: Size(size, size),
              painter: _QiblaPointerPainter(
                isAligned: isAligned,
              ),
            ),
          ),

          // 3. Merkez Göbek Rozeti
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned
                  ? AppColors.brassGold
                  : (isDark ? AppColors.darkSurfaceElevated : AppColors.forestGreen),
              border: Border.all(
                color: isAligned ? AppColors.brassGlow : AppColors.brassGold.withValues(alpha: 0.5),
                width: 2.0,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.navigation_rounded,
                size: 20,
                color: isAligned ? AppColors.darkBg : AppColors.parchment,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pusula halkası, çentikler ve ana yön harfleri (K, D, G, B)
class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  final bool isAligned;

  const _CompassDialPainter({
    required this.isDark,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Dış kılcal çember
    final ringPaint = Paint()
      ..color = isAligned
          ? AppColors.brassGold
          : (isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.25))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 2.0 : 1.0;

    canvas.drawCircle(Offset(cx, cy), r - 12, ringPaint);
    canvas.drawCircle(Offset(cx, cy), r - 26, ringPaint..strokeWidth = 0.6);

    // Çentikler (Her 15° ve 5°)
    final tickPaint = Paint()
      ..color = isDark ? AppColors.darkMuted.withValues(alpha: 0.5) : AppColors.inkMuted.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 360; i += 5) {
      final rad = (i - 90) * (math.pi / 180.0);
      final isMajor = i % 90 == 0;
      final isMedium = i % 30 == 0;
      final tickLength = isMajor ? 12.0 : (isMedium ? 8.0 : 4.0);

      final outerR = r - 12;
      final innerR = outerR - tickLength;

      final p1 = Offset(cx + outerR * math.cos(rad), cy + outerR * math.sin(rad));
      final p2 = Offset(cx + innerR * math.cos(rad), cy + innerR * math.sin(rad));

      canvas.drawLine(p1, p2, tickPaint);
    }

    // Ana yönler (Kuzey, Doğu, Güney, Batı)
    _drawCardinalText(canvas, cx, cy, r - 38, -math.pi / 2, 'K', AppColors.brassGold);
    _drawCardinalText(canvas, cx, cy, r - 38, 0, 'D', isDark ? AppColors.darkMuted : AppColors.inkMuted);
    _drawCardinalText(canvas, cx, cy, r - 38, math.pi / 2, 'G', isDark ? AppColors.darkMuted : AppColors.inkMuted);
    _drawCardinalText(canvas, cx, cy, r - 38, math.pi, 'B', isDark ? AppColors.darkMuted : AppColors.inkMuted);
  }

  void _drawCardinalText(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    double angle,
    String text,
    Color color,
  ) {
    final x = cx + radius * math.cos(angle);
    final y = cy + radius * math.sin(angle);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.isAligned != isAligned;
  }
}

/// Kâbe yönünü gösteren zarif sivri ibre
class _QiblaPointerPainter extends CustomPainter {
  final bool isAligned;

  const _QiblaPointerPainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final pointerColor = isAligned ? AppColors.brassGold : AppColors.mossGreen;

    final path = Path();
    // İbre tepesi (Kâbe yönü)
    path.moveTo(cx, cy - r + 8);
    // Sol kanat
    path.lineTo(cx - 10, cy - 30);
    // İç bel
    path.lineTo(cx, cy - 24);
    // Sağ kanat
    path.lineTo(cx + 10, cy - 30);
    path.close();

    final paint = Paint()
      ..color = pointerColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Kâbe sembolü / altın rozet
    final kabePaint = Paint()
      ..color = AppColors.brassGold
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx, cy - r + 18), 4.5, kabePaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaPointerPainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
