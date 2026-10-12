import 'dart:convert';

import '../models/problem_details.dart';

/// Reads an RFC 9457 problem body (REQ-F09-005). Tolerant by design: it
/// never throws. A body that is empty, not JSON, or not a JSON object
/// yields `null`; an ill-typed member is simply left out.
ProblemDetails? parseProblemDetails(String body) {
  if (body.trim().isEmpty) return null;
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded is! Map<String, dynamic>) return null;
  final Map<String, dynamic> json = decoded;

  String? string(String key) {
    final value = json[key];
    return value is String && value.trim().isNotEmpty ? value : null;
  }

  final status = json['status'];
  return ProblemDetails(
    status: status is int ? status : null,
    code: string('code'),
    title: string('title'),
    requestId: string('requestId'),
  );
}
