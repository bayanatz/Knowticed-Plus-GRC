/// Module: database / db2_database_details / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_grant_fields.dart
/// Description: Declares `DatabaseGrantFields`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The extra keys this module writes on an `Access_Grants` document, kept
/// next to the grant models that read and write them.
library;

/// Keys inside an `Access_Grants` document that db1's `DatabaseAccessGrant`
/// does not know about.
///
/// `DatabaseAccessGrantModel.toMap` writes the grant itself; this module merges
/// these on top when it rewrites a document. They are named here rather than
/// inline because the write path and the read path are in different files and
/// a typo between them is a silently empty column.
abstract final class DatabaseGrantFields {
  /// People whose access was revoked — see `RemovedAccessMember`.
  static const String removedMembers = 'removed_members';

  /// Employee id of whoever granted the access ("Access Grantor").
  static const String grantedBy = 'granted_by';
  static const String grantedByNameEn = 'granted_by_name_en';
  static const String grantedByNameAr = 'granted_by_name_ar';

  /// Server timestamp of the last rewrite. Not rendered anywhere yet; written
  /// so a support question about when a grant changed has an answer that does
  /// not depend on Firestore's history being enabled.
  static const String updatedAt = 'updated_at';
}
