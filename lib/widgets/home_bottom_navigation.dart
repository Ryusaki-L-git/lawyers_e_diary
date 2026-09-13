import 'package:flutter/material.dart';

import 'app_bottom_navigation.dart';
import 'app_nav_controller.dart';

/// Backward-compatible wrapper that directs to AppBottomNavigation with NavMode.home.
class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<String>? onNavigate;

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigation(
      mode: NavMode.home,
      currentIndex: currentIndex,
      onNavigate: onNavigate,
    );
  }
}
