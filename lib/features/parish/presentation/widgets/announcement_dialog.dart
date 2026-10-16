import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/parish_notice.dart';

/// Shows [notice] in a pop-up window, like the parish website's own pop-up.
Future<void> showAnnouncementDialog(BuildContext context, ParishNotice notice) {
  return showDialog<void>(
    context: context,
    builder: (_) => AnnouncementDialog(notice: notice),
  );
}

/// The parish website's current pop-up image (e.g. the "Save the Date"
/// poster): zoomable, with Open full size and a close button.
class AnnouncementDialog extends ConsumerWidget {
  const AnnouncementDialog({super.key, required this.notice});

  final ParishNotice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Special Announcement',
                        style: AppTypography.display(
                          fontSize: 18,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            // Pinch to zoom in on the poster's small print.
            InteractiveViewer(
              maxScale: 5,
              child: Image.network(
                notice.imageUrl,
                semanticLabel:
                    'Special announcement from the parish website. Use '
                    '"Open full size" for a larger view.',
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const AspectRatio(
                        aspectRatio: 1.4,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                errorBuilder: (context, error, stackTrace) => const AspectRatio(
                  aspectRatio: 1.4,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'The announcement could not be loaded. Please '
                        'check your internet connection.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pinch to zoom in.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () => ref
                        .read(urlLauncherServiceProvider)
                        .launchExternal(notice.imageUrl),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open full size'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
