import 'package:flutter/material.dart';

/// Active mode of the application's persistent bottom navigation.
///
/// Home mode:
///   Home / Calendar / Cases / Juris / Profile
///
/// Case Section mode:
///   Search / Cases / Case Management / Home
enum NavMode {
  home,
  caseSection,
}

/// Immutable state representing the current navigation configuration.
///
/// This is intentionally small and focused. The controller manages navigation
/// state; individual screens remain responsible for their own screen logic.
@immutable
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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NavState &&
            other.mode == mode &&
            other.currentIndex == currentIndex &&
            other.currentRoute == currentRoute;
  }

  @override
  int get hashCode {
    return Object.hash(
      mode,
      currentIndex,
      currentRoute,
    );
  }

  @override
  String toString() {
    return 'NavState('
        'mode: $mode, '
        'currentIndex: $currentIndex, '
        'currentRoute: $currentRoute'
        ')';
  }
}

/// Global controller for the application's persistent bottom navigation.
///
/// Responsibilities:
/// - Maintains the active navigation mode.
/// - Maintains the active tab index.
/// - Maintains the logical current route.
/// - Coordinates transitions between Home and Case Section modes.
/// - Prevents unnecessary duplicate navigation.
/// - Keeps navigation state independent from the visual navigation widget.
///
/// This controller deliberately does NOT contain screen-specific business
/// logic. Screens remain responsible for their own functionality.
class AppNavController extends ValueNotifier<NavState> {
  AppNavController._()
      : super(
          const NavState(
            mode: NavMode.home,
            currentIndex: 0,
            currentRoute: '/home',
          ),
        );

  /// Single application-wide navigation controller.
  static final AppNavController instance = AppNavController._();

  // ===========================================================================
  // NAVIGATION CONFIGURATION
  // ===========================================================================

  /// Number of tabs in Home mode.
  static const int homeTabCount = 5;

  /// Number of tabs in Case Section mode.
  static const int caseSectionTabCount = 4;

  // ===========================================================================
  // CURRENT STATE
  // ===========================================================================

  NavMode get mode => value.mode;

  int get currentIndex => value.currentIndex;

  String get currentRoute => value.currentRoute;

  // ===========================================================================
  // INTERNAL HELPERS
  // ===========================================================================

  /// Returns the number of tabs available in the supplied navigation mode.
  int _tabCountForMode(NavMode mode) {
    switch (mode) {
      case NavMode.home:
        return homeTabCount;

      case NavMode.caseSection:
        return caseSectionTabCount;
    }
  }

  /// Ensures that a tab index is always valid for its navigation mode.
  int _safeIndex(
    NavMode mode,
    int index,
  ) {
    final int maxIndex = _tabCountForMode(mode) - 1;

    return index.clamp(
      0,
      maxIndex,
    );
  }

  /// Reads the route currently displayed by Flutter's Navigator.
  String? _routeOf(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  /// Updates state only when the new state is actually different.
  void _setState(NavState nextState) {
    if (value == nextState) {
      return;
    }

    value = nextState;
  }

  // ===========================================================================
  // STATE-ONLY UPDATE
  // ===========================================================================

  /// Updates the controller's logical state without performing navigation.
  ///
  /// Use this when a route has already been changed elsewhere and the
  /// navigation controller only needs to synchronize itself with that route.
  void updateState({
    required NavMode mode,
    required int index,
    required String route,
  }) {
    _setState(
      NavState(
        mode: mode,
        currentIndex: _safeIndex(
          mode,
          index,
        ),
        currentRoute: route,
      ),
    );
  }

  // ===========================================================================
  // HOME MODE
  // ===========================================================================

  /// Switches the application to Home navigation mode.
  ///
  /// Home is treated as the root of the primary application navigation
  /// hierarchy. When a real transition to Home is required, the existing
  /// navigation stack is cleared.
  void switchToHome(
    BuildContext context, {
    int index = 0,
    String route = '/home',
  }) {
    const NavMode targetMode = NavMode.home;

    final int safeIndex = _safeIndex(
      targetMode,
      index,
    );

    final String? displayedRoute = _routeOf(context);

    _setState(
      NavState(
        mode: targetMode,
        currentIndex: safeIndex,
        currentRoute: route,
      ),
    );

    // Already on the requested route.
    //
    // We still update controller state above so that the selected tab and
    // navigation mode remain synchronized.
    if (displayedRoute == route) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      route,
      (route) => false,
    );
  }

  // ===========================================================================
  // CASE SECTION MODE
  // ===========================================================================

  /// Switches the application to Case Section navigation mode.
  ///
  /// The Case Section uses its own four-tab navigation structure:
  ///
  /// Search → Cases → Case Management → Home
  ///
  /// Unlike Home mode, this method does not clear the entire navigation stack.
  void switchToCaseSection(
    BuildContext context, {
    int index = 1,
    String route = '/cases',
  }) {
    const NavMode targetMode = NavMode.caseSection;

    final int safeIndex = _safeIndex(
      targetMode,
      index,
    );

    final String? displayedRoute = _routeOf(context);

    _setState(
      NavState(
        mode: targetMode,
        currentIndex: safeIndex,
        currentRoute: route,
      ),
    );

    // Already displaying the requested route.
    if (displayedRoute == route) {
      return;
    }

    Navigator.of(context).pushNamed(route);
  }

  // ===========================================================================
  // SYNCHRONIZATION
  // ===========================================================================

  /// Synchronizes the navigation controller with a route that has already
  /// been reached through another navigation mechanism.
  ///
  /// This performs no Navigator operation.
  void synchronize({
    required NavMode mode,
    required int index,
    required String route,
  }) {
    updateState(
      mode: mode,
      index: index,
      route: route,
    );
  }

  // ===========================================================================
  // RESET
  // ===========================================================================

  /// Resets the controller to the application's initial navigation state.
  ///
  /// This changes controller state only. It does not navigate.
  void reset() {
    const NavState initialState = NavState(
      mode: NavMode.home,
      currentIndex: 0,
      currentRoute: '/home',
    );

    _setState(initialState);
  }
}