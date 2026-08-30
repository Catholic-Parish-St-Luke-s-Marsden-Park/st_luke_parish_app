import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/failures/bulletins_failure.dart';
import '../providers/bulletins_provider.dart';
import 'bulletin_list_tile.dart';
import 'bulletins_loading_view.dart';
import 'bulletins_message_view.dart';
import 'news_card.dart';
import 'news_section_header.dart';

/// "Latest Bulletins" section: reads `bulletinsProvider` and renders the
/// loading / success / empty / parsing-failure / network-failure states
/// (REQ-F05-016..022). The screen reads bulletins only through this
/// provider (REQ-F05-015) — no repository/datasource/parser import here.
class BulletinsSection extends ConsumerWidget {
  const BulletinsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulletinsAsync = ref.watch(bulletinsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NewsSectionHeader('Latest Bulletins'),
        NewsCard(
          padding: EdgeInsets.zero,
          child: bulletinsAsync.when(
            loading: () => const BulletinsLoadingView(),
            error: (error, _) => BulletinsMessageView(
              message: error is BulletinsNetworkFailure
                  ? "Couldn't connect to load the latest bulletins. Check "
                        'your connection and try again later.'
                  : "Couldn't load the latest bulletins right now.",
            ),
            data: (bulletins) {
              if (bulletins.isEmpty) {
                return const BulletinsMessageView(
                  message: 'No bulletins are available right now.',
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    for (var i = 0; i < bulletins.length; i++)
                      BulletinListTile(
                        bulletin: bulletins[i],
                        isLatest: i == 0,
                        isLast: i == bulletins.length - 1,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
