import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/ask_luke/data/config/ask_luke_topics.dart';
import 'package:st_luke_parish_app/features/ask_luke/presentation/screens/ask_luke_screen.dart';
import 'package:st_luke_parish_app/features/ask_luke/presentation/widgets/quick_reply_chip.dart';

/// Covers the Ask Luke screen acceptance criteria: REQ-F02-020 through
/// REQ-F02-028.
void main() {
  Future<void> pumpAskLuke(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: AskLukeScreen())),
    );
    await tester.pumpAndSettle();
  }

  group('REQ-F02-020: header, subtitle, online indicator', () {
    testWidgets('renders title, subtitle conveying required copy, and an '
        'Online indicator', (tester) async {
      await pumpAskLuke(tester);

      expect(find.text('Ask Luke'), findsWidgets); // title
      expect(find.textContaining("St Luke's Parish Assistant"), findsOneWidget);
      expect(find.textContaining('Always here to help'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });
  });

  group('REQ-F02-021: welcome bubble before any chip tap', () {
    testWidgets('shows a welcome message on initial load, before any chip '
        'is tapped', (tester) async {
      await pumpAskLuke(tester);

      expect(find.textContaining("Hi, I'm Luke!"), findsOneWidget);
      // No topic response yet.
      for (final topic in askLukeTopics) {
        expect(find.text(topic.response), findsNothing);
      }
    });
  });

  group('REQ-F02-022: exactly 4 quick-reply chips, exact order, text-only', () {
    testWidgets(
      'renders exactly 4 QuickReplyChip widgets in the required order '
      'with no icon/emoji inside each chip',
      (tester) async {
        await pumpAskLuke(tester);

        final chips = tester.widgetList<QuickReplyChip>(
          find.byType(QuickReplyChip),
        );
        expect(chips.length, 4);
        expect(chips.map((c) => c.label).toList(), [
          'Mass times',
          'Join a ministry',
          'Baptism',
          'Sacraments',
        ]);

        for (final chip in find.byType(QuickReplyChip).evaluate()) {
          final iconsInChip = find.descendant(
            of: find.byWidget(chip.widget),
            matching: find.byType(Icon),
          );
          expect(iconsInChip, findsNothing);
        }
      },
    );
  });

  group('REQ-F02-023..026: tapping each chip surfaces its exact hardcoded '
      'response', () {
    for (final topic in askLukeTopics) {
      testWidgets(
        'tapping "${topic.label}" makes its exact response text visible',
        (tester) async {
          await pumpAskLuke(tester);

          await tester.tap(find.text(topic.label));
          await tester.pumpAndSettle();

          expect(find.text(topic.response), findsOneWidget);
        },
      );
    }

    testWidgets('response strings match the BA plan verbatim', (tester) async {
      final byLabel = {for (final t in askLukeTopics) t.label: t.response};

      expect(
        byLabel['Mass times'],
        'Weekend Mass: Saturday 6:00pm (Vigil), Sunday 8:00am & 10:00am. '
        'Weekday Mass: Tuesday–Friday 9:00am. Times may vary on public '
        'holidays — please check the parish bulletin for the latest '
        'schedule.',
      );
      expect(
        byLabel['Join a ministry'],
        "St Luke's has many ministries you can get involved in, from music "
        'and hospitality to youth and outreach. Contact the parish office '
        'and our team will help you find the right fit.',
      );
      expect(
        byLabel['Baptism'],
        "We'd love to welcome your child into our parish family through "
        'Baptism. Please contact the parish office to arrange a '
        'preparation session and booking.',
      );
      expect(
        byLabel['Sacraments'],
        "St Luke's celebrates the Sacraments of Baptism, First Holy "
        'Communion, Reconciliation, Confirmation, Marriage and Anointing '
        'of the Sick. Contact the parish office for more information on '
        'preparation and scheduling.',
      );
    });
  });

  group('REQ-F02-027: no free-text input / send button anywhere', () {
    testWidgets('widget tree contains no TextField/TextFormField or send '
        'button', (tester) async {
      await pumpAskLuke(tester);

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byIcon(Icons.send), findsNothing);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
      expect(find.textContaining('Ask me anything'), findsNothing);
    });
  });

  group('REQ-F02-028: topic->response mapping is typed config', () {
    test('askLukeTopics is a typed List<AskLukeTopic>, not a dynamic map', () {
      expect(askLukeTopics, isA<List<Object>>());
      expect(askLukeTopics.length, 4);
      // Type-level check: each element exposes `label`/`response` typed
      // getters (compiles only if AskLukeTopic is the actual static type).
      for (final t in askLukeTopics) {
        expect(t.label, isA<String>());
        expect(t.response, isA<String>());
      }
    });
  });
}
