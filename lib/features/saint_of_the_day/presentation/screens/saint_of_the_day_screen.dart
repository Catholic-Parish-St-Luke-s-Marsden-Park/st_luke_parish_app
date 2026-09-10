import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/saint_of_the_day.dart';
import '../../domain/failures/saint_of_the_day_failure.dart';
import '../providers/saint_of_the_day_provider.dart';
import '../widgets/saint_of_the_day_error_view.dart';
import '../widgets/saint_of_the_day_header.dart';
import '../widgets/saint_of_the_day_loading_view.dart';
import '../widgets/saint_of_the_day_section_card.dart';

/// Full-screen "Saint of the Day" page (REQ-F06-001), reached by tapping
/// the AppBar pill — matching the Ask Luke pill's push-navigation pattern
/// rather than the reference implementation's bottom sheet. No business
/// logic, network calls, or parsing lives in this widget tree; all of that
/// is behind `saintOfTheDayProvider`.
class SaintOfTheDayScreen extends ConsumerWidget {
  const SaintOfTheDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saintAsync = ref.watch(saintOfTheDayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saint of the Day')),
      body: saintAsync.when(
        loading: () => const SaintOfTheDayLoadingView(),
        error: (error, _) => SaintOfTheDayErrorView(
          message: _messageFor(error),
          onRetry: () => ref.invalidate(saintOfTheDayProvider),
        ),
        data: (saint) => _SaintOfTheDayContent(saint: saint),
      ),
    );
  }

  String _messageFor(Object error) {
    if (error is SaintOfTheDayNotConfiguredFailure) {
      return "Saint of the Day isn't set up on this build yet. "
          'Please let the parish app team know.';
    }
    if (error is SaintOfTheDayNetworkFailure) {
      return "Unable to fetch today's saint. Please check your connection "
          'and try again.';
    }
    return "Something went wrong loading today's saint. Please try again.";
  }
}

class _SaintOfTheDayContent extends StatelessWidget {
  const _SaintOfTheDayContent({required this.saint});

  final SaintOfTheDay saint;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        SaintOfTheDayHeader(saint: saint),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              if (saint.about.isNotEmpty)
                SaintOfTheDaySectionCard(label: 'About', body: saint.about),
              if (saint.bornDied.isNotEmpty)
                SaintOfTheDaySectionCard(
                  label: 'Born & Died',
                  body: saint.bornDied,
                ),
              if (saint.saying.isNotEmpty)
                SaintOfTheDaySectionCard(
                  label: 'Famous Saying',
                  body: saint.saying,
                ),
              if (saint.didYouKnow.isNotEmpty)
                SaintOfTheDaySectionCard(
                  label: 'Did You Know?',
                  body: saint.didYouKnow,
                ),
              if (saint.patronOf.isNotEmpty)
                SaintOfTheDaySectionCard(
                  label: 'Patron Of',
                  body: saint.patronOf,
                ),
              if (saint.prayer.isNotEmpty)
                SaintOfTheDaySectionCard(
                  label: 'Prayer',
                  body: saint.prayer,
                  emphasized: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
