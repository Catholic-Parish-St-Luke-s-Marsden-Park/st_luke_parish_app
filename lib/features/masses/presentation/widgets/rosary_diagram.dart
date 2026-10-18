import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/rosary_step.dart';

/// An animated rosary: the beads for [beads] light up in gold, with the
/// decades already prayed shown lightly. Where a step
/// counts several beads (three or ten Hail Marys), they light one after
/// another, as if being prayed; single beads glow gently. Everything holds
/// still when the system asks for reduced motion, and in widget tests.
class RosaryDiagram extends StatefulWidget {
  const RosaryDiagram({super.key, required this.beads});

  final RosaryBeads beads;

  /// Set by `test/flutter_test_config.dart`: an endlessly repeating
  /// animation would stop `pumpAndSettle()` from ever settling.
  static bool disableForTesting = false;

  @override
  State<RosaryDiagram> createState() => _RosaryDiagramState();
}

class _RosaryDiagramState extends State<RosaryDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  bool get _still =>
      RosaryDiagram.disableForTesting ||
      MediaQuery.of(context).disableAnimations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void didUpdateWidget(RosaryDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beads.kind != widget.beads.kind ||
        oldWidget.beads.decade != widget.beads.decade) {
      _restart();
    }
  }

  /// Starts this step's animation from the beginning: a count through the
  /// beads (0.6s each, then a pause), or a slow glow for a single bead.
  void _restart() {
    if (_still) {
      _controller.stop();
      return;
    }
    final count = _beadsFor(widget.beads).sequence.length;
    _controller
      ..duration = Duration(milliseconds: count > 1 ? 600 * (count + 2) : 1600)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1.3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _RosaryPainter(
            beads: _beadsFor(widget.beads),
            phase: _controller.isAnimating ? _controller.value : null,
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
const _crucifix = 0;
const _centrepiece = 7;
const _loopStart = 8;

int _decadeBead(int decade, int bead) => _loopStart + decade * 11 + bead;
int _ourFatherAfter(int decade) => _loopStart + decade * 11 + 10;
int _chainAfter(int decade) => 62 + decade;

List<int> _decade(int decade) => [
  for (var i = 0; i < 10; i++) _decadeBead(decade, i),
];

/// Decades already prayed before [decade], with their Our Father beads.
List<int> _prayedBefore(int decade) => [
  for (var d = 0; d < decade; d++) ...[
    ..._decade(d),
    if (d > 0) _ourFatherAfter(d - 1),
  ],
  if (decade > 0) 6,
];

/// The beads a step lights: [sequence] are prayed one after another; [also]
/// are shown lightly, as already prayed.
class _Beads {
  const _Beads(this.sequence, [this.also = const []]);

  final List<int> sequence;
  final List<int> also;
}

_Beads _beadsFor(RosaryBeads beads) {
  final d = beads.decade;
  return switch (beads.kind) {
    RosaryBeadKind.crucifix => const _Beads([_crucifix]),
    RosaryBeadKind.firstOurFather => const _Beads([1]),
    RosaryBeadKind.threeHailMarys => const _Beads([2, 3, 4]),
    RosaryBeadKind.gloryBeforeDecades => const _Beads([5]),
    RosaryBeadKind.decadeOurFather => _Beads([
      d == 0 ? 6 : _ourFatherAfter(d - 1),
    ], _prayedBefore(d)),
    RosaryBeadKind.decadeHailMarys => _Beads(_decade(d), [
      ..._prayedBefore(d),
      d == 0 ? 6 : _ourFatherAfter(d - 1),
    ]),
    RosaryBeadKind.afterDecade => _Beads([
      _chainAfter(d),
    ], _prayedBefore(d + 1)),
    RosaryBeadKind.centrepiece => _Beads([_centrepiece], _prayedBefore(5)),
  };
}

enum _BeadKind { crucifix, large, small, chain, centrepiece }

class _Bead {
  const _Bead(this.position, this.kind);

  final Offset position;
  final _BeadKind kind;
}

class _RosaryPainter extends CustomPainter {
  _RosaryPainter({required this.beads, required this.phase});

  final _Beads beads;

  /// 0 to 1 through the animation; `null` when still.
  final double? phase;

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

    // Which beads are lit right now. A counted sequence lights bead by
    // bead, then pauses with all lit before starting again.
    final sequence = beads.sequence;
    var lit = sequence.length;
    int? current;
    var glow = 0.5;
    if (phase case final t?) {
      if (sequence.length > 1) {
        final steps = sequence.length + 2;
        lit = math.min(sequence.length, (t * steps).floor() + 1);
        current = lit <= sequence.length ? sequence[lit - 1] : null;
        glow = 1 - ((t * steps) % 1);
      } else {
        glow = 0.5 + 0.5 * math.sin(t * 2 * math.pi);
        current = sequence.single;
      }
    }
    final litBeads = sequence.take(lit).toSet();

    for (final (i, bead) in layout.indexed) {
      final isLit = litBeads.contains(i);
      final isAlso = beads.also.contains(i);
      final colour = isLit
          ? AppColors.gold
          : isAlso
          ? AppColors.gold.withValues(alpha: 0.45)
          : AppColors.primaryNavy.withValues(alpha: 0.35);
      final fill = Paint()..color = colour;

      if (isLit && (i == current || phase == null)) {
        canvas.drawCircle(
          bead.position,
          w * (0.045 + 0.02 * glow),
          Paint()
            ..color = AppColors.gold.withValues(alpha: 0.18 + 0.2 * glow)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.015),
        );
      }

      switch (bead.kind) {
        case _BeadKind.small:
          canvas.drawCircle(bead.position, w * 0.017, fill);
        case _BeadKind.large:
          canvas.drawCircle(bead.position, w * 0.027, fill);
        case _BeadKind.chain:
          if (isLit) canvas.drawCircle(bead.position, w * 0.012, fill);
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
      oldDelegate.phase != phase || oldDelegate.beads != beads;
}
