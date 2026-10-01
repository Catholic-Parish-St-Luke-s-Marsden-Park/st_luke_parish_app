import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
/// section (REQ-F08-028, REQ-F08-030). Paginates via a "Load more" button
/// over the already-fetched, already-expanded in-memory list rather than
/// re-fetching per page, so it never builds every remaining event's row in
/// a single frame if the feed is large (REQ-F08-029). Back navigation to
/// the News tab is Flutter's default pushed-screen behaviour — no custom
/// handling needed.
class AllEventsScreen extends ConsumerStatefulWidget {
  const AllEventsScreen({super.key});

  @override
  ConsumerState<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends ConsumerState<AllEventsScreen> {
  int _visibleCount = _pageSize;

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

          final visible = events.take(_visibleCount).toList();
          final hasMore = _visibleCount < events.length;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: visible.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == visible.length) {
                return _LoadMoreButton(
                  onTap: () => setState(() {
                    _visibleCount += _pageSize;
                  }),
                );
              }
              final event = visible[index];
              return EventRow(
                event: event,
                isLast: index == visible.length - 1 && !hasMore,
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

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                'Load more',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
