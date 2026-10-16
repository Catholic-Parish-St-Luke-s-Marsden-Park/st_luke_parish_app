import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/services/url_launcher_service.dart';
import 'package:st_luke_parish_app/features/parish/domain/entities/parish_notice.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/announcement_dialog.dart';

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
  testWidgets('shows the poster, zoomable, with Open full size and a 48dp '
      'Close button', (tester) async {
    final launcher = _FakeUrlLauncher();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [urlLauncherServiceProvider.overrideWithValue(launcher)],
        child: const MaterialApp(
          home: Scaffold(
            body: AnnouncementDialog(notice: ParishNotice(imageUrl: _poster)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Special Announcement'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, _poster);

    final close = find.ancestor(
      of: find.byIcon(Icons.close_rounded),
      matching: find.byType(IconButton),
    );
    expect(tester.getSize(close).height, greaterThanOrEqualTo(48));

    await tester.ensureVisible(find.text('Open full size'));
    await tester.tap(find.text('Open full size'));
    expect(launcher.launchedUrls, [_poster]);
  });
}
