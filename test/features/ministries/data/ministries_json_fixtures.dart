import 'dart:convert';

/// A single ministry as `GET /v1/ministries` returns it, with every field
/// derived from [id].
Map<String, Object?> ministryJson(String id, {String category = 'Cat A'}) => {
  'id': id,
  'category': category,
  'name': 'Name $id',
  'membersLine': 'Members $id',
  'dayLine': 'Day $id',
  'tagline': 'Tagline $id',
  'time': 'Sat 5:30pm · Sun 8am',
  'location': 'Location $id',
  'open': 'Open $id',
  'about': 'About $id\n\nSecond paragraph — $id',
  'leaderName': 'Leader $id',
  'leaderRole': 'Role $id',
  'leaderInitials': 'LI',
  'joinInfo': 'Join $id',
  'ctaLabel': 'Join $id',
  'contactEmail': 'office@example.org',
  'emailSubject': '$id Interest',
};

/// A `GET /v1/ministries` body: two categories, with ministries `a1`, `a2`
/// under "Cat A" and `b1` under "Cat B".
String ministriesBody() => jsonEncode({
  'items': [
    {
      'name': 'Cat A',
      'ministries': [ministryJson('a1'), ministryJson('a2')],
    },
    {
      'name': 'Cat B',
      'ministries': [ministryJson('b1', category: 'Cat B')],
    },
  ],
});
