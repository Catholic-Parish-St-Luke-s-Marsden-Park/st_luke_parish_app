import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/progress/shared_preferences_prayer_progress_store.dart';
import '../../domain/repositories/prayer_progress_store.dart';

part 'prayer_progress_provider.g.dart';

/// Where the Rosary and the Chaplet remember the step reached. `Future`-typed
/// because `SharedPreferences.getInstance()` is async.
@riverpod
Future<PrayerProgressStore> prayerProgressStore(Ref ref) async =>
    SharedPreferencesPrayerProgressStore(await SharedPreferences.getInstance());
