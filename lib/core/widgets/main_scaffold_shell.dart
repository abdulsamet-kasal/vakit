import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Alt sekmelerle donatılmış ana iskelet (Navigation Shell).
/// Kullanıcı girişi gerektirmeyen, doğrudan erişilebilir 5 temel bölüm.
class MainScaffoldShell extends StatelessWidget {
  final Widget child;

  const MainScaffoldShell({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/kible')) return 1;
    if (location.startsWith('/ayet')) return 2;
    if (location.startsWith('/hadis')) return 3;
    if (location.startsWith('/ayarlar')) return 4;
    return 0; // /vakitler
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/vakitler');
        break;
      case 1:
        context.go('/kible');
        break;
      case 2:
        context.go('/ayet');
        break;
      case 3:
        context.go('/hadis');
        break;
      case 4:
        context.go('/ayarlar');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.parchment,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.15),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.access_time_rounded,
                  label: 'Vakitler',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onItemTapped(0, context),
                ),
                _NavBarItem(
                  icon: Icons.explore_outlined,
                  label: 'Kıble',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onItemTapped(1, context),
                ),
                _NavBarItem(
                  icon: Icons.menu_book_rounded,
                  label: 'Âyet',
                  isSelected: selectedIndex == 2,
                  onTap: () => _onItemTapped(2, context),
                ),
                _NavBarItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'Hadis',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onItemTapped(3, context),
                ),
                _NavBarItem(
                  icon: Icons.tune_rounded,
                  label: 'Ayarlar',
                  isSelected: selectedIndex == 4,
                  onTap: () => _onItemTapped(4, context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.brassGold;
    final inactiveColor = isDark ? AppColors.darkMuted : AppColors.inkMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.labelSmall(
                color: isSelected ? activeColor : inactiveColor,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
