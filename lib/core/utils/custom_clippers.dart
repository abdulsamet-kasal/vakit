import 'package:flutter/material.dart';

/// Klasik Selçuklu ve Osmanlı mimarisindeki sivri mihrap kemeri biçimi (CustomClipper).
/// Üstte sivri tepe noktası (apex), yanlarda ogee/kemer kavisleri ve tabana inen dik hatlar.
class MihrapClipper extends CustomClipper<Path> {
  /// Kemerin omuz yüksekliği oranı (üstten aşağıya, örn: 0.35 = kemer yüksekliğin %35'ini kaplar)
  final double archRatio;

  /// Kemer tepesindeki sivrilik keskinliği
  final double pointedness;

  const MihrapClipper({
    this.archRatio = 0.38,
    this.pointedness = 0.55,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final shoulderY = h * archRatio;
    final apexX = w / 2;
    const apexY = 0.0;

    // Alt sol köşeden başla
    path.moveTo(0, h);
    // Sol duvardan sol kemer omzuna çık
    path.lineTo(0, shoulderY);

    // Sol kemer kavisi: omuzdan sivri tepeye doğru ogee eğrisi
    path.cubicTo(
      0,
      shoulderY * (1 - pointedness),
      apexX * 0.45,
      apexY,
      apexX,
      apexY,
    );

    // Sağ kemer kavisi: sivri tepeden sağ omuza simetrik iniş
    path.cubicTo(
      w - (apexX * 0.45),
      apexY,
      w,
      shoulderY * (1 - pointedness),
      w,
      shoulderY,
    );

    // Sağ duvardan alt sağ köşeye in
    path.lineTo(w, h);

    // Tabanı kapat
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant MihrapClipper oldClipper) {
    return oldClipper.archRatio != archRatio || oldClipper.pointedness != pointedness;
  }
}

/// Ters / Kubbe kemeri (üstte düz veya tam yarım kemer gerektiğinde)
class SemiCircleArchClipper extends CustomClipper<Path> {
  const SemiCircleArchClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final r = w / 2;

    path.moveTo(0, h);
    path.lineTo(0, r);
    path.arcToPoint(
      Offset(w, r),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(w, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
