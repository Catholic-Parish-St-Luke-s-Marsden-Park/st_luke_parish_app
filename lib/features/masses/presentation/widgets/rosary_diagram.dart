import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/rosary_step.dart';

/// A rosary showing progress through the prayers: [path] is every bead
/// prayed so far, in order, ending with the current one. Earlier beads stay
/// lit; the current bead lights up in gold with a brief glow each time it
/// changes (when the user taps Next). Nothing moves on its own. The glow is
/// skipped when the system asks for reduced motion, and in widget tests.
class RosaryDiagram extends StatefulWidget {
  const RosaryDiagram({super.key, required this.path});

  final List<RosaryBeads> path;

  /// Set by `test/flutter_test_config.dart` so tests see the settled state.
  static bool disableForTesting = false;

  @override
  State<RosaryDiagram> createState() => _RosaryDiagramState();
}

class _RosaryDiagramState extends State<RosaryDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    value: 1,
  );

  @override
  void didUpdateWidget(RosaryDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path.length == widget.path.length) return;
    if (RosaryDiagram.disableForTesting ||
        MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indices = [for (final beads in widget.path) _beadIndex(beads)];
    return AspectRatio(
      aspectRatio: 1 / 1.3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _RosaryPainter(
            current: indices.last,
            prayed: indices.take(indices.length - 1).toSet(),
            lightUp: Curves.easeOut.transform(_controller.value),
          ),
        ),
      ),
    );
  }
}

/// Indices into the rosary's beads, as laid out by [_RosaryPainter]:
/// 0 crucifix, 1 first Our Father, 2-4 three Hail Marys (bottom to top),
/// 5 the chain before the next bead, 6 the First Mystery's Our Father,
/// 7 the centrepiece, then the loop from 8: each decade's ten Hail Marys,
/// followed (for the first four decades) by the next Our Father bead; then
/// from 62 the chain point after each decade (for its Glory Be).
const _centrepiece = 7;
const _loopStart = 8;

int _beadIndex(RosaryBeads beads) {
  final d = beads.decade;
  return switch (beads.kind) {
    RosaryBeadKind.crucifix => 0,
    RosaryBeadKind.firstOurFather => 1,
    RosaryBeadKind.introHailMary => 2 + beads.bead,
    RosaryBeadKind.gloryBeforeDecades => 5,
    RosaryBeadKind.decadeOurFather => d == 0 ? 6 : _loopStart + d * 11 - 1,
    RosaryBeadKind.decadeHailMary => _loopStart + d * 11 + beads.bead,
    RosaryBeadKind.afterDecade => 62 + d,
    RosaryBeadKind.centrepiece => _centrepiece,
  };
}

enum _BeadKind { crucifix, large, small, chain, centrepiece }

class _Bead {
  const _Bead(this.position, this.kind);

  final Offset position;
  final _BeadKind kind;
}

class _RosaryPainter extends CustomPainter {
  _RosaryPainter({
    required this.current,
    required this.prayed,
    required this.lightUp,
  });

  final int current;
  final Set<int> prayed;

  /// 0 to 1 as the current bead lights up.
  final double lightUp;

  List<_Bead> _layout(Size size) {
    final w = size.width;
    final centre = Offset(w * 0.5, w * 0.36);
    final radius = w * 0.3;
    final bottom = centre + Offset(0, radius);

    final list = <_Bead>[
      _Bead(bottom + Offset(0, w * 0.48), _BeadKind.crucifix),
      _Bead(bottom + Offset(0, w * 0.32), _BeadKind.large),
      _Bead(bottom + Offset(0, w * 0.25), _BeadKind.small),
      _Bead(bottom + Offset(0, w * 0.20), _BeadKind.small),
      _Bead(bottom + Offset(0, w * 0.15), _BeadKind.small),
      _Bead(bottom + Offset(0, w * 0.115), _BeadKind.chain),
      _Bead(bottom + Offset(0, w * 0.07), _BeadKind.large),
      _Bead(bottom, _BeadKind.centrepiece),
    ];
    // The loop: 54 beads in 56 even slots, leaving room at the bottom for
    // the centrepiece.
    const slots = 56;
    for (var i = 0; i < 54; i++) {
      final angle = math.pi / 2 + (i + 1) * 2 * math.pi / slots;
      final isOurFather = i % 11 == 10;
      list.add(
        _Bead(
          centre + Offset.fromDirection(angle, radius),
          isOurFather ? _BeadKind.large : _BeadKind.small,
        ),
      );
    }
    // The chain just after each decade's last Hail Mary.
    for (var d = 0; d < 5; d++) {
      final slot = d < 4 ? d * 11 + 10.5 : 55.0;
      final angle = math.pi / 2 + slot * 2 * math.pi / slots;
      list.add(
        _Bead(centre + Offset.fromDirection(angle, radius), _BeadKind.chain),
      );
    }
    return list;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final layout = _layout(size);
    final centre = Offset(w * 0.5, w * 0.36);

    final chain = Paint()
      ..color = AppColors.primaryNavy.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.006;
    canvas
      ..drawCircle(centre, w * 0.3, chain)
      ..drawLine(layout[_centrepiece].position, layout[1].position, chain);

    for (final (i, bead) in layout.indexed) {
      final isCurrent = i == current;
      final isPrayed = prayed.contains(i);
      final isLit = isCurrent || isPrayed;
      final colour = isCurrent
          ? Color.lerp(
              AppColors.primaryNavy.withValues(alpha: 0.35),
              AppColors.gold,
              lightUp,
            )!
          : isPrayed
          ? AppColors.gold.withValues(alpha: 0.55)
          : AppColors.primaryNavy.withValues(alpha: 0.35);
      final fill = Paint()..color = colour;

      if (isCurrent) {
        // A burst of glow as the bead lights, settling to a soft halo.
        final burst = 1 - lightUp;
        canvas.drawCircle(
          bead.position,
          w * (0.05 + 0.04 * burst),
          Paint()
            ..color = AppColors.gold.withValues(alpha: 0.3 + 0.25 * burst)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.018),
        );
      }

      switch (bead.kind) {
        case _BeadKind.small:
          canvas.drawCircle(bead.position, w * 0.017, fill);
        case _BeadKind.large:
          canvas.drawCircle(bead.position, w * 0.027, fill);
        case _BeadKind.chain:
          if (isLit) canvas.drawCircle(bead.position, w * 0.014, fill);
        case _BeadKind.centrepiece:
          canvas.drawOval(
            Rect.fromCenter(
              center: bead.position,
              width: w * 0.07,
              height: w * 0.09,
            ),
            fill,
          );
        case _BeadKind.crucifix:
          final cross = Paint()
            ..color = colour
            ..strokeWidth = w * 0.022
            ..strokeCap = StrokeCap.round;
          final p = bead.position;
          canvas
            ..drawLine(p - Offset(0, w * 0.09), p + Offset(0, w * 0.09), cross)
            ..drawLine(
              p + Offset(-w * 0.05, -w * 0.04),
              p + Offset(w * 0.05, -w * 0.04),
              cross,
            );
      }
    }
  }

  @override
  bool shouldRepaint(_RosaryPainter oldDelegate) =>
      oldDelegate.current != current ||
      oldDelegate.lightUp != lightUp ||
      oldDelegate.prayed.length != prayed.length;
}
