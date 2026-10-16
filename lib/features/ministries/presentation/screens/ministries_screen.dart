import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ministry_category.dart';
import '../providers/ministries_providers.dart';
import '../widgets/ministries_status_view.dart';
import '../widgets/ministry_category_header.dart';
import '../widgets/ministry_group_card.dart';
import 'ministry_detail_screen.dart';

/// Ministries destination: a header, then a card of ministry rows under each
/// category, in the order the parish API returns them. Pull down to refresh.
class MinistriesScreen extends ConsumerWidget {
  const MinistriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ministries = ref.watch(ministriesProvider);

    return RefreshIndicator(
      onRefresh: () => _refresh(context, ref),
      child: ListView(
        // Lets pull-to-refresh work even when the content is shorter than
        // the screen (loading, error and empty states).
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const _MinistriesHero(),
          // Previous data stays on screen while reloading.
          ...switch (ministries) {
            AsyncValue(:final value?) => _content(context, value),
            AsyncValue(hasError: true) => [
              MinistriesMessageView(
                message:
                    "Couldn't load the ministries right now. Check your "
                    'connection and try again.',
                onRetry: () => ref.invalidate(ministriesProvider),
              ),
            ],
            _ => const [MinistriesLoadingView(caption: 'Loading ministries…')],
          },
        ],
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    List<MinistryCategory> categories,
  ) {
    if (categories.isEmpty) {
      return const [
        MinistriesMessageView(message: 'No ministries are listed right now.'),
      ];
    }
    return [
      for (final category in categories) ...[
        MinistryCategoryHeader(category.name),
        MinistryGroupCard(
          ministries: category.ministries,
          onTap: (ministry) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MinistryDetailScreen(ministryId: ministry.id),
            ),
          ),
        ),
      ],
    ];
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final refreshed = await ref.read(ministriesProvider.notifier).refresh();
    if (refreshed) return;
    messenger?.showSnackBar(
      const SnackBar(
        content: Text(
          "Couldn't refresh. Showing the ministries saved on this device.",
        ),
      ),
    );
  }
}

class _MinistriesHero extends StatelessWidget {
  const _MinistriesHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ministries & Groups',
            style: AppTypography.display(
              fontSize: 22,
              height: 1.25,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
