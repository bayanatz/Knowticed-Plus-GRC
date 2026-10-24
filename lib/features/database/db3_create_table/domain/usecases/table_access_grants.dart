/// Module: database / db3_create_table / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_grants.dart
/// Description: Declares `TableAccessGrants`.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
///
/// The pure half of the table access screens: folding a table's grant
/// documents into the one rule the screens edit, and turning that rule back
/// into the documents a save writes. Moved out of `TableAccessCubit` so the
/// cubit keeps to loading, editing and saving, and stays under the file-size
/// rule (rule 7). No Flutter, no Firestore — plain functions over entities.
library;

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';

/// The pure operations of the table access screens: reading grant documents
/// into the one rule the screens edit, and writing that rule back.
abstract final class TableAccessGrants {
  /// Function Name: [rulesByMember]
  ///
  /// Purpose: Each member's level and dates as loaded, so a save does not
  /// flatten several groups onto the first one's rule (DB-TABLE-07).
  ///
  /// Parameters: [records] the table's grant documents.
  ///
  /// Returns: [Map<String, DatabaseAccessGrant>] employee id -> their grant.
  static Map<String, DatabaseAccessGrant> rulesByMember(
    List<DatabaseAccessGrantRecord> records,
  ) {
    final Map<String, DatabaseAccessGrant> out =
        <String, DatabaseAccessGrant>{};
    for (final DatabaseAccessGrantRecord record in records) {
      for (final DatabaseMember member in record.grant.members) {
        out.putIfAbsent(member.employeeId, () => record.grant);
      }
    }
    return out;
  }

  /// Function Name: [fieldsByMember]
  ///
  /// Purpose: Employee id -> the columns THAT person's own grant lets them see.
  ///
  /// The subcollection holds one document per distinct rule (see [recordsToWrite]), so
  /// this is the read half of that split: it unpacks the documents back into
  /// the per-person map the review screen edits.
  ///
  /// A member listed on two records keeps the FIRST one's fields rather than a
  /// union — a union would silently widen what somebody can see, which is the
  /// wrong direction to be wrong in on an access screen.
  ///
  /// Returns: [Map] employee id -> column ids.
  static Map<String, List<String>> fieldsByMember(
    List<DatabaseAccessGrantRecord> records,
  ) {
    final Map<String, List<String>> out = <String, List<String>>{};
    for (final DatabaseAccessGrantRecord record in records) {
      for (final DatabaseMember member in record.grant.members) {
        out.putIfAbsent(
          member.employeeId,
          () => List<String>.unmodifiable(record.grant.viewableFields),
        );
      }
    }
    return out;
  }

  /// Function Name: [merge]
  ///
  /// Purpose: Fold however many grant documents exist into the one rule this
  /// screen edits: every person, the first level and window anyone was given,
  /// and the union of the field restrictions. Each person's own fields and
  /// rule are kept separately by [fieldsByMember] and [rulesByMember].
  ///
  /// Parameters: [records] the table's grant documents.
  ///
  /// Returns: [DatabaseAccessGrant] the merged rule.
  static DatabaseAccessGrant merge(List<DatabaseAccessGrantRecord> records) {
    if (records.isEmpty) {
      return const DatabaseAccessGrant(members: <DatabaseMember>[]);
    }
    if (records.length == 1) return records.first.grant;

    final Set<DatabaseMember> members = <DatabaseMember>{};
    final Set<String> fields = <String>{};
    DatabasePermissionLevel? permission;
    DateTime? start;
    DateTime? end;

    for (final DatabaseAccessGrantRecord record in records) {
      members.addAll(record.grant.members);
      fields.addAll(record.grant.viewableFields);
      permission ??= record.grant.permission;
      start ??= record.grant.startDate;
      end ??= record.grant.endDate;
    }

    return DatabaseAccessGrant(
      members: members.toList(growable: false),
      permission: permission,
      startDate: start,
      endDate: end,
      viewableFields: fields.toList(growable: false),
    );
  }

  /// Function Name: [recordsToWrite]
  ///
  /// Purpose: The grant documents a save writes for [grant] — one per
  /// distinct rule — or none when nobody is on it and nobody was removed.
  ///
  /// Parameters: [grant] the rule on screen; [loaded] the rule as loaded
  /// (null for a table never granted); [memberRules] each loaded member's own
  /// level and dates; [fieldsFor] the columns one member may see; [recordId]
  /// the document id the rule was loaded under; [removedMembers] the removal
  /// history; [grantedBy] who is saving.
  ///
  /// Returns: [List<DatabaseAccessGrantRecord>].
  static List<DatabaseAccessGrantRecord> recordsToWrite({
    required DatabaseAccessGrant grant,
    required DatabaseAccessGrant? loaded,
    required Map<String, DatabaseAccessGrant> memberRules,
    required List<String> Function(DatabaseMember member) fieldsFor,
    required String recordId,
    required List<RemovedAccessMember> removedMembers,
    required String? grantedBy,
  }) {
    // ONE RECORD PER DISTINCT RULE — the same Viewable Fields, level and
    // dates. The review screen gives every person their own Viewable Fields,
    // and each person keeps the level and dates they were loaded with unless
    // the screen changed that field (below), so people whose rules differ end
    // up on different records. Ten people with the same rule are one record.
    final Map<String, List<DatabaseMember>> byFields =
        <String, List<DatabaseMember>>{};
    final Map<String, List<String>> fieldsByKey = <String, List<String>>{};

    // Each person keeps the level and dates they were loaded with, unless the
    // screen changed that field (DB-TABLE-07). Merging several grant documents
    // on load used to write the FIRST group's rule back onto everyone.
    final DatabaseAccessGrant? loadedRule = loaded;
    final bool permissionEdited =
        loadedRule == null || grant.permission != loadedRule.permission;
    final bool startEdited =
        loadedRule == null || grant.startDate != loadedRule.startDate;
    final bool endEdited =
        loadedRule == null || grant.endDate != loadedRule.endDate;
    final Map<String, DatabaseAccessGrant> ruleByKey =
        <String, DatabaseAccessGrant>{};

    for (final DatabaseMember member in grant.members) {
      final List<String> fields = List<String>.of(fieldsFor(member))..sort();
      final DatabaseAccessGrant? own = memberRules[member.employeeId];
      final DatabaseAccessGrant rule = grant.copyWith(
        permission:
            permissionEdited || own == null ? grant.permission : own.permission,
        startDate: startEdited || own == null ? grant.startDate : own.startDate,
        endDate: endEdited || own == null ? grant.endDate : own.endDate,
      );
      // Sorted before joining, so the same set picked in a different order is
      // still one bucket rather than two rules that happen to agree. The rule
      // is part of the key: two levels are two documents.
      final String key = <String>[
        fields.join('\u0000'),
        rule.permission?.storageKey ?? '',
        rule.startDate?.toIso8601String() ?? '',
        rule.endDate?.toIso8601String() ?? '',
      ].join('\u0001');
      byFields.putIfAbsent(key, () => <DatabaseMember>[]).add(member);
      fieldsByKey[key] = fields;
      ruleByKey[key] = rule;
    }

    final List<DatabaseAccessGrantRecord> records = <DatabaseAccessGrantRecord>[
      for (final MapEntry<String, List<DatabaseMember>> entry
          in byFields.entries)
        DatabaseAccessGrantRecord(
          // The FIRST bucket keeps the document id that was loaded, so an edit
          // that did not split anyone rewrites the same row instead of leaving
          // the old one to be swept and a new one created.
          id: entry.key == byFields.keys.first ? recordId : '',
          grant: ruleByKey[entry.key]!.copyWith(
            members: entry.value,
            viewableFields: fieldsByKey[entry.key]!,
          ),
          // The removed people ride on the first record only — they are a
          // property of the table's access as a whole, not of one field set,
          // and repeating them would count each person once per bucket.
          removedMembers: entry.key == byFields.keys.first
              ? removedMembers
              : const <RemovedAccessMember>[],
          grantedBy: grantedBy,
        ),
    ];

    // Nobody on the grant means the rule is gone, not that an empty rule should
    // be stored: an empty `members` list would leave a document claiming a
    // permission level nobody holds. The removed people still travel — they are
    // on the record, and the record is only dropped when there is nothing left
    // to say about them either.
    final bool empty = grant.members.isEmpty && removedMembers.isEmpty;

    // Everyone removed (DB-TABLE-06): one placeholder record carries only the
    // history of who was removed, as the database access screen does. Without
    // it the removals were dropped, and the save was refused outright.
    return empty
        ? const <DatabaseAccessGrantRecord>[]
        : records.isEmpty
            ? <DatabaseAccessGrantRecord>[
                DatabaseAccessGrantRecord(
                  id: recordId,
                  grant: const DatabaseAccessGrant(members: <DatabaseMember>[]),
                  removedMembers: removedMembers,
                  grantedBy: grantedBy,
                ),
              ]
            : records;
  }

  /// Function Name: [sameFields]
  ///
  /// Purpose: Whether two field lists hold the same column ids, in any order.
  ///
  /// Parameters: [before], [after] the two lists.
  ///
  /// Returns: [bool].
  static bool sameFields(List<String> before, List<String> after) {
    final Set<String> was = before.toSet();
    final Set<String> now = after.toSet();
    return was.length == now.length && was.containsAll(now);
  }
}
