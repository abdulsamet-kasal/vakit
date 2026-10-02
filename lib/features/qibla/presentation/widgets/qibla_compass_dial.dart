import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Ultra modern, lüks saatçilik ve astronomi pusulası kadranı.
/// Pürüzsüz animasyon enterpolasyonu ve zarif kılcal çentik mimarisi.
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
    this.size = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Kadran cihazın heading açısına göre ters yönde döner (Kuzey gerçek coğrafi yönde kalsın)
    final dialAngleRadian = (360.0 - heading) * (math.pi / 180.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: dialAngleRadian, end: dialAngleRadian),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, animatedDialAngle, _) {
        final animatedQiblaAngle = (qiblaBearing * (math.pi / 180.0)) + animatedDialAngle;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.darkSurface : Colors.white.withValues(alpha: 0.85),
            border: Border.all(
              color: isAligned
                  ? AppColors.brassGold
                  : (isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15)),
              width: isAligned ? 2.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isAligned
                    ? AppColors.brassGold.withValues(alpha: 0.35)
                    : (isDark ? Colors.black.withValues(alpha: 0.4) : AppColors.mossGreen.withValues(alpha: 0.08)),
                blurRadius: isAligned ? 32 : 20,
                spreadRadius: isAligned ? 4 : 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Dönen Dış Pusula Kadranı (Modern derece çentikleri ve ana yön harfleri)
              Transform.rotate(
                angle: animatedDialAngle,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _ModernCompassDialPainter(
                    isDark: isDark,
                    isAligned: isAligned,
                  ),
                ),
              ),

              // 2. Kâbe Yönü İbresi (Pürüzsüz sivri ibre ve altın Kâbe rozeti)
              Transform.rotate(
                angle: animatedQiblaAngle,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _ModernQiblaNeedlePainter(
                    isAligned: isAligned,
                  ),
                ),
              ),

              // 3. Merkez Lüks Pirinç Pim (Watchmaker Pin)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isAligned
                        ? [const Color(0xFFF3D079), const Color(0xFF9E7728)]
                        : [
                            isDark ? const Color(0xFF385E4D) : const Color(0xFFD6C8AC),
                            isDark ? const Color(0xFF133526) : const Color(0xFF9E7728),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Ultra rafine İsviçre saatçiliği tarzı kadran çizimi
class _ModernCompassDialPainter extends CustomPainter {
  final bool isDark;
  final bool isAligned;

  const _ModernCompassDialPainter({
    required this.isDark,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // İç referans çemberi
    final innerRingPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.ink).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(Offset(cx, cy), r - 46, innerRingPaint);

    // Çentikler: 360 derece kadranı
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 2) {
      final rad = (i - 90) * (math.pi / 180.0);
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      final isMedium = i % 10 == 0;

      double tickLength;
      double strokeWidth;
      Color tickColor;

      if (isCardinal) {
        tickLength = 14.0;
        strokeWidth = 2.0;
        tickColor = (i == 0) ? const Color(0xFFE24A4A) : (isDark ? Colors.white : AppColors.forestGreen);
      } else if (isMajor) {
        tickLength = 10.0;
        strokeWidth = 1.4;
        tickColor = (isDark ? Colors.white : AppColors.forestGreen).withValues(alpha: 0.7);
      } else if (isMedium) {
        tickLength = 6.0;
        strokeWidth = 1.0;
        tickColor = (isDark ? Colors.white : AppColors.forestGreen).withValues(alpha: 0.35);
      } else {
        tickLength = 3.5;
        strokeWidth = 0.7;
        tickColor = (isDark ? Colors.white : AppColors.forestGreen).withValues(alpha: 0.15);
      }

      tickPaint
        ..color = tickColor
        ..strokeWidth = strokeWidth;

      final outerR = r - 12;
      final innerR = outerR - tickLength;

      final p1 = Offset(cx + outerR * math.cos(rad), cy + outerR * math.sin(rad));
      final p2 = Offset(cx + innerR * math.cos(rad), cy + innerR * math.sin(rad));

      canvas.drawLine(p1, p2, tickPaint);
    }

    // Ana yön harfleri (K, D, G, B) - Modern şık font ve konumlandırma
    _drawCardinal(canvas, cx, cy, r - 32, -math.pi / 2, 'K', const Color(0xFFE24A4A), isBold: true);
    _drawCardinal(canvas, cx, cy, r - 32, 0, 'D', isDark ? const Color(0xFFA9C4B0) : const Color(0xFF4A6B5D));
    _drawCardinal(canvas, cx, cy, r - 32, math.pi / 2, 'G', isDark ? const Color(0xFFA9C4B0) : const Color(0xFF4A6B5D));
    _drawCardinal(canvas, cx, cy, r - 32, math.pi, 'B', isDark ? const Color(0xFFA9C4B0) : const Color(0xFF4A6B5D));
  }

  void _drawCardinal(
    Canvas canvas,
    double cx,
    double cy,
    double radius,
    double angle,
    String text,
    Color color, {
    bool isBold = false,
  }) {
    final x = cx + radius * math.cos(angle);
    final y = cy + radius * math.sin(angle);

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _ModernCompassDialPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.isAligned != isAligned;
  }
}

/// Saf İsviçre iğnesi (Needle) tarzında Kâbe ibresi
class _ModernQiblaNeedlePainter extends CustomPainter {
  final bool isAligned;

  const _ModernQiblaNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Kâbe İbresi Gövdesi (Sivri, modern mimari iğne)
    final needlePath = Path();
    needlePath.moveTo(cx, cy - r + 14); // İğne ucu
    needlePath.lineTo(cx - 7, cy - 16);  // Sol omuz
    needlePath.lineTo(cx, cy - 4);       // Merkez giriş
    needlePath.lineTo(cx + 7, cy - 16);  // Sağ omuz
    needlePath.close();

    final needlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isAligned
            ? [const Color(0xFFFFDF7D), const Color(0xFFB8934A)]
            : [const Color(0xFF4A8B6B), const Color(0xFF1E4A38)],
      ).createShader(Rect.fromLTWH(cx - 7, cy - r + 14, 14, r));

    canvas.drawPath(needlePath, needlePaint);

    // İbrenin altın çizgisi
    final linePaint = Paint()
      ..color = isAligned ? const Color(0xFFFFF6D6) : const Color(0xFFB8934A)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx, cy - r + 16), Offset(cx, cy - 14), linePaint);

    // Kâbe Altın Rozeti (İğne tepesinde parıldayan nokta)
    final rosettePaint = Paint()
      ..color = const Color(0xFFB8934A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - r + 24), 4.0, rosettePaint);

    // İğnenin karşı denge kuyruğu (Modern minimal karşıt uç)
    final tailPath = Path();
    tailPath.moveTo(cx, cy + 34);
    tailPath.lineTo(cx - 4, cy + 12);
    tailPath.lineTo(cx + 4, cy + 12);
    tailPath.close();

    final tailPaint = Paint()
      ..color = (isAligned ? const Color(0xFFB8934A) : Colors.grey).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(tailPath, tailPaint);
  }

  @override
  bool shouldRepaint(covariant _ModernQiblaNeedlePainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
