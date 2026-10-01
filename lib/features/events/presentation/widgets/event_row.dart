import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/parish_event.dart';

/// A single event row: date/time pill + bold title + italic location (when
/// present) on the left, with "Details" and "Add to my calendar" grouped
/// compactly in the top-right corner (REQ-F08-022) -- a visualiser-phase
/// layout revision (2026-10-01) requested after a live Android run showed
/// the original `Wrap`-stacked actions making each row far taller than
/// necessary. Both actions use the same plain-text-link treatment: an
/// earlier round of this same revision tried a filled "Add to my calendar"
/// button, but a second live run showed the filled pill reading as too
/// large/heavy, and the user asked for a plain text link like "Details"
/// instead. Both tap targets remain at least 48x48 logical pixels
/// (REQ-F08-035), and the action column is width-bounded so the longer
/// "Add to my calendar" label wraps onto a second line at large text
/// scales instead of growing unboundedly and squeezing the title/location
/// column into a `RenderFlex` overflow (REQ-F08-037). Shared by
/// `EventsSection` (the inline News-tab list, now the only place events are
/// listed -- the separate "All Events" screen was retired in this same
/// revision in favour of inline weekly pagination). No `Icon`/emoji
/// anywhere (REQ-F08-032).
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
            width: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionLink(label: 'Details', onTap: onDetails),
                const SizedBox(height: 2),
                _ActionLink(
                  label: 'Add to my calendar',
                  onTap: onAddToCalendar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared plain-text-link treatment for both "Details" and "Add to my
/// calendar" -- unified onto one style after live feedback found a filled
/// button for "Add to my calendar" too visually heavy for a compact row
/// (visualiser feedback, 2026-10-01). Still a plain `Text` label, no
/// `Icon` (REQ-F08-032).
class _ActionLink extends StatelessWidget {
  const _ActionLink({required this.label, required this.onTap});

  final String label;
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
            label,
            textAlign: TextAlign.right,
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
