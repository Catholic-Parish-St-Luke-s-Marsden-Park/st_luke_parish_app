import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

/// Guards the portrait-only lock. No screen is laid out for landscape, and
/// the lock lives in native config rather than Dart, so nothing else in the
/// test suite would notice it being reverted (for example by a
/// `flutter create` regenerating the platform files).
void main() {
  test('Android MainActivity is locked to portrait', () {
    final manifest = XmlDocument.parse(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
    );
    final mainActivity = manifest
        .findAllElements('activity')
        .singleWhere((e) => e.getAttribute('android:name') == '.MainActivity');

    expect(mainActivity.getAttribute('android:screenOrientation'), 'portrait');
  });

  group('iOS Info.plist', () {
    late Map<String, XmlElement> plist;

    setUpAll(() {
      final document = XmlDocument.parse(
        File('ios/Runner/Info.plist').readAsStringSync(),
      );
      final entries = document.rootElement
          .getElement('dict')!
          .childElements
          .toList();
      // A plist dict alternates <key> elements with their value elements.
      plist = {
        for (var i = 0; i < entries.length; i += 2)
          entries[i].innerText: entries[i + 1],
      };
    });

    List<String> orientations(String key) =>
        plist[key]!.childElements.map((e) => e.innerText).toList();

    test('iPhone supports portrait only', () {
      expect(orientations('UISupportedInterfaceOrientations'), [
        'UIInterfaceOrientationPortrait',
      ]);
    });

    test('iPad supports portrait only', () {
      expect(orientations('UISupportedInterfaceOrientations~ipad'), [
        'UIInterfaceOrientationPortrait',
      ]);
    });

    test('iPad requires full screen, which App Store validation needs for a '
        'portrait-only iPad app', () {
      expect(plist['UIRequiresFullScreen']?.name.local, 'true');
    });
  });
}
