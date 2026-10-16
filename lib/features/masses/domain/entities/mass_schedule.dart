import 'mass_sub_group.dart';
import 'mass_times_card.dart';
import 'parish_activity.dart';

/// The full static content shown on the Masses tab: the "What's On"
/// section's Mass times cards, and the "Regular Parish Activities"
/// section's entries.
class MassSchedule {
  const MassSchedule({
    required this.whatsOnCards,
    required this.regularActivities,
  });

  final List<MassTimesCard> whatsOnCards;
  final List<ParishActivity> regularActivities;

  /// Every sub-group across the cards, in display order.
  List<MassSubGroup> get whatsOnSubGroups => [
    for (final card in whatsOnCards) ...card.subGroups,
  ];
}
