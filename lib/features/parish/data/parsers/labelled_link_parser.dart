import 'package:html/parser.dart' as html_parser;

import '../selectors/parish_home_selectors.dart';

/// Finds the link described by [selector] in [html] and returns its
/// [LabelledLinkSelector.attribute], resolved against [baseUri] so a
/// relative link becomes absolute. Returns `null` when no link matches or
/// the matching link has no usable attribute.
String? parseLabelledLink(
  String html,
  LabelledLinkSelector selector, {
  required Uri baseUri,
}) {
  final document = html_parser.parse(html);
  for (final element in document.querySelectorAll(selector.selector)) {
    final label = element.text.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    if (!selector.labelContains.every(label.contains)) continue;

    final value = element.attributes[selector.attribute]?.trim();
    if (value == null || value.isEmpty) continue;
    final uri = Uri.tryParse(value);
    if (uri == null) continue;
    return baseUri.resolveUri(uri).toString();
  }
  return null;
}
