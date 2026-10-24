/// Module: database / db3_create_table / data / data_source
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_remote_data_source.dart
/// Description: Declares `CreateTableRemoteDataSource`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// Raw Firestore calls for the Creating Table section. Throws on failure;
/// turning those throws into `Failure` values is the repository's job, so there
/// is no try/catch and no dartz import here — same split as db1 and db2.
///
/// The databases collection path comes from `CreateDatabaseCollections`; only
/// the `Tables` subcollection name is this module's. Re-declaring the parent
/// path here is how a module ends up writing to a collection nothing reads.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/create_table_collections.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/database_table_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_comment_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_data_row_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_rows_save_result.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/usecases/table_rows_diff.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/models/database_access_index_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/database/db2_database_details/data/models/database_access_record_model.dart';

class CreateTableRemoteDataSource {
  CreateTableRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// `Demo/{companyId}/Modules/Database/Databases`.
  ///
  /// The empty-baseUri check is not defensive noise — see db1's data source for
  /// the full reasoning. Short version: with no tenant prefix the path is three
  /// segments, which Firestore accepts as a DIFFERENT, top-level collection;
  /// reads come back empty and writes land where nobody looks.
  CollectionReference<Map<String, dynamic>> get _databases {
    if (ApiConstants.baseUri.trim().isEmpty) {
      throw StateError(S.current.dbNoCompanySignedIn);
    }
    return _firestore.collection(
      getBaseUrl(CreateDatabaseCollections.databases),
    );
  }

  DocumentReference<Map<String, dynamic>> _databaseDoc(String databaseId) =>
      _databases.doc(databaseId);

  /// `…/Databases/{databaseId}/Tables`. Nested under a document, so no tenant
  /// prefix — the parent path already carries it.
  CollectionReference<Map<String, dynamic>> _tablesOf(String databaseId) =>
      _databaseDoc(databaseId).collection(CreateTableCollections.tables);

  /// `…/Tables/{tableId}/Access_Grants`.
  ///
  /// Reuses `CreateDatabaseCollections.accessGrants` rather than naming a
  /// second constant: a table's grants and a database's grants are the same
  /// documents one level apart, and two names for one subcollection is how a
  /// reader ends up looking in the wrong place.
  CollectionReference<Map<String, dynamic>> _grantsOfTable(
    String databaseId,
    String tableId,
  ) =>
      _tablesOf(databaseId)
          .doc(tableId)
          .collection(CreateDatabaseCollections.accessGrants);

  /// `…/Tables/{tableId}/Comments` — the thread the Comments screen draws
  /// (Figma 7398:8232).
  ///
  /// A SUBCOLLECTION rather than an array on the table document, unlike
  /// `columns`. The two are opposite cases: a table is opened whole and has a
  /// handful of columns, while a thread grows without a ceiling and is appended
  /// to by several people at once. As an array it would be rewritten in full on
  /// every reply, and two replies posted in the same second would lose one.
  CollectionReference<Map<String, dynamic>> _commentsOfTable(
    String databaseId,
    String tableId,
  ) =>
      _tablesOf(databaseId)
          .doc(tableId)
          .collection(CreateTableCollections.comments);

  /// Function Name: [fetchTables]
  ///
  /// Purpose: Read every table under one database, newest first.
  ///
  /// Ordered by `created_at` DESCENDING so a table the user just made is the
  /// first row they see rather than the last. Documents written before
  /// `created_at` existed sort last under Firestore's null ordering, which is
  /// the right place for them: they are the oldest.
  Future<List<DatabaseTableModel>> fetchTables(String databaseId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _tablesOf(
      databaseId,
    ).orderBy(DatabaseTableModel.fCreatedAt, descending: true).get();

    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              DatabaseTableModel.fromSnapshot(doc, databaseId: databaseId),
        )
        .toList(growable: false);
  }

  /// Function Name: [fillMissingCreators]
  ///
  /// Purpose: Give the tables in [tableIds], made before the creator was
  /// saved, the database's creator as their creator (DB-TABLE-02). Without
  /// one, nobody can post on a Private table's comments. Only `created_by` is
  /// written, and only where it is still empty.
  ///
  /// Parameters: [databaseId]; [tableIds] tables whose creator is empty.
  ///
  /// Returns: [Future<String?>] the creator written, or null when the
  /// database has none either and nothing was written.
  Future<String?> fillMissingCreators({
    required String databaseId,
    required List<String> tableIds,
  }) async {
    if (tableIds.isEmpty) return null;
    final DocumentSnapshot<Map<String, dynamic>> database =
        await _databaseDoc(databaseId).get();
    final Object? creator = database.data()?[DatabaseModel.fCreatedBy];
    if (creator is! String || creator.isEmpty) return null;

    await _firestore.runTransaction<void>((Transaction transaction) async {
      final List<DocumentReference<Map<String, dynamic>>> refs =
          <DocumentReference<Map<String, dynamic>>>[
        for (final String id in tableIds) _tablesOf(databaseId).doc(id),
      ];
      final List<DocumentSnapshot<Map<String, dynamic>>> current =
          <DocumentSnapshot<Map<String, dynamic>>>[
        for (final DocumentReference<Map<String, dynamic>> ref in refs)
          await transaction.get(ref),
      ];
      for (final DocumentSnapshot<Map<String, dynamic>> table in current) {
        final Object? existing = table.data()?[DatabaseTableModel.fCreatedBy];
        if (!table.exists || (existing is String && existing.isNotEmpty)) {
          continue;
        }
        transaction.update(table.reference, <String, dynamic>{
          DatabaseTableModel.fCreatedBy: creator,
        });
      }
    });
    return creator;
  }

  /// Function Name: [fetchTable]
  ///
  /// Purpose: Read one table as the server holds it now — its columns and
  /// row count — so a screen can drop the copy it opened with (DB-TABLE-01,
  /// DB-TABLE-13).
  ///
  /// Parameters: [databaseId], [tableId].
  ///
  /// Returns: [Future<DatabaseTableModel>]; throws when the table is gone.
  Future<DatabaseTableModel> fetchTable({
    required String databaseId,
    required String tableId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _tablesOf(databaseId).doc(tableId).get();
    if (!snapshot.exists) throw StateError(S.current.dbTableNoLongerExists);
    return DatabaseTableModel.fromSnapshot(snapshot, databaseId: databaseId);
  }

  /// Function Name: [createTable]
  ///
  /// Purpose: Write a new table and bring the parent's count up with it,
  /// atomically.
  ///
  /// ONE BATCH, deliberately. The alternative — write the table, then increment
  /// — leaves a window in which the table exists and the card above it still
  /// says "No. Of Tables: 0"; a crash inside that window makes the discrepancy
  /// permanent, and nothing recounts. A batch either lands whole or not at all.
  ///
  /// `FieldValue.increment(1)` rather than "the count I read plus one": two
  /// people adding a table at the same time would otherwise both write the same
  /// number and one table would go uncounted forever.
  ///
  /// The document is re-read after the commit rather than assembled locally,
  /// because `created_at` is a SERVER timestamp — the value the caller needs is
  /// the one Firestore resolved, not the sentinel that was sent.
  Future<DatabaseTableModel> createTable(DatabaseTableModel model) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _tablesOf(model.databaseId).doc();

    final WriteBatch batch = _firestore.batch();

    batch.set(ref, model.toCreateMap());
    batch.update(_databaseDoc(model.databaseId), <String, dynamic>{
      DatabaseModel.fTablesCount: FieldValue.increment(1),
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();
    return DatabaseTableModel.fromSnapshot(
      saved,
      databaseId: model.databaseId,
    );
  }

  /// Function Name: [updateTable]
  ///
  /// Purpose: Write the Editing Table Name card's fields back and return the
  /// record as the SERVER now holds it.
  ///
  /// No batch and no count here: editing a table does not change how many there
  /// are. The parent's `updated_at` is still stamped, so the database's "Last
  /// Edit" line reflects that something inside it changed.
  Future<DatabaseTableModel> updateTable(DatabaseTableModel model) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _tablesOf(model.databaseId).doc(model.id);

    final WriteBatch batch = _firestore.batch();
    batch.update(ref, model.toUpdateMap());
    batch.update(_databaseDoc(model.databaseId), <String, dynamic>{
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });
    await batch.commit();

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();

    // A missing document means it was deleted underneath the editor — which the
    // user has to be told about, not shown as an empty form.
    if (!saved.exists) {
      throw StateError(S.current.dbTableNoLongerExists);
    }
    return DatabaseTableModel.fromSnapshot(
      saved,
      databaseId: model.databaseId,
    );
  }

  /// Function Name: [cleanColumnValues]
  ///
  /// Purpose: After the table's columns were edited (DB-TABLE-08), delete the
  /// stored values of [removedColumnIds], and the values in [retypedColumns]
  /// that do not fit their column's new type. Bumps `rows_version` when any
  /// row changed, so an editor opened before the change cannot save over it.
  ///
  /// Parameters: [databaseId], [tableId]; [removedColumnIds];
  /// [retypedColumns] column id -> its new type.
  ///
  /// Returns: [Future<int>] how many rows were changed.
  Future<int> cleanColumnValues({
    required String databaseId,
    required String tableId,
    required Set<String> removedColumnIds,
    required Map<String, TableColumnType> retypedColumns,
  }) async {
    if (removedColumnIds.isEmpty && retypedColumns.isEmpty) return 0;

    final CollectionReference<Map<String, dynamic>> rows =
        _rowsOfTable(databaseId, tableId);
    int changed = 0;
    DocumentSnapshot<Map<String, dynamic>>? last;

    while (true) {
      Query<Map<String, dynamic>> page =
          rows.orderBy(FieldPath.documentId).limit(_deletePageSize);
      if (last != null) page = page.startAfterDocument(last);
      final QuerySnapshot<Map<String, dynamic>> snapshot = await page.get();
      if (snapshot.docs.isEmpty) break;

      final WriteBatch batch = _firestore.batch();
      bool any = false;
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final Object? raw = doc.data()[TableDataRowModel.fValues];
        final Map<Object?, Object?> values =
            raw is Map ? raw : const <Object?, Object?>{};
        final Map<Object, Object?> updates = <Object, Object?>{
          for (final String id in removedColumnIds)
            if (values.containsKey(id))
              FieldPath(<String>[TableDataRowModel.fValues, id]):
                  FieldValue.delete(),
          for (final MapEntry<String, TableColumnType> column
              in retypedColumns.entries)
            if (values[column.key] is String &&
                !column.value.accepts(values[column.key]! as String))
              FieldPath(<String>[TableDataRowModel.fValues, column.key]):
                  FieldValue.delete(),
        };
        if (updates.isEmpty) continue;
        batch.update(doc.reference, updates);
        any = true;
        changed++;
      }
      if (any) await batch.commit();

      if (snapshot.docs.length < _deletePageSize) break;
      last = snapshot.docs.last;
    }

    if (changed > 0) {
      await _tablesOf(databaseId).doc(tableId).update(<String, dynamic>{
        DatabaseTableModel.fRowsVersion: FieldValue.increment(1),
      });
    }
    return changed;
  }

  /// Function Name: [deleteTable]
  ///
  /// Purpose: Remove one table with its rows, comments and access grants, then
  /// take the parent's count down (DB-TABLE-05).
  Future<void> deleteTable({
    required String databaseId,
    required String tableId,
  }) async {
    // The table's rows, comments and access grants go FIRST (DB-TABLE-05).
    // Deleting only the table document left all three in Firestore with no
    // screen to see or remove them. Children before the parent: if this stops
    // halfway the table is still listed, and deleting it again finishes the
    // job — the other order would orphan whatever was left.
    for (final CollectionReference<Map<String, dynamic>> child
        in <CollectionReference<Map<String, dynamic>>>[
      _rowsOfTable(databaseId, tableId),
      _commentsOfTable(databaseId, tableId),
      _grantsOfTable(databaseId, tableId),
    ]) {
      await _deleteAll(child);
    }

    final WriteBatch batch = _firestore.batch();

    batch.delete(_tablesOf(databaseId).doc(tableId));
    batch.update(_databaseDoc(databaseId), <String, dynamic>{
      DatabaseModel.fTablesCount: FieldValue.increment(-1),
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Deletes every document in [collection], a batch at a time.
  Future<void> _deleteAll(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    while (true) {
      final QuerySnapshot<Map<String, dynamic>> page =
          await collection.limit(_deletePageSize).get();
      if (page.docs.isEmpty) return;
      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Documents per delete batch; below Firestore's 500 operations per batch.
  static const int _deletePageSize = 400;

  /// Function Name: [tableNameExists]
  ///
  /// Purpose: True when a table OTHER than [excludeId] in the SAME database
  /// already uses either name.
  ///
  /// Two queries rather than one, for the same reason as db1's title check:
  /// Firestore has no OR across different fields in one `where` chain. Each is
  /// capped at two documents, not one — the record being edited is expected to
  /// match itself, so a limit of one could return only that and report the name
  /// free while a real duplicate sat behind it.
  Future<bool> tableNameExists({
    required String databaseId,
    required String nameEn,
    required String nameAr,
    required String excludeId,
  }) async {
    final CollectionReference<Map<String, dynamic>> tables =
        _tablesOf(databaseId);

    Future<bool> otherThanSelf(String field, String value) async {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await tables
          .where(field, isEqualTo: value.toLowerCase())
          .limit(2)
          .get();

      return snapshot.docs.any(
        (QueryDocumentSnapshot<Map<String, dynamic>> d) => d.id != excludeId,
      );
    }

    if (await otherThanSelf(DatabaseTableModel.fNameEnLower, nameEn)) {
      return true;
    }
    return otherThanSelf(DatabaseTableModel.fNameArLower, nameAr);
  }

  // ── Editing Table Access ─────────────────────────────────────────────────

  /// Function Name: [fetchTableGrants]
  ///
  /// Purpose: Read one table's `Access_Grants` subcollection, keeping each
  /// document's id so an edit can rewrite the right rows.
  ///
  /// `DatabaseAccessGrant.fromMap` reads the grant itself — including the
  /// `viewable_fields` key it gained on 16/8/2026. The keys it does not know
  /// about, the removed members and the grantor, are picked out here using
  /// db2's `DatabaseGrantFields`, because those are that module's addition to a
  /// shape db1 owns and this module is only reusing both.
  Future<List<DatabaseAccessGrantRecord>> fetchTableGrants({
    required String databaseId,
    required String tableId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _grantsOfTable(databaseId, tableId).get();

    return snapshot.docs
        .map(DatabaseAccessRecordModel.fromSnapshot)
        .toList(growable: false);
  }

  /// Function Name: [replaceTableGrants]
  ///
  /// Purpose: Swap the whole subcollection for [records] and bring the table
  /// document back in step, atomically.
  ///
  /// ONE BATCH, for the same reason db2's `replaceGrants` uses one: clear-then-
  /// write leaves a window in which the table exists with nobody on it, and a
  /// crash inside that window revokes everyone's access from a screen that has
  /// already navigated away.
  ///
  /// The existing ids are read BEFORE the batch so the delete set is a snapshot
  /// rather than a live query — a document added between the read and the
  /// commit survives, which is the safe direction to be wrong in.
  Future<void> replaceTableGrants({
    required String databaseId,
    required String tableId,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final CollectionReference<Map<String, dynamic>> grants =
        _grantsOfTable(databaseId, tableId);

    final QuerySnapshot<Map<String, dynamic>> existing = await grants.get();

    final WriteBatch batch = _firestore.batch();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in existing.docs) {
      batch.delete(doc.reference);
    }

    for (final DatabaseAccessGrantRecord record in records) {
      // Reusing the document id where there is one keeps the subcollection
      // stable across edits, so an audit trail or a security rule keyed on a
      // grant id does not see every save as a fresh set of grants.
      final DocumentReference<Map<String, dynamic>> ref =
          record.id.isEmpty ? grants.doc() : grants.doc(record.id);

      batch.set(
          ref,
          DatabaseAccessRecordModel.toMap(
            record,
            grantedBy: grantedBy,
            grantedByNameEn: grantedByNameEn,
            grantedByNameAr: grantedByNameAr,
          ));
    }

    // Distinct people across every grant — the same dedupe db2 uses, so the
    // number on the table row and the number in the subcollection cannot
    // disagree.
    final int memberCount = records
        .expand((DatabaseAccessGrantRecord r) => r.grant.members)
        .toSet()
        .length;

    batch.update(_tablesOf(databaseId).doc(tableId), <String, dynamic>{
      DatabaseTableModel.fMemberCount: memberCount,
      DatabaseTableModel.fUpdatedAt: FieldValue.serverTimestamp(),
      // Same batch as the grants (DB-TABLE-03, DB-TABLE-06).
      DatabaseTableModel.fAccessRestricted: records.isNotEmpty,
      ...DatabaseAccessIndexModel.fieldsFor(
        records.map((DatabaseAccessGrantRecord r) => r.grant),
      ),
    });

    // The DATABASE's own timestamp moves too: something inside it changed, and
    // the details card's "Last Edit" line is the only place that shows it.
    // `tables_count` is untouched — granting access adds no tables.
    batch.update(_databaseDoc(databaseId), <String, dynamic>{
      DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Rows (Figma 7398:3042 / 15076 / 15210) ───────────────────────────────

  /// `…/Tables/{tableId}/Rows` — the table's own data.
  ///
  /// A subcollection for the reasons `TableDataRowModel` states: 5000 rows do
  /// not fit in one document, the Preview screen pages through them, and one
  /// edited cell should not rewrite the whole table.
  CollectionReference<Map<String, dynamic>> _rowsOfTable(
    String databaseId,
    String tableId,
  ) =>
      _tablesOf(databaseId)
          .doc(tableId)
          .collection(CreateTableCollections.rows);

  /// Function Name: [fetchRows]
  ///
  /// Purpose: Read one table's rows in the order the user arranged them.
  ///
  /// Ordered by `order` ASCENDING — the opposite of `fetchTables`, and
  /// deliberately: a table is a list of records where newest-first is useful,
  /// while a row's position IS its meaning. Row 3 sits under row 2 or the grid
  /// is not the grid the user typed.
  ///
  /// Returns: [List] rows, first to last.
  Future<List<TableDataRowModel>> fetchRows({
    required String databaseId,
    required String tableId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _rowsOfTable(databaseId, tableId)
            .orderBy(TableDataRowModel.fOrder)
            .get();

    return <TableDataRowModel>[
      for (int i = 0; i < snapshot.docs.length; i++)
        TableDataRowModel.fromSnapshot(snapshot.docs[i], fallbackOrder: i),
    ];
  }

  /// Function Name: [fetchRowsVersion]
  ///
  /// Purpose: The table's `rows_version`, read BEFORE its rows. If someone
  /// saves in between, the rows are newer than the version and the next save
  /// is refused — the safe direction to be wrong in.
  ///
  /// Parameters: [databaseId], [tableId].
  ///
  /// Returns: [Future<int>] the version; 0 for a table saved before versions.
  Future<int> fetchRowsVersion({
    required String databaseId,
    required String tableId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> table =
        await _tablesOf(databaseId).doc(tableId).get();
    return (table.data()?[DatabaseTableModel.fRowsVersion] as num?)?.toInt() ??
        0;
  }

  /// Function Name: [saveRowChanges]
  ///
  /// Purpose: Write ONLY what changed on the editing screen (DB-TABLE-01), in
  /// one transaction that first checks nobody saved since [expectedVersion]
  /// and nobody changed the columns since the screen loaded them.
  ///
  /// The table's names, description and comment setting are never written
  /// here, and the columns only when this screen changed them — so a save can
  /// no longer write back an old copy over someone else's change.
  ///
  /// The old save deleted every stored row missing from the screen. A screen
  /// whose load failed, or that was opened before somebody else added rows,
  /// therefore deleted rows it never saw. Now only rows this screen loaded and
  /// then removed are deleted, and a stale screen is refused outright.
  ///
  /// Parameters:
  ///   [created]        rows with local ids; each gets a new document.
  ///   [updated]        loaded rows whose cells or order changed.
  ///   [deletedIds]     loaded rows the user removed or emptied.
  ///   [expectedVersion] the `rows_version` read when the screen loaded.
  ///   [expectedColumns] the columns the screen loaded.
  ///   [columns]        the columns to write, or null when unchanged.
  ///   [rowCount]       rows the table holds after the save.
  ///
  /// Returns: [Future<TableRowsSaveResult>]; throws [StaleRowsException] when
  /// the version or the stored columns moved.
  Future<TableRowsSaveResult> saveRowChanges({
    required String databaseId,
    required String tableId,
    required List<TableDataRow> created,
    required List<TableDataRow> updated,
    required Set<String> deletedIds,
    required int expectedVersion,
    required List<TableColumn> expectedColumns,
    List<TableColumn>? columns,
    required int rowCount,
  }) {
    final CollectionReference<Map<String, dynamic>> rows =
        _rowsOfTable(databaseId, tableId);
    final DocumentReference<Map<String, dynamic>> tableRef =
        _tablesOf(databaseId).doc(tableId);

    return _firestore.runTransaction<TableRowsSaveResult>(
      (Transaction transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> table =
            await transaction.get(tableRef);
        final int current =
            (table.data()?[DatabaseTableModel.fRowsVersion] as num?)?.toInt() ??
                0;
        if (current != expectedVersion) throw const StaleRowsException();
        if (!table.exists) throw StateError(S.current.dbTableNoLongerExists);
        final DatabaseTableModel stored =
            DatabaseTableModel.fromSnapshot(table, databaseId: databaseId);
        // Someone changed the columns since this screen loaded them: writing
        // ours would undo their change (DB-TABLE-01).
        if (!TableRowsDiff.sameColumns(stored.columns, expectedColumns)) {
          throw const StaleRowsException();
        }
        final DatabaseTableModel after = DatabaseTableModel.fromEntity(
          stored.copyWith(columns: columns, rowCount: rowCount),
        );

        for (final String id in deletedIds) {
          transaction.delete(rows.doc(id));
        }
        // `update`, not a merge: a merge keeps keys missing from the new
        // `values` map, so a removed column's values stayed in every row
        // (DB-TABLE-08). The version check above guarantees the row exists.
        for (final TableDataRow row in updated) {
          transaction.update(
            rows.doc(row.id),
            TableDataRowModel.fromEntity(row).toUpdateMap(),
          );
        }
        final Map<String, String> createdIds = <String, String>{};
        for (final TableDataRow row in created) {
          final DocumentReference<Map<String, dynamic>> ref = rows.doc();
          createdIds[row.id] = ref.id;
          transaction.set(ref, TableDataRowModel.fromEntity(row).toCreateMap());
        }

        transaction.update(tableRef, <String, dynamic>{
          DatabaseTableModel.fRowsVersion: current + 1,
          DatabaseTableModel.fRowCount: rowCount,
          if (columns != null)
            DatabaseTableModel.fColumns: after.columnsToMap(),
          DatabaseTableModel.fUpdatedAt: FieldValue.serverTimestamp(),
        });
        transaction.update(_databaseDoc(databaseId), <String, dynamic>{
          DatabaseModel.fUpdatedAt: FieldValue.serverTimestamp(),
        });

        return TableRowsSaveResult(
          createdIds: createdIds,
          rowsVersion: current + 1,
          table: after.copyWith(updatedAt: DateTime.now()),
        );
      },
    );
  }

  // ── Comments (Figma 7398:8232 / 8311 / 8587) ─────────────────────────────

  /// Function Name: [fetchComments]
  ///
  /// Purpose: Read one table's thread, OLDEST first.
  ///
  /// The opposite order to `fetchTables`, and deliberately: a list of records is
  /// read newest-first because the newest is the one you were looking for, but a
  /// conversation is read top-to-bottom or it stops being a conversation. The
  /// screen scrolls to the bottom on open, which is where the newest message
  /// then is.
  ///
  /// A document written before `created_at` existed sorts FIRST under
  /// Firestore's null ordering — the right place for it, since it is the oldest.
  Future<List<TableCommentModel>> fetchComments({
    required String databaseId,
    required String tableId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _commentsOfTable(databaseId, tableId)
            .orderBy(TableCommentModel.fCreatedAt)
            .get();

    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              TableCommentModel.fromSnapshot(doc, tableId: tableId),
        )
        .toList(growable: false);
  }

  /// Function Name: [addComment]
  ///
  /// Purpose: Post one message and return it as the SERVER now holds it.
  ///
  /// Re-read after the write rather than assembled locally, for the same reason
  /// `createTable` re-reads: `created_at` is a server timestamp, and the value
  /// the bubble has to print is the one Firestore resolved, not the sentinel
  /// that was sent. Without it every message would render with no date until the
  /// screen was reopened.
  ///
  /// No batch and no counter on the table document. A comment count is not drawn
  /// anywhere — the Figma's tile beside it reads "Comments Access", which is a
  /// setting, not a total — so there is nothing to keep in step, and adding a
  /// counter now would be a second number that can only ever go wrong.
  Future<TableCommentModel> addComment({
    required String databaseId,
    required TableCommentModel comment,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _commentsOfTable(databaseId, comment.tableId).doc();

    await ref.set(comment.toCreateMap());

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();
    return TableCommentModel.fromSnapshot(saved, tableId: comment.tableId);
  }

  /// Function Name: [deleteComment]
  ///
  /// Purpose: Remove one message.
  ///
  /// Hard delete, not a flag. A database record is soft-deleted because it has
  /// a Deleted chip to sit in and things hanging off it; a retracted sentence
  /// has neither, and keeping the text of something the author took back is the
  /// opposite of what taking it back means.
  Future<void> deleteComment({
    required String databaseId,
    required String tableId,
    required String commentId,
  }) {
    return _commentsOfTable(databaseId, tableId).doc(commentId).delete();
  }

  /// Function Name: [setCommentReaction]
  ///
  /// Purpose: Apply, switch or clear one person's thumb on one comment, and
  /// return the comment as it stands afterwards.
  ///
  /// ONE update with BOTH arrays in it. [reaction] null clears; otherwise the id
  /// is unioned into that reaction's array and removed from the other in the
  /// same write, which is what enforces "at most one of the two" — as two writes
  /// there is a window in which a thumb is counted on both sides, and a crash
  /// inside it makes that permanent.
  ///
  /// `arrayUnion` / `arrayRemove` rather than writing the list this client read:
  /// several people react to the same message at once, and a whole-array write
  /// would drop whichever reactions arrived between the read and the write.
  Future<TableCommentModel> setCommentReaction({
    required String databaseId,
    required String tableId,
    required String commentId,
    required String employeeId,
    required TableCommentReaction? reaction,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _commentsOfTable(databaseId, tableId).doc(commentId);

    await ref.update(<String, dynamic>{
      for (final TableCommentReaction value in TableCommentReaction.values)
        value.storageField: value == reaction
            ? FieldValue.arrayUnion(<String>[employeeId])
            : FieldValue.arrayRemove(<String>[employeeId]),
    });

    final DocumentSnapshot<Map<String, dynamic>> saved = await ref.get();

    // Gone means somebody deleted it while this thumb was in flight. Saying so
    // is the only honest answer — the alternative is an empty bubble that the
    // user cannot tell apart from a reaction that silently failed.
    if (!saved.exists) {
      throw StateError(S.current.dbCommentNoLongerExists);
    }
    return TableCommentModel.fromSnapshot(saved, tableId: tableId);
  }
}

/// Thrown by [CreateTableRemoteDataSource.saveRowChanges] when the table's rows
/// were saved by someone else after this screen loaded them.
class StaleRowsException implements Exception {
  const StaleRowsException();
}
