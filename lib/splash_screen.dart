import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ld_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _entryController; // entry staggered
  late final AnimationController _loaderController; // infinite loader + subtle background motion + particles
  late final AnimationController _exitController; // exit animation before navigation

  // Entry animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoPulse; // subtle pulse driven by loader
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loaderFade;

  // Navigation target saved after async work
  String? _nextRoute;

  // Particle seeds (stable across rebuilds)
  final List<double> _particleSeeds = List<double>.generate(5, (i) => (i + 1) * 13.37);

  @override
  void initState() {
    super.initState();

    // ENTRY: staggered, premium easing with overshoot
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScale = Tween<double>(begin: 0.76, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.48, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.36, curve: Curves.easeIn),
      ),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.7), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.36, 0.68, curve: Curves.easeOutBack),
    ));
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.36, 0.68, curve: Curves.easeIn),
      ),
    );

    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.9), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.58, 0.9, curve: Curves.easeOutBack),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.58, 0.9, curve: Curves.easeIn),
      ),
    );

    _loaderFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
      ),
    );

    // LOADER: independent infinite animation for shimmer, background motion, particles
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // subtle logo pulse derived from loader but eased
    _logoPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );

    // EXIT: short fade + scale down + upward drift
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // Start entry animation
    _entryController.forward();

    // Start async startup logic (keeps Firebase + SharedPreferences logic intact)
    _startApp();
  }

  // Keep Firebase + SharedPreferences logic unchanged, but ensure 2s minimum AFTER async completes.
  Future<void> _startApp() async {
    // Run the auth/profile checks first (unchanged logic)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    String routeToPush;
    if (isLoggedIn) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        routeToPush = '/login';
      } else {
        bool profileCompleted = false;
        try {
          final profileSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 10));
          profileCompleted = profileSnapshot.data()?['profileCompleted'] == true;
        } on FirebaseException {
          // keep profileCompleted false on error (same behavior)
        }
        routeToPush = profileCompleted ? '/home' : '/welcome';
      }
    } else {
      routeToPush = '/login';
    }

    // Ensure at least 2 seconds AFTER async work completes
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Save route and run exit animation
    _nextRoute = routeToPush;
    await _playExitAndNavigate();
  }

  Future<void> _playExitAndNavigate() async {
    // Smoothly fade out, scale down, and drift up everything
    try {
      await _exitController.forward().orCancel;
    } catch (_) {
      // ignore if cancelled
    }

    if (!mounted || _nextRoute == null) return;

    Navigator.pushReplacementNamed(context, _nextRoute!);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _loaderController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  // Premium shimmer loader: independent animation (looping)
  Widget _buildShimmerLoader({required double width, required double height}) {
    return FadeTransition(
      opacity: _loaderFade,
      child: SizedBox(
        width: width,
        height: height,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loaderController,
            builder: (context, child) {
              // variable speed factor to avoid perfectly constant motion
              final base = _loaderController.value;
              final speedVariance = 0.5 + 0.5 * math.sin(base * math.pi * 2 * 0.7);
              final t = (base * speedVariance) % 1.0;

              // shimmer center moves left->right->left for a smooth sweep
              final double center = (math.sin(t * math.pi * 2) * 0.5) + 0.5;
              // gradient sweep width (slightly varying)
              final double sweep = 0.18 + 0.04 * math.sin(base * math.pi * 2);

              // spark position along bar (slightly ahead of center)
                final double sparkPos = (center + 0.12 * math.cos(base * math.pi * 2))
                  .clamp(0.0, 1.0)
                  .toDouble();

              return ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: CustomPaint(
                  painter: _ShimmerPainter(
                    center: center,
                    sweep: sweep,
                    sparkPos: sparkPos,
                  ),
                  child: Container(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Animated background with subtle flowing gradient + particles
  BoxDecoration _buildAnimatedBackground() {
    // drift between -0.25 and 0.25
    final double drift = lerpDouble(-0.25, 0.25, _loaderController.value);
    // rotate subtle angle for cinematic flow
    final double angle = math.sin(_loaderController.value * math.pi * 2) * 0.02;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(-0.8 + drift, -1.0),
        end: Alignment(0.8 + drift, 1.0),
        colors: const [
          Color(0xFFFFFBF8), // very light cream
          Color(0xFFF7F2E9), // soft warm beige
          Color(0xFFF5F0E6), // soft beige
        ],
        stops: const [0.0, 0.6, 1.0],
        transform: GradientRotation(angle),
      ),
    );
  }

  // Simple lerp helper
  double lerpDouble(num a, num b, double t) => a + (b - a) * t;

  @override
  Widget build(BuildContext context) {
    // Exit animations: fade out, scale down, and slight upward drift
    final exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    final exitScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );
    final exitDrift = Tween<double>(begin: 0.0, end: -24.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    // Merge controllers to rebuild background & exit transforms efficiently
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_loaderController, _entryController, _exitController]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: _buildAnimatedBackground(),
            child: Stack(
              children: [
                // Particles layer (repaint boundary)
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _ParticlesPainter(
                        progress: _loaderController.value,
                        seeds: _particleSeeds,
                      ),
                    ),
                  ),
                ),

                // Main content with exit transforms
                Opacity(
                  opacity: exitFade.value,
                  child: Transform.translate(
                    offset: Offset(0, exitDrift.value),
                    child: Transform.scale(
                      scale: exitScale.value,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        // Main content passed as child to avoid rebuilding static subtree unnecessarily
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo with scale, fade, subtle rotation, and layered pulsing glow
                FadeTransition(
                  opacity: _logoFade,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_entryController, _loaderController]),
                    builder: (context, _) {
                      // tiny oscillation rotation ±2 degrees
                      final double rot = math.sin(_loaderController.value * math.pi * 2) * (2 * math.pi / 180);
                      // breathing offset for inner glow
                      final double breath = 0.96 + 0.04 * _logoPulse.value;
                      return Transform.rotate(
                        angle: rot,
                        child: Transform.scale(
                          scale: breath * _logoScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer layered glow (very subtle)
                              Container(
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFD4AF37).withValues(alpha: 0.06 + 0.08 * _logoPulse.value),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.04 + 0.06 * _logoPulse.value),
                                      blurRadius: 18 + 8 * _logoPulse.value,
                                      spreadRadius: 0.8,
                                    ),
                                  ],
                                ),
                              ),

                              // Inner subtle halo
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFFF8ED).withValues(alpha: 0.9),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),

                              // Actual logo (must be used)
                              const SizedBox(
                                width: 120,
                                height: 120,
                                child: LawFirmMark(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Title with overshoot settle
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: const Text(
                      "LAWYER'S E-DIARY",
                      style: TextStyle(
                        color: Color(0xFF8B6F00), // deep gold
                        fontSize: 26,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline with slight delay and settle
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: const Text(
                      "Never miss a date",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Loader + subtle divider
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // thin divider with gold accent
                    Container(
                      width: 220,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFFD4AF37).withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Shimmer loader (real-feeling)
                    _buildShimmerLoader(width: 200, height: 7),

                    const SizedBox(height: 22),

                    // micro copy (optional subtle)
                    FadeTransition(
                      opacity: _loaderFade,
                      child: const Text(
                        "Securing your schedule • Encrypted",
                        style: TextStyle(
                          color: Color(0xFF9A7F00),
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for shimmer sweep (gold + cream) with trailing spark
class _ShimmerPainter extends CustomPainter {
  final double center; // 0..1
  final double sweep; // fraction width of highlight
  final double sparkPos; // 0..1

  _ShimmerPainter({
    required this.center,
    required this.sweep,
    required this.sparkPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // base background (subtle cream)
    final basePaint = Paint()..color = const Color(0xFFEFE7D8);
    canvas.drawRect(rect, basePaint);

    // compute stops safely
    final double left = (center - sweep).clamp(0.0, 1.0).toDouble();
    final double right = (center + sweep).clamp(0.0, 1.0).toDouble();

    // gradient for shimmer sweep (soft gold highlight)
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        Color(0xFFEFE7D8), // base cream
        Color(0xFFF7E6B8), // soft gold mid
        Color(0xFFD4AF37), // gold highlight
        Color(0xFFF7F1E6), // light cream
      ],
      stops: [
        left,
        (center - (sweep * 0.35)).clamp(0.0, 1.0).toDouble(),
        center,
        right,
      ],
      tileMode: TileMode.clamp,
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    // draw rounded rect to give premium look
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    canvas.drawRRect(rrect, paint);

    // subtle inner gloss
    final gloss = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..blendMode = BlendMode.srcOver;
    canvas.drawRRect(rrect, gloss);

    // trailing spark: small soft circle with trailing fade
    final sparkX = rect.left + sparkPos * rect.width;
    final sparkY = rect.center.dy;
    final sparkRadius = size.height * 0.9;
    final sparkPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF7E6).withValues(alpha: 0.0),
          const Color(0xFFFFF7E6).withValues(alpha: 0.35),
          const Color(0xFFD4AF37).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.12, 0.28],
      ).createShader(Rect.fromCircle(center: Offset(sparkX, sparkY), radius: sparkRadius));

    canvas.drawCircle(Offset(sparkX, sparkY), sparkRadius * 0.18, sparkPaint);

    // tiny bright core
    final core = Paint()..color = const Color(0xFFFFF8E8).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(sparkX, sparkY), size.height * 0.06, core);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.sweep != sweep ||
        oldDelegate.sparkPos != sparkPos;
  }
}

/// Particles painter for ultra-subtle floating gold dust
class _ParticlesPainter extends CustomPainter {
  final double progress; // 0..1
  final List<double> seeds;

  _ParticlesPainter({required this.progress, required this.seeds});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // For each seed, compute a slow drifting position and draw a tiny circle
    for (int i = 0; i < seeds.length; i++) {
      final double seed = seeds[i];
      // unique phase per particle
      final double phase = (seed % 1.0) + progress;
      // horizontal drift across screen
      final double x = (math.sin((phase + seed * 0.13) * math.pi * 2) * 0.45 + 0.5) * size.width;
      // vertical slow float
      final double y = ((phase * 0.6 + (seed * 0.07)) % 1.0) * size.height;
      // size and opacity vary subtly
      final double radius = 0.8 + (i % 3) * 0.6 + 0.6 * math.sin(progress * math.pi * 2 + seed);
      final double opacity = 0.03 + 0.02 * (i % 3) + 0.02 * math.sin(progress * math.pi * 2 + seed * 1.3);

        paint.color = const Color(0xFFD4AF37)
          .withValues(alpha: opacity.clamp(0.01, 0.12).toDouble());
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
