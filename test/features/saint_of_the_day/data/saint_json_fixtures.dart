import 'dart:convert';

/// A complete `Saint` payload as served by `GET /v1/saints/{date}`, shaped
/// like the live response checked on 2026-10-12 (empty `saying`).
Map<String, dynamic> saintPayload({
  String dateKey = '2026-10-12',
  Map<String, Object?> overrides = const {},
  List<String> without = const [],
}) {
  final payload = <String, dynamic>{
    'name': 'Saint Wilfrid, Bishop',
    'feast': 'October 12 - Optional Memorial',
    'bornDied': 'c. 633, Northumbria - 709, Oundle',
    'about': 'A bishop of York who championed Roman customs in England.',
    'saying': '',
    'didYouKnow': 'He evangelised the South Saxons.',
    'patronOf': 'Middlesbrough',
    'prayer': 'Saint Wilfrid, pray for us.',
    'dateKey': dateKey,
    'displayDate': 'October 12',
    ...overrides,
  };
  for (final key in without) {
    payload.remove(key);
  }
  return payload;
}

String saintJson({
  String dateKey = '2026-10-12',
  Map<String, Object?> overrides = const {},
  List<String> without = const [],
}) => jsonEncode(
  saintPayload(dateKey: dateKey, overrides: overrides, without: without),
);

/// An RFC 9457 problem body like the parish API's.
String problemJson({
  required int status,
  required String code,
  String? requestId,
}) => jsonEncode({
  'type': 'https://parish-app-service.fly.dev/problems/$code',
  'title': 'Problem $code',
  'status': status,
  'code': code,
  'requestId': ?requestId,
});
