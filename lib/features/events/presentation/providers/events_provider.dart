import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/http_client_provider.dart';
import '../../data/datasources/parish_events_feed_datasource.dart';
import '../../data/repositories/feed_events_repository.dart';
import '../../domain/entities/parish_event.dart';
import '../../domain/repositories/events_repository.dart';

part 'events_provider.g.dart';

/// Wires the concrete [FeedEventsRepository] behind the abstract
/// [EventsRepository] contract, mirroring `bulletinsRepositoryProvider`'s
/// pattern exactly, so a future scraped/remote data source can be swapped
/// in later without touching presentation code.
@riverpod
EventsRepository eventsRepository(Ref ref) {
  return FeedEventsRepository(
    ParishEventsFeedDatasource(ref.watch(httpClientProvider)),
  );
}

/// Exposes the full upcoming-events list (no 7-day limit, already expanded
/// across the recurrence lookahead window — REQ-F08-012) as
/// `AsyncValue<List<ParishEvent>>`. Both `EventsSection` (the inline News-tab
/// section, which itself slices this to the next 7 days) and
/// `AllEventsScreen` (which paginates over the rest) read from this single
/// provider — neither fetches independently. `@riverpod` generates an
/// `AutoDispose...` provider by default — no caching across screen entries,
/// matching the News feature's `bulletinsProvider` precedent and CLAUDE.md's
/// "no local persistence until there's a clear requirement" rule.
@riverpod
Future<List<ParishEvent>> upcomingEvents(Ref ref) {
  return ref.watch(eventsRepositoryProvider).getUpcomingEvents();
}
