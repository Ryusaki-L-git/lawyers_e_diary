import 'package:flutter/material.dart';

/// Active mode of the persistent bottom navigation bar.
enum NavMode {
  home,
  caseSection,
}

/// Immutable state holding the active navigation configuration.
class NavState {
  const NavState({
    required this.mode,
    required this.currentIndex,
    required this.currentRoute,
  });

  final NavMode mode;
  final int currentIndex;
  final String currentRoute;

  NavState copyWith({
    NavMode? mode,
    int? currentIndex,
    String? currentRoute,
  }) {
    return NavState(
      mode: mode ?? this.mode,
      currentIndex: currentIndex ?? this.currentIndex,
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

/// Global controller managing bottom navigation mode, animated tab transitions,
/// and morphing state across screens without flickering or rebuild glitches.
class AppNavController extends ValueNotifier<NavState> {
  AppNavController._()
      : super(
          const NavState(
            mode: NavMode.home,
            currentIndex: 0,
            currentRoute: '/home',
          ),
        );

  static final AppNavController instance = AppNavController._();

  void switchToHome(BuildContext context, {int index = 0, String route = '/home'}) {
    value = NavState(
      mode: NavMode.home,
      currentIndex: index,
      currentRoute: route,
    );
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    }
  }

  void switchToCaseSection(BuildContext context, {int index = 1, String route = '/cases'}) {
    value = NavState(
      mode: NavMode.caseSection,
      currentIndex: index,
      currentRoute: route,
    );
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.of(context).pushNamed(route);
    }
  }

  void updateState({required NavMode mode, required int index, required String route}) {
    value = NavState(
      mode: mode,
      currentIndex: index,
      currentRoute: route,
    );
  }
}
