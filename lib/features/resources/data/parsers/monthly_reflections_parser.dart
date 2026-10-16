import 'package:html/parser.dart' as html_parser;

import '../../domain/entities/monthly_reflection.dart';
import '../selectors/reflections_selectors.dart';

/// Every monthly booklet link in [html] (links labelled "Month YYYY"),
/// resolved against [baseUri]. Links with any other label are ignored.
/// Listed in page order; the caller picks which month to show.
List<MonthlyReflection> parseMonthlyReflections(
  String html, {
  required Uri baseUri,
}) {
  final document = html_parser.parse(html);
  final reflections = <MonthlyReflection>[];
  for (final element in document.querySelectorAll(
    ReflectionsSelectors.linkSelector,
  )) {
    final label = element.text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final match = ReflectionsSelectors.monthLabel.firstMatch(label);
    if (match == null) continue;

    final href = element.attributes['href']?.trim();
    if (href == null || href.isEmpty) continue;
    final uri = Uri.tryParse(href);
    if (uri == null) continue;

    final month =
        ReflectionsSelectors.monthNames.indexOf(match.group(1)!.toLowerCase()) +
        1;
    reflections.add(
      MonthlyReflection(
        label: label,
        month: DateTime(int.parse(match.group(2)!), month),
        url: baseUri.resolveUri(uri).toString(),
      ),
    );
  }
  return reflections;
}
