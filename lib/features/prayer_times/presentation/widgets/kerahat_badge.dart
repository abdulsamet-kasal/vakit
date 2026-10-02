import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Kerahat vakitleri durumu ve küçük, sakin uyarı etiketi.
enum KerahatType {
  none,
  sunrise,  // Güneş doğarken (~45 dk)
  midday,   // İstiva / Güneş tepedeyken (~40 dk)
  sunset,   // Güneş batarken (~45 dk)
}

class KerahatBadge extends StatelessWidget {
  final KerahatType type;
  final String? customMessage;

  const KerahatBadge({
    super.key,
    required this.type,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (type == KerahatType.none) {
      return const SizedBox.shrink();
    }

    final message = customMessage ?? _getDefaultMessage(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.clayAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.clayAmber.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.clayAmber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: AppTypography.labelSmall(color: AppColors.clayAmber).copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getDefaultMessage(KerahatType type) {
    switch (type) {
      case KerahatType.sunrise:
        return 'Kerahat Vakti (Gündoğumu, yakl. 45 dk)';
      case KerahatType.midday:
        return 'Kerahat Vakti (İstiva, yakl. 40 dk)';
      case KerahatType.sunset:
        return 'Kerahat Vakti (Günbatımı, yakl. 45 dk)';
      case KerahatType.none:
        return '';
    }
  }
}
