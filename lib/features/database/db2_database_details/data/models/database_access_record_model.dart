/// Module: database / db2_database_details / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_record_model.dart
/// Description: Declares `DatabaseAccessRecordModel`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// Reads and writes one `Access_Grants` document — a database's or a
/// table's, which share the shape — as a `DatabaseAccessGrantRecord`: db1's
/// grant plus the removed members and the grantor this module adds. Both
/// data sources go through here, so the read and the write cannot disagree
/// about a key.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_access_grant_model.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/models/database_grant_fields.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/models/removed_access_member_model.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

/// Serialization of a [DatabaseAccessGrantRecord].
abstract final class DatabaseAccessRecordModel {
  /// Function Name: [fromSnapshot]
  ///
  /// Purpose: One stored grant document as a record. A missing or malformed
  /// removed-members list reads as empty.
  ///
  /// Parameters: [doc] the grant document.
  ///
  /// Returns: [DatabaseAccessGrantRecord].
  static DatabaseAccessGrantRecord fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final Object? rawRemoved = data[DatabaseGrantFields.removedMembers];
    return DatabaseAccessGrantRecord(
      id: doc.id,
      grant: DatabaseAccessGrantModel.fromMap(data),
      removedMembers: rawRemoved is List
          ? rawRemoved
              .whereType<Map<String, dynamic>>()
              .map(RemovedAccessMemberModel.fromMap)
              .toList(growable: false)
          : const <RemovedAccessMember>[],
      grantedBy: _string(data[DatabaseGrantFields.grantedBy]),
      grantedByNameEn: _string(data[DatabaseGrantFields.grantedByNameEn]),
      grantedByNameAr: _string(data[DatabaseGrantFields.grantedByNameAr]),
    );
  }

  /// Function Name: [toMap]
  ///
  /// Purpose: The document a save writes for [record]. The record's own
  /// grantor wins; [grantedBy] and its names fill in for a new grant.
  ///
  /// Parameters: [record]; [grantedBy], [grantedByNameEn], [grantedByNameAr]
  /// the person saving.
  ///
  /// Returns: [Map<String, dynamic>] with a server `updated_at`.
  static Map<String, dynamic> toMap(
    DatabaseAccessGrantRecord record, {
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) =>
      <String, dynamic>{
        ...DatabaseAccessGrantModel.toMap(record.grant),
        DatabaseGrantFields.removedMembers: record.removedMembers
            .map(RemovedAccessMemberModel.toMap)
            .toList(growable: false),
        DatabaseGrantFields.grantedBy: record.grantedBy ?? grantedBy,
        DatabaseGrantFields.grantedByNameEn:
            record.grantedByNameEn ?? grantedByNameEn,
        DatabaseGrantFields.grantedByNameAr:
            record.grantedByNameAr ?? grantedByNameAr,
        DatabaseGrantFields.updatedAt: FieldValue.serverTimestamp(),
      };

  static String? _string(Object? value) => value is String ? value : null;
}
