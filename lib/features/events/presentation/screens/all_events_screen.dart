import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/failures/events_failure.dart';
import '../providers/events_provider.dart';
import '../utils/add_to_device_calendar.dart';
import '../widgets/event_details_sheet.dart';
import '../widgets/event_row.dart';
import '../widgets/events_loading_view.dart';
import '../widgets/events_message_view.dart';

const _pageSize = 20;

/// Lists every upcoming event (no 7-day limit), reached only via
/// `EventsSection`'s "View all upcoming events" link (REQ-F08-027),
/// reusing the same provider/row widget/`AsyncValue` states as the inline
/// section (REQ-F08-028, REQ-F08-030). Paginates via forward/back page
/// navigation over the already-fetched, already-expanded in-memory list
/// rather than re-fetching per page, so it never builds every remaining
/// event's row in a single frame if the feed is large (REQ-F08-029) — a
/// visualiser-phase revision (2026-10-01) replacing the original
/// cumulative "Load more" button after a live Android run showed it
/// growing the list indefinitely with no way back to earlier pages. The
/// "Back" control only appears once the user has paged forward into later
/// events, since page 0 (the soonest upcoming events) has nothing earlier
/// to go back to. Both controls are plain-text Unicode glyphs, never a
/// Flutter `Icon` widget, per this app's no-icon convention (REQ-F08-032).
/// Back navigation to the News tab is Flutter's default pushed-screen
/// behaviour — no custom handling needed.
class AllEventsScreen extends ConsumerStatefulWidget {
  const AllEventsScreen({super.key});

  @override
  ConsumerState<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends ConsumerState<AllEventsScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: eventsAsync.when(
        loading: () => const EventsLoadingView(),
        error: (error, _) => EventsMessageView(
          message: error is EventsNetworkFailure
              ? "Couldn't connect to load upcoming events. Check your "
                    'connection and try again later.'
              : "Couldn't load upcoming events right now.",
        ),
        data: (events) {
          if (events.isEmpty) {
            return const EventsMessageView(
              message: 'No upcoming events right now.',
            );
          }

          final pageStart = _pageIndex * _pageSize;
          final visible = events.skip(pageStart).take(_pageSize).toList();
          final hasNext = pageStart + _pageSize < events.length;
          final hasPrevious = _pageIndex > 0;
          final showPaginationBar = hasNext || hasPrevious;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: visible.length + (showPaginationBar ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == visible.length) {
                return _PaginationBar(
                  hasPrevious: hasPrevious,
                  hasNext: hasNext,
                  onPrevious: () => setState(() {
                    _pageIndex -= 1;
                  }),
                  onNext: () => setState(() {
                    _pageIndex += 1;
                  }),
                );
              }
              final event = visible[index];
              return EventRow(
                event: event,
                isLast: index == visible.length - 1 && !showPaginationBar,
                onDetails: () => showEventDetailsSheet(context, event),
                onAddToCalendar: () =>
                    addEventToDeviceCalendar(context, ref, event),
              );
            },
          );
        },
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.hasPrevious,
    required this.hasNext,
    required this.onPrevious,
    required this.onNext,
  });

  final bool hasPrevious;
  final bool hasNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: hasPrevious
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          if (hasPrevious)
            _PaginationButton(label: '< Back', onTap: onPrevious),
          if (hasNext) _PaginationButton(label: 'Next >', onTap: onNext),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.pillBorderRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
