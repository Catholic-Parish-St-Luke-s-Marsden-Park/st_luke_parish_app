/// One mystery of the Rosary, e.g. "The Annunciation", with its Scripture
/// verse and the grace (fruit) prayed for while meditating on it.
class RosaryMystery {
  const RosaryMystery({
    required this.title,
    required this.verse,
    required this.reference,
    required this.fruit,
  });

  final String title;
  final String verse;

  /// Where [verse] is found, e.g. "Luke 1: 30 - 31".
  final String reference;
  final String fruit;
}

/// Which set a [RosaryMysterySet] is; the presentation layer maps it to the
/// set's accent colour.
enum RosaryMysteryKind { joyful, luminous, sorrowful, glorious }

/// One set of five mysteries, e.g. the Joyful Mysteries, and the days of the
/// week it is prayed on.
class RosaryMysterySet {
  const RosaryMysterySet({
    required this.kind,
    required this.name,
    required this.daysLabel,
    required this.weekdays,
    required this.mysteries,
  });

  final RosaryMysteryKind kind;

  /// e.g. "The Joyful Mysteries".
  final String name;

  /// e.g. "Prayed on Monday & Saturday".
  final String daysLabel;

  /// [DateTime.weekday] values (Monday = 1 ... Sunday = 7) it is prayed on.
  final List<int> weekdays;

  /// The five mysteries, in order.
  final List<RosaryMystery> mysteries;

  /// The singular word used to number this set's mysteries, e.g. "Joyful"
  /// in "1st Joyful Mystery".
  String get adjective => switch (kind) {
    RosaryMysteryKind.joyful => 'Joyful',
    RosaryMysteryKind.luminous => 'Luminous',
    RosaryMysteryKind.sorrowful => 'Sorrowful',
    RosaryMysteryKind.glorious => 'Glorious',
  };
}

/// The set prayed on [date]'s day of the week, or `null` if none of [sets]
/// covers it.
RosaryMysterySet? mysterySetForDay(List<RosaryMysterySet> sets, DateTime date) {
  for (final set in sets) {
    if (set.weekdays.contains(date.weekday)) return set;
  }
  return null;
}
