import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/parsers/ics_event_parser.dart' show sydneyNowAsFakeUtc;
import '../../domain/entities/parish_event.dart';
import '../../domain/failures/events_failure.dart';
import '../providers/events_provider.dart';
import '../screens/all_events_screen.dart';
import '../utils/add_to_device_calendar.dart';
import 'event_details_sheet.dart';
import 'event_row.dart';
import 'events_card.dart';
import 'events_loading_view.dart';
import 'events_message_view.dart';
import 'events_section_header.dart';

const _inlineWindow = Duration(days: 7);

/// "Upcoming Events" section: reads `upcomingEventsProvider` and renders the
/// loading / success / two distinct empty states / parsing-failure /
/// network-failure states (REQ-F08-014..021). Inserted into
/// `news_screen.dart` between `NewsHeroBanner()` and `BulletinsSection()`
/// (REQ-F08-031). Shows only events within the next 7 days; a "View all
/// upcoming events" link opens `AllEventsScreen` for the rest (REQ-F08-015,
/// REQ-F08-021). The screen reads events only through this provider
/// (REQ-F08-013) — no repository/datasource/parser import here beyond the
/// shared, pure [sydneyNowAsFakeUtc] time helper used to compute the 7-day
/// window boundary (display windowing, not fetch/parse/export logic).
class EventsSection extends ConsumerWidget {
  const EventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EventsSectionHeader('Upcoming Events'),
        EventsCard(
          padding: EdgeInsets.zero,
          child: eventsAsync.when(
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

              final now = sydneyNowAsFakeUtc();
              final weekEnd = now.add(_inlineWindow);
              final thisWeek = <ParishEvent>[];
              for (final event in events) {
                if (event.start.isBefore(weekEnd)) {
                  thisWeek.add(event);
                } else {
                  break; // events is sorted ascending by start.
                }
              }

              return Column(
                children: [
                  if (thisWeek.isEmpty)
                    const EventsMessageView(
                      message: 'No events in the next 7 days.',
                      showWebsiteLink: false,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          for (var i = 0; i < thisWeek.length; i++)
                            EventRow(
                              event: thisWeek[i],
                              isLast: i == thisWeek.length - 1,
                              onDetails: () =>
                                  showEventDetailsSheet(context, thisWeek[i]),
                              onAddToCalendar: () => addEventToDeviceCalendar(
                                context,
                                ref,
                                thisWeek[i],
                              ),
                            ),
                        ],
                      ),
                    ),
                  // REQ-F08-021: shown whenever the full upcoming-events
                  // list has 1+ events, regardless of how many fall within
                  // the current 7-day window.
                  _ViewAllLink(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AllEventsScreen(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ViewAllLink extends StatelessWidget {
  const _ViewAllLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: Text(
              'View all upcoming events',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
