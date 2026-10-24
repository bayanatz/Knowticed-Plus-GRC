/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: employee_backup_remote_data_source.dart
/// Purpose: All Firestore access for employee reads, writes and the two-level
///          backup/restore, lifted out of EmployeeController.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// `EmployeeController` previously held `FirebaseFirestore db` and ran queries,
/// merges, whole-collection deletes and the backup rotation directly from a UI
/// controller. All of it lives here now.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/data/models/employee_directory_model.dart';
import 'package:knowticed_plus/features/settings/data/utils/employee_collection_paths.dart';

class EmployeeBackupRemoteDataSource {
  EmployeeBackupRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _main =>
      _firestore.collection(EmployeeCollectionPaths.main);
  CollectionReference<Map<String, dynamic>> get _backupOne =>
      _firestore.collection(EmployeeCollectionPaths.backupOne);
  CollectionReference<Map<String, dynamic>> get _backupTwo =>
      _firestore.collection(EmployeeCollectionPaths.backupTwo);

  /// Function Name: [getEmployeeByEmail]
  ///
  /// Purpose: Find an employee whose `Email` array contains [email].
  ///
  /// Returns: [Future<NewEmployeeModelHistory?>] — `null` when not found.
  Future<NewEmployeeModelHistory?> getEmployeeByEmail(String email) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _main.where('Email', arrayContains: email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return NewEmployeeModelHistory.fromMap(snapshot.docs.first.data());
  }

  /// Function Name: [getEmployeeDirectory]
  ///
  /// Purpose: Read the directory entry keyed by email.
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(ApiConstants.employeesDirectory)
        .doc(email)
        .get();
    final Map<String, dynamic>? data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return EmployeeDirectoryModel.fromMap(data);
  }

  /// Function Name: [saveEmployee]
  ///
  /// Purpose: Create or merge-update the employee document.
  Future<void> saveEmployee(NewEmployeeModelHistory employee) async {
    final String? id = employee.id;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Cannot save an employee without an id.');
    }
    await _main.doc(id).set(employee.toMap(), SetOptions(merge: true));
  }

  /// Function Name: [clearCollection]
  ///
  /// Purpose: Delete every document in [collection], in batches.
  ///
  /// **Destructive.** [confirmDestructive] must be `true`. The guard exists
  /// because this used to be a public method on a UI controller sitting one
  /// call away from the live `Employees_Info` collection — an accidental or
  /// mis-ordered call wipes the tenant's employees.
  ///
  /// Parameters:
  /// - [collection]: Target collection.
  /// - [confirmDestructive]: Must be `true`.
  ///
  /// Throws: [StateError] when the guard is not set.
  Future<void> clearCollection(
    CollectionReference<Map<String, dynamic>> collection, {
    required bool confirmDestructive,
  }) async {
    if (!confirmDestructive) {
      throw StateError(
        'clearCollection deletes every document in ${collection.path}. '
        'Pass confirmDestructive: true to proceed.',
      );
    }
    // Batched: the original deleted one document per round-trip, which is slow
    // and can partially fail on a large collection.
    const int batchLimit = 400;
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await collection.limit(batchLimit).get();
      if (snapshot.docs.isEmpty) break;
      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snapshot.docs.length < batchLimit) break;
    }
  }

  /// Function Name: [getBackupEmployees]
  ///
  /// Purpose: Read every document of one backup collection, so the Restore
  ///          dialog can show what a backup actually holds BEFORE the
  ///          destructive [restoreFromBackup] runs.
  ///
  /// ADDED 30/8/2026. `restoreFromBackup` was the only reader of these two
  /// collections and it reads them one step before clearing `Employees_Info` —
  /// there was no way to look at a backup without restoring it. The Restore
  /// button therefore showed a success dialog and touched no data at all.
  ///
  /// Parameters:
  /// - [backupVersion]: `'second'` for backup two, anything else for backup
  ///   one — the same convention [restoreFromBackup] uses, so the value the
  ///   dialog previews with is the value it restores with.
  ///
  /// Returns: [Future<List<NewEmployeeModelHistory>>] — empty when the backup
  ///          has never been written.
  ///
  /// A document that does not parse is still skipped so one bad record cannot
  /// blank the preview, but since 20/10/2026 (CR-KNP-SET-PROFILE-02) it is
  /// counted in [lastSkippedCount] and logged, instead of vanishing without a
  /// trace — the preview used to say "12 employees" for a 15-document backup.
  Future<List<NewEmployeeModelHistory>> getBackupEmployees(
    String backupVersion,
  ) async {
    final CollectionReference<Map<String, dynamic>> backup =
        backupVersion == 'second' ? _backupTwo : _backupOne;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await backup.get();

    final List<NewEmployeeModelHistory> employees = <NewEmployeeModelHistory>[];
    int skipped = 0;
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      try {
        employees.add(NewEmployeeModelHistory.fromMap(doc.data()));
      } catch (e) {
        skipped++;
        debugPrint('Backup "$backupVersion": skipped ${doc.id} — $e');
      }
    }
    lastSkippedCount = skipped;
    return employees;
  }

  /// How many documents the last [getBackupEmployees] could not parse.
  int lastSkippedCount = 0;

  /// Function Name: [backupCollections]
  ///
  /// Purpose: Roll the two-level backup — backup1 → backup2, then main →
  ///          backup1. Reads main first so the snapshot is consistent.
  ///
  /// CHANGED 20/10/2026 (CR-KNP-SET-PROFILE-02): was "clear the target, then
  /// copy one document per round-trip" — a crash or a lost connection in the
  /// middle left the backup EMPTY. Now every target is overwritten by a
  /// batched copy FIRST and only the documents that no longer exist in the
  /// source are deleted AFTERWARDS, so at no point is a backup emptier than
  /// its source.
  Future<void> backupCollections() async {
    final QuerySnapshot<Map<String, dynamic>> mainSnapshot = await _main.get();
    final QuerySnapshot<Map<String, dynamic>> backupOneSnapshot =
        await _backupOne.get();

    await _replaceCollection(_backupTwo, backupOneSnapshot.docs);
    await _replaceCollection(_backupOne, mainSnapshot.docs);
  }

  /// Overwrite [target] with [source]: batched set of every source document,
  /// then batched delete of the target documents the source does not have.
  Future<void> _replaceCollection(
    CollectionReference<Map<String, dynamic>> target,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> source,
  ) async {
    const int batchLimit = 400;
    for (int i = 0; i < source.length; i += batchLimit) {
      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in source.sublist(
              i,
              i + batchLimit > source.length
                  ? source.length
                  : i + batchLimit)) {
        batch.set(target.doc(doc.id), doc.data());
      }
      await batch.commit();
    }

    final Set<String> keep = source
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.id)
        .toSet();
    final QuerySnapshot<Map<String, dynamic>> existing = await target.get();
    final List<DocumentReference<Map<String, dynamic>>> stale = existing.docs
        .where((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            !keep.contains(d.id))
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) => d.reference)
        .toList();
    for (int i = 0; i < stale.length; i += batchLimit) {
      final WriteBatch batch = _firestore.batch();
      for (final DocumentReference<Map<String, dynamic>> ref in stale.sublist(
          i, i + batchLimit > stale.length ? stale.length : i + batchLimit)) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }

  /// Function Name: [restoreFromBackup]
  ///
  /// Purpose: Replace the main collection with a backup's contents.
  ///
  /// **Destructive** — clears `Employees_Info` before copying.
  ///
  /// Parameters:
  /// - [backupVersion]: `'second'` for backup two, anything else for backup one.
  /// - [confirmDestructiveRestore]: Must be `true`.
  ///
  /// Throws: [StateError] when the guard is not set, or when the chosen backup
  ///         is empty — restoring from an empty backup would delete every
  ///         employee and replace them with nothing.
  Future<void> restoreFromBackup(
    String backupVersion, {
    required bool confirmDestructiveRestore,
  }) async {
    if (!confirmDestructiveRestore) {
      throw StateError(
        'restoreFromBackup replaces the entire employee collection. '
        'Pass confirmDestructiveRestore: true to proceed.',
      );
    }

    final CollectionReference<Map<String, dynamic>> backup =
        backupVersion == 'second' ? _backupTwo : _backupOne;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await backup.get();
    if (snapshot.docs.isEmpty) {
      throw StateError(
        'Backup "$backupVersion" is empty; refusing to clear the live '
        'employee collection.',
      );
    }

    // CR-KNP-SET-PROFILE-02 (20/10/2026): copy in, then prune — never an
    // empty Employees_Info between the two steps.
    await _replaceCollection(_main, snapshot.docs);
  }
}
