import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_ministries_repository.dart';

/// REQ-F08-018: the Join CTA's mailto link.
void main() {
  group('contactMailtoUri', () {
    test('encodes spaces in the subject as %20, not +', () {
      final uri = testMinistry(
        'music',
        contactEmail: 'marsdenpark@parracatholic.org',
        emailSubject: 'Music Ministry Interest',
      ).contactMailtoUri;

      expect(
        uri.toString(),
        'mailto:marsdenpark@parracatholic.org?subject=Music%20Ministry%20Interest',
      );
      expect(uri.toString(), isNot(contains('+')));
    });

    test('an empty subject leaves no query at all', () {
      final uri = testMinistry(
        'x',
        contactEmail: 'office@example.org',
        emailSubject: '',
      ).contactMailtoUri;

      expect(uri.toString(), 'mailto:office@example.org');
    });

    test('encodes reserved characters so they stay in the subject', () {
      final uri = testMinistry(
        'x',
        contactEmail: 'office@example.org',
        emailSubject: 'Faith & Fellowship? 100%',
      ).contactMailtoUri;

      expect(
        uri.toString(),
        'mailto:office@example.org?subject=Faith%20%26%20Fellowship%3F%20100%25',
      );
      expect(uri.query, 'subject=Faith%20%26%20Fellowship%3F%20100%25');
    });

    test("keeps an apostrophe, as in \"Children's Liturgy Interest\"", () {
      final uri = testMinistry(
        'childrens',
        contactEmail: 'marsdenpark@parracatholic.org',
        emailSubject: "Children's Liturgy Interest",
      ).contactMailtoUri;

      expect(
        uri.toString(),
        "mailto:marsdenpark@parracatholic.org?subject=Children's%20Liturgy%20Interest",
      );
    });

    test('round-trips through Uri.parse, as UrlLauncherService does', () {
      final uri = testMinistry(
        'x',
        contactEmail: 'office@example.org',
        emailSubject: 'Music Ministry Interest',
      ).contactMailtoUri;

      final reparsed = Uri.parse(uri.toString());
      expect(reparsed.scheme, 'mailto');
      expect(reparsed.path, 'office@example.org');
      expect(reparsed.queryParameters['subject'], 'Music Ministry Interest');
    });
  });
}
