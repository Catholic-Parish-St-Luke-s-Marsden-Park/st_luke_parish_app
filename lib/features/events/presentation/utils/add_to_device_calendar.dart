import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/parish_event.dart';

/// Exports [event] to the user's device calendar via `add_2_calendar`
/// (REQ-F08-007, REQ-F08-024) — opens the native Calendar app pre-filled
/// with the event for the user to confirm; no calendar read/write
/// permission needed for this default flow. Shows an explicit,
/// user-friendly message on failure rather than silently no-opping
/// (REQ-F08-025).
Future<void> addEventToDeviceCalendar(
  BuildContext context,
  ParishEvent event,
) async {
  final calendarEvent = Event(
    title: event.title,
    description: event.description ?? '',
    location: event.location ?? '',
    startDate: event.start,
    // The feed doesn't always provide an end time; default to a 1-hour
    // duration rather than a zero-length event, which some calendar apps
    // handle poorly.
    endDate: event.end ?? event.start.add(const Duration(hours: 1)),
  );

  var success = false;
  try {
    success = await Add2Calendar.addEvent2Cal(calendarEvent);
  } catch (_) {
    success = false;
  }

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
