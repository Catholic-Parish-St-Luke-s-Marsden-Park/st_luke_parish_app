import 'package:flutter/material.dart';

import '../../domain/entities/mass_times_card.dart';

/// The icon shown before each "What's On" card title: an evening moon for
/// the Saturday Vigil, the sun for Sunday, and a calendar for weekdays.
IconData massTimesCardIcon(MassTimesCardKind kind) => switch (kind) {
  MassTimesCardKind.saturdayVigil => Icons.nights_stay_outlined,
  MassTimesCardKind.sunday => Icons.wb_sunny_outlined,
  MassTimesCardKind.weekday => Icons.calendar_today_outlined,
};
