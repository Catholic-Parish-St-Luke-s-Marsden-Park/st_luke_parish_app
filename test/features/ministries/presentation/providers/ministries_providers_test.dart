import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry_category.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/providers/ministries_providers.dart';

import '../../../../helpers/fake_ministries_repository.dart';

/// Provider wiring for REQ-F08-009 (stale then fresh), REQ-F08-014
/// (pull-to-refresh) and REQ-F08-015/016 (detail lookup).
void main() {
  final cached = [
    MinistryCategory(name: 'Cached', ministries: [testMinistry('c1')]),
  ];
  final fresh = [
    MinistryCategory(name: 'Fresh', ministries: [testMinistry('f1')]),
  ];

  ProviderContainer containerFor(FakeMinistriesRepository repository) {
    final container = ProviderContainer(
      overrides: [
        ministriesRepositoryProvider.overrideWith((ref) async => repository),
      ],
      retry: noAutomaticRetry,
    );
    addTearDown(container.dispose);
    // Keeps the auto-dispose list provider alive between reads.
    container.listen(ministriesProvider, (_, _) {});
    return container;
  }

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  Future<Ministry> readById(ProviderContainer container, String id) {
    container.listen(ministryByIdProvider(id), (_, _) {});
    return container.read(ministryByIdProvider(id).future);
  }

  group('ministriesProvider', () {
    test('shows the saved list, then the fresh one when it arrives', () async {
      final controller = StreamController<List<MinistryCategory>>();
      addTearDown(controller.close);
      final container = containerFor(
        FakeMinistriesRepository(watch: () => controller.stream),
      );

      expect(container.read(ministriesProvider).isLoading, isTrue);

      controller.add(cached);
      await flush();
      expect(container.read(ministriesProvider).value, same(cached));

      controller.add(fresh);
      await flush();
      expect(container.read(ministriesProvider).value, same(fresh));
    });

    test('surfaces a stream error as an error state', () async {
      final container = containerFor(
        FakeMinistriesRepository(
          watch: () => Stream.error(const MinistriesParsingFailure('bad')),
        ),
      );

      await expectLater(
        container.read(ministriesProvider.future),
        throwsA(isA<MinistriesParsingFailure>()),
      );
    });
  });

  group('Ministries.refresh', () {
    test('replaces the list and returns true on success', () async {
      final repository = FakeMinistriesRepository(
        categories: cached,
        refreshed: fresh,
      );
      final container = containerFor(repository);
      await container.read(ministriesProvider.future);

      final refreshed = await container
          .read(ministriesProvider.notifier)
          .refresh();

      expect(refreshed, isTrue);
      expect(repository.refreshCalls, 1);
      expect(container.read(ministriesProvider).value, same(fresh));
    });

    test('keeps the current list and returns false on failure', () async {
      final container = containerFor(
        FakeMinistriesRepository(
          categories: cached,
          refreshFailure: const MinistriesNetworkFailure('offline'),
        ),
      );
      await container.read(ministriesProvider.future);

      final refreshed = await container
          .read(ministriesProvider.notifier)
          .refresh();

      expect(refreshed, isFalse);
      final state = container.read(ministriesProvider);
      expect(state.hasError, isFalse);
      expect(state.value, same(cached));
    });

    test('recovers an error state on success', () async {
      final container = containerFor(
        FakeMinistriesRepository(
          watch: () => Stream.error(const MinistriesParsingFailure('bad')),
          refreshed: fresh,
        ),
      );
      await container
          .read(ministriesProvider.future)
          .then<void>((_) {}, onError: (_) {});

      expect(
        await container.read(ministriesProvider.notifier).refresh(),
        isTrue,
      );
      expect(container.read(ministriesProvider).value, same(fresh));
    });
  });

  group('ministryByIdProvider', () {
    test('finds the ministry in the loaded list without a fetch', () async {
      final repository = FakeMinistriesRepository(categories: cached);
      final container = containerFor(repository);

      final ministry = await readById(container, 'c1');

      expect(ministry.id, 'c1');
      expect(repository.byIdRequests, isEmpty);
    });

    test('fetches by id when it is not in the list', () async {
      final repository = FakeMinistriesRepository(
        categories: cached,
        byId: {'deep': testMinistry('deep')},
      );
      final container = containerFor(repository);

      final ministry = await readById(container, 'deep');

      expect(ministry.id, 'deep');
      expect(repository.byIdRequests, ['deep']);
    });

    test('a 404 surfaces as MinistryNotFoundFailure', () async {
      final container = containerFor(
        FakeMinistriesRepository(categories: cached),
      );

      await expectLater(
        readById(container, 'gone'),
        throwsA(isA<MinistryNotFoundFailure>()),
      );
    });
  });
}
