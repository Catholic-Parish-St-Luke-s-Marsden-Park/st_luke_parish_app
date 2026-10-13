import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/entities/saint_of_the_day.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/domain/failures/saint_of_the_day_failure.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/providers/saint_of_the_day_provider.dart';
import 'package:st_luke_parish_app/features/saint_of_the_day/presentation/screens/saint_of_the_day_screen.dart';

/// Covers REQ-F06-014: loading/error/empty text reflows rather than
/// overflows at increased system text scale, across representative screen
/// sizes — same sweep pattern as `news_screen_test.dart`'s REQ-F05-036
/// group and `masses_screen_test.dart`'s equivalent. `saint_of_the_day_screen_test.dart`
/// covers the functional behaviour of every provider state; this file
/// covers only the layout-robustness sweep, which no test previously did
/// for this screen.
const _fullSaint = SaintOfTheDay(
  name: 'Saint John Mary Baptist Vianney, Priest and Patron of Parish Priests',
  feast: 'August 4 - Optional Memorial in the General Roman Calendar',
  bornDied:
      '8 May 1786, Dardilly, France - 4 August 1859, Ars-sur-Formans, '
      'France',
  about:
      'A dedicated parish priest renowned for his tireless ministry in the '
      'confessional, spending up to sixteen hours a day hearing '
      'confessions and drawing pilgrims from across France to the small '
      'village of Ars.',
  saying: '"The priest is not a priest for himself; he is a priest for you."',
  didYouKnow:
      'He struggled academically in seminary and nearly failed his '
      'studies due to difficulty learning Latin, yet became the patron of '
      'parish priests worldwide.',
  patronOf: 'Parish priests, confessors, and the Diocese of Ars',
  prayer:
      'Saint John Vianney, faithful shepherd of souls, pray for all '
      'priests that they may love their people as you loved yours. Amen.',
  dateKey: '2026-09-01',
  displayDate: 'September 1',
);

const _minimalSaint = SaintOfTheDay(
  name: 'Saint of the Day',
  feast: '',
  bornDied: '',
  about: '',
  saying: '',
  didYouKnow: '',
  patronOf: '',
  prayer: '',
  dateKey: '2026-09-01',
  displayDate: 'September 1',
);

void main() {
  const phoneSize = Size(390, 844);
  const smallPhoneSize = Size(360, 690);
  const tabletSize = Size(1024, 1366);

  Future<void> expectNoOverflowAt(
    WidgetTester tester,
    Size size,
    TextScaler textScaler, {
    required FutureOr<SaintOfTheDay> Function(Ref ref) override,
    // The loading state's `CircularProgressIndicator` animates
    // continuously, so `pumpAndSettle()` never quiesces and times out —
    // a single `pump()` is correct there instead, matching
    // `saint_of_the_day_screen_test.dart`'s own loading test. Every other
    // state settles normally (a resolved/rejected Future, no ongoing
    // animation), so `pumpAndSettle()` is used for those by default.
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [saintOfTheDayProvider.overrideWith(override)],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScaler),
                child: const SaintOfTheDayScreen(),
              );
            },
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }

    expect(
      tester.takeException(),
      isNull,
      reason:
          'Expected no overflow/clipping exceptions at size $size, '
          'textScaler $textScaler',
    );
  }

  group('REQ-F06-014: success state (worst-case full content) reflows without '
      'overflow at increased text scale and across screen sizes', () {
    for (final size in [smallPhoneSize, phoneSize, tabletSize]) {
      for (final scaler in [
        TextScaler.noScaling,
        TextScaler.linear(1.5),
        TextScaler.linear(2.0),
      ]) {
        testWidgets('no overflow at $size, textScaler $scaler', (tester) async {
          await expectNoOverflowAt(
            tester,
            size,
            scaler,
            override: (ref) async => _fullSaint,
          );
        });
      }
    }
  });

  group(
    'REQ-F06-014: loading/error/empty states reflow without overflow at '
    'the worst-case size/text-scale combination (smallest phone, 2x text)',
    () {
      testWidgets('loading state', (tester) async {
        await expectNoOverflowAt(
          tester,
          smallPhoneSize,
          TextScaler.linear(2.0),
          override: (ref) => Completer<SaintOfTheDay>().future,
          settle: false,
        );
      });

      testWidgets('minimal-content success state (only name populated)', (
        tester,
      ) async {
        await expectNoOverflowAt(
          tester,
          smallPhoneSize,
          TextScaler.linear(2.0),
          override: (ref) async => _minimalSaint,
        );
      });

      testWidgets('network failure state', (tester) async {
        await expectNoOverflowAt(
          tester,
          smallPhoneSize,
          TextScaler.linear(2.0),
          override: (ref) =>
              Future.error(const SaintOfTheDayNetworkFailure('down')),
        );
      });

      testWidgets('not-configured failure state', (tester) async {
        await expectNoOverflowAt(
          tester,
          smallPhoneSize,
          TextScaler.linear(2.0),
          override: (ref) =>
              Future.error(const SaintOfTheDayNotConfiguredFailure('no key')),
        );
      });

      testWidgets('parsing failure state', (tester) async {
        await expectNoOverflowAt(
          tester,
          smallPhoneSize,
          TextScaler.linear(2.0),
          override: (ref) =>
              Future.error(const SaintOfTheDayParsingFailure('bad response')),
        );
      });
    },
  );

  group('REQ-F09-016: the feature 09 failure states reflow without overflow '
      'at 1.0x, 1.5x and 2.0x text scale on the smallest phone', () {
    const failures = <SaintOfTheDayFailure>[
      SaintOfTheDayNotReadyFailure('503'),
      SaintOfTheDayDateUnavailableFailure('404'),
      SaintOfTheDayUnavailableFailure('401'),
      SaintOfTheDayNetworkFailure('offline'),
      SaintOfTheDayNotConfiguredFailure('no base'),
      SaintOfTheDayParsingFailure('empty'),
    ];
    for (final failure in failures) {
      for (final scaler in [
        TextScaler.noScaling,
        TextScaler.linear(1.5),
        TextScaler.linear(2.0),
      ]) {
        testWidgets('${failure.runtimeType} at $scaler', (tester) async {
          await expectNoOverflowAt(
            tester,
            smallPhoneSize,
            scaler,
            override: (ref) => Future.error(failure),
          );
          expect(find.text('Try again'), findsOneWidget);
        });
      }
    }
  });
}
