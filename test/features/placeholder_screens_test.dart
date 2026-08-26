import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/contact/presentation/screens/contact_screen.dart';
import 'package:st_luke_parish_app/features/donate/presentation/screens/donate_screen.dart';
import 'package:st_luke_parish_app/features/masses/presentation/screens/masses_screen.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/screens/ministries_screen.dart';
import 'package:st_luke_parish_app/features/news/presentation/screens/news_screen.dart';
import 'package:st_luke_parish_app/features/prayer_request/presentation/screens/prayer_request_screen.dart';
import 'package:st_luke_parish_app/features/resources/presentation/screens/resources_screen.dart';

/// Covers REQ-F01-004: each of the remaining 7 nav destinations renders a
/// distinct placeholder screen with no build errors. "No reference to real
/// feature data" is verified by asserting each screen's own rendered
/// title/icon (its only content) rather than any live/fetched data.
///
/// `ParishScreen` was removed from this table as of feature 02-parish-tab
/// (REQ-F02-001): it no longer renders the generic `PlaceholderScreen`
/// stub, so it no longer belongs in this shared "still a placeholder"
/// table. Its own real-content coverage now lives in
/// `test/features/parish/parish_screen_test.dart`.
void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  final cases = <String, ({Widget screen, String title, IconData icon})>{
    'MassesScreen': (
      screen: const MassesScreen(),
      title: 'Masses & Events',
      icon: Icons.calendar_month_rounded,
    ),
    'NewsScreen': (
      screen: const NewsScreen(),
      title: 'News & Bulletins',
      icon: Icons.article_rounded,
    ),
    'MinistriesScreen': (
      screen: const MinistriesScreen(),
      title: 'Ministries',
      icon: Icons.groups_rounded,
    ),
    'ContactScreen': (
      screen: const ContactScreen(),
      title: 'Contact & Map',
      icon: Icons.location_on_rounded,
    ),
    'DonateScreen': (
      screen: const DonateScreen(),
      title: 'Donate',
      icon: Icons.favorite_rounded,
    ),
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

  test('all 7 destination titles are distinct from each other', () {
    final titles = cases.values.map((c) => c.title).toSet();
    expect(titles.length, cases.length);
  });
}
