
import 'package:flutter/material.dart';

import 'app_nav_controller.dart';

class NavItemConfig {
  const NavItemConfig({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Unified premium bottom navigation bar supporting both:
/// - Home Mode: Home, Calendar, Cases, Juris, Profile
/// - Case Section Mode: Search, Cases, Case Management, Home
///
/// Navigation behavior is preserved while the visual system uses a restrained
/// premium treatment with a subtle active indicator and smooth transitions.
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

  // ---------------------------------------------------------------------------
  // Navigation palette
  // ---------------------------------------------------------------------------

  static const Color navBackground = Color(0xFF111916);
  static const Color navSurface = Color(0xFF17211D);

  static const Color gold = Color(0xFFD1AD5A);
  static const Color goldSoft = Color(0x66D1AD5A);

  static const Color activeText = Color(0xFFF0E7D2);
  static const Color inactiveIcon = Color(0xFF8E9893);
  static const Color inactiveText = Color(0xFF8E9893);

  // ---------------------------------------------------------------------------
  // Home Mode
  // ---------------------------------------------------------------------------

  static const List<NavItemConfig> homeTabs = [
    NavItemConfig(
      label: 'Home',
      icon: Icons.home_rounded,
      route: '/home',
    ),
    NavItemConfig(
      label: 'Calendar',
      icon: Icons.calendar_month_outlined,
      route: '/calendar',
    ),
    NavItemConfig(
      label: 'Cases',
      icon: Icons.business_center_outlined,
      route: '/cases',
    ),
    NavItemConfig(
      label: 'Juris',
      icon: Icons.auto_awesome_outlined,
      route: '/juris',
    ),
    NavItemConfig(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      route: '/profile',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Case Section Mode
  // ---------------------------------------------------------------------------

  static const List<NavItemConfig> caseTabs = [
    NavItemConfig(
      label: 'Search',
      icon: Icons.search_rounded,
      route: '/search_cases',
    ),
    NavItemConfig(
      label: 'Cases',
      icon: Icons.business_center_rounded,
      route: '/cases',
    ),
    NavItemConfig(
      label: 'Case Management',
      icon: Icons.assignment_outlined,
      route: '/case_management',
    ),
    NavItemConfig(
      label: 'Home',
      icon: Icons.home_rounded,
      route: '/home',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _handleTap(
    BuildContext context,
    int index,
    NavItemConfig item,
  ) {
    // Preserve parent-controlled navigation behavior.
    if (onNavigate != null) {
      onNavigate!(item.route);
      return;
    }

    if (mode == NavMode.home) {
      // Cases is the entry point into Case Section Mode.
      if (item.route == '/cases') {
        AppNavController.instance.switchToCaseSection(
          context,
          index: 1,
          route: '/cases',
        );
        return;
      }

      // Do nothing when the currently selected tab is tapped.
      if (index == currentIndex) return;

      Navigator.of(context).pushNamed(item.route);
      return;
    }

    // -------------------------------------------------------------------------
    // Case Section Mode
    // -------------------------------------------------------------------------

    // Home exits Case Section Mode and restores Home Mode.
    if (item.route == '/home') {
      AppNavController.instance.switchToHome(
        context,
        index: 0,
        route: '/home',
      );
      return;
    }

    // Do nothing when the currently selected tab is tapped.
    if (index == currentIndex) return;

    AppNavController.instance.updateState(
      mode: NavMode.caseSection,
      index: index,
      route: item.route,
    );

    Navigator.of(context).pushNamed(item.route);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final List<NavItemConfig> tabs =
        mode == NavMode.home ? homeTabs : caseTabs;

    final int clampedIndex =
        currentIndex.clamp(0, tabs.length - 1);

    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        decoration: const BoxDecoration(
          color: navBackground,
          border: Border(
            top: BorderSide(
              color: Color(0x261F2B26),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40101815),
              blurRadius: 22,
              offset: Offset(0, -6),
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
              children: List.generate(
                tabs.length,
                (index) {
                  final NavItemConfig item = tabs[index];
                  final bool isSelected =
                      index == clampedIndex;

                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label: item.label,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              _handleTap(context, index, item),
                          splashColor:
                              gold.withValues(alpha: 0.06),
                          highlightColor:
                              gold.withValues(alpha: 0.03),
                          child: _NavigationItem(
                            item: item,
                            isSelected: isSelected,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Navigation Item
// =============================================================================

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.item,
    required this.isSelected,
  });

  final NavItemConfig item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // -------------------------------------------------------------------
          // Active vertical indicator
          // -------------------------------------------------------------------
          Positioned(
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: isSelected ? 28 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppBottomNavigation.gold
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppBottomNavigation.gold
                              .withValues(alpha: 0.20),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // Icon + label
          // -------------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppBottomNavigation.navSurface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: AppBottomNavigation.goldSoft,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: Icon(
                        item.icon,
                        key: ValueKey<bool>(isSelected),
                        size: isSelected ? 22 : 21,
                        color: isSelected
                            ? AppBottomNavigation.gold
                            : AppBottomNavigation.inactiveIcon,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: isSelected
                        ? AppBottomNavigation.activeText
                        : AppBottomNavigation.inactiveText,
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    letterSpacing: 0,
                    height: 1,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

