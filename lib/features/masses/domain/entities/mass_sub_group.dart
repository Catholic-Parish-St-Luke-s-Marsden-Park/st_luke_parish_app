import 'mass_time.dart';

/// A labeled group of [MassTime] rows inside a single card — e.g. the
/// "Sunday" / "Saturday Vigil" / "Weekday" sub-groups within the
/// "What's On" section's single card.
class MassSubGroup {
  const MassSubGroup({required this.label, required this.rows});

  final String label;
  final List<MassTime> rows;
}
