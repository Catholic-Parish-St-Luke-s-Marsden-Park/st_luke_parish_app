import 'dart:convert';

import '../../domain/entities/ministry.dart';
import '../../domain/entities/ministry_category.dart';
import '../../domain/failures/ministries_failure.dart';

/// Parses a `GET /v1/ministries` body (or a cached/bundled copy of one) into
/// categories, keeping the API's order. Unknown fields are ignored; a
/// missing or ill-typed required field throws [MinistriesParsingFailure]
/// naming its path, e.g. `items[0].ministries[2].name`.
List<MinistryCategory> parseMinistriesJson(String body) {
  final root = _asObject(_decode(body), r'$');
  final items = _require<List<dynamic>>(root, 'items', r'$');
  return [
    for (var i = 0; i < items.length; i++)
      _parseCategory(items[i], 'items[$i]'),
  ];
}

/// Parses a `GET /v1/ministries/{id}` body into a single [Ministry].
Ministry parseMinistryJson(String body) => _parseMinistry(_decode(body), r'$');

Object? _decode(String body) {
  try {
    return jsonDecode(body);
  } on FormatException catch (e) {
    throw MinistriesParsingFailure('Response is not valid JSON: ${e.message}');
  }
}

MinistryCategory _parseCategory(Object? value, String path) {
  final json = _asObject(value, path);
  final ministries = _require<List<dynamic>>(json, 'ministries', path);
  return MinistryCategory(
    name: _require<String>(json, 'name', path),
    ministries: [
      for (var i = 0; i < ministries.length; i++)
        _parseMinistry(ministries[i], '$path.ministries[$i]'),
    ],
  );
}

Ministry _parseMinistry(Object? value, String path) {
  final json = _asObject(value, path);
  String field(String key) => _require<String>(json, key, path);

  final id = field('id');
  if (id.trim().isEmpty) {
    throw MinistriesParsingFailure('$path.id is empty');
  }
  return Ministry(
    id: id,
    category: field('category'),
    name: field('name'),
    membersLine: field('membersLine'),
    dayLine: field('dayLine'),
    tagline: field('tagline'),
    time: field('time'),
    location: field('location'),
    open: field('open'),
    about: field('about'),
    leaderName: field('leaderName'),
    leaderRole: field('leaderRole'),
    leaderInitials: field('leaderInitials'),
    joinInfo: field('joinInfo'),
    ctaLabel: field('ctaLabel'),
    contactEmail: field('contactEmail'),
    emailSubject: field('emailSubject'),
  );
}

Map<String, dynamic> _asObject(Object? value, String path) {
  if (value is Map<String, dynamic>) return value;
  throw MinistriesParsingFailure('$path is not a JSON object');
}

T _require<T>(Map<String, dynamic> json, String key, String path) {
  final value = json[key];
  if (value is T) return value;
  throw MinistriesParsingFailure(
    value == null ? '$path.$key is missing' : '$path.$key is not a $T',
  );
}
