import 'package:xml/xml.dart';

import '../../domain/failures/bulletins_failure.dart';

/// Raw shape produced straight from the WordPress bulletins RSS feed,
/// deliberately kept separate from the `domain` `Bulletin` entity — mapping,
/// URL validation, and sorting happen in `FeedBulletinsRepository`, not
/// here. Ported from the working reference app's `rss_bulletin_parser.dart`
/// (see `.claude/decisions/0004-news-rss-regex-vs-css-selector.md`).
class RawBulletinFeedItem {
  const RawBulletinFeedItem({
    required this.title,
    required this.pageUrl,
    required this.pdfUrl,
    required this.pubDate,
  });

  final String title;
  final String pageUrl;
  final String pdfUrl;
  final DateTime? pubDate;
}

const _maxBulletinItems = 6;

final _pdfHrefPattern = RegExp(
  r'href="([^"]+\.pdf[^"]*)"',
  caseSensitive: false,
);

/// Parses a WordPress category RSS feed (e.g.
/// `https://stlukesmarsdenpark.org.au/category/bulletins/feed/`) into
/// bulletin items, capped at the first 6 `<item>` elements (REQ-F05-002).
///
/// The PDF download link is extracted from the post content
/// (`content:encoded`, falling back to `description`) since the RSS
/// `<link>` element only points at the post's page, not the PDF file
/// itself (REQ-F05-003); if no PDF link is found there, [RawBulletinFeedItem
/// .pdfUrl] falls back to the item's `<link>` (REQ-F05-004).
///
/// Throws [BulletinsParsingFailure] if [xmlBody] is not well-formed XML.
/// Per-item issues (e.g. an unparseable `pubDate`) are handled explicitly
/// and do not throw (REQ-F05-005).
List<RawBulletinFeedItem> parseBulletinsRss(String xmlBody) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(xmlBody);
  } on XmlException catch (e) {
    throw BulletinsParsingFailure('Malformed bulletins feed XML: $e');
  }

  final items = document.findAllElements('item').take(_maxBulletinItems);

  final results = <RawBulletinFeedItem>[];
  for (final item in items) {
    final title = _normalizeWhitespace(_text(item, 'title'));
    final link = _text(item, 'link').trim();
    final pubDateRaw = _text(item, 'pubDate');

    final contentEncoded = _text(item, 'content:encoded');
    final content = contentEncoded.isNotEmpty
        ? contentEncoded
        : _text(item, 'description');

    final pdfMatch = _pdfHrefPattern.firstMatch(content);
    final pdfUrl = pdfMatch != null ? pdfMatch.group(1)!.trim() : link;

    results.add(
      RawBulletinFeedItem(
        title: title,
        pageUrl: link,
        pdfUrl: pdfUrl,
        pubDate: _tryParseRfc822(pubDateRaw),
      ),
    );
  }
  return results;
}

String _text(XmlElement item, String tagName) {
  final matches = item.findElements(tagName);
  if (matches.isEmpty) return '';
  return matches.first.innerText;
}

String _normalizeWhitespace(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ');

DateTime? _tryParseRfc822(String value) {
  if (value.trim().isEmpty) return null;
  try {
    return _Rfc822.parse(value);
  } catch (_) {
    return null;
  }
}

/// Minimal RFC 822/1123 date parser matching the format WordPress uses for
/// `<pubDate>`. Self-contained (rather than depending on `dart:io`'s
/// `HttpDate`) so the parser has no platform-specific I/O dependency.
abstract final class _Rfc822 {
  static final _pattern = RegExp(
    r'^\w+,\s+(\d{1,2})\s+(\w+)\s+(\d{4})\s+(\d{2}):(\d{2}):(\d{2})\s+(.*)$',
  );

  static const _months = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };

  static DateTime parse(String value) {
    final match = _pattern.firstMatch(value.trim());
    if (match == null) {
      throw FormatException('Not an RFC 822 date: $value');
    }
    final day = int.parse(match.group(1)!);
    final month = _months[match.group(2)!];
    if (month == null) {
      throw FormatException('Unrecognized month in RFC 822 date: $value');
    }
    final year = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);
    // WordPress RSS pubDate is typically GMT/UTC; treat as UTC.
    return DateTime.utc(year, month, day, hour, minute, second);
  }
}
