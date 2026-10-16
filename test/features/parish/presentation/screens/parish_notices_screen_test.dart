import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/parish/domain/entities/parish_notice.dart';
import 'package:st_luke_parish_app/features/parish/domain/failures/parish_documents_failure.dart';
import 'package:st_luke_parish_app/features/parish/presentation/providers/parish_notice_provider.dart';
import 'package:st_luke_parish_app/features/parish/presentation/screens/parish_notices_screen.dart';

class _FakeUrlLauncher implements UrlLauncherService {
  final List<String> launchedUrls = [];

  @override
  Future<bool> launchExternal(String url) async {
    launchedUrls.add(url);
    return true;
  }
}

const _poster =
    'https://stlukesmarsdenpark.org.au/wp-content/uploads/2026/09/'
    'STD-LS-SLMP-1024x724.jpg';

void main() {
  late _FakeUrlLauncher launcher;

  Future<void> pumpNotices(
    WidgetTester tester,
    Future<ParishNotice?> Function() notice,
  ) async {
    launcher = _FakeUrlLauncher();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          urlLauncherServiceProvider.overrideWithValue(launcher),
          currentParishNoticeProvider.overrideWith((ref) => notice()),
        ],
        child: const MaterialApp(home: ParishNoticesScreen()),
      ),
    );
  }

  testWidgets('shows a loading indicator while the notice loads', (
    tester,
  ) async {
    final completer = Completer<ParishNotice?>();
    await pumpNotices(tester, () => completer.future);
    await tester.pump();

    expect(
      find.widgetWithText(AppBar, 'Special Announcements'),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    completer.complete(null);
  });

  testWidgets("shows the home page's pop-up image, zoomable, with an Open "
      'full size button', (tester) async {
    await pumpNotices(
      tester,
      () async => const ParishNotice(imageUrl: _poster),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, _poster);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    await tester.tap(find.text('Open full size'));
    expect(launcher.launchedUrls, [_poster]);
  });

  testWidgets('says there are no notices when the home page has no pop-up', (
    tester,
  ) async {
    await pumpNotices(tester, () async => null);
    await tester.pumpAndSettle();

    expect(find.text('No announcements right now'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows a friendly error with Try Again when offline', (
    tester,
  ) async {
    var calls = 0;
    await pumpNotices(tester, () async {
      calls++;
      throw const ParishDocumentsNetworkFailure('offline');
    });
    await tester.pumpAndSettle();

    expect(find.text('Unable to load announcements'), findsOneWidget);
    expect(find.textContaining('offline'), findsNothing);
    // Riverpod also retries on its own, so only check that Try Again asks
    // again.
    final before = calls;
    await tester.tap(find.text('Try Again'));
    await tester.pump();
    expect(calls, greaterThan(before));
  });
}
