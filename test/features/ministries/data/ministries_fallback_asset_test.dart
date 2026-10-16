import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:st_luke_parish_app/features/ministries/data/datasources/bundled_ministries_source.dart';
import 'package:st_luke_parish_app/features/ministries/data/parsers/ministries_json_parser.dart';

import '../../../helpers/fake_ministries_repository.dart';

/// REQ-F08-011 and REQ-F08-019: the bundled `GET /v1/ministries` snapshot
/// holds the 25 ministries in 4 categories, in the order of the parish
/// ministry list (Ministries.pdf).
///
/// When the snapshot is refreshed at release time (README > Parish API) and
/// staff have changed ministries, these expectations change with it.
void main() {
  final categories = loadFallbackMinistries();
  final ministries = categories.expand((c) => c.ministries).toList();

  test('exactly 4 categories, in order', () {
    expect(categories.map((c) => c.name), [
      'Liturgical Ministries',
      'Church Ministries',
      'Community Building & Outreach',
      'Evangelisation Ministries',
    ]);
  });

  test('exactly 25 ministries with unique ids', () {
    expect(ministries, hasLength(25));
    expect(ministries.map((m) => m.id).toSet(), hasLength(25));
  });

  test('exact id/name pairs, in order, under each category', () {
    const expected = {
      'Liturgical Ministries': {
        'ministers-at-the-altar': 'Ministers at the Altar',
        'altar-servers': 'Altar Servers',
        'extraordinary-ministers': 'Extraordinary Ministers of Holy Communion',
        'readers-commentators': 'Readers & Commentators',
        'childrens-liturgy': "Children's Liturgy",
        'collectors': 'Collectors',
        'music-ministry': 'Music',
        'prayer-group': 'Prayer Group',
      },
      'Church Ministries': {
        'church-cleaning': 'Church Cleaning',
        'flowers': 'Flowers',
        'counting': 'Counting',
        'church-maintenance': 'Church Maintenance',
        'logistics-ministry': 'Logistics',
        'ict-ministry': 'Information and Communication Technology (ICT)',
      },
      'Community Building & Outreach': {
        'pastoral-care-of-the-sick': 'Pastoral Care of the Sick',
        'youth-ministry': 'Youth',
        'fundraising-ministry': 'Fundraising',
        'hospitality-ministry': 'Hospitality',
        'welcome-ministry': 'Welcome',
        'social-media': 'Social Media',
        'safeguarding': 'Safeguarding',
      },
      'Evangelisation Ministries': {
        'ocia-ocic': 'OCIA/OCIC',
        'sre-ministry': 'SRE',
        'sacramental-programme': 'Sacramental Programme',
        'bible-study': 'Bible Study',
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

  test('leads are first names only; ministries with no lead use the parish '
      'office', () {
    final byId = {for (final m in ministries) m.id: m};

    expect(byId['music-ministry']!.leaderName, 'Annah');
    expect(byId['collectors']!.leaderName, 'John and Juanita');
    expect(
      byId['fundraising-ministry']!.leaderName,
      'Cherryll, Christine, Deanne and Christina',
    );
    for (final id in ['church-cleaning', 'flowers', 'bible-study']) {
      expect(byId[id]!.leaderName, 'Parish Office', reason: id);
    }
    for (final m in ministries) {
      expect(m.leaderName.trim(), isNotEmpty, reason: m.id);
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
    final sacramental = fallbackMinistry('sacramental-programme');

    expect(sacramental.contactEmail, 'sacraments@stlukesmarsdenpark.org.au');
    expect(sacramental.emailSubject, 'Sacramental Programme Interest');
  });

  test('the other 24 ministries use marsdenpark@parracatholic.org with a '
      'subject', () {
    final others = ministries
        .where((m) => m.id != 'sacramental-programme')
        .toList();

    expect(others, hasLength(24));
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
