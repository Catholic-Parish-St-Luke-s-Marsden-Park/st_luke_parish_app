import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../domain/entities/bulletin.dart';

/// A single bulletin row: LATEST/PREVIOUS text pill, title, date, and a
/// "Download PDF ↗" tappable text-glyph affordance (REQ-F05-007,
/// REQ-F05-017). No icon/emoji anywhere (REQ-F05-030).
class BulletinListTile extends ConsumerWidget {
  const BulletinListTile({
    super.key,
    required this.bulletin,
    required this.isLatest,
    this.isLast = false,
  });

  final Bulletin bulletin;
  final bool isLatest;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: isLatest ? AppColors.paleGold : AppColors.border,
              borderRadius: AppShapes.pillBorderRadius,
            ),
            child: Text(
              isLatest ? 'LATEST' : 'PREVIOUS',
              style: textTheme.labelSmall?.copyWith(
                color: isLatest ? const Color(0xFF8A6A12) : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bulletin.title,
            style: textTheme.titleMedium?.copyWith(
              fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
            ),
          ),
          const SizedBox(height: 2),
          // Wrap (not a fixed-width Row) so the date and "Download PDF ↗"
          // affordance reflow onto their own lines rather than overflow at
          // increased system text scale on narrow screens (REQ-F05-036).
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(bulletin.displayDate, style: textTheme.bodySmall),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ref
                      .read(urlLauncherServiceProvider)
                      .launchExternal(bulletin.pdfUrl),
                  borderRadius: AppShapes.pillBorderRadius,
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 48,
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Download PDF ↗',
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
        ],
      ),
    );
  }
}
