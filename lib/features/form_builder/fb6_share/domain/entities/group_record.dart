/// Module: form_builder_module/f7_share
///
///*************************** FILE INFO ****************************///
/// File Name: group_record.dart
/// Description: `GroupRecord`, a saved group as the domain sees it (latest
///              name, description and image, and the emails of its active
///              members). The repository builds it from the Firestore model.
/// Author: Amr Mesbah
/// Created at: 19/10/2026
library;

/// A saved group: latest name, description and image, active members.
class GroupRecord {
  /// The group id.
  final String id;

  /// The latest name.
  final String name;

  /// The latest description.
  final String description;

  /// The latest image URL, or null.
  final String? image;

  /// Emails of the members who are still active, in order.
  final List<String> activeMemberEmails;

  const GroupRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.activeMemberEmails,
  });
}
