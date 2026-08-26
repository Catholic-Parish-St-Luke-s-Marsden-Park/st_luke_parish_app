import 'church_leadership_entry.dart';

/// One named part of the 3-part "Church Leadership" section (Universal
/// Church, Diocese of Parramatta, Parish), each containing one or more
/// [ChurchLeadershipEntry] rows.
class ChurchLeadershipSection {
  const ChurchLeadershipSection({required this.title, required this.entries});

  final String title;
  final List<ChurchLeadershipEntry> entries;
}
