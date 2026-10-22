/// What kind of activity a [ParishActivity] is. The presentation layer maps
/// each kind to its icon, so the domain stays free of Flutter types.
enum ParishActivityKind {
  communionToSick,
  reconciliation,
  childrensLiturgy,
  baptism,
  marriage,
  sacraments,
  youth,
  scripture,
  cuppa,
  foodStall,
  prayer,
  careCommunity,
  rosary,
  faithGroup,
  prayRosary,
}

/// A web link shown as a button on an activity, e.g. a prayer card.
class ActivityLink {
  const ActivityLink({required this.label, required this.url});

  final String label;
  final String url;
}

/// One entry in the Masses tab's "Regular Activities" section, e.g.
/// "Youth Ministry". Every detail is optional because the bulletin gives
/// different facts for different activities.
class ParishActivity {
  const ParishActivity({
    required this.title,
    required this.kind,
    this.when,
    this.where,
    this.who,
    this.description,
    this.contact,
    this.link,
    this.showsRosaryMysteries = false,
  });

  final String title;
  final ParishActivityKind kind;
  final String? when;
  final String? where;
  final String? who;
  final String? description;
  final String? contact;
  final ActivityLink? link;

  /// Adds a "The Rosary" button that opens how to pray it and the Mysteries.
  final bool showsRosaryMysteries;

  /// Every detail that has a value, in display order.
  List<String> get details => [
    ?when,
    ?where,
    ?who,
    ?description,
    ?contact,
    ?link?.label,
  ];
}
