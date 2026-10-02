import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

/// Alt sekmelerle donatılmış modern mimari ana iskelet (Navigation Shell).
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
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.mossGreen.withValues(alpha: 0.1),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.access_time_rounded,
                  activeIcon: Icons.access_time_filled_rounded,
                  label: 'Vakitler',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onItemTapped(0, context),
                ),
                _NavBarItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Kıble',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onItemTapped(1, context),
                ),
                _NavBarItem(
                  icon: Icons.menu_book_rounded,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Âyet',
                  isSelected: selectedIndex == 2,
                  onTap: () => _onItemTapped(2, context),
                ),
                _NavBarItem(
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'Hadis',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onItemTapped(3, context),
                ),
                _NavBarItem(
                  icon: Icons.tune_rounded,
                  activeIcon: Icons.tune_rounded,
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
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFFF3D079) : const Color(0xFF9E7728);
    final inactiveColor = isDark ? AppColors.darkMuted : AppColors.inkMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.brassGold.withValues(alpha: 0.12) : const Color(0xFFB8934A).withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
