import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../data/parsers/ics_event_parser.dart' show sydneyNowAsFakeUtc;
import '../../domain/entities/parish_event.dart';
import '../../domain/failures/events_failure.dart';
import '../providers/events_provider.dart';
import '../utils/add_to_device_calendar.dart';
import 'event_details_sheet.dart';
import 'event_row.dart';
import 'events_card.dart';
import 'events_loading_view.dart';
import 'events_message_view.dart';
import 'events_section_header.dart';

const _weekWindow = Duration(days: 7);

/// "Upcoming Events" section: reads `upcomingEventsProvider` and renders the
/// loading / success / two distinct empty states / parsing-failure /
/// network-failure states (REQ-F08-014..020). Inserted into
/// `news_screen.dart` between `NewsHeroBanner()` and `BulletinsSection()`
/// (REQ-F08-031).
///
/// Paginates inline, a week at a time, with `Next`/`Back` controls -- a
/// visualiser-phase redesign (2026-10-01) that retires the original
/// "show the next 7 days, plus a 'View all upcoming events' link to a
/// separate full-list screen" design (the former `REQ-F08-021` and
/// `REQ-F08-027..030`, and the now-deleted `AllEventsScreen`). Live
/// feedback on the original design asked for paging directly within this
/// section instead of a separate screen: "Next" advances the window by one
/// week, "Back" returns to the previous week, and "Back" only appears once
/// the user has paged forward past the first (soonest) week -- there is
/// nothing earlier than "now" to go back to from week 0.
///
/// The screen reads events only through this provider (REQ-F08-013) -- no
/// repository/datasource/parser import here beyond the shared, pure
/// [sydneyNowAsFakeUtc] time helper used to compute each week's window
/// boundaries (display windowing, not fetch/parse/export logic).
class EventsSection extends ConsumerStatefulWidget {
  const EventsSection({super.key});

  @override
  ConsumerState<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends ConsumerState<EventsSection> {
  int _weekIndex = 0;

  @override
  Widget build(BuildContext context) {
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
              final weekStart = now.add(_weekWindow * _weekIndex);
              final weekEnd = now.add(_weekWindow * (_weekIndex + 1));
              final thisWeek = <ParishEvent>[];
              for (final event in events) {
                if (event.start.isBefore(weekStart)) continue;
                if (event.start.isBefore(weekEnd)) {
                  thisWeek.add(event);
                } else {
                  break; // events is sorted ascending by start.
                }
              }
              final hasNext = events.any(
                (event) => !event.start.isBefore(weekEnd),
              );
              final hasPrevious = _weekIndex > 0;
              final showPaginationBar = hasNext || hasPrevious;

              return Column(
                children: [
                  if (thisWeek.isEmpty)
                    const EventsMessageView(
                      message: 'No events this week.',
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
                  if (showPaginationBar)
                    _WeekPaginationBar(
                      hasPrevious: hasPrevious,
                      hasNext: hasNext,
                      onPrevious: () => setState(() {
                        _weekIndex -= 1;
                      }),
                      onNext: () => setState(() {
                        _weekIndex += 1;
                      }),
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

/// Inline week-pagination footer, replacing the old "View all upcoming
/// events" link (visualiser-phase redesign, 2026-10-01). "Back" only
/// renders when [hasPrevious], per the live-feedback requirement that
/// there is nothing to go back to from the first (soonest) week.
class _WeekPaginationBar extends StatelessWidget {
  const _WeekPaginationBar({
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
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        mainAxisAlignment: hasPrevious
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end,
        children: [
          if (hasPrevious)
            _WeekPaginationButton(label: '< Back', onTap: onPrevious),
          if (hasNext)
            _WeekPaginationButton(label: 'More events >', onTap: onNext),
        ],
      ),
    );
  }
}

class _WeekPaginationButton extends StatelessWidget {
  const _WeekPaginationButton({required this.label, required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
