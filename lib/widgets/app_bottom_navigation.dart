import 'package:flutter/material.dart';

import 'app_nav_controller.dart';

class _NavItemConfig {
  const _NavItemConfig({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Unified, morphing bottom navigation bar supporting both Home Mode (5 tabs)
/// and Case Section Mode (4 tabs: Search, Cases, Case Management, Home).
/// Includes smooth 200ms sliding gold indicator and zero-flicker transitions.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.mode,
    required this.currentIndex,
    this.onNavigate,
  });

  final NavMode mode;
  final int currentIndex;
  final ValueChanged<String>? onNavigate;

  static const Color navBackground = Color(0xFF13382E);
  static const Color gold = Color(0xFFCCA046);
  static const Color inactiveIcon = Color(0xFF9EABA4);

  static const List<_NavItemConfig> homeTabs = [
    _NavItemConfig(label: 'Home', icon: Icons.home_rounded, route: '/home'),
    _NavItemConfig(label: 'Calendar', icon: Icons.calendar_month_outlined, route: '/calendar'),
    _NavItemConfig(label: 'Cases', icon: Icons.business_center_outlined, route: '/cases'),
    _NavItemConfig(label: 'Juris', icon: Icons.auto_awesome_outlined, route: '/juris'),
    _NavItemConfig(label: 'Profile', icon: Icons.person_outline_rounded, route: '/profile'),
  ];

  static const List<_NavItemConfig> caseTabs = [
    _NavItemConfig(label: 'Search', icon: Icons.search_rounded, route: '/search_cases'),
    _NavItemConfig(label: 'Cases', icon: Icons.business_center_rounded, route: '/cases'),
    _NavItemConfig(label: 'Case Management', icon: Icons.assignment_outlined, route: '/case_management'),
    _NavItemConfig(label: 'Home', icon: Icons.home_rounded, route: '/home'),
  ];

  void _handleTap(BuildContext context, int index, _NavItemConfig item) {
    if (mode == NavMode.home) {
      if (item.route == '/cases') {
        AppNavController.instance.switchToCaseSection(context, index: 1, route: '/cases');
        return;
      }
      if (index == currentIndex) return;
      if (onNavigate != null) {
        onNavigate!(item.route);
      } else {
        Navigator.of(context).pushNamed(item.route);
      }
    } else {
      // Case Section Mode
      if (item.route == '/home') {
        AppNavController.instance.switchToHome(context, index: 0, route: '/home');
        return;
      }
      if (index == currentIndex) return;
      AppNavController.instance.updateState(
        mode: NavMode.caseSection,
        index: index,
        route: item.route,
      );
      if (onNavigate != null) {
        onNavigate!(item.route);
      } else {
        Navigator.of(context).pushNamed(item.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = mode == NavMode.home ? homeTabs : caseTabs;
    final clampedIndex = currentIndex.clamp(0, tabs.length - 1);

    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: navBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Color(0x2A111716),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<NavMode>(mode),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final item = tabs[index];
                final isSelected = index == clampedIndex;

                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: item.label,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleTap(context, index, item),
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: isSelected ? 42 : 36,
                              height: isSelected ? 42 : 36,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? gold.withValues(alpha: 0.16)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: gold.withValues(alpha: 0.4), width: 1.2)
                                    : null,
                              ),
                              child: Icon(
                                item.icon,
                                color: isSelected ? gold : inactiveIcon,
                                size: isSelected ? 23 : 21,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isSelected ? gold : inactiveIcon,
                                fontSize: 9.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
