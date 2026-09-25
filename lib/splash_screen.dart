import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ld_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // MODERN LEGAL EDITORIAL THEME
  // ============================================================

  static const Color _background =
      Color(0xFFF7F5F2);

  static const Color _primaryGreen =
      Color(0xFF1F3D2B);

  static const Color _gold =
      Color(0xFFCCA046);

  static const Color _textDark =
      Color(0xFF1A1A1A);

  static const Color _textMuted =
      Color(0xFF6B665E);

  // ============================================================
  // ANIMATION
  // ============================================================

  late final AnimationController _entryController;
  late final AnimationController _loadingController;
  late final AnimationController _exitController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _contentFade;
  late final Animation<double> _contentOffset;

  String? _nextRoute;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    )..repeat();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 420,
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(
        0.0,
        0.65,
        curve: Curves.easeOut,
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.0,
          0.75,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _contentFade = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(
        0.28,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _contentOffset = Tween<double>(
      begin: 8.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.28,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _entryController.forward();

    _startApp();
  }

  // ============================================================
  // STARTUP
  // ============================================================

  Future<void> _startApp() async {
    final Stopwatch startupTimer =
        Stopwatch()..start();

    final String routeToPush =
        await _determineStartupRoute();

    startupTimer.stop();

    const Duration minimumSplashDuration =
        Duration(seconds: 2);

    if (startupTimer.elapsed <
        minimumSplashDuration) {
      final Duration remainingTime =
          minimumSplashDuration -
              startupTimer.elapsed;

      await Future.delayed(
        remainingTime,
      );
    }

    if (!mounted) return;

    _nextRoute = routeToPush;

    await _playExitAndNavigate();
  }

  // ============================================================
  // STARTUP ROUTING
  // ============================================================

  Future<String> _determineStartupRoute() async {
    try {
      final SharedPreferences prefs =
          await SharedPreferences.getInstance();

      final bool isLoggedIn =
          prefs.getBool('isLoggedIn') ??
              false;

      if (!isLoggedIn) {
        return '/login';
      }

      final User? user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return '/login';
      }

      final DocumentSnapshot<
          Map<String, dynamic>> profileSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(
                const Duration(
                  seconds: 10,
                ),
              );

      final Map<String, dynamic>? profileData =
          profileSnapshot.data();

      final bool profileCompleted =
          profileData?['profileCompleted'] ==
              true;

      if (profileCompleted) {
        return '/home';
      }

      return '/welcome';
    } catch (_) {
      return '/login';
    }
  }

  // ============================================================
  // EXIT
  // ============================================================

  Future<void> _playExitAndNavigate() async {
    if (!mounted) return;

    try {
      await _exitController
          .forward()
          .orCancel;
    } catch (_) {
      return;
    }

    if (!mounted ||
        _nextRoute == null) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      _nextRoute!,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _entryController.dispose();
    _loadingController.dispose();
    _exitController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _entryController,
          _exitController,
        ]),
        builder: (
          context,
          child,
        ) {
          final double exitProgress =
              Curves.easeInOutCubic.transform(
            _exitController.value,
          );

          final double exitOpacity =
              1.0 - exitProgress;

          final double exitScale =
              1.0 -
                  (exitProgress * 0.025);

          final double exitOffset =
              exitProgress * -14.0;

          return Opacity(
            opacity: exitOpacity,
            child: Transform.translate(
              offset: Offset(
                0,
                exitOffset,
              ),
              child: Transform.scale(
                scale: exitScale,
                child: child,
              ),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _EditorialBackground(),

            SafeArea(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      // ==================================================
                      // MARK
                      // ==================================================

                      FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child:
                              const _LogoContainer(),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // ==================================================
                      // WORDMARK
                      // ==================================================

                      FadeTransition(
                        opacity: _contentFade,
                        child: AnimatedBuilder(
                          animation:
                              _contentOffset,
                          builder:
                              (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                _contentOffset
                                    .value,
                              ),
                              child: child,
                            );
                          },
                          child: const Column(
                            children: [
                              Text(
                                "LAWYER'S",
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                      'serif',
                                  color:
                                      _primaryGreen,
                                  fontSize: 27,
                                  fontWeight:
                                      FontWeight.w700,
                                  letterSpacing:
                                      2.0,
                                  height: 1.0,
                                ),
                              ),

                              SizedBox(
                                height: 4,
                              ),

                              Text(
                                'E-DIARY',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  fontFamily:
                                      'serif',
                                  color:
                                      _textDark,
                                  fontSize: 25,
                                  fontWeight:
                                      FontWeight.w600,
                                  letterSpacing:
                                      3.0,
                                  height: 1.0,
                                ),
                              ),

                              SizedBox(
                                height: 18,
                              ),

                              SizedBox(
                                width: 42,
                                child:
                                    Divider(
                                  height: 1,
                                  thickness:
                                      1,
                                  color:
                                      _gold,
                                ),
                              ),

                              SizedBox(
                                height: 17,
                              ),

                              Text(
                                'ORGANISE  •  MANAGE  •  WIN',
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color:
                                      _textMuted,
                                  fontSize: 9.5,
                                  fontWeight:
                                      FontWeight.w600,
                                  letterSpacing:
                                      2.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 46,
                      ),

                      // ==================================================
                      // LOADING
                      // ==================================================

                      FadeTransition(
                        opacity:
                            _contentFade,
                        child:
                            AnimatedBuilder(
                          animation:
                              _loadingController,
                          builder:
                              (
                            context,
                            child,
                          ) {
                            return
                                _GoldLoadingLine(
                              progress:
                                  _loadingController
                                      .value,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // BOTTOM LABEL
            // ============================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: FadeTransition(
                opacity: _contentFade,
                child: const Text(
                  'LEGAL CASE MANAGEMENT',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================
// LOGO CONTAINER
// ========================================================================

class _LogoContainer extends StatelessWidget {
  const _LogoContainer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 132,
      child: Center(
        child: Container(
          width: 116,
          height: 116,
          padding:
              const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color:
                  const Color(0xFFE5DFD7),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color:
                    Color(0x10111716),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const LawFirmMark(
            width: 96,
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// EDITORIAL BACKGROUND
// ========================================================================

class _EditorialBackground
    extends StatelessWidget {
  const _EditorialBackground();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(
        painter:
            _EditorialBackgroundPainter(),
      ),
    );
  }
}

class _EditorialBackgroundPainter
    extends CustomPainter {
  const _EditorialBackgroundPainter();

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Rect bounds =
        Offset.zero & size;

    // Warm paper base.
    canvas.drawRect(
      bounds,
      Paint()
        ..color =
            const Color(0xFFF7F5F2),
    );

    // Extremely subtle warm tonal area.
    final Paint softLight =
        Paint()
          ..shader =
              RadialGradient(
            center:
                const Alignment(
              0,
              -0.25,
            ),
            radius: 0.9,
            colors: const [
              Color(0xFFFFFFFF),
              Color(0x00FFFFFF),
            ],
          ).createShader(bounds);

    canvas.drawRect(
      bounds,
      softLight,
    );

    // Very subtle lower paper depth.
    final Paint lowerTone =
        Paint()
          ..shader =
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: const [
              Color(0x00E9E3DA),
              Color(0x28D9D0C3),
            ],
          ).createShader(bounds);

    canvas.drawRect(
      bounds,
      lowerTone,
    );
  }

  @override
  bool shouldRepaint(
    covariant
        _EditorialBackgroundPainter
        oldDelegate,
  ) {
    return false;
  }
}

// ========================================================================
// GOLD LOADING LINE
// ========================================================================

class _GoldLoadingLine
    extends StatelessWidget {
  const _GoldLoadingLine({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 2,
      child: CustomPaint(
        painter:
            _GoldLoadingPainter(
          progress: progress,
        ),
      ),
    );
  }
}

class _GoldLoadingPainter
    extends CustomPainter {
  const _GoldLoadingPainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint trackPaint =
        Paint()
          ..color =
              const Color(0xFFE1DBD2);

    final double centerY =
        size.height / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          centerY - 0.5,
          size.width,
          1,
        ),
        const Radius.circular(1),
      ),
      trackPaint,
    );

    const double segmentWidth = 42;

    final double start =
        (size.width +
                segmentWidth) *
            progress -
        segmentWidth;

    final Rect segmentRect =
        Rect.fromLTWH(
      start,
      centerY - 0.7,
      segmentWidth,
      1.4,
    );

    final Paint segmentPaint =
        Paint()
          ..shader =
              const LinearGradient(
            colors: [
              Color(0x00CCA046),
              Color(0xFFCCA046),
              Color(0x00CCA046),
            ],
          ).createShader(
            segmentRect,
          );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        segmentRect,
        const Radius.circular(1),
      ),
      segmentPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant
        _GoldLoadingPainter
        oldDelegate,
  ) {
    return oldDelegate.progress !=
        progress;
  }
}