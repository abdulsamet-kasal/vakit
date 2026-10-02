import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografi hiyerarşisi:
/// - Saat ve başlıklar: [Newsreader] (zarif, edebi serif)
/// - Gövde metinleri: [SourceSans3] (okunabilir, humanist sans-serif)
/// - Arapça metinler: [Amiri] (hat estetiğine sahip Naskh yazı tipi)
/// Geri sayımlarda ve saatlerde zıplamayı önlemek için [FontFeature.tabularFigures()] uygulanır.
abstract final class AppTypography {
  // --- Başlıklar & Saat Rakamları (Newsreader) ---
  static TextStyle displayLarge({Color? color}) {
    return GoogleFonts.newsreader(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle displayMedium({Color? color}) {
    return GoogleFonts.newsreader(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.3,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle countdownTime({Color? color}) {
    return GoogleFonts.newsreader(
      fontSize: 42,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle headlineLarge({Color? color}) {
    return GoogleFonts.newsreader(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color,
    );
  }

  static TextStyle headlineMedium({Color? color}) {
    return GoogleFonts.newsreader(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle prayerTimeDigits({Color? color, bool isActive = false}) {
    return GoogleFonts.newsreader(
      fontSize: 20,
      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      letterSpacing: 0.5,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // --- Gövde Metinleri (Source Sans 3) ---
  static TextStyle bodyLarge({Color? color}) {
    return GoogleFonts.sourceSans3(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return GoogleFonts.sourceSans3(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: 0.1,
      color: color,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return GoogleFonts.sourceSans3(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.2,
      color: color,
    );
  }

  static TextStyle labelLarge({Color? color, bool isBold = false}) {
    return GoogleFonts.sourceSans3(
      fontSize: 14,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
      letterSpacing: 0.5,
      color: color,
    );
  }

  static TextStyle labelSmall({Color? color}) {
    return GoogleFonts.sourceSans3(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      color: color,
    );
  }

  // --- Arapça Metinler (Amiri) ---
  static TextStyle arabicAyah({Color? color}) {
    return GoogleFonts.amiri(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      height: 2.0, // Bol satır aralığı
      letterSpacing: 0,
      color: color,
    );
  }

  static TextStyle arabicShort({Color? color}) {
    return GoogleFonts.amiri(
      fontSize: 20,
      fontWeight: FontWeight.w400,
      height: 1.8,
      letterSpacing: 0,
      color: color,
    );
  }
}
