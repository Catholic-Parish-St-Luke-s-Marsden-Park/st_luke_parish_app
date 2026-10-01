import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/parish_event.dart';

/// A single event row: date/time pill + bold title + italic location (when
/// present) on the left, with "Details" and "Add to my calendar" grouped
/// compactly in the top-right corner instead of stacked as separate
/// full-width lines (REQ-F08-022) — a visualiser-phase layout revision
/// (2026-10-01) requested after a live Android run showed the original
/// `Wrap`-stacked actions making each row far taller than necessary.
/// "Add to my calendar" is styled as a small filled button, distinct from
/// "Details"' plain-text-link treatment, per the same feedback. Both tap
/// targets remain at least 48x48 logical pixels (REQ-F08-035). Shared by
/// `EventsSection` (the inline News-tab list) and `AllEventsScreen` so
/// neither duplicates this layout (REQ-F08-030). No `Icon`/emoji anywhere
/// (REQ-F08-032).
class EventRow extends StatelessWidget {
  const EventRow({
    super.key,
    required this.event,
    required this.onDetails,
    required this.onAddToCalendar,
    this.isLast = false,
  });

  final ParishEvent event;
  final VoidCallback onDetails;
  final VoidCallback onAddToCalendar;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: AppShapes.pillBorderRadius,
                  ),
                  child: Text(
                    event.displayTime,
                    style: textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontFamily: textTheme.titleLarge?.fontFamily,
                  ),
                ),
                if (event.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.location!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            // Bounds the corner actions so "Add to my calendar" wraps onto
            // a second line at large text scales instead of growing
            // unboundedly and squeezing the title/location column into a
            // RenderFlex overflow (REQ-F08-037).
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _DetailsLink(onTap: onDetails),
                const SizedBox(height: 6),
                _AddToCalendarButton(onTap: onAddToCalendar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain-text-link treatment for "Details" — kept visually distinct from
/// [_AddToCalendarButton]'s filled-button treatment, per the visualiser
/// feedback that only "Add to my calendar" should look like a button.
class _DetailsLink extends StatelessWidget {
  const _DetailsLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.pillBorderRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Details',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small filled-pill button treatment for "Add to my calendar" — distinct
/// from [_DetailsLink]'s plain-text treatment (visualiser feedback,
/// 2026-10-01). Still a plain `Text` label, no `Icon` (REQ-F08-032).
class _AddToCalendarButton extends StatelessWidget {
  const _AddToCalendarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.primaryNavy,
      borderRadius: AppShapes.pillBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.pillBorderRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(
            'Add to my calendar',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
