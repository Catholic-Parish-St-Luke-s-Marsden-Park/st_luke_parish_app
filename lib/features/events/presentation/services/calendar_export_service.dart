import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cross-cutting contract for exporting a single event to the device
/// calendar (REQ-F08-024). Kept as an injectable abstraction, not a direct
/// static `add_2_calendar` call, so widget tests can override
/// [calendarExportServiceProvider] with a fake and verify export behavior
/// (REQ-F08-039d) without touching platform channels — same precedent as
/// `UrlLauncherService` in `lib/core/services/url_launcher_service.dart`.
abstract class CalendarExportService {
  /// Attempts to add [event] to the device calendar. Returns `false`
  /// (without throwing) if the export could not be started, matching
  /// [UrlLauncherService.launchExternal]'s never-throw contract so callers
  /// have one failure-handling shape to deal with (REQ-F08-025).
  Future<bool> addEvent(Event event);
}

class CalendarExportServiceImpl implements CalendarExportService {
  const CalendarExportServiceImpl();

  @override
  Future<bool> addEvent(Event event) async {
    try {
      return await Add2Calendar.addEvent2Cal(event);
    } catch (_) {
      return false;
    }
  }
}

final calendarExportServiceProvider = Provider<CalendarExportService>((ref) {
  return const CalendarExportServiceImpl();
});
