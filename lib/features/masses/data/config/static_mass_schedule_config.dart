import '../../domain/entities/mass_schedule.dart';
import '../../domain/entities/mass_sub_group.dart';
import '../../domain/entities/mass_time.dart';

/// Static, in-code (non-scraped) configuration for the Masses tab, sourced
/// from the user-reviewed HTML mockup referenced by the approved BA plan
/// (`.claude/plans/ba/2026-08-30_11-22-04-masses-tab.md`). This is a static
/// local data source, not a scraper — it lives under `data/` so it can
/// later be swapped for a scraped/remote source without restructuring.

const List<MassTime> sundayMasses = [
  MassTime(time: 'Sun 8:00 AM', name: 'Sunday Mass'),
  MassTime(time: 'Sun 10:00 AM', name: 'Sunday Mass'),
  MassTime(time: 'Sun 5:30 PM', name: 'Sunday Mass'),
];

const List<MassTime> saturdayVigilMasses = [
  MassTime(
    time: 'Sat 5:30 PM',
    name: 'Vigil Mass',
    note: 'Reconciliation from 4:30–5:25pm',
  ),
];

const List<MassTime> weekdayMasses = [
  MassTime(time: 'Wed 7:30 AM', name: 'Weekday Mass'),
  MassTime(time: 'Thu 9:00 AM', name: 'St.Luke Catholic College Mass'),
  MassTime(time: 'Fri 6:30 PM', name: 'Weekday Mass'),
  MassTime(time: 'Fri 11:00 AM', name: 'Marsden Park Care Community Mass'),
];

/// "What's On" section's three labeled sub-groups, in order.
const List<MassSubGroup> whatsOnSubGroups = [
  MassSubGroup(label: 'Sunday', rows: sundayMasses),
  MassSubGroup(label: 'Saturday Vigil', rows: saturdayVigilMasses),
  MassSubGroup(label: 'Weekday', rows: weekdayMasses),
];

/// "Reconciliation & Sacraments" section's flat row list, in order.
const List<MassTime> reconciliationAndSacramentsRows = [
  MassTime(
    time: 'Sat 4:30 PM',
    name: 'Reconciliation',
    note: 'Before the Vigil Mass',
  ),
  MassTime(time: 'By request', name: 'Baptisms & House Blessings'),
  MassTime(time: 'By enrolment', name: 'Sacramental Programme'),
];

/// The full static schedule exposed to the UI via `massScheduleProvider`.
const MassSchedule staticMassSchedule = MassSchedule(
  whatsOnSubGroups: whatsOnSubGroups,
  reconciliationAndSacraments: reconciliationAndSacramentsRows,
);
