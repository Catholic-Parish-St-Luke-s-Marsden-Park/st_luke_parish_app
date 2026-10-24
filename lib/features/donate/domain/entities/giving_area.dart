/// What a [GivingArea] shows as its icon; the presentation layer maps it to
/// a glyph.
enum GivingAreaKind {
  staffing,
  facilities,
  sacramental,
  formation,
  buildingFund,
}

/// One area a donation supports, e.g. "Facilities & Operations".
class GivingArea {
  const GivingArea({
    required this.title,
    required this.description,
    required this.kind,
  });

  final String title;
  final String description;
  final GivingAreaKind kind;
}
