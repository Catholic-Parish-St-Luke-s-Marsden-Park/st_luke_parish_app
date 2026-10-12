import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/providers/saint_of_the_day_provider.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/screens/saint_of_the_day_screen.dart';

/// Covers REQ-F06-011 (explicit loading/success/error UI states) and
/// REQ-F06-013 (no icon/emoji glyphs) through the full `SaintOfTheDayScreen`
/// widget tree, overriding `saintOfTheDayProvider` directly (never the real
/// parish API datasource in widget tests) — same override-the-outermost-
/// provider approach as `news_screen_test.dart`.
const _saint = SaintOfTheDay(
  name: 'Saint John Vianney, Priest',
  feast: 'August 4 - Optional Memorial',
  bornDied: '1786 - 1859',
  about: 'A dedicated parish priest.',
  saying: '"A quote."',
  didYouKnow: 'A fact.',
  patronOf: 'Parish priests',
  prayer: 'A short prayer.',
  dateKey: '2026-09-01',
  displayDate: 'September 1',
);

Future<void> _pump(
  WidgetTester tester, {
  required FutureOr<SaintOfTheDay> Function(Ref ref) override,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [saintOfTheDayProvider.overrideWith(override)],
      child: const MaterialApp(home: SaintOfTheDayScreen()),
    ),
  );
}

void main() {
  testWidgets('shows a loading indicator while the future is pending', (
    tester,
  ) async {
    await _pump(tester, override: (ref) => Completer<SaintOfTheDay>().future);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  group('REQ-F06-011: success state', () {
    testWidgets(
      'renders the saint\'s name, feast, and every non-empty section',
      (tester) async {
        await _pump(tester, override: (ref) async => _saint);
        await tester.pumpAndSettle();

        expect(find.text('Saint John Vianney, Priest'), findsOneWidget);
        expect(find.text('August 4 - Optional Memorial'), findsOneWidget);
        expect(find.text('A dedicated parish priest.'), findsOneWidget);
        expect(find.text('"A quote."'), findsOneWidget);
        expect(find.text('A fact.'), findsOneWidget);
        expect(find.text('Parish priests'), findsOneWidget);
        expect(find.text('A short prayer.'), findsOneWidget);
      },
    );

    testWidgets('does not render an empty section', (tester) async {
      const noSaying = SaintOfTheDay(
        name: 'Saint Example',
        feast: '',
        bornDied: '',
        about: 'About only.',
        saying: '',
        didYouKnow: '',
        patronOf: '',
        prayer: '',
        dateKey: '2026-09-01',
        displayDate: 'September 1',
      );
      await _pump(tester, override: (ref) async => noSaying);
      await tester.pumpAndSettle();

      expect(find.text('FAMOUS SAYING'), findsNothing);
      expect(find.textContaining('SAYING'), findsNothing);
    });

    testWidgets('REQ-F06-013: no Icon widgets appear on the content screen', (
      tester,
    ) async {
      await _pump(tester, override: (ref) async => _saint);
      await tester.pumpAndSettle();

      expect(find.byType(Icon), findsNothing);
    });
  });

  group('REQ-F06-011: failure states', () {
    testWidgets('a network failure shows a user-friendly message with retry', (
      tester,
    ) async {
      await _pump(
        tester,
        override: (ref) =>
            Future.error(const SaintOfTheDayNetworkFailure('down')),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining("Unable to fetch today's saint"),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      // No raw exception text leaked to the UI.
      expect(find.textContaining('SaintOfTheDayNetworkFailure'), findsNothing);
    });

    testWidgets('a not-configured failure shows a distinct message', (
      tester,
    ) async {
      await _pump(
        tester,
        override: (ref) =>
            Future.error(const SaintOfTheDayNotConfiguredFailure('no key')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining("isn't set up on this build"), findsOneWidget);
    });

    testWidgets('a parsing failure shows a generic user-friendly message', (
      tester,
    ) async {
      await _pump(
        tester,
        override: (ref) =>
            Future.error(const SaintOfTheDayParsingFailure('bad response')),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Something went wrong loading'),
        findsOneWidget,
      );
    });
  });

  group('REQ-F09-016: one exact message per failure, each with Try again', () {
    const cases = <(SaintOfTheDayFailure, String)>[
      (
        SaintOfTheDayNotReadyFailure('503 code=saint_not_ready'),
        "Today's saint is still being prepared. Please try again in a few "
            'minutes.',
      ),
      (
        SaintOfTheDayDateUnavailableFailure('404 code=saint_not_available'),
        "Today's saint isn't available for your phone's current date. "
            'Please check your date and time settings, then try again.',
      ),
      (
        SaintOfTheDayUnavailableFailure('401 code=app_check_required'),
        'Saint of the Day is temporarily unavailable. Please try again later.',
      ),
      (
        SaintOfTheDayNetworkFailure('offline'),
        "Unable to fetch today's saint. Please check your connection and "
            'try again.',
      ),
      (
        SaintOfTheDayNotConfiguredFailure('no API_BASE_URL'),
        "Saint of the Day isn't set up on this build yet. Please let the "
            'parish app team know.',
      ),
      (
        SaintOfTheDayParsingFailure('empty name'),
        "Something went wrong loading today's saint. Please try again.",
      ),
    ];

    for (final (failure, message) in cases) {
      testWidgets('${failure.runtimeType}', (tester) async {
        await _pump(tester, override: (ref) => Future.error(failure));
        await tester.pumpAndSettle();

        expect(find.text(message), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        // Diagnostics (status, code, requestId) never reach the UI.
        expect(find.textContaining(failure.message), findsNothing);
        expect(
          tester
              .getSize(
                find.ancestor(
                  of: find.text('Try again'),
                  matching: find.byType(InkWell),
                ),
              )
              .height,
          greaterThanOrEqualTo(48),
        );
      });
    }
  });
}
