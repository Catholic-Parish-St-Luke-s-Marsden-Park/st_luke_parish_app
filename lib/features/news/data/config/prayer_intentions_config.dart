/// Static "Submit a Prayer Request" content (REQ-F05-026, REQ-F05-029).
/// The CTA URL itself lives in `ExternalLinks.prayerRequests` (core), kept
/// alongside the app's other typed external-link constants rather than
/// duplicated here.
abstract final class PrayerIntentionsConfig {
  static const String quote =
      'The prayer of a righteous person has great power. — James 5:16';

  static const String body =
      'Our youth and prayer groups are willing to support you in prayer. '
      'Submit your intentions on our website.';
}
