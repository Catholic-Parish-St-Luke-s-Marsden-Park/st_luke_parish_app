import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/parish_notice.dart';
import '../providers/parish_notice_provider.dart';

/// The side menu's Special Announcements page: whatever the parish
/// website's home page currently shows in its pop-up (e.g. the "Save the
/// Date" events poster), read afresh each time (parish request,
/// 2026-10-16).
class ParishNoticesScreen extends ConsumerWidget {
  const ParishNoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Special Announcements')),
      body: switch (ref.watch(currentParishNoticeProvider)) {
        AsyncData(value: final notice?) => _NoticeView(notice: notice),
        AsyncData() => const _Message(
          icon: Icons.campaign_outlined,
          title: 'No announcements right now',
          body:
              'There are no special announcements at the moment. Please check '
              'back soon.',
        ),
        AsyncError() => _Message(
          icon: Icons.wifi_off_rounded,
          title: 'Unable to load announcements',
          body: 'Please check your internet connection and try again.',
          onRetry: () => ref.invalidate(currentParishNoticeProvider),
        ),
        _ => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
      },
    );
  }
}

class _NoticeView extends ConsumerWidget {
  const _NoticeView({required this.notice});

  final ParishNotice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        Text('From the parish website', style: textTheme.bodySmall),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppShapes.cardBorderRadius,
            boxShadow: AppShapes.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: AppShapes.cardBorderRadius,
            // Pinch to zoom in on the poster's small print.
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.network(
                notice.imageUrl,
                semanticLabel:
                    'Parish notice from the parish website. Use "Open full '
                    'size" for a larger view.',
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
                        'The notice image could not be loaded.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pinch to zoom in.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => ref
              .read(urlLauncherServiceProvider)
              .launchExternal(notice.imageUrl),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.open_in_new_rounded),
          label: const Text('Open full size'),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 40, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.display(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry case final retry?) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: retry, child: const Text('Try Again')),
            ],
          ],
        ),
      ),
    );
  }
}
