import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ================= GOOGLE LOGO =================
///
/// KEEP THIS LOGO FOR GOOGLE SIGN-IN.
/// This implementation is intentionally preserved.

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.40;
    final strokeWidth = size.shortestSide * 0.14;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    Paint arcPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(
      rect,
      -math.pi * 0.9,
      math.pi * 0.6,
      false,
      arcPaint(_red),
    );

    canvas.drawArc(
      rect,
      -math.pi * 0.3,
      math.pi * 0.3,
      false,
      arcPaint(_blue),
    );

    canvas.drawArc(
      rect,
      math.pi * 0.0,
      math.pi * 0.5,
      false,
      arcPaint(_green),
    );

    canvas.drawArc(
      rect,
      math.pi * 0.5,
      math.pi * 0.5,
      false,
      arcPaint(_yellow),
    );

    final barHeight = strokeWidth;
    final barWidth = size.width * 0.35;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          center.dx + barWidth * 0.2,
          center.dy,
        ),
        width: barWidth,
        height: barHeight,
      ),
      Paint()
        ..color = _blue
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(
    covariant _GoogleLogoPainter oldDelegate,
  ) {
    return false;
  }
}

/// ================= LAWYER'S E-DIARY MARK =================
///
/// Modern Legal Editorial mark.
///
/// Concept:
/// - Classical legal architecture
/// - Fountain pen / legal drafting
/// - Partial circular arch
/// - Forest green authority
/// - Restrained antique gold prestige
///
/// Transparent background.
/// No background plate.
/// No glow.
/// No gradients.
/// Suitable for splash, app icon, headers and branding.

class LawFirmMark extends StatelessWidget {
  const LawFirmMark({
    super.key,
    this.width,
    this.gold = const Color(0xFFCCA046),
    this.ink = const Color(0xFF1F3D2B),
  });

  final double? width;
  final Color gold;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _LawFirmMarkPainter(
            gold: gold,
            ink: ink,
          ),
          child:  Semantics(
            label: "Lawyer's E-Diary legal mark",
            image: true,
          ),
        ),
      ),
    );
  }
}

class _LawFirmMarkPainter extends CustomPainter {
  const _LawFirmMarkPainter({
    required this.gold,
    required this.ink,
  });

  final Color gold;
  final Color ink;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final double scale = size.shortestSide / 400;

    canvas.save();

    canvas.translate(
      (size.width - 400 * scale) / 2,
      (size.height - 400 * scale) / 2,
    );

    canvas.scale(scale);

    _paintArch(canvas);
    _paintCapital(canvas);
    _paintColumns(canvas);
    _paintPenNib(canvas);

    canvas.restore();
  }

  // ============================================================
  // PARTIAL CIRCULAR LEGAL ARCH
  // ============================================================

  void _paintArch(Canvas canvas) {
    final Paint paint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    const Rect rect = Rect.fromLTWH(
      55,
      45,
      290,
      290,
    );

    // Open at the bottom.
    canvas.drawArc(
      rect,
      math.pi * 0.18,
      math.pi * 0.64,
      false,
      paint,
    );
  }

  // ============================================================
  // CLASSICAL CAPITAL
  // ============================================================

  void _paintCapital(Canvas canvas) {
    final Paint goldPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Upper thin line.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          105,
          82,
          190,
          10,
        ),
        const Radius.circular(3),
      ),
      goldPaint,
    );

    // Main capital.
    final Path capital = Path()
      ..moveTo(92, 96)
      ..lineTo(308, 96)
      ..lineTo(296, 108)
      ..lineTo(104, 108)
      ..close();

    canvas.drawPath(
      capital,
      goldPaint,
    );
  }

  // ============================================================
  // LEGAL COLUMNS
  // ============================================================

  void _paintColumns(Canvas canvas) {
    final Paint paint = Paint()
      ..color = ink
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Left column.
    _drawColumn(
      canvas,
      paint,
      122,
    );

    // Center column.
    _drawColumn(
      canvas,
      paint,
      174,
    );

    // Right column.
    _drawColumn(
      canvas,
      paint,
      226,
    );

    // Lower architectural base.
    final Path base = Path()
      ..moveTo(106, 247)
      ..lineTo(294, 247)
      ..lineTo(283, 260)
      ..lineTo(117, 260)
      ..close();

    canvas.drawPath(
      base,
      Paint()
        ..color = gold
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  void _drawColumn(
    Canvas canvas,
    Paint paint,
    double x,
  ) {
    // Column shaft.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          113,
          18,
          112,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Small capital detail.
    final Paint goldPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawRect(
      Rect.fromLTWH(
        x - 5,
        109,
        28,
        6,
      ),
      goldPaint,
    );

    // Small base.
    canvas.drawRect(
      Rect.fromLTWH(
        x - 4,
        222,
        26,
        6,
      ),
      goldPaint,
    );
  }

  // ============================================================
  // FOUNTAIN-PEN NIB
  // ============================================================

  void _paintPenNib(Canvas canvas) {
    final Paint goldPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path nib = Path()
      ..moveTo(173, 220)
      ..lineTo(200, 220)
      ..lineTo(200, 292)
      ..lineTo(187, 330)
      ..lineTo(173, 292)
      ..close();

    canvas.drawPath(
      nib,
      goldPaint,
    );

    // Nib interior.
    final Path innerNib = Path()
      ..moveTo(187, 245)
      ..lineTo(194, 263)
      ..lineTo(187, 305)
      ..lineTo(180, 263)
      ..close();

    canvas.drawPath(
      innerNib,
      Paint()
        ..color = ink
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // Central slit.
    final Paint slit = Paint()
      ..color = const Color(0xFFF7F5F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawLine(
      const Offset(187, 260),
      const Offset(187, 312),
      slit,
    );

    // Small gold diamond accent.
    final Path diamond = Path()
      ..moveTo(187, 275)
      ..lineTo(195, 283)
      ..lineTo(187, 291)
      ..lineTo(179, 283)
      ..close();

    canvas.drawPath(
      diamond,
      goldPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _LawFirmMarkPainter oldDelegate,
  ) {
    return oldDelegate.gold != gold ||
        oldDelegate.ink != ink;
  }

  @override
  bool shouldRebuildSemantics(
    covariant _LawFirmMarkPainter oldDelegate,
  ) {
    return false;
  }
}