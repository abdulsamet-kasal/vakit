import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Vakit uygulaması özel tema tanımları.
/// Jenerik Material 3 tohum rengi veya AI şablonları kullanılmaz.
/// Koyu ve açık tema paleti el yazması mushaf ve cami mermeri hissini korur.
abstract final class AppTheme {
  // --- AÇIK TEMA ---
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.forestGreen,
      onPrimary: AppColors.parchment,
      primaryContainer: AppColors.mossGreen,
      onPrimaryContainer: AppColors.parchment,
      secondary: AppColors.brassGold,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.sageGreen.withValues(alpha: 0.35),
      onSecondaryContainer: AppColors.forestGreen,
      tertiary: AppColors.clayAmber,
      onTertiary: Colors.white,
      surface: AppColors.parchment,
      onSurface: AppColors.ink,
      surfaceContainerHighest: AppColors.paleSage,
      outline: AppColors.mossGreen.withValues(alpha: 0.2),
      outlineVariant: AppColors.mossGreen.withValues(alpha: 0.1),
      error: const Color(0xFF9E2A2B),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.parchment,
      cardTheme: CardThemeData(
        color: AppColors.paleSage.withValues(alpha: 0.7),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.mossGreen.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.mossGreen.withValues(alpha: 0.12),
        thickness: 0.8,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMedium(color: AppColors.ink),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
    );
  }

  // --- KOYU TEMA ---
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.sageGreen,
      onPrimary: AppColors.darkBg,
      primaryContainer: AppColors.mossGreen,
      onPrimaryContainer: AppColors.darkText,
      secondary: AppColors.brassGold,
      onSecondary: AppColors.darkBg,
      secondaryContainer: AppColors.darkSurfaceElevated,
      onSecondaryContainer: AppColors.darkText,
      tertiary: AppColors.clayAmber,
      onTertiary: AppColors.darkBg,
      surface: AppColors.darkBg,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurface,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder.withValues(alpha: 0.5),
      error: const Color(0xFFC05252),
      onError: AppColors.darkBg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.8,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMedium(color: AppColors.darkText),
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
    );
  }
}
