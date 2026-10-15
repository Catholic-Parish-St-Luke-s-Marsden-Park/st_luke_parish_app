import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A gold chalice with the host and rays of light above it, the
/// traditional symbol of the Eucharist (parish request, 2026-10-16).
/// Material Icons has no such glyph, so it is painted here, as a solid
/// shape so it reads clearly at icon size.
class MassSymbolIcon extends StatelessWidget {
  const MassSymbolIcon({super.key, required this.color, this.size = 24});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _MassSymbolPainter(color)),
    );
  }
}

class _MassSymbolPainter extends CustomPainter {
  const _MassSymbolPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color;
    final ray = Paint()
      ..color = color
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;

    // A layer, so the cross can be cut out of the host.
    canvas.saveLayer(Offset.zero & size, Paint());

    // The host, marked with a cross, with rays of light around it.
    final host = Offset(w * 0.5, h * 0.23);
    canvas.drawCircle(host, w * 0.17, fill);
    final cut = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(host.translate(0, -h * 0.09), host.translate(0, h * 0.09), cut)
      ..drawLine(
        host.translate(-w * 0.09, 0),
        host.translate(w * 0.09, 0),
        cut,
      );
    for (final degrees in [-90, -50, -130, -15, -165]) {
      final direction = Offset.fromDirection(degrees * math.pi / 180);
      canvas.drawLine(
        host + direction.scale(w * 0.23, h * 0.23),
        host + direction.scale(w * 0.31, h * 0.31),
        ray,
      );
    }

    // The chalice: bowl, stem with a knop, and a flared foot.
    final bowl = Path()
      ..moveTo(w * 0.20, h * 0.45)
      ..lineTo(w * 0.80, h * 0.45)
      ..quadraticBezierTo(w * 0.78, h * 0.65, w * 0.5, h * 0.68)
      ..quadraticBezierTo(w * 0.22, h * 0.65, w * 0.20, h * 0.45)
      ..close();
    final foot = Path()
      ..moveTo(w * 0.45, h * 0.66)
      ..lineTo(w * 0.55, h * 0.66)
      ..lineTo(w * 0.55, h * 0.84)
      ..quadraticBezierTo(w * 0.60, h * 0.91, w * 0.75, h * 0.92)
      ..lineTo(w * 0.75, h * 0.98)
      ..lineTo(w * 0.25, h * 0.98)
      ..lineTo(w * 0.25, h * 0.92)
      ..quadraticBezierTo(w * 0.40, h * 0.91, w * 0.45, h * 0.84)
      ..close();
    canvas
      ..drawPath(bowl, fill)
      ..drawPath(foot, fill)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.76),
          width: w * 0.22,
          height: h * 0.08,
        ),
        fill,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_MassSymbolPainter oldDelegate) =>
      oldDelegate.color != color;
}
