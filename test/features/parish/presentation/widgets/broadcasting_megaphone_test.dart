import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/parish/presentation/widgets/broadcasting_megaphone.dart';

void main() {
  tearDown(() => BroadcastingMegaphone.disableForTesting = true);

  Future<void> pump(WidgetTester tester, {bool reduceMotion = false}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: BroadcastingMegaphone(color: Colors.black)),
        ),
      ),
    );
  }

  testWidgets('the sound lines keep bursting out', (tester) async {
    BroadcastingMegaphone.disableForTesting = false;
    await pump(tester);

    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('holds still when the phone asks for reduced motion', (
    tester,
  ) async {
    BroadcastingMegaphone.disableForTesting = false;
    await pump(tester, reduceMotion: true);

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
