import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/parsers/ics_event_parser.dart' show sydneyFakeUtcToRealUtc;
import '../../domain/entities/parish_event.dart';
import '../services/calendar_export_service.dart';

/// Exports [event] to the user's device calendar via the injectable
/// [CalendarExportService] (REQ-F08-007, REQ-F08-024) — opens the native
/// Calendar app pre-filled with the event for the user to confirm; no
/// calendar read/write permission needed for this default flow. Shows an
/// explicit, user-friendly message on failure rather than silently
/// no-opping (REQ-F08-025).
///
/// [ParishEvent.start]/[ParishEvent.end] are in the "fake UTC" wall-clock
/// representation (see `ics_event_parser.dart`'s class doc) -- fine for
/// this app's own display code, which only ever reads the digits directly,
/// but wrong the moment it crosses into `add_2_calendar`, which converts
/// whatever `DateTime` it's given via `millisecondsSinceEpoch` (a real
/// instant). [sydneyFakeUtcToRealUtc] converts to the true UTC instant
/// first -- without it, every exported event lands 10-11 hours off in the
/// native calendar app (confirmed live, 2026-10-08: a 7:00pm event showed
/// as 6:00am the next day).
Future<void> addEventToDeviceCalendar(
  BuildContext context,
  WidgetRef ref,
  ParishEvent event,
) async {
  // The feed doesn't always provide an end time; default to a 1-hour
  // duration (computed in the fake-UTC representation, same as every other
  // date computed from event.start elsewhere in this app) rather than a
  // zero-length event, which some calendar apps handle poorly -- then
  // convert both to real UTC instants before handing off to the plugin.
  final fakeUtcEnd = event.end ?? event.start.add(const Duration(hours: 1));
  final calendarEvent = Event(
    title: event.title,
    description: event.description ?? '',
    location: event.location ?? '',
    startDate: sydneyFakeUtcToRealUtc(event.start),
    endDate: sydneyFakeUtcToRealUtc(fakeUtcEnd),
  );

  final success = await ref
      .read(calendarExportServiceProvider)
      .addEvent(calendarEvent);

  if (!context.mounted) return;
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Couldn't open your calendar app to add this event. Please try again.",
        ),
      ),
    );
  }
}
