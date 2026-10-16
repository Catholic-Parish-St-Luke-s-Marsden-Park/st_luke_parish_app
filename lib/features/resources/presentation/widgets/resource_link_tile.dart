import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/resource_link.dart';
import 'resource_icon.dart';

/// One Resources row: icon, title and subtitle, with an "opens in browser"
/// or "goes to tab" cue. At least 48dp tall and wraps at large text sizes.
class ResourceLinkTile extends StatelessWidget {
  const ResourceLinkTile({
    super.key,
    required this.link,
    required this.onTap,
    this.title,
    this.subtitle,
  });

  final ResourceLink link;
  final VoidCallback onTap;

  /// Overrides [ResourceLink.title], e.g. to add this month's edition.
  final String? title;

  /// Overrides [ResourceLink.subtitle].
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final opensBrowser = link.destination is! AppTabDestination;

    return Semantics(
      button: true,
      hint: opensBrowser ? 'Opens in your browser' : null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.paleGold,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      resourceIcon(link.kind),
                      color: AppColors.primaryNavy,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? link.title,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle ?? link.subtitle,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Icon(
                    opensBrowser
                        ? Icons.open_in_new_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
