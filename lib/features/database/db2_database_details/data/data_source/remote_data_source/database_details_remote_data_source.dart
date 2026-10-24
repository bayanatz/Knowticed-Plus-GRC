/// Module: database / db2_database_details / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_remote_data_source.dart
/// Description: Declares `DatabaseDetailsRemoteDataSource`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// Raw Firestore / Storage calls for the details section. Throws on failure;
/// turning those throws into `Failure` values is the repository's job, so
/// there is no try/catch and no dartz import here — same split as db1.
///
/// The collection path, the covers folder and the grants subcollection name
/// all come from `CreateDatabaseCollections`. Re-declaring them here is how a
/// module ends up writing to a collection nothing else reads.
library;

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/create_database_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_status.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_access_index_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/data_source/remote_data_source/database_title_index.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/models/database_access_record_model.dart';

class DatabaseDetailsRemoteDataSource {
  DatabaseDetailsRemoteDataSource({
    FirebaseFirestore? firestore,
    CreateDatabaseRemoteDataSource? databases,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        // Cover uploads and the "title exists" query go through db1's data
        // source rather than being reimplemented (db2 rule 3): one copy, so
        // the create and edit screens cannot disagree.
        _databases = databases ?? CreateDatabaseRemoteDataSource();

  final FirebaseFirestore _firestore;
  final CreateDatabaseRemoteDataSource _databases;

  /// `Demo/{companyId}/Modules/Database/Databases`.
  ///
  /// The empty-baseUri check is not defensive noise — see db1's data source
  /// for the full reasoning. Short version: with no tenant prefix the path is
  /// three segments, which Firestore accepts as a DIFFERENT, top-level
  /// collection; reads come back empty and writes land where nobody looks.
  CollectionReference<Map<String, dynamic>> get _collection {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(S.current.dbNoCompanySignedIn);
    }
    return _firestore.collection(
      getBaseUrl(CreateDatabaseCollections.databases),
    );
  }

  CollectionReference<Map<String, dynamic>> _grantsOf(String databaseId) =>
      _collection.doc(databaseId).collection(
            CreateDatabaseCollections.accessGrants,
          );

  /// Function Name: [uploadCoverImage]
  ///
  /// Purpose: Push a newly picked cover to Storage and return its URL.
  Future<String> uploadCoverImage(File image) =>
      _databases.uploadCoverImage(image);

  /// Function Name: [deleteCoverImage]
  ///
  /// Purpose: Remove a cover from Storage; best effort (DB-CREATE-10).
  ///
  /// Parameters: [url] the cover's download URL.
  ///
  /// Returns: [Future<void>]; never throws.
  Future<void> deleteCoverImage(String url) => _databases.deleteCoverImage(url);

  /// Function Name: [fetchAccessVersion]
  ///
  /// Purpose: The database's `access_version`, read BEFORE its grants so the
  /// editor's save can refuse to overwrite a newer one (DB-DETAILS-04).
  ///
  /// Parameters: [databaseId].
  ///
  /// Returns: [Future<int>]; 0 for a database saved before versions.
  Future<int> fetchAccessVersion(String databaseId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _collection.doc(databaseId).get();
    return (snapshot.data()?[DatabaseModel.fAccessVersion] as num?)?.toInt() ??
        0;
  }

  /// Function Name: [fetchDatabase]
  ///
  /// Purpose: Read one record back from the server.
  ///
  /// A missing document throws rather than returning null: every caller
  /// reaches this holding a record it just wrote or just opened, so "not
  /// there" means it was deleted underneath them — which the user has to be
  /// told about, not shown as an empty form.
  Future<DatabaseModel> fetchDatabase(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _collection.doc(id).get();

    if (!snapshot.exists) {
      throw StateError(S.current.dbDatabaseNoLongerExists);
    }
    return DatabaseModel.fromSnapshot(snapshot);
  }

  /// Function Name: [fetchGrants]
  ///
  /// Purpose: Read the `Access_Grants` subcollection, keeping each document's
  /// id so an edit can rewrite the right rows.
  ///
  /// Each document is read by `DatabaseAccessRecordModel`: db1's grant plus
  /// the removed members and the grantor this module adds.
  Future<List<DatabaseAccessGrantRecord>> fetchGrants(String databaseId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _grantsOf(databaseId).get();

    return snapshot.docs
        .map(DatabaseAccessRecordModel.fromSnapshot)
        .toList(growable: false);
  }

  /// Function Name: [updateDatabase]
  ///
  /// Purpose: Write the Editing screen's fields back. The repository reads
  /// the saved record afterwards with [fetchDatabase] (DB-CREATE-14).
  ///
  /// The map is built field by field rather than reusing `toCreateMap()`.
  /// That map carries `created_at: FieldValue.serverTimestamp()`, `created_by`
  /// and `status` — using it for an update would stamp today's date onto the
  /// creation of a record made months ago and re-activate a draft, from a
  /// screen that only ever showed a title, a description and a picture.
  Future<void> updateDatabase(
    DatabaseModel model, {
    String? coverImageUrl,
  }) async {
    final DocumentReference<Map<String, dynamic>> doc =
        _collection.doc(model.id);

    final Map<String, dynamic> payload = <String, dynamic>{
      DatabaseModel.fTitleEn: model.titleEn,
      DatabaseModel.fTitleAr: model.titleAr,
      DatabaseModel.fTitleEnLower: model.titleEn.toLowerCase(),
      DatabaseModel.fTitleArLower: model.titleAr.toLowerCase(),
      DatabaseModel.fDescriptionEn: model.descriptionEn,
      DatabaseModel.fDescriptionAr: model.descriptionAr,
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
      // Only overwrite the cover when a new file was actually uploaded.
      // Passing the existing (possibly null) URL back would clear the picture
      // of a record whose owner only renamed it.
      if (coverImageUrl != null) DatabaseModel.fCoverImageUrl: coverImageUrl,
    };

    // The titles are claimed with the rename, in one transaction, so two
    // databases cannot end up with the same title (DB-CREATE-11).
    await _firestore.runTransaction<void>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> current =
          await transaction.get(doc);
      await DatabaseTitleIndex(_firestore).claim(
        transaction,
        databaseId: model.id,
        titleEn: model.titleEn,
        titleAr: model.titleAr,
        previousEn: current.data()?[DatabaseModel.fTitleEn] as String?,
        previousAr: current.data()?[DatabaseModel.fTitleAr] as String?,
      );
      transaction.update(doc, payload);
    });
    // The read-back is a separate call ([fetchDatabase]), so a failed read can
    // never be mistaken for a failed write (DB-CREATE-14).
  }

  /// Function Name: [titleExists]
  ///
  /// Purpose: True when a database OTHER than [excludeId] already uses either
  /// title.
  ///
  /// The same query the create wizard uses — db1's data source — so the two
  /// screens cannot disagree about what counts as taken.
  Future<bool> titleExists({
    required String titleEn,
    required String titleAr,
    required String excludeId,
  }) =>
      _databases.titleExists(
        titleEn: titleEn,
        titleAr: titleAr,
        excludeId: excludeId,
      );

  /// Function Name: [replaceGrants]
  ///
  /// Purpose: Swap the whole `Access_Grants` subcollection for [records] and
  /// bring the parent document back in step, atomically.
  ///
  /// ONE BATCH, deliberately. The alternative — clear, then write — leaves a
  /// window in which the database exists with nobody on it; a crash or a lost
  /// connection inside that window revokes everyone's access and the screen
  /// that caused it has already navigated away. A batch either lands whole or
  /// not at all.
  ///
  /// The parent carries `access_type` and `member_count`, both denormalised so
  /// the list screen never reads the subcollection. They are written here
  /// rather than by a separate call for the same reason: a parent claiming
  /// "Open Access, 20 members" over an empty subcollection is a state no
  /// screen can explain, and two calls can always produce it.
  ///
  /// [DatabaseAccessType] is written even when it did not change, because it
  /// is one field in a map that is being set anyway; branching on "did it
  /// change" would cost a read to find out.
  Future<void> replaceGrants({
    required String databaseId,
    required DatabaseAccessType accessType,
    required List<DatabaseAccessGrantRecord> records,
    required int expectedAccessVersion,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final CollectionReference<Map<String, dynamic>> grants =
        _grantsOf(databaseId);

    // Read the existing ids BEFORE the batch so the delete set is a snapshot
    // rather than a live query — a document added between the read and the
    // commit survives, which is the safe direction to be wrong in.
    final QuerySnapshot<Map<String, dynamic>> existing = await grants.get();

    // ONE transaction that first checks nobody saved access since this screen
    // read it (DB-DETAILS-04). Every grant write bumps `access_version`, so
    // an unchanged version means the delete set read above is still the
    // whole subcollection — and a stale screen can no longer erase grants
    // another admin just added.
    final DocumentReference<Map<String, dynamic>> databaseRef =
        _collection.doc(databaseId);
    await _firestore.runTransaction<void>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> current =
          await transaction.get(databaseRef);
      // A deleted database's access cannot change (DB-DETAILS-02): checked
      // here, inside the transaction, so no caller can write around it.
      final Object? status = current.data()?[DatabaseModel.fStatus];
      if (!current.exists ||
          DatabaseStatus.fromStorageKey(status is String ? status : null) ==
              DatabaseStatus.deleted) {
        throw const DeletedDatabaseException();
      }
      final int version =
          (current.data()?[DatabaseModel.fAccessVersion] as num?)?.toInt() ?? 0;
      if (version != expectedAccessVersion) throw const StaleAccessException();

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in existing.docs) {
        transaction.delete(doc.reference);
      }

      for (final DatabaseAccessGrantRecord record in records) {
        // Reusing the document id where there is one keeps the subcollection
        // stable across edits, so an audit trail or a security rule keyed on a
        // grant id does not see every save as a fresh set of grants.
        final DocumentReference<Map<String, dynamic>> ref =
            record.id.isEmpty ? grants.doc() : grants.doc(record.id);

        transaction.set(
            ref,
            DatabaseAccessRecordModel.toMap(
              record,
              grantedBy: grantedBy,
              grantedByNameEn: grantedByNameEn,
              grantedByNameAr: grantedByNameAr,
            ));
      }

      // Distinct people across every grant — the same dedupe rule the review
      // screen's "Total Employees" tile uses, so the number on the card and the
      // number in the document cannot disagree.
      final int memberCount = records
          .expand((DatabaseAccessGrantRecord r) => r.grant.members)
          .toSet()
          .length;

      transaction.update(databaseRef, <String, dynamic>{
        DatabaseModel.fAccessVersion: version + 1,
        DatabaseModel.fAccessType: accessType.storageKey,
        DatabaseModel.fMemberCount: memberCount,
        DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
        // Same batch as the grants, so the list never sees one without the
        // other (DB-CREATE-01).
        ...DatabaseAccessIndexModel.fieldsFor(
          records.map((DatabaseAccessGrantRecord r) => r.grant),
        ),
      });
    });
  }
}

/// Thrown by [DatabaseDetailsRemoteDataSource.replaceGrants] when someone else
/// saved the database's access after this screen read it (DB-DETAILS-04).
class StaleAccessException implements Exception {
  const StaleAccessException();
}

/// Thrown by [DatabaseDetailsRemoteDataSource.replaceGrants] when the database
/// is deleted or gone: its access cannot change (DB-DETAILS-02).
class DeletedDatabaseException implements Exception {
  const DeletedDatabaseException();
}
