/// A single parish ministry/group shown on the Ministries tab.
///
/// Loaded from the parish API (`GET /v1/ministries`), or from the cached or
/// bundled copy of that response when offline.
class Ministry {
  const Ministry({
    required this.id,
    required this.category,
    required this.name,
    required this.membersLine,
    required this.dayLine,
    required this.tagline,
    required this.time,
    required this.location,
    required this.open,
    required this.about,
    required this.leaderName,
    required this.leaderRole,
    required this.leaderInitials,
    required this.joinInfo,
    required this.ctaLabel,
    required this.contactEmail,
    required this.emailSubject,
  });

  /// Stable slug, e.g. `music`, `sacramental`. Never changes, so it is safe
  /// as a key and in deep links.
  final String id;

  /// Name of the category this ministry is listed under.
  final String category;

  final String name;

  /// Short line shown on the grid card, e.g. "9 choirs".
  final String membersLine;

  /// Short line shown on the grid card, e.g. "Weekend Masses".
  final String dayLine;

  final String tagline;
  final String time;
  final String location;
  final String open;
  final String about;
  final String leaderName;
  final String leaderRole;
  final String leaderInitials;
  final String joinInfo;
  final String ctaLabel;

  /// Address the "Join" CTA emails, e.g. `marsdenpark@parracatholic.org`.
  final String contactEmail;

  /// Subject line for the "Join" email. May be empty.
  final String emailSubject;

  /// `mailto:` link for the "Join" CTA.
  ///
  /// The subject is encoded by hand rather than through `queryParameters`,
  /// which encodes spaces as `+` that some mail apps show literally.
  Uri get contactMailtoUri => Uri(
    scheme: 'mailto',
    path: contactEmail,
    query: emailSubject.isEmpty
        ? null
        : 'subject=${Uri.encodeComponent(emailSubject)}',
  );
}
