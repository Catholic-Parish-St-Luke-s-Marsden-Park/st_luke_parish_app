/// Today's Catholic saint, parsed from the model's structured text response
/// (REQ-F06-006). Immutable; produced only by
/// `OpenRouterSaintOfTheDayRepository`, never constructed ad hoc in
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

  /// Saint's name and title, e.g. "Saint John Vianney, Priest". Defaults to
  /// "Saint of the Day" if the model's response has no recognisable
  /// "SAINT NAME" section (REQ-F06-006).
  final String name;

  /// Feast day and liturgical rank, e.g. "August 4 - Optional Memorial".
  /// Empty string if the section was not present in the response.
  final String feast;

  /// Birth/death years and places. Empty string if not present.
  final String bornDied;

  /// A short paragraph on the saint's life, mission and significance.
  /// Empty string if not present.
  final String about;

  /// One of the saint's well-known quotes/sayings, if the model returned
  /// one. Empty string if not present.
  final String saying;

  /// One lesser-known fact about the saint. Empty string if not present.
  final String didYouKnow;

  /// What/who the saint is patron of. Empty string if not present.
  final String patronOf;

  /// A short traditional prayer to the saint. Empty string if not present.
  final String prayer;

  /// The `Australia/Sydney` calendar-date key (`YYYY-MM-DD`) this entry was
  /// generated for and is cached under (REQ-F06-008/REQ-F06-009).
  final String dateKey;

  /// Human-readable date for the screen header, e.g. "September 1".
  final String displayDate;
}
