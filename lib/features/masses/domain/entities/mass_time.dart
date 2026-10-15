/// A single Mass schedule row (e.g. "Wednesday: 7:30 AM").
///
/// [time] is a pre-formatted display string: a clock time (e.g.
/// `"7:30 AM"`), shown after the optional [label] (a day such as
/// `"Wednesday"`, or `"Time"`), with weekday names spelled out in full.
/// There is no sorting/date-math requirement for this static schedule, so a
/// structured `DateTime`/`TimeOfDay` is intentionally not used here.
class MassTime {
  const MassTime({required this.time, this.label, this.name, this.note});

  final String time;

  /// Optional prefix shown before [time], e.g. "Time" renders
  /// "Time: 5:30 PM".
  final String? label;

  /// Optional: weekday Mass rows show only the day and time.
  final String? name;
  final String? note;
}
