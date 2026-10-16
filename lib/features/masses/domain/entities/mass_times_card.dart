import 'mass_sub_group.dart';

/// Which Mass times card this is; the presentation layer maps it to the
/// header icon.
enum MassTimesCardKind { saturdayVigil, sunday, weekday }

/// One card in the "What's On" section, e.g. "Weekend Mass Times" holding
/// the Saturday Vigil and Sunday sub-groups.
class MassTimesCard {
  const MassTimesCard({
    required this.title,
    required this.subGroups,
    this.listTimes = false,
    this.kind,
  });

  /// Optional: no header icon is shown when null.
  final MassTimesCardKind? kind;

  final String title;
  final List<MassSubGroup> subGroups;

  /// Lay out each row as its day (if any) followed by its times, rather
  /// than as "Day: time" text.
  final bool listTimes;
}
