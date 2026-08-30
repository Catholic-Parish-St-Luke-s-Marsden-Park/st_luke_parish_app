import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/news/domain/entities/bulletin.dart';
import 'package:st_luke_parish_app/features/news/domain/failures/bulletins_failure.dart';
import 'package:st_luke_parish_app/features/news/domain/repositories/bulletins_repository.dart';
import 'package:st_luke_parish_app/features/news/presentation/providers/bulletins_provider.dart';

/// Covers REQ-F05-014/015 (bulletins exposed as `AsyncValue<List<Bulletin>>`
/// via a Riverpod provider) and the loading/success/empty/network-failure
/// `AsyncValue` states per REQ-F05-038(b), independent of any widget tree.
class _FakeBulletinsRepository implements BulletinsRepository {
  _FakeBulletinsRepository.returning(this._result) : _error = null;
  _FakeBulletinsRepository.throwing(Object error)
    : _result = null,
      _error = error;

  final List<Bulletin>? _result;
  final Object? _error;

  @override
  Future<List<Bulletin>> getBulletins() async {
    if (_error != null) throw _error;
    return _result!;
  }
}

Bulletin _bulletin(String title) => Bulletin(
  title: title,
  pageUrl: 'https://stlukesmarsdenpark.org.au/$title',
  pdfUrl: 'https://stlukesmarsdenpark.org.au/$title.pdf',
  date: DateTime.utc(2026, 8, 29),
  displayDate: '29 August 2026',
);

void main() {
  group('success states', () {
    test('single-item result is exposed via AsyncData', () async {
      final container = ProviderContainer(
        overrides: [
          bulletinsRepositoryProvider.overrideWithValue(
            _FakeBulletinsRepository.returning([_bulletin('Only one')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(bulletinsProvider.future);

      expect(result, hasLength(1));
      expect(result.single.title, 'Only one');
    });

    test(
      'multi-item result is exposed via AsyncData in the given order',
      () async {
        final container = ProviderContainer(
          overrides: [
            bulletinsRepositoryProvider.overrideWithValue(
              _FakeBulletinsRepository.returning([
                _bulletin('First'),
                _bulletin('Second'),
                _bulletin('Third'),
              ]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(bulletinsProvider.future);

        expect(result.map((b) => b.title), ['First', 'Second', 'Third']);
      },
    );
  });

  group('empty result', () {
    test(
      'an empty repository result is exposed as an empty AsyncData list',
      () async {
        final container = ProviderContainer(
          overrides: [
            bulletinsRepositoryProvider.overrideWithValue(
              _FakeBulletinsRepository.returning([]),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(bulletinsProvider.future);

        expect(result, isEmpty);
      },
    );
  });

  group('loading state', () {
    test('the provider starts in a loading state before resolution', () {
      final container = ProviderContainer(
        overrides: [
          bulletinsRepositoryProvider.overrideWithValue(
            _FakeBulletinsRepository.returning([_bulletin('Loading test')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final initial = container.read(bulletinsProvider);

      expect(initial, isA<AsyncLoading<List<Bulletin>>>());
    });
  });

  group('network failure', () {
    test('a BulletinsNetworkFailure surfaces as AsyncError', () async {
      final container = ProviderContainer(
        overrides: [
          bulletinsRepositoryProvider.overrideWithValue(
            _FakeBulletinsRepository.throwing(
              const BulletinsNetworkFailure('offline'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(bulletinsProvider.future),
        throwsA(isA<BulletinsNetworkFailure>()),
      );
    });
  });

  group('parsing failure', () {
    test('a BulletinsParsingFailure surfaces as AsyncError', () async {
      final container = ProviderContainer(
        overrides: [
          bulletinsRepositoryProvider.overrideWithValue(
            _FakeBulletinsRepository.throwing(
              const BulletinsParsingFailure('malformed'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(bulletinsProvider.future),
        throwsA(isA<BulletinsParsingFailure>()),
      );
    });
  });
}
