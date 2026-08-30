/// A single Mass/sacrament schedule row (e.g. "Sat 5:30 PM · Vigil Mass").
///
/// [time] is a pre-formatted display string — either a weekday abbreviation
/// plus a clock time (e.g. `"Sat 5:30 PM"`) or one of the two non-clock-time
/// labels used for by-appointment items (`"By request"`, `"By enrolment"`).
/// There is no sorting/date-math requirement for this static schedule, so a
/// structured `DateTime`/`TimeOfDay` is intentionally not used here.
class MassTime {
  const MassTime({required this.time, required this.name, this.note});

  final String time;
  final String name;
  final String? note;
}
