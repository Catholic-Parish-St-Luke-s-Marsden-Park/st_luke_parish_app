import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/ministries/data/datasources/bundled_ministries_source.dart';
import 'package:st_luke_parish_app/features/ministries/data/parsers/ministries_json_parser.dart';

import '../../../helpers/fake_ministries_repository.dart';

/// REQ-F08-011 and REQ-F08-019: the bundled `GET /v1/ministries` snapshot
/// holds the same 16 ministries in 4 categories, in order, as the static
/// config it replaced. These replace the old REQ-F03-002 "16 / 4" checks.
///
/// When the snapshot is refreshed at release time (README > Parish API) and
/// staff have changed ministries, these expectations change with it.
void main() {
  final categories = loadFallbackMinistries();
  final ministries = categories.expand((c) => c.ministries).toList();

  test('exactly 4 categories, in order', () {
    expect(categories.map((c) => c.name), [
      'Liturgy & Worship',
      'Children & Youth',
      'Community & Outreach',
      'Operations & Governance',
    ]);
  });

  test('exactly 16 ministries with unique ids', () {
    expect(ministries, hasLength(16));
    expect(ministries.map((m) => m.id).toSet(), hasLength(16));
  });

  test('exact id/name pairs, in order, under each category', () {
    const expected = {
      'Liturgy & Worship': {
        'music': 'Music Ministry',
        'liturgical': 'Liturgical Ministry',
        'altar': 'Ministers of the Altar',
        'emohc': 'Extraordinary Ministers of Holy Communion',
      },
      'Children & Youth': {
        'youth': 'Luke-18',
        'childrens': "Children's Liturgy",
        'sacramental': 'Sacramental Process',
        'sre': 'SRE Ministry',
      },
      'Community & Outreach': {
        'welcome': 'Welcome Ministry',
        'hospitality': 'Hospitality Team',
        'fundraising': 'Fundraising Team',
        'scripture': 'Walking with Christ',
      },
      'Operations & Governance': {
        'finance': 'Finance Committee',
        'ict': 'ICT Committee',
        'logistics': 'Logistics Team',
        'maintenance': 'Maintenance Ministry',
      },
    };

    for (final category in categories) {
      final pairs = [for (final m in category.ministries) (m.id, m.name)];
      final want = [
        for (final e in expected[category.name]!.entries) (e.key, e.value),
      ];
      expect(pairs, want, reason: category.name);
    }
  });

  test("every ministry's category field matches its heading", () {
    for (final category in categories) {
      for (final ministry in category.ministries) {
        expect(ministry.category, category.name, reason: ministry.id);
      }
    }
  });

  test('REQ-F03-008: sacramental uses the distinct sacraments@ address', () {
    final sacramental = fallbackMinistry('sacramental');

    expect(sacramental.contactEmail, 'sacraments@stlukesmarsdenpark.org.au');
    expect(sacramental.emailSubject, 'Sacramental Programme 2026');
  });

  test('the other 15 ministries use marsdenpark@parracatholic.org with a '
      'subject', () {
    final others = ministries.where((m) => m.id != 'sacramental').toList();

    expect(others, hasLength(15));
    for (final ministry in others) {
      expect(
        ministry.contactEmail,
        'marsdenpark@parracatholic.org',
        reason: ministry.id,
      );
      expect(ministry.emailSubject, isNotEmpty, reason: ministry.id);
    }
  });

  testWidgets('the asset is registered in pubspec.yaml and loads from the '
      'bundle', (tester) async {
    final json = await rootBundle.loadString(BundledMinistriesSource.assetPath);

    expect(parseMinistriesJson(json), hasLength(4));
  });
}
