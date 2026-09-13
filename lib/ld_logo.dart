import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ================= GOOGLE LOGO =================

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24});

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

    final rect = Rect.fromCircle(center: center, radius: radius);

    Paint arcPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawArc(rect, -math.pi * 0.9, math.pi * 0.6, false, arcPaint(_red));
    canvas.drawArc(rect, -math.pi * 0.3, math.pi * 0.3, false, arcPaint(_blue));
    canvas.drawArc(rect, math.pi * 0.0, math.pi * 0.5, false, arcPaint(_green));
    canvas.drawArc(rect, math.pi * 0.5, math.pi * 0.5, false, arcPaint(_yellow));

    final barHeight = strokeWidth;
    final barWidth = size.width * 0.35;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + barWidth * 0.2, center.dy),
        width: barWidth,
        height: barHeight,
      ),
      Paint()
        ..color = _blue
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ================= LAW FIRM LOGO =================

/// A transparent, scalable LD legal mark.
///
/// The painter never draws a canvas background, so it can sit over any color,
/// image, or gradient supplied by the app that uses it.
class LawFirmMark extends StatelessWidget {
  const LawFirmMark({
    super.key,
    this.width,
    this.gold = const Color(0xFFC79435),
    this.ink = const Color(0xFF39241B),
  });

  /// Leave null to let the parent constrain the mark. Its native ratio is 5:4.
  final double? width;
  final Color gold;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 5 / 4,
        child: CustomPaint(
          painter: _LawFirmMarkPainter(gold: gold, ink: ink),
          child:  Semantics(
            label: 'LD legal services logo',
            image: true,
          ),
        ),
      ),
    );
  }
}

class _LawFirmMarkPainter extends CustomPainter {
  const _LawFirmMarkPainter({required this.gold, required this.ink});

  final Color gold;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 700;
    canvas.save();
    canvas.scale(scale, scale);

    _paintD(canvas);
    _paintL(canvas);
    _paintScales(canvas);
    _paintBook(canvas);

    canvas.restore();
  }

  Paint _paintFor(Color color) => Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color.lerp(color, Colors.white, .16)!,
        color,
        Color.lerp(color, Colors.black, .14)!,
      ],
      stops: const <double>[0, .52, 1],
    ).createShader(const Rect.fromLTWH(0, 0, 700, 560));

  void _paintD(Canvas canvas) {
    final d = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(245, 80)
      ..lineTo(385, 80)
      ..cubicTo(552, 80, 650, 169, 650, 300)
      ..cubicTo(650, 431, 552, 520, 385, 520)
      ..lineTo(245, 520)
      ..close()
      ..moveTo(331, 110)
      ..lineTo(383, 110)
      ..cubicTo(502, 110, 575, 181, 575, 300)
      ..cubicTo(575, 419, 502, 490, 383, 490)
      ..lineTo(331, 490)
      ..close();
    canvas.drawPath(d, _paintFor(gold));
  }

  void _paintL(Canvas canvas) {
    final l = Path()
      ..moveTo(47, 80)
      ..lineTo(189, 80)
      ..quadraticBezierTo(194, 82, 189, 86)
      ..cubicTo(163, 89, 151, 103, 151, 142)
      ..lineTo(151, 451)
      ..cubicTo(151, 474, 162, 486, 188, 486)
      ..lineTo(248, 486)
      ..cubicTo(305, 486, 328, 466, 346, 427)
      ..quadraticBezierTo(352, 411, 369, 403)
      ..lineTo(412, 403)
      ..cubicTo(400, 474, 354, 521, 273, 523)
      ..lineTo(47, 523)
      ..quadraticBezierTo(42, 519, 48, 515)
      ..cubicTo(72, 510, 86, 492, 86, 455)
      ..lineTo(86, 143)
      ..cubicTo(86, 103, 73, 89, 48, 86)
      ..quadraticBezierTo(42, 82, 47, 80)
      ..close();
    canvas.drawPath(l, _paintFor(ink));
  }

  void _paintScales(Canvas canvas) {
    final fill = _paintFor(gold);
    final stroke = Paint()
      ..color = gold
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(const Offset(442, 231), 6, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(437, 242, 10, 113),
        const Radius.circular(5),
      ),
      fill,
    );
    canvas.drawCircle(const Offset(442, 251), 9, fill);
    canvas.drawLine(const Offset(380, 253), const Offset(504, 253), stroke);
    canvas.drawCircle(const Offset(380, 253), 6, fill);
    canvas.drawCircle(const Offset(504, 253), 6, fill);

    _paintPan(canvas, const Offset(380, 253), fill, stroke);
    _paintPan(canvas, const Offset(504, 253), fill, stroke);

    final base = Path()
      ..moveTo(434, 354)
      ..quadraticBezierTo(442, 344, 450, 354)
      ..lineTo(458, 360)
      ..quadraticBezierTo(461, 365, 455, 365)
      ..lineTo(429, 365)
      ..quadraticBezierTo(423, 365, 426, 360)
      ..close();
    canvas.drawPath(base, fill);
  }

  void _paintPan(Canvas canvas, Offset pivot, Paint fill, Paint stroke) {
    final left = Offset(pivot.dx - 26, 326);
    final right = Offset(pivot.dx + 26, 326);
    canvas.drawLine(pivot, left, stroke);
    canvas.drawLine(pivot, right, stroke);

    final pan = Path()
      ..moveTo(pivot.dx - 30, 326)
      ..quadraticBezierTo(pivot.dx, 354, pivot.dx + 30, 326)
      ..lineTo(pivot.dx + 26, 326)
      ..quadraticBezierTo(pivot.dx, 340, pivot.dx - 26, 326)
      ..close();
    canvas.drawPath(pan, fill);
  }

  void _paintBook(Canvas canvas) {
    final dark = _paintFor(ink);
    final bright = _paintFor(gold);

    final pages = Path()
      ..moveTo(354, 374)
      ..quadraticBezierTo(400, 369, 442, 397)
      ..quadraticBezierTo(484, 369, 530, 374)
      ..lineTo(535, 381)
      ..quadraticBezierTo(487, 376, 442, 405)
      ..quadraticBezierTo(397, 376, 349, 381)
      ..close();
    canvas.drawPath(pages, bright);

    final book = Path()
      ..moveTo(356, 383)
      ..quadraticBezierTo(400, 378, 441, 403)
      ..quadraticBezierTo(482, 378, 528, 383)
      ..lineTo(533, 395)
      ..quadraticBezierTo(483, 389, 442, 414)
      ..quadraticBezierTo(401, 389, 351, 395)
      ..close();
    canvas.drawPath(book, dark);

    final pageHighlight = Path()
      ..moveTo(362, 388)
      ..quadraticBezierTo(401, 384, 440, 407)
      ..quadraticBezierTo(479, 384, 522, 388)
      ..lineTo(518, 391)
      ..quadraticBezierTo(480, 387, 442, 409)
      ..quadraticBezierTo(404, 387, 366, 391)
      ..close();
    canvas.drawPath(pageHighlight, _paintFor(const Color(0xFFF7E4AE)));
  }

  @override
  bool shouldRepaint(covariant _LawFirmMarkPainter oldDelegate) =>
      oldDelegate.gold != gold || oldDelegate.ink != ink;

  @override
  bool shouldRebuildSemantics(covariant _LawFirmMarkPainter oldDelegate) =>
      false;
}