import 'mass_sub_group.dart';

/// One card in the "What's On" section, e.g. "Weekend Mass Times" holding
/// the Saturday Vigil and Sunday sub-groups.
class MassTimesCard {
  const MassTimesCard({
    required this.title,
    required this.subGroups,
    this.highlightTimes = false,
  });

  final String title;
  final List<MassSubGroup> subGroups;

  /// Show each time in a gold oval (after its day, if any) rather than as
  /// plain "Day: time" text.
  final bool highlightTimes;
}
