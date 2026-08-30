import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/prayer_request/presentation/screens/prayer_request_screen.dart';
import 'package:st_luke_parish_app/features/resources/presentation/screens/resources_screen.dart';

/// Covers REQ-F01-004: each of the remaining nav destinations renders a
/// distinct placeholder screen with no build errors. "No reference to real
/// feature data" is verified by asserting each screen's own rendered
/// title/icon (its only content) rather than any live/fetched data.
///
/// `ParishScreen` was removed from this table as of feature 02-parish-tab
/// (REQ-F02-001): it no longer renders the generic `PlaceholderScreen`
/// stub, so it no longer belongs in this shared "still a placeholder"
/// table. Its own real-content coverage now lives in
/// `test/features/parish/parish_screen_test.dart`.
///
/// `MinistriesScreen`, `ContactScreen`, and `DonateScreen` were removed from
/// this table as of feature 03-multi-pages (REQ-F03-001/011/019): none of
/// the three renders the generic `PlaceholderScreen` stub any longer. Their
/// own real-content coverage now lives in
/// `test/features/ministries/ministries_screen_test.dart`,
/// `test/features/ministries/ministry_detail_screen_test.dart`,
/// `test/features/contact/contact_screen_test.dart`, and
/// `test/shared/webview/simple_webview_screen_test.dart`
/// (+ `test/features/donate/donate_screen_test.dart`).
///
/// `MassesScreen` was removed from this table as of feature 04-masses-tab
/// (REQ-F04-001): it no longer renders the generic `PlaceholderScreen`
/// stub either. Its own real-content coverage now lives in
/// `test/features/masses/masses_screen_test.dart`.
///
/// `NewsScreen` was removed from this table as of feature 05-news-tab
/// (REQ-F05-031): it no longer renders the generic `PlaceholderScreen`
/// stub either. Its own real-content coverage now lives in
/// `test/features/news/presentation/screens/news_screen_test.dart`.
void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  final cases = <String, ({Widget screen, String title, IconData icon})>{
    'ResourcesScreen': (
      screen: const ResourcesScreen(),
      title: 'Resources',
      icon: Icons.menu_book_rounded,
    ),
    'PrayerRequestScreen': (
      screen: const PrayerRequestScreen(),
      title: 'Prayer Request',
      icon: Icons.favorite_border_rounded,
    ),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key} builds without error and shows its own '
        'distinct placeholder title/icon', (tester) async {
      await pumpScreen(tester, entry.value.screen);

      expect(tester.takeException(), isNull);
      // Resources/PrayerRequest wrap the shared PlaceholderScreen in their
      // own Scaffold+AppBar, so the title text appears twice (AppBar title
      // + placeholder body title); the other 5 destinations show it once.
      expect(find.text(entry.value.title), findsAtLeastNWidgets(1));
      expect(find.byIcon(entry.value.icon), findsOneWidget);
    });
  }

  test('all remaining destination titles are distinct from each other', () {
    final titles = cases.values.map((c) => c.title).toSet();
    expect(titles.length, cases.length);
  });
}
