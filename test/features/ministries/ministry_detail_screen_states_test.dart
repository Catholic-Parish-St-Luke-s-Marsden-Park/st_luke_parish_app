import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/provider_retry.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry_category.dart';
import 'package:st_luke_parish_app/features/ministries/domain/failures/ministries_failure.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/providers/ministries_providers.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministry_detail_screen.dart';

import '../../helpers/fake_ministries_repository.dart';

/// Detail screen states: REQ-F08-015 (lookup by id, fetch fallback),
/// REQ-F08-016 (404 and error) and REQ-F08-018 (mailto with an empty
/// subject).
class _FakeUrlLauncherService implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

void main() {
  const errorMessage =
      "Couldn't load this ministry. Check your connection and try again.";

  Future<_FakeUrlLauncherService> pumpDetail(
    WidgetTester tester,
    FakeMinistriesRepository repository, {
    required String ministryId,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final launcher = _FakeUrlLauncherService();
    await tester.pumpWidget(
      ProviderScope(
        retry: noAutomaticRetry,
        overrides: [
          ministriesRepositoryProvider.overrideWith((ref) async => repository),
          urlLauncherServiceProvider.overrideWithValue(launcher),
        ],
        child: MaterialApp(home: MinistryDetailScreen(ministryId: ministryId)),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    return launcher;
  }

  testWidgets('shows a loading state until the list arrives', (tester) async {
    final controller = StreamController<List<MinistryCategory>>();
    addTearDown(controller.close);

    await pumpDetail(
      tester,
      FakeMinistriesRepository(watch: () => controller.stream),
      ministryId: 'music-ministry',
      settle: false,
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Loading ministry…'), findsOneWidget);

    controller.add(loadFallbackMinistries());
    await tester.pumpAndSettle();
    expect(find.text('Music'), findsOneWidget);
  });

  testWidgets('REQ-F08-015: a ministry in the loaded list is shown without '
      'a fetch', (tester) async {
    final repository = FakeMinistriesRepository();

    await pumpDetail(tester, repository, ministryId: 'sre-ministry');

    expect(find.text('SRE'), findsOneWidget);
    expect(repository.byIdRequests, isEmpty);
  });

  testWidgets('REQ-F08-015: an id missing from the list is fetched '
      '(e.g. a deep link)', (tester) async {
    final repository = FakeMinistriesRepository(
      byId: {'new-group': testMinistry('new-group')},
    );

    await pumpDetail(tester, repository, ministryId: 'new-group');

    expect(repository.byIdRequests, ['new-group']);
    expect(find.text('Name new-group'), findsOneWidget);
    expect(find.text('Join new-group'), findsOneWidget);
  });

  testWidgets('REQ-F08-016: a 404 shows "Ministry not found."', (tester) async {
    await pumpDetail(
      tester,
      FakeMinistriesRepository(),
      ministryId: 'hidden-group',
    );

    expect(find.text('Ministry not found.'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });

  testWidgets('REQ-F08-016: other failures show a message and retry', (
    tester,
  ) async {
    final repository = FakeMinistriesRepository(
      byIdFailure: const MinistriesNetworkFailure('offline'),
    );

    await pumpDetail(tester, repository, ministryId: 'new-group');

    expect(find.text(errorMessage), findsOneWidget);
    expect(find.text('Ministry not found.'), findsNothing);
    expect(find.textContaining('offline'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(repository.byIdRequests, ['new-group', 'new-group']);
  });

  testWidgets('REQ-F08-018: an empty email subject launches a bare mailto', (
    tester,
  ) async {
    final launcher = await pumpDetail(
      tester,
      FakeMinistriesRepository(
        categories: [
          MinistryCategory(
            name: 'Test Category',
            ministries: [
              testMinistry(
                'nosubject',
                contactEmail: 'office@example.org',
                emailSubject: '',
              ),
            ],
          ),
        ],
      ),
      ministryId: 'nosubject',
    );

    await tester.tap(find.text('Join nosubject'));
    await tester.pumpAndSettle();

    expect(launcher.launchedUrls, ['mailto:office@example.org']);
  });
}
