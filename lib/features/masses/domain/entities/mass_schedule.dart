import 'mass_sub_group.dart';
import 'mass_time.dart';

/// The full static Mass-schedule content shown on the Masses tab: the
/// "What's On" section's three labeled sub-groups, and the
/// "Reconciliation & Sacraments" section's flat row list.
class MassSchedule {
  const MassSchedule({
    required this.whatsOnSubGroups,
    required this.reconciliationAndSacraments,
  });

  final List<MassSubGroup> whatsOnSubGroups;
  final List<MassTime> reconciliationAndSacraments;
}
