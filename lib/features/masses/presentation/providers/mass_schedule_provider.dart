import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/config/static_mass_schedule_config.dart';
import '../../domain/entities/mass_schedule.dart';

part 'mass_schedule_provider.g.dart';

/// Exposes the static Mass schedule to [MassesScreen]. The screen and its
/// widgets read this provider rather than importing
/// `static_mass_schedule_config.dart` directly, so a future scraped/remote
/// data source can be swapped in behind this provider without touching
/// presentation code.
@riverpod
MassSchedule massSchedule(Ref ref) => staticMassSchedule;
