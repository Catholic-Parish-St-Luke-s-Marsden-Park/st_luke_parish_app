import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/shell/widgets/ask_luke_pill.dart';
import 'package:st_luke_parish_app/app/shell/widgets/saint_of_the_day_pill.dart';
import 'package:st_luke_parish_app/core/theme/app_colors.dart';
import 'package:st_luke_parish_app/shared/widgets/app_pill_button.dart';

/// Covers REQ-F06-018: the "Saint of the Day" pill renders with a solid
/// [AppColors.gold] background and [AppColors.textPrimary] icon/label,
/// while [AskLukePill]'s appearance (unchanged translucent-white style) is
/// not affected by [AppPillButton]'s new optional color parameters. No test
/// previously asserted either pill's actual rendered colors — only that
/// the widgets were present (`app_bar_chrome_test.dart`).
void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(appBar: AppBar(actions: [child])),
      ),
    );
  }

  // `MaterialApp`/`Scaffold`/`AppBar` all introduce their own `Material`
  // widgets, so every finder below is scoped to descendants of the pill
  // itself (`AppPillButton`'s own subtree) rather than an unscoped
  // `find.byType(Material)`/`find.byType(Icon)`, either of which would
  // otherwise match more than one widget and fail.
  Finder inPill(Type type) => find.descendant(
    of: find.byType(AppPillButton),
    matching: find.byType(type),
  );

  group('AppPillButton defaults (unchanged for existing callers)', () {
    testWidgets('with no backgroundColor/foregroundColor, uses the original '
        'translucent-white style', (tester) async {
      await pump(tester, AppPillButton(label: 'Test', onPressed: () {}));

      final material = tester.widget<Material>(inPill(Material));
      expect(material.color, Colors.white.withValues(alpha: 0.14));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('with an icon and no backgroundColor, the icon uses '
        'AppColors.lightGold', (tester) async {
      await pump(
        tester,
        AppPillButton(label: 'Test', icon: Icons.star, onPressed: () {}),
      );

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.lightGold);
    });
  });

  group('AppPillButton with explicit colors', () {
    testWidgets('renders the supplied backgroundColor and foregroundColor', (
      tester,
    ) async {
      await pump(
        tester,
        AppPillButton(
          label: 'Test',
          icon: Icons.star,
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.textPrimary,
          onPressed: () {},
        ),
      );

      final material = tester.widget<Material>(inPill(Material));
      expect(material.color, AppColors.gold);

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, AppColors.textPrimary);

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.textPrimary);
    });
  });

  group('REQ-F06-018: real pill widgets', () {
    testWidgets('SaintOfTheDayPill renders with a solid gold background and '
        'textPrimary icon/label', (tester) async {
      await pump(tester, const SaintOfTheDayPill());

      final material = tester.widget<Material>(inPill(Material));
      expect(material.color, AppColors.gold);

      final text = tester.widget<Text>(find.text('Saint of the Day'));
      expect(text.style?.color, AppColors.textPrimary);

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.textPrimary);
    });

    testWidgets("AskLukePill's appearance is unaffected — still the original "
        'translucent-white style', (tester) async {
      await pump(tester, const AskLukePill());

      final material = tester.widget<Material>(inPill(Material));
      expect(material.color, Colors.white.withValues(alpha: 0.14));

      final text = tester.widget<Text>(find.text('Ask Luke'));
      expect(text.style?.color, Colors.white);

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.lightGold);
    });
  });
}
