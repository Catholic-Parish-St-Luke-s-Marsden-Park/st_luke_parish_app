/// A prayer said during the Rosary, e.g. the "Our Father".
class RosaryPrayer {
  const RosaryPrayer({required this.name, required this.text});

  final String name;
  final String text;
}

/// The beads (or part of the chain) a [RosaryStep] is prayed on; the
/// presentation layer maps each to beads on its rosary diagram.
enum RosaryBeadGroup {
  crucifix,
  firstOurFather,
  threeHailMarys,
  gloryBeforeFirstDecade,
  firstMysteryOurFather,
  firstDecade,
  afterFirstDecade,
  remainingDecades,
  centrepiece,
}

/// One step of "How to Pray the Rosary".
class RosaryStep {
  const RosaryStep({
    required this.instruction,
    required this.beads,
    this.prayers = const [],
    this.announcesMystery = false,
  });

  final String instruction;
  final RosaryBeadGroup beads;
  final List<RosaryPrayer> prayers;

  /// True when this step announces a Mystery, so the page can point to
  /// today's set.
  final bool announcesMystery;
}
