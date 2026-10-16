import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A second rosary, drawn differently from [RosaryIcon] so the two rosary
/// ribbons are told apart: beads draped in an arc, with a small medal and a
/// cross hanging from the middle.
class DrapedRosaryIcon extends StatelessWidget {
  const DrapedRosaryIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _DrapedRosaryPainter(color)),
    );
  }
}

class _DrapedRosaryPainter extends CustomPainter {
  const _DrapedRosaryPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bead = Paint()..color = color;
    final cord = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    // The draped arc of beads, hanging from both upper corners.
    final arcCentre = Offset(w * 0.5, h * 0.08);
    final arcRadius = w * 0.40;
    const startDegrees = 20.0;
    const sweepDegrees = 140.0;
    canvas.drawArc(
      Rect.fromCircle(center: arcCentre, radius: arcRadius),
      startDegrees * math.pi / 180,
      sweepDegrees * math.pi / 180,
      false,
      cord,
    );
    for (var i = 0; i <= 8; i++) {
      // Leave the lowest point free for the medal.
      if (i == 4) continue;
      final angle = (startDegrees + i * sweepDegrees / 8) * math.pi / 180;
      canvas.drawCircle(
        arcCentre + Offset.fromDirection(angle, arcRadius),
        w * 0.055,
        bead,
      );
    }

    // The medal at the centre of the arc, then a cord down to the cross.
    final medalCentre = Offset(w * 0.5, arcCentre.dy + arcRadius);
    canvas
      ..drawOval(
        Rect.fromCenter(center: medalCentre, width: w * 0.16, height: h * 0.2),
        bead,
      )
      ..drawLine(
        Offset(w * 0.5, medalCentre.dy),
        Offset(w * 0.5, h * 0.72),
        cord,
      );

    // The cross.
    final cross = Paint()
      ..color = color
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(w * 0.5, h * 0.72), Offset(w * 0.5, h * 0.98), cross)
      ..drawLine(Offset(w * 0.4, h * 0.8), Offset(w * 0.6, h * 0.8), cross);
  }

  @override
  bool shouldRepaint(_DrapedRosaryPainter oldDelegate) =>
      oldDelegate.color != color;
}
