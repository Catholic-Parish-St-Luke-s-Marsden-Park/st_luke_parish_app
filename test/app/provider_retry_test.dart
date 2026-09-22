import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';

/// Guards the app-wide Riverpod retry policy.
///
/// Riverpod 3.x retries a failing provider automatically unless a policy
/// is supplied, so "no `retry` argument" is not a neutral default — it
/// opts the whole app into up to 10 re-runs with exponential backoff. The
/// regression these tests exist to catch is `ProviderScope`/
/// `ProviderContainer` being constructed without [noAutomaticRetry] and
/// silently inheriting that behaviour.
void main() {
  group('noAutomaticRetry', () {
    test('returns null for every retry count', () {
      for (var i = 0; i < 12; i++) {
        expect(
          noAutomaticRetry(i, Exception('boom')),
          isNull,
          reason: 'retry $i should not be scheduled',
        );
      }
    });

    test('returns null for an Exception, which the default would retry', () {
      // ProviderContainer.defaultRetry skips Error and ProviderException
      // but retries everything else — and every typed failure in this app
      // implements Exception, so all of them fall inside the default.
      expect(noAutomaticRetry(0, Exception('a plain exception')), isNull);
      expect(noAutomaticRetry(0, const FormatException('bad')), isNull);
    });
  });

  group('a failing provider under the policy', () {
    test('is built exactly once — no automatic re-runs', () async {
      var buildCount = 0;
      final failing = FutureProvider<int>((ref) async {
        buildCount++;
        throw Exception('always fails');
      });

      final container = ProviderContainer(retry: noAutomaticRetry);
      addTearDown(container.dispose);
      container.listen(failing, (_, _) {});

      await expectLater(
        container.read(failing.future),
        throwsA(isA<Exception>()),
      );

      // Give any scheduled retry (the default's first backoff is 200ms)
      // a generous window to fire. It must not.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(buildCount, 1);
      expect(container.read(failing), isA<AsyncError<int>>());
    });
  });

  group('the app ProviderScope', () {
    testWidgets('supplies the policy, so a failure surfaces immediately', (
      tester,
    ) async {
      var buildCount = 0;
      final failing = FutureProvider<int>((ref) async {
        buildCount++;
        throw Exception('always fails');
      });

      await tester.pumpWidget(
        ProviderScope(
          retry: noAutomaticRetry,
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => ref
                  .watch(failing)
                  .when(
                    loading: () => const Text('loading'),
                    error: (_, _) => const Text('error'),
                    data: (value) => Text('$value'),
                  ),
            ),
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('error'), findsOneWidget);
      expect(buildCount, 1);
    });
  });
}
