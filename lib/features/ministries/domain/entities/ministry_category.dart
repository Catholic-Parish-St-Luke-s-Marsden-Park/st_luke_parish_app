import 'ministry.dart';

/// A heading on the Ministries tab and the ministries listed under it, in
/// the order parish staff set in the admin console.
class MinistryCategory {
  const MinistryCategory({required this.name, required this.ministries});

  final String name;
  final List<Ministry> ministries;
}
