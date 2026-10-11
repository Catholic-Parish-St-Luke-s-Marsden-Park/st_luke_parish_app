import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/parish_event.dart';

/// Shows the in-app "Details" bottom sheet for [event] (REQ-F08-023): full
/// title, date/time, location, and description, all already parsed from the
/// feed — no external navigation or extra network call. If the feed also
/// provided a per-event URL, an optional secondary "View on parish website
/// ↗" link is shown (launched externally only when tapped); otherwise the
/// sheet simply omits it. Dismissible via the explicit "Close" tap target,
/// the swipe-down gesture, and the platform back button/gesture (all three
/// are `showModalBottomSheet` defaults except the explicit close button,
/// added here for discoverability/accessibility).
Future<void> showEventDetailsSheet(BuildContext context, ParishEvent event) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: AppShapes.sheetBorderRadius,
    ),
    builder: (context) => _EventDetailsSheet(event: event),
  );
}

class _EventDetailsSheet extends ConsumerWidget {
  const _EventDetailsSheet({required this.event});

  final ParishEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: AppShapes.pillBorderRadius,
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        minWidth: 48,
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Close',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.displayTime,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.location!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(event.description!, style: textTheme.bodyMedium),
                  ],
                  if (event.detailUrl != null) ...[
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => ref
                            .read(urlLauncherServiceProvider)
                            .launchExternal(event.detailUrl!),
                        borderRadius: AppShapes.pillBorderRadius,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'View on parish website ↗',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
