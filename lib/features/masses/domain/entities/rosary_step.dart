import 'rosary_mystery.dart';

/// A prayer said during the Rosary, e.g. the "Our Father".
class RosaryPrayer {
  const RosaryPrayer({required this.name, required this.text});

  final String name;
  final String text;
}

/// Which part of the rosary a step is prayed on.
enum RosaryBeadKind {
  crucifix,
  firstOurFather,
  threeHailMarys,
  gloryBeforeDecades,

  /// The Our Father bead before a decade (where its Mystery is announced).
  decadeOurFather,

  /// A decade's ten Hail Mary beads.
  decadeHailMarys,

  /// The chain after a decade, where the Glory Be and Fatima Prayer are said.
  afterDecade,
  centrepiece,
}

/// The beads a [RosaryStep] is prayed on; the presentation layer maps them
/// to its rosary diagram.
class RosaryBeads {
  const RosaryBeads(this.kind, {this.decade = 0});

  final RosaryBeadKind kind;

  /// 0 to 4, for the decade kinds.
  final int decade;
}

/// One step of praying the Rosary.
class RosaryStep {
  const RosaryStep({
    required this.instruction,
    required this.beads,
    this.prayers = const [],
    this.mystery,
  });

  final String instruction;
  final RosaryBeads beads;
  final List<RosaryPrayer> prayers;

  /// The Mystery announced or meditated on in this step, if any.
  final RosaryMystery? mystery;

  /// The decade (0 to 4) when this step belongs to one.
  int? get decade => switch (beads.kind) {
    RosaryBeadKind.decadeOurFather ||
    RosaryBeadKind.decadeHailMarys ||
    RosaryBeadKind.afterDecade => beads.decade,
    _ => null,
  };
}
