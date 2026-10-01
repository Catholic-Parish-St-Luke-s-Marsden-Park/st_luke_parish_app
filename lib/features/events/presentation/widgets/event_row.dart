import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/parish_event.dart';

/// A single event row: date/time pill, bold title, italic location (when
/// present), and two separate 48x48-minimum tap targets — "Details" and
/// "Add to my calendar" (REQ-F08-022). Shared by `EventsSection` (the
/// inline News-tab list) and `AllEventsScreen` so neither duplicates this
/// layout (REQ-F08-030). No `Icon`/emoji anywhere (REQ-F08-032).
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 2),
          // Wrap (not a fixed-width Row) so the two actions reflow onto
          // their own lines rather than overflow at increased system text
          // scale on narrow screens (REQ-F08-037), same precedent as
          // `BulletinListTile`.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              _RowAction(label: 'Details', onTap: onDetails),
              _RowAction(label: 'Add to my calendar', onTap: onAddToCalendar),
            ],
          ),
        ],
      ),
    );
  }
}

class _RowAction extends StatelessWidget {
  const _RowAction({required this.label, required this.onTap});

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
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
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
