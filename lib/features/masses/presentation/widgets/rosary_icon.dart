import 'package:flutter/material.dart';

/// A rosary: a loop of beads with a short drop of beads to a cross. Material
/// Icons has no rosary glyph, so it is painted here at icon size.
class RosaryIcon extends StatelessWidget {
  const RosaryIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _RosaryPainter(color)),
    );
  }
}

class _RosaryPainter extends CustomPainter {
  const _RosaryPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bead = Paint()..color = color;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    // The loop: a thin cord with ten beads on it.
    final loopCentre = Offset(w * 0.5, h * 0.36);
    final loopRadius = w * 0.28;
    canvas.drawCircle(loopCentre, loopRadius, line);
    for (var i = 0; i < 10; i++) {
      // Leave a gap at the bottom, where the drop joins.
      final angle = (90 + 18 + i * 36) * 3.141592653589793 / 180;
      canvas.drawCircle(
        loopCentre + Offset.fromDirection(angle, loopRadius),
        w * 0.06,
        bead,
      );
    }

    // The drop: cord and two beads down to the cross.
    final joinY = loopCentre.dy + loopRadius;
    canvas
      ..drawLine(Offset(w * 0.5, joinY), Offset(w * 0.5, h * 0.80), line)
      ..drawCircle(Offset(w * 0.5, joinY), w * 0.07, bead)
      ..drawCircle(Offset(w * 0.5, h * 0.73), w * 0.06, bead);

    // The cross.
    final cross = Paint()
      ..color = color
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(w * 0.5, h * 0.80), Offset(w * 0.5, h * 0.98), cross)
      ..drawLine(Offset(w * 0.42, h * 0.86), Offset(w * 0.58, h * 0.86), cross);
  }

  @override
  bool shouldRepaint(_RosaryPainter oldDelegate) => oldDelegate.color != color;
}
