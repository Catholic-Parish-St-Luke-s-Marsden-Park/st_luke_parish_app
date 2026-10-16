import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Material megaphone with its sound lines shooting out of its mouth in
/// bursts, so the announcement button looks "live" (parish request,
/// 2026-10-16). The lines hold still when the system asks for reduced
/// motion, and in widget tests.
class BroadcastingMegaphone extends StatefulWidget {
  const BroadcastingMegaphone({super.key, required this.color, this.size = 32});

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
    final size = widget.size;
    return SizedBox.square(
      dimension: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Stack(
          children: [
            // The Material megaphone, with its own static lines clipped off.
            ClipRect(
              clipper: const _MegaphoneOnly(),
              child: Icon(
                Icons.campaign_rounded,
                size: size,
                color: widget.color,
              ),
            ),
            CustomPaint(
              size: Size.square(size),
              painter: _SoundLinesPainter(
                color: widget.color,
                // Still: the lines rest just outside the mouth.
                phase: _controller.isAnimating ? _controller.value : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Keeps the megaphone body of [Icons.campaign_rounded] (the left ~71% of
/// the glyph) and drops its drawn sound lines.
class _MegaphoneOnly extends CustomClipper<Rect> {
  const _MegaphoneOnly();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * 0.71, size.height);

  @override
  bool shouldReclip(_MegaphoneOnly oldClipper) => false;
}

/// Three short lines (up, straight and down) that shoot out from the
/// megaphone's mouth and fade, then a pause before the next burst.
class _SoundLinesPainter extends CustomPainter {
  const _SoundLinesPainter({required this.color, required this.phase});

  final Color color;

  /// 0 to 1 through one burst cycle; `null` draws them at rest.
  final double? phase;

  /// The part of each cycle spent moving; the rest is a pause.
  static const _burst = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final double progress;
    final double opacity;
    if (phase case final t?) {
      if (t > _burst) return; // The pause between bursts.
      progress = Curves.easeOut.transform(t / _burst);
      opacity = 1 - progress;
    } else {
      progress = 0.15;
      opacity = 1;
    }

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round;
    // Where the lines start: just outside the horn's mouth.
    final origin = Offset(w * 0.68, size.height * 0.5);
    final start = w * (0.07 + 0.2 * progress);
    final length = w * 0.12;
    for (final degrees in const [-35.0, 0.0, 35.0]) {
      final direction = Offset.fromDirection(degrees * math.pi / 180);
      canvas.drawLine(
        origin + direction * start,
        origin + direction * (start + length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SoundLinesPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.color != color;
}
