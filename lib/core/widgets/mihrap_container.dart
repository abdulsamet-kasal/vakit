import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/custom_clippers.dart';

/// Mihrap kemeri biçiminde panel container'ı.
/// İsteğe bağlı olarak kemer çevresinde ince pirinç / altın çerçeve çizer.
class MihrapContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double archRatio;

  const MihrapContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor = AppColors.brassGold,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.fromLTRB(20, 36, 20, 20),
    this.archRatio = 0.36,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.darkSurfaceElevated : AppColors.forestGreen);

    final clipper = MihrapClipper(archRatio: archRatio);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        foregroundPainter: _MihrapBorderPainter(
          clipper: clipper,
          borderColor: borderColor.withValues(alpha: 0.5),
          borderWidth: borderWidth,
        ),
        child: ClipPath(
          clipper: clipper,
          child: Container(
            color: bg,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _MihrapBorderPainter extends CustomPainter {
  final MihrapClipper clipper;
  final Color borderColor;
  final double borderWidth;

  const _MihrapBorderPainter({
    required this.clipper,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = clipper.getClip(size);
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(path, paint);

    // İçte daha ince, daha saydam ikinci bir kılcal çizgi (klasik taş işçiliği tezyinatı)
    final innerPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    canvas.save();
    canvas.translate(size.width * 0.015, size.height * 0.015);
    canvas.scale(0.97, 0.97);
    canvas.drawPath(path, innerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MihrapBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
