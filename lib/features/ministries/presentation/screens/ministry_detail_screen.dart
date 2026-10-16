import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cta_pill_button.dart';
import '../../domain/entities/ministry.dart';
import '../../domain/failures/ministries_failure.dart';
import '../providers/ministries_providers.dart';
import '../widgets/ministries_status_view.dart';

/// Full detail screen for a single ministry, reached by tapping a
/// `MinistryRow` on the Ministries tab. Looks the ministry up by id in the loaded list, falling
/// back to `GET /v1/ministries/{id}` when it isn't there.
class MinistryDetailScreen extends ConsumerWidget {
  const MinistryDetailScreen({super.key, required this.ministryId});

  final String ministryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(ministryByIdProvider(ministryId))) {
      AsyncValue(:final value?) => _MinistryDetailView(ministry: value),
      AsyncValue(error: MinistryNotFoundFailure()) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Ministry not found.')),
      ),
      AsyncValue(hasError: true) => Scaffold(
        appBar: AppBar(),
        body: MinistriesMessageView(
          message:
              "Couldn't load this ministry. Check your connection and try "
              'again.',
          onRetry: () => ref.invalidate(ministryByIdProvider(ministryId)),
        ),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: const MinistriesLoadingView(caption: 'Loading ministry…'),
      ),
    };
  }
}

class _MinistryDetailView extends StatelessWidget {
  const _MinistryDetailView({required this.ministry});

  final Ministry ministry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                alignment: Alignment.bottomLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ministry.name,
                      style: AppTypography.display(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT THIS MINISTRY',
                    style: AppTypography.display(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _DetailCard(
                    child: Text(
                      ministry.about,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MINISTRY LEAD / CONTACT',
                    style: AppTypography.display(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          ministry.leaderInitials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ministry.leaderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ministry.leaderRole,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HOW TO JOIN',
                    style: AppTypography.display(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _DetailCard(
                    child: Text(
                      ministry.joinInfo,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.65,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _JoinUsButton(ministry: ministry),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Join Us" CTA that launches [Ministry.contactMailtoUri] via the shared
/// [UrlLauncherService] (same injectable/testable pattern used in
/// 02-parish-tab), not a bare inline `url_launcher` call.
class _JoinUsButton extends ConsumerWidget {
  const _JoinUsButton({required this.ministry});

  final Ministry ministry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CtaPillButton(
      label: ministry.ctaLabel,
      icon: Icons.mail_outline_rounded,
      onPressed: () => ref
          .read(urlLauncherServiceProvider)
          .launchExternal(ministry.contactMailtoUri.toString()),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppShapes.cardBorderRadius,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShapes.cardShadow,
      ),
      child: child,
    );
  }
}
