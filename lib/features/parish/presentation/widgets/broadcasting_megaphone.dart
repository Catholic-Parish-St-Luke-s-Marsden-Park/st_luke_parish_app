import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A megaphone with sound waves rippling out of its mouth, fading as they
/// travel, on a loop, so the announcement button looks "live" (parish
/// request, 2026-10-16). The waves hold still when the system asks for
/// reduced motion, and in widget tests.
class BroadcastingMegaphone extends StatefulWidget {
  const BroadcastingMegaphone({super.key, required this.color, this.size = 30});

  final Color color;
  final double size;

  /// Set by `test/flutter_test_config.dart`: an endlessly repeating
  /// animation would stop `pumpAndSettle()` from ever settling.
  static bool disableForTesting = false;

  @override
  State<BroadcastingMegaphone> createState() => _BroadcastingMegaphoneState();
}

class _BroadcastingMegaphoneState extends State<BroadcastingMegaphone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still =
        BroadcastingMegaphone.disableForTesting ||
        MediaQuery.of(context).disableAnimations;
    if (still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _MegaphonePainter(
            color: widget.color,
            // Still: show the waves part-way out, like the static icon.
            phase: _controller.isAnimating ? _controller.value : 0.5,
          ),
        ),
      ),
    );
  }
}

class _MegaphonePainter extends CustomPainter {
  const _MegaphonePainter({required this.color, required this.phase});

  final Color color;

  /// 0 to 1 through one wave cycle.
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color;

    // The megaphone, pointing right: a handle block, then a flaring horn.
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.06, h * 0.38, w * 0.16, h * 0.24),
      Radius.circular(w * 0.03),
    );
    final horn = Path()
      ..moveTo(w * 0.2, h * 0.38)
      ..lineTo(w * 0.52, h * 0.16)
      ..quadraticBezierTo(w * 0.57, h * 0.5, w * 0.52, h * 0.84)
      ..lineTo(w * 0.2, h * 0.62)
      ..close();
    final grip = Path()
      ..moveTo(w * 0.17, h * 0.62)
      ..lineTo(w * 0.27, h * 0.62)
      ..lineTo(w * 0.31, h * 0.82)
      ..lineTo(w * 0.22, h * 0.82)
      ..close();
    canvas
      ..drawRRect(body, fill)
      ..drawPath(horn, fill)
      ..drawPath(grip, fill);

    // Three sound waves travelling out from the horn's mouth, each fading
    // as it goes, staggered so one is always on its way.
    final mouth = Offset(w * 0.5, h * 0.5);
    for (var i = 0; i < 3; i++) {
      final t = (phase + i / 3) % 1;
      final radius = w * (0.14 + 0.34 * t);
      final opacity = (1 - t).clamp(0.0, 1.0);
      final wave = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: mouth, radius: radius),
        -math.pi / 4,
        math.pi / 2,
        false,
        wave,
      );
    }
  }

  @override
  bool shouldRepaint(_MegaphonePainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}
