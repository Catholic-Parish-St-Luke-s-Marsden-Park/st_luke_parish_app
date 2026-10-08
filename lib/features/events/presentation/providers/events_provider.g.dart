// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Wires the concrete [FeedEventsRepository] behind the abstract
/// [EventsRepository] contract, mirroring `bulletinsRepositoryProvider`'s
/// pattern exactly, so a future scraped/remote data source can be swapped
/// in later without touching presentation code.

@ProviderFor(eventsRepository)
final eventsRepositoryProvider = EventsRepositoryProvider._();

/// Wires the concrete [FeedEventsRepository] behind the abstract
/// [EventsRepository] contract, mirroring `bulletinsRepositoryProvider`'s
/// pattern exactly, so a future scraped/remote data source can be swapped
/// in later without touching presentation code.

final class EventsRepositoryProvider
    extends
        $FunctionalProvider<
          EventsRepository,
          EventsRepository,
          EventsRepository
        >
    with $Provider<EventsRepository> {
  /// Wires the concrete [FeedEventsRepository] behind the abstract
  /// [EventsRepository] contract, mirroring `bulletinsRepositoryProvider`'s
  /// pattern exactly, so a future scraped/remote data source can be swapped
  /// in later without touching presentation code.
  EventsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventsRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventsRepository create(Ref ref) {
    return eventsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventsRepository>(value),
    );
  }
}

String _$eventsRepositoryHash() => r'e8c5d32772eb4f62521e810957314f62bd6d1cea';

/// Exposes the full upcoming-events list (no 7-day limit, already expanded
/// across the recurrence lookahead window — REQ-F08-012) as
/// `AsyncValue<List<ParishEvent>>`. `EventsSection` (the inline News-tab
/// section, the only place events are listed since a visualiser-phase
/// redesign retired the separate "All Events" screen -- see
/// `events_section.dart`'s own doc comment) slices this into weekly windows
/// for its inline pagination. `@riverpod` generates an
/// `AutoDispose...` provider by default — no caching across screen entries,
/// matching the News feature's `bulletinsProvider` precedent and CLAUDE.md's
/// "no local persistence until there's a clear requirement" rule.

@ProviderFor(upcomingEvents)
final upcomingEventsProvider = UpcomingEventsProvider._();

/// Exposes the full upcoming-events list (no 7-day limit, already expanded
/// across the recurrence lookahead window — REQ-F08-012) as
/// `AsyncValue<List<ParishEvent>>`. `EventsSection` (the inline News-tab
/// section, the only place events are listed since a visualiser-phase
/// redesign retired the separate "All Events" screen -- see
/// `events_section.dart`'s own doc comment) slices this into weekly windows
/// for its inline pagination. `@riverpod` generates an
/// `AutoDispose...` provider by default — no caching across screen entries,
/// matching the News feature's `bulletinsProvider` precedent and CLAUDE.md's
/// "no local persistence until there's a clear requirement" rule.

final class UpcomingEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ParishEvent>>,
          List<ParishEvent>,
          FutureOr<List<ParishEvent>>
        >
    with
        $FutureModifier<List<ParishEvent>>,
        $FutureProvider<List<ParishEvent>> {
  /// Exposes the full upcoming-events list (no 7-day limit, already expanded
  /// across the recurrence lookahead window — REQ-F08-012) as
  /// `AsyncValue<List<ParishEvent>>`. `EventsSection` (the inline News-tab
  /// section, the only place events are listed since a visualiser-phase
  /// redesign retired the separate "All Events" screen -- see
  /// `events_section.dart`'s own doc comment) slices this into weekly windows
  /// for its inline pagination. `@riverpod` generates an
  /// `AutoDispose...` provider by default — no caching across screen entries,
  /// matching the News feature's `bulletinsProvider` precedent and CLAUDE.md's
  /// "no local persistence until there's a clear requirement" rule.
  UpcomingEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingEventsHash();

  @$internal
  @override
  $FutureProviderElement<List<ParishEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ParishEvent>> create(Ref ref) {
    return upcomingEvents(ref);
  }
}

String _$upcomingEventsHash() => r'1c4731c01a7d685693e3f1d2050f63740a450a36';
