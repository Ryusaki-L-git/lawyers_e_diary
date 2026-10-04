import 'package:flutter/material.dart';

import '../../../widgets/app_palette.dart';

/// Team navigation aligned to the LED Theme Park: warm ivory surfaces,
/// deep green active states, and muted neutral text.
class TeamBottomNavigation extends StatelessWidget {
  const TeamBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isOwnerOrLeader = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isOwnerOrLeader;

  static const Color _barBg = AppPalette.cardBackground;
  static const Color _activeColor = AppPalette.primaryGreen;
  static const Color _inactiveColor = AppPalette.textMuted;

  @override
  Widget build(BuildContext context) {
    final items = isOwnerOrLeader ? _ownerItems : _memberItems;

    return Container(
      decoration: BoxDecoration(
        color: _barBg,
        border: const Border(
          top: BorderSide(color: AppPalette.borderLight, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppPalette.primaryGreen.withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? _activeColor : _inactiveColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? _activeColor : _inactiveColor,
                          letterSpacing: 0.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  static const _memberItems = <_TeamNavItem>[
    _TeamNavItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    _TeamNavItem(
      label: 'Cases',
      icon: Icons.gavel_outlined,
      activeIcon: Icons.gavel_rounded,
    ),
    _TeamNavItem(
      label: 'Chat',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _TeamNavItem(
      label: 'Groups',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
    ),
    _TeamNavItem(
      label: 'Roster',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
    ),
  ];

  static const _ownerItems = <_TeamNavItem>[
    _TeamNavItem(
      label: 'Dashboard',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
    ),
    _TeamNavItem(
      label: 'Docket',
      icon: Icons.gavel_outlined,
      activeIcon: Icons.gavel_rounded,
    ),
    _TeamNavItem(
      label: 'Broadcast',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _TeamNavItem(
      label: 'Groups',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
    ),
    _TeamNavItem(
      label: 'Hub',
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings_rounded,
    ),
  ];
}

class _TeamNavItem {
  const _TeamNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
