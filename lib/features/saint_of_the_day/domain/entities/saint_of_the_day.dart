/// Today's Catholic saint, as served by the parish API's
/// `GET /v1/saints/{date}` (REQ-F09-008). Immutable; produced only by the
/// data layer (JSON parser or cache), never constructed ad hoc in
/// presentation code.
class SaintOfTheDay {
  const SaintOfTheDay({
    required this.name,
    required this.feast,
    required this.bornDied,
    required this.about,
    required this.saying,
    required this.didYouKnow,
    required this.patronOf,
    required this.prayer,
    required this.dateKey,
    required this.displayDate,
  });

  /// Saint's name and title, e.g. "Saint John Vianney, Priest". Never empty:
  /// a response with an empty name is rejected (REQ-F09-009).
  final String name;

  /// Feast day and liturgical rank, e.g. "August 4 - Optional Memorial".
  /// May be an empty string.
  final String feast;

  /// Birth/death years and places. May be an empty string.
  final String bornDied;

  /// A short paragraph on the saint's life, mission and significance.
  /// May be an empty string.
  final String about;

  /// One of the saint's well-known sayings. Empty when the server knows no
  /// reliably attributed saying (REQ-F09-010).
  final String saying;

  /// One lesser-known fact about the saint. May be an empty string.
  final String didYouKnow;

  /// What/who the saint is patron of. May be an empty string.
  final String patronOf;

  /// A short traditional prayer to the saint. May be an empty string.
  final String prayer;

  /// The `Australia/Sydney` calendar-date key (`YYYY-MM-DD`) this entry was
  /// served for and is cached under, taken from the server response
  /// (REQ-F09-013).
  final String dateKey;

  /// Human-readable date for the screen header, e.g. "September 1", taken
  /// from the server response (REQ-F09-013).
  final String displayDate;
}
