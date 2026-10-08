import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry_category.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/providers/ministries_providers.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_row.dart';

import '../../helpers/fake_ministries_repository.dart';

/// Ministries tab states: REQ-F08-009 (stale then fresh), REQ-F08-013
/// (loading/error/empty) and REQ-F08-014 (pull-to-refresh).
void main() {
  const loadingCaption = 'Loading ministries…';
  const errorMessage =
      "Couldn't load the ministries right now. Check your connection and try "
      'again.';
  const emptyMessage = 'No ministries are listed right now.';
  const refreshFailedMessage =
      "Couldn't refresh. Showing the ministries saved on this device.";

  final cached = [
    MinistryCategory(name: 'Cached', ministries: [testMinistry('c1')]),
  ];

  Future<void> pumpScreen(
    WidgetTester tester,
    FakeMinistriesRepository repository, {
    Size size = const Size(800, 6000),
    TextScaler textScaler = TextScaler.noScaling,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        retry: noAutomaticRetry,
        overrides: [
          ministriesRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: const Scaffold(body: MinistriesScreen()),
            ),
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  // RefreshIndicator arms after a drag of a quarter of the viewport height,
  // so the refresh tests use a phone-height surface rather than the tall one.
  const phone = Size(390, 844);

  Future<void> pullToRefresh(WidgetTester tester) async {
    await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
    await tester.pumpAndSettle();
  }

  /// A repository whose list stream never emits, so the screen stays loading.
  FakeMinistriesRepository pending() {
    final controller = StreamController<List<MinistryCategory>>();
    addTearDown(controller.close);
    return FakeMinistriesRepository(watch: () => controller.stream);
  }

  FakeMinistriesRepository failing() => FakeMinistriesRepository(
    watch: () => Stream.error(const MinistriesParsingFailure('secret detail')),
  );

  group('REQ-F08-013: explicit states', () {
    testWidgets('loading shows a spinner and caption under the hero', (
      tester,
    ) async {
      await pumpScreen(tester, pending(), settle: false);

      expect(find.text('Ministries & Groups'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(loadingCaption), findsOneWidget);
      expect(find.byType(MinistryRow), findsNothing);
    });

    testWidgets('error shows a friendly message and no exception text', (
      tester,
    ) async {
      await pumpScreen(tester, failing());

      expect(find.text('Ministries & Groups'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.textContaining('secret detail'), findsNothing);
      expect(find.byType(MinistryRow), findsNothing);
    });

    testWidgets('"Try again" has at least a 48x48 target', (tester) async {
      await pumpScreen(tester, failing());

      final target = tester.getSize(
        find.ancestor(
          of: find.text('Try again'),
          matching: find.byType(InkWell),
        ),
      );
      expect(target.width, greaterThanOrEqualTo(48));
      expect(target.height, greaterThanOrEqualTo(48));
    });

    testWidgets('"Try again" reloads the list', (tester) async {
      var attempts = 0;
      final repository = FakeMinistriesRepository(
        watch: () => attempts++ == 0
            ? Stream.error(const MinistriesNetworkFailure('offline'))
            : Stream.value(loadFallbackMinistries()),
      );
      await pumpScreen(tester, repository);
      expect(find.text(errorMessage), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.watchCalls, 2);
      expect(find.text(errorMessage), findsNothing);
      expect(find.byType(MinistryRow), findsNWidgets(16));
    });

    testWidgets('empty shows a message and no rows', (tester) async {
      await pumpScreen(tester, FakeMinistriesRepository(categories: const []));

      expect(find.text(emptyMessage), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(find.byType(MinistryRow), findsNothing);
    });
  });

  group('REQ-F08-009: stale-while-revalidate', () {
    testWidgets('shows the saved list, then swaps in the fresh one', (
      tester,
    ) async {
      final controller = StreamController<List<MinistryCategory>>();
      addTearDown(controller.close);
      await pumpScreen(
        tester,
        FakeMinistriesRepository(watch: () => controller.stream),
        settle: false,
      );

      controller.add(cached);
      await tester.pumpAndSettle();
      expect(find.text('CACHED'), findsOneWidget);
      expect(find.byType(MinistryRow), findsOneWidget);

      controller.add(loadFallbackMinistries());
      await tester.pumpAndSettle();
      expect(find.text('CACHED'), findsNothing);
      expect(find.byType(MinistryRow), findsNWidgets(16));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('REQ-F08-014: pull-to-refresh', () {
    testWidgets('replaces the list on success', (tester) async {
      final repository = FakeMinistriesRepository(categories: cached);
      await pumpScreen(tester, repository, size: phone);
      expect(find.text('Name c1'), findsOneWidget);

      await pullToRefresh(tester);

      expect(repository.refreshCalls, 1);
      expect(find.text('Name c1'), findsNothing);
      expect(find.text('Music Ministry'), findsOneWidget);
      expect(find.text(refreshFailedMessage), findsNothing);
    });

    testWidgets('keeps the list and says so on failure', (tester) async {
      final repository = FakeMinistriesRepository(
        categories: cached,
        refreshFailure: const MinistriesNetworkFailure('offline'),
      );
      await pumpScreen(tester, repository, size: phone);

      await pullToRefresh(tester);

      expect(repository.refreshCalls, 1);
      expect(find.text(refreshFailedMessage), findsOneWidget);
      expect(find.text('Name c1'), findsOneWidget);
    });

    testWidgets('works from the empty state too', (tester) async {
      final repository = FakeMinistriesRepository(categories: const []);
      await pumpScreen(tester, repository, size: phone);

      await pullToRefresh(tester);

      expect(repository.refreshCalls, 1);
      expect(find.text(emptyMessage), findsNothing);
      expect(find.text('Music Ministry'), findsOneWidget);
    });

    testWidgets('works from the error state too', (tester) async {
      final repository = FakeMinistriesRepository(
        watch: () => Stream.error(const MinistriesNetworkFailure('offline')),
      );
      await pumpScreen(tester, repository, size: phone);
      expect(find.text(errorMessage), findsOneWidget);

      await pullToRefresh(tester);

      expect(repository.refreshCalls, 1);
      expect(find.text(errorMessage), findsNothing);
      expect(find.text('Music Ministry'), findsOneWidget);
    });
  });

  group('REQ-F08-013: every state reflows at increased text scale', () {
    const sizes = [Size(360, 690), Size(390, 844)];
    const scalers = [
      TextScaler.noScaling,
      TextScaler.linear(1.5),
      TextScaler.linear(2.0),
    ];
    final states = <String, (FakeMinistriesRepository Function(), bool)>{
      'loading': (pending, false),
      'error': (failing, true),
      'empty': (() => FakeMinistriesRepository(categories: const []), true),
      // All 16 ministries from the fallback asset, including the longest
      // name ("Extraordinary Ministers of Holy Communion").
      'data': (FakeMinistriesRepository.new, true),
    };

    for (final MapEntry(key: state, value: (repository, settle))
        in states.entries) {
      for (final size in sizes) {
        for (final scaler in scalers) {
          testWidgets('$state at $size, $scaler', (tester) async {
            await pumpScreen(
              tester,
              repository(),
              size: size,
              textScaler: scaler,
              settle: settle,
            );

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
