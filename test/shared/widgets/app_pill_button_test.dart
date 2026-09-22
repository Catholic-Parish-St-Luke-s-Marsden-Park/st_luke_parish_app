import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/app/shell/widgets/ask_luke_pill.dart';
import 'package:st_luke_parish_app/app/shell/widgets/saint_of_the_day_pill.dart';
import 'package:st_luke_parish_app/core/theme/app_colors.dart';
import 'package:st_luke_parish_app/shared/widgets/app_pill_button.dart';

/// Covers REQ-F06-018: the "Saint of the Day" pill renders with a solid
/// [AppColors.gold] background and [AppColors.textPrimary] icon/label,
/// while [AskLukePill]'s appearance (unchanged translucent-white style) is
/// not affected by [AppPillButton]'s optional color parameters.
///
/// Also covers the accessibility rules in CLAUDE.md that apply to this
/// widget: a tap target of at least 48x48 logical pixels, and no
/// hardcoded font size below 12.
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
  // finder, which would otherwise match more than one widget and fail.
  Finder inPill(Type type) => find.descendant(
    of: find.byType(AppPillButton),
    matching: find.byType(type),
  );

  /// The pill's visual fill. The coloured surface is a [DecoratedBox]
  /// rather than the [Material]'s own colour: the Material is
  /// transparent and sits outside the tap-target constraint so the ink
  /// response can cover the full 48x48 area while the coloured pill
  /// stays compact.
  BoxDecoration pillDecoration(WidgetTester tester) {
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AppPillButton),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).color != null,
        ),
      ),
    );
    return box.decoration as BoxDecoration;
  }

  group('AppPillButton defaults (unchanged for existing callers)', () {
    testWidgets('with no backgroundColor/foregroundColor, uses the original '
        'translucent-white style', (tester) async {
      await pump(tester, AppPillButton(label: 'Test', onPressed: () {}));

      expect(
        pillDecoration(tester).color,
        Colors.white.withValues(alpha: 0.14),
      );

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

      expect(pillDecoration(tester).color, AppColors.gold);

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, AppColors.textPrimary);

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.textPrimary);
    });

    testWidgets('foregroundColor alone also recolors the icon', (tester) async {
      // Regression: the icon used to consult `backgroundColor` to decide
      // whether to honour `foregroundColor`, so this combination left a
      // gold icon beside a recoloured label.
      await pump(
        tester,
        AppPillButton(
          label: 'Test',
          icon: Icons.star,
          foregroundColor: AppColors.textPrimary,
          onPressed: () {},
        ),
      );

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.textPrimary);

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.color, AppColors.textPrimary);
    });

    testWidgets('backgroundColor alone gives a white icon, not gold', (
      tester,
    ) async {
      await pump(
        tester,
        AppPillButton(
          label: 'Test',
          icon: Icons.star,
          backgroundColor: AppColors.primaryNavy,
          onPressed: () {},
        ),
      );

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, Colors.white);
    });
  });

  group('accessibility (CLAUDE.md)', () {
    // Before this widget was restructured the coloured `Material` was the
    // outermost box and shrink-wrapped its child, so the whole button —
    // and with it the `InkWell` — measured 127x30 in an AppBar. The ink
    // response now sits outside that coloured surface, so it takes the
    // toolbar's full height, and a `ConstrainedBox` holds the 48dp floor
    // anywhere the parent does not stretch it.
    testWidgets('in an AppBar, the tap target is at least 48x48', (
      tester,
    ) async {
      await pump(
        tester,
        AppPillButton(label: 'Test', icon: Icons.star, onPressed: () {}),
      );

      final target = tester.getSize(inPill(InkWell));

      expect(
        target.height,
        greaterThanOrEqualTo(AppPillButton.minTapTarget),
        reason: 'tap target height must meet the 48dp minimum',
      );
      expect(
        target.width,
        greaterThanOrEqualTo(AppPillButton.minTapTarget),
        reason: 'tap target width must meet the 48dp minimum',
      );
    });

    testWidgets('outside a stretching parent, the 48dp floor still holds', (
      tester,
    ) async {
      // The pill shrink-wraps on both axes, so nothing but the explicit
      // minimum keeps it above 48 here: neutering the ConstrainedBox
      // drops this to the ~31dp of the visual pill itself.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppPillButton(
                label: 'Test',
                icon: Icons.star,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final target = tester.getSize(inPill(InkWell));

      expect(target.height, greaterThanOrEqualTo(AppPillButton.minTapTarget));
      expect(target.width, greaterThanOrEqualTo(AppPillButton.minTapTarget));
    });

    testWidgets('the whole 48dp target is tappable, not just the pill', (
      tester,
    ) async {
      var taps = 0;
      await pump(tester, AppPillButton(label: 'Test', onPressed: () => taps++));

      // Tap near the top edge of the target, above the compact pill.
      final rect = tester.getRect(inPill(InkWell));
      await tester.tapAt(Offset(rect.center.dx, rect.top + 3));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('does not hardcode a font size below 12', (tester) async {
      await pump(tester, AppPillButton(label: 'Test', onPressed: () {}));

      final text = tester.widget<Text>(find.text('Test'));
      expect(text.style?.fontSize, greaterThanOrEqualTo(12));
    });
  });

  group('REQ-F06-018: real pill widgets', () {
    testWidgets('SaintOfTheDayPill renders with a solid gold background and '
        'textPrimary icon/label', (tester) async {
      await pump(tester, const SaintOfTheDayPill());

      expect(pillDecoration(tester).color, AppColors.gold);

      final text = tester.widget<Text>(find.text('Saint of the Day'));
      expect(text.style?.color, AppColors.textPrimary);

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.textPrimary);
    });

    testWidgets("AskLukePill's appearance is unaffected — still the original "
        'translucent-white style', (tester) async {
      await pump(tester, const AskLukePill());

      expect(
        pillDecoration(tester).color,
        Colors.white.withValues(alpha: 0.14),
      );

      final text = tester.widget<Text>(find.text('Ask Luke'));
      expect(text.style?.color, Colors.white);

      final icon = tester.widget<Icon>(inPill(Icon));
      expect(icon.color, AppColors.lightGold);
    });
  });
}
