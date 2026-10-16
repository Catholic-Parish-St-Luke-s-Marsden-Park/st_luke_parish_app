import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/core/theme/app_theme.dart';
import 'package:st_luke_parish_app/features/ministries/domain/entities/ministry.dart';
import 'package:st_luke_parish_app/features/ministries/presentation/widgets/ministry_row.dart';

import '../../../../helpers/fake_ministries_repository.dart';

/// The compact list row that replaced the fixed-aspect-ratio grid card.
void main() {
  Future<void> pumpRow(
    WidgetTester tester,
    Ministry ministry, {
    VoidCallback? onTap,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: MinistryRow(ministry: ministry, onTap: onTap ?? () {}),
          ),
        ),
      ),
    );
  }

  testWidgets('shows only the name, not members or day', (tester) async {
    await pumpRow(
      tester,
      testMinistry('music', membersLine: '9 choirs', dayLine: 'Weekend Masses'),
    );

    expect(find.text('Name music'), findsOneWidget);
    expect(find.text('9 choirs · Weekend Masses'), findsNothing);
    expect(find.textContaining('9 choirs'), findsNothing);
    expect(find.textContaining('Weekend Masses'), findsNothing);
  });

  testWidgets('is compact: one short row, not a tall card', (tester) async {
    await pumpRow(tester, testMinistry('music'));

    // The old fixed-aspect grid card was ~210pt tall on a phone. A row is
    // its name plus padding, and never below a 48pt target.
    final height = tester.getSize(find.byType(MinistryRow)).height;
    expect(height, greaterThanOrEqualTo(48));
    expect(height, lessThan(100));
  });

  testWidgets('a tap anywhere on the row calls onTap', (tester) async {
    var taps = 0;
    await pumpRow(tester, testMinistry('music'), onTap: () => taps++);

    await tester.tap(find.byType(MinistryRow));

    expect(taps, 1);
  });

  testWidgets('reads as one button labelled with the name', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpRow(
      tester,
      testMinistry('music', membersLine: '9 choirs', dayLine: 'Weekend Masses'),
    );

    expect(
      tester.getSemantics(find.byType(MinistryRow)),
      matchesSemantics(
        label: 'Name music',
        isButton: true,
        hasTapAction: true,
        isFocusable: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('long names wrap instead of overflowing at 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 690);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 690),
            textScaler: TextScaler.linear(2.0),
          ),
          child: Scaffold(
            body: MinistryRow(
              ministry: fallbackMinistry('extraordinary-ministers'),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.text('Extraordinary Ministers of Holy Communion'),
      findsOneWidget,
    );
  });
}
