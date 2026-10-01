import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/parish_event.dart';

/// A single event row: date/time pill + bold title + italic location (when
/// present) on the left, with "Details" and "Add to my calendar" grouped
/// compactly in the top-right corner (REQ-F08-022) -- a visualiser-phase
/// layout revision (2026-10-01) requested after a live Android run showed
/// the original `Wrap`-stacked actions making each row far taller than
/// necessary.
///
/// "Details" stays a plain text link ([_ActionLink]). "Add to my calendar"
/// went through three rounds of live feedback: a filled pill button (too
/// heavy/large), then a plain text link matching "Details" (the user's
/// fallback at the time), and finally -- after the user shared a reference
/// screenshot of a rail-journey app's outlined "Add to Calendar" button --
/// an outlined pill button with a calendar icon ([_AddToCalendarButton]).
/// That icon is a deliberate, explicit exception to this app's otherwise
/// strict no-Icon-widget convention (REQ-F08-032), confirmed with the user
/// before implementing since it breaks a rule enforced by automated tests
/// since 01-bootstrap-app; it is the only `Icon` anywhere in the app. No
/// emoji glyph appears anywhere, which REQ-F08-032 still fully requires.
///
/// Both tap targets remain at least 48x48 logical pixels (REQ-F08-035),
/// and the action column is width-bounded so "Add to my calendar" wraps
/// onto a second line at large text scales instead of growing unboundedly
/// and squeezing the title/location column into a `RenderFlex` overflow
/// (REQ-F08-037) -- the button's inner `Text` is wrapped in `Flexible` for
/// the same reason, since a bare `Text` inside a `Row` is otherwise given
/// unbounded width and will not wrap. Shared by `EventsSection` (the
/// inline News-tab list, now the only place events are listed -- the
/// separate "All Events" screen was retired in an earlier round of this
/// same revision in favour of inline weekly pagination).
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
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: AppShapes.pillBorderRadius,
                  ),
                  child: Text(
                    event.displayTime,
                    // Slightly larger than the old labelSmall (9sp) per
                    // visualiser feedback (2026-10-01) that the date/time
                    // pill was too small to read comfortably.
                    style: textTheme.labelMedium?.copyWith(color: Colors.white),
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
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionLink(label: 'Details', onTap: onDetails),
                const SizedBox(height: 4),
                _AddToCalendarButton(onTap: onAddToCalendar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Plain-text-link treatment for "Details". Still a plain `Text` label, no
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

/// Outlined pill button with a calendar glyph for "Add to my calendar" --
/// a deliberate, explicit exception to this app's otherwise strict
/// no-Icon-widget convention (REQ-F08-032), requested by the user
/// (2026-10-01) to match a reference rail-journey-app "Add to Calendar"
/// button design. This is the only `Icon` anywhere in the app; every other
/// tap target/action remains plain `Text`, and no emoji glyph appears
/// anywhere, which REQ-F08-032 still fully requires. The inner `Text` is
/// wrapped in `Flexible` rather than left bare: a bare `Text` child of a
/// `Row` is given unbounded main-axis width and will not wrap, which would
/// reopen the `RenderFlex` overflow risk REQ-F08-037's width bound exists
/// to prevent.
class _AddToCalendarButton extends StatelessWidget {
  const _AddToCalendarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: AppShapes.pillBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppShapes.pillBorderRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primaryNavy),
            borderRadius: AppShapes.pillBorderRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 16,
                color: AppColors.primaryNavy,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Add to my calendar',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
