/// Module: database / db3_create_table / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_base_repository.dart
/// Description: Declares `CreateTableBaseRepository`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// The contract the table cubits depend on, so the presentation layer never
/// names the Firestore-backed implementation and a test can pass a fake.
///
/// EVERY WRITE HERE ALSO OWNS `tables_count`.
/// -----------------------------------------
/// The parent database document carries a denormalised count that the Database
/// Builder list card renders ("No. Of Tables: 15"), and db2's
/// `DatabaseDetailsBaseRepository.updateDatabase` deliberately does not touch
/// it. That leaves exactly one writer — this repository — and it keeps the
/// count in the SAME batch as the document it counts, because a create and a
/// separate increment can always produce a card that disagrees with the list
/// underneath it.
library;

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_rows_save_result.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';

abstract class CreateTableBaseRepository {
  /// Every table under [databaseId], newest first.
  ///
  /// An unsaved parent (empty id) is not a failure — it has no subcollection
  /// and the honest answer is an empty list, the same call the details screen
  /// makes before anything has been created.
  Future<Either<Failure, List<DatabaseTableEntity>>> fetchTables(
    String databaseId,
  );

  /// Writes a new table and returns it with the id the server assigned.
  ///
  /// Bumps the parent's `tables_count` by one in the same batch.
  Future<Either<Failure, DatabaseTableEntity>> createTable(
    DatabaseTableEntity table,
  );

  /// Writes an edited table back.
  ///
  /// Only the fields the Editing Table Name card owns are touched —
  /// `created_at`, `created_by` and `row_count` are left alone, so an edit
  /// cannot restamp a table made months ago or silently resize it. The count on
  /// the parent is not touched either: editing a table does not change how many
  /// there are.
  Future<Either<Failure, DatabaseTableEntity>> updateTable(
    DatabaseTableEntity table,
  );

  /// Function Name: [cleanColumnValues]
  ///
  /// Purpose: Remove stored row values left behind by a column edit: those of
  /// removed columns, and those that no longer fit a retyped column
  /// (DB-TABLE-08).
  ///
  /// Parameters: [databaseId], [tableId]; [removedColumnIds];
  /// [retypedColumns] column id -> new type.
  ///
  /// Returns: [Either<Failure, int>] rows changed.
  Future<Either<Failure, int>> cleanColumnValues({
    required String databaseId,
    required String tableId,
    required Set<String> removedColumnIds,
    required Map<String, TableColumnType> retypedColumns,
  });

  /// Deletes one table and decrements the parent's `tables_count`, in one batch.
  ///
  /// The decrement is `FieldValue.increment(-1)` rather than a recount, so two
  /// people deleting different tables at the same time do not both write the
  /// same "one fewer than I saw" number.
  Future<Either<Failure, void>> deleteTable({
    required String databaseId,
    required String tableId,
  });

  /// True when a DIFFERENT table in the SAME database already uses either name.
  ///
  /// Scoped to one database on purpose: two departments each having an
  /// "Employees" table is normal, two inside one database is the collision the
  /// user has to be told about.
  ///
  /// [excludeId] is what makes this usable on the edit card — without it,
  /// saving an edit that did not touch the name would match the record against
  /// itself and be rejected as a duplicate. Pass an empty string when creating.
  Future<Either<Failure, bool>> tableNameExists({
    required String databaseId,
    required String nameEn,
    required String nameAr,
    required String excludeId,
  });

  // ── Editing Table Access (Figma 7398:13651 / 14122 / 14553) ──────────────

  /// Every grant document under one TABLE.
  ///
  /// A table's grants live in its own `Access_Grants` subcollection, the same
  /// name and the same document shape db1 and db2 use one level up:
  ///
  ///     …/Databases/{databaseId}/Access_Grants/{grantId}   the database's
  ///     …/Databases/{databaseId}/Tables/{tableId}/Access_Grants/{grantId}
  ///
  /// Same shape, deliberately. A grant is a grant — permission, window, people,
  /// and now viewable fields — and giving the table version its own entity
  /// would mean two definitions of one document that drift the first time
  /// either side adds a field.
  ///
  /// An unwritten table (empty id) reports an empty list rather than a failure:
  /// "nobody has access yet" is the honest state for one, not an error banner.
  Future<Either<Failure, List<DatabaseAccessGrantRecord>>> fetchTableGrants({
    required String databaseId,
    required String tableId,
  });

  /// Replaces the whole `Access_Grants` subcollection under one table.
  ///
  /// REPLACE, not merge — same contract and same reasoning as
  /// `DatabaseDetailsBaseRepository.replaceGrants`: the edit screen hands back
  /// the complete intended state, and a diff-and-patch would have to
  /// reconstruct that intent from two snapshots.
  ///
  /// The table's `updated_at` and its member count are written in the same
  /// batch, so a table claiming "12 people" over an empty subcollection is a
  /// state no screen has to explain.
  Future<Either<Failure, void>> replaceTableGrants({
    required String databaseId,
    required String tableId,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  });

  // ── Rows (Figma 7398:3042 / 15076 / 15210) ───────────────────────────────

  /// One table's rows, first to last.
  ///
  /// An unwritten table (empty id) reports an empty list rather than a failure,
  /// the same tolerance [fetchTableGrants] and [fetchComments] show: a table
  /// nobody has filled in yet has no rows, and that is not an error.
  Future<Either<Failure, List<TableDataRow>>> fetchRows({
    required String databaseId,
    required String tableId,
  });

  /// Function Name: [fetchTable]
  ///
  /// Purpose: One table as the server holds it now, so a screen can replace
  /// the copy it opened with (DB-TABLE-01, DB-TABLE-13).
  ///
  /// Parameters: [databaseId], [tableId].
  ///
  /// Returns: [Either<Failure, DatabaseTableEntity>].
  Future<Either<Failure, DatabaseTableEntity>> fetchTable({
    required String databaseId,
    required String tableId,
  });

  /// Function Name: [fetchRowsVersion]
  ///
  /// Purpose: The table's rows version, read before its rows so a later save
  /// can tell whether someone else saved in between (DB-TABLE-01).
  ///
  /// Parameters: [databaseId], [tableId].
  ///
  /// Returns: [Either<Failure, int>]; 0 for a table saved before versions.
  Future<Either<Failure, int>> fetchRowsVersion({
    required String databaseId,
    required String tableId,
  });

  /// Function Name: [saveRowChanges]
  ///
  /// Purpose: Save only the rows this screen created, changed or removed, and
  /// refuse the save when the table's rows changed since [expectedVersion]
  /// (DB-TABLE-01). Rows the screen never loaded are never touched.
  ///
  /// Parameters:
  ///   [created]         new rows, still carrying local ids.
  ///   [updated]         loaded rows whose cells or order changed.
  ///   [deletedIds]      loaded rows the user removed.
  ///   [expectedVersion] the version read when the rows were loaded.
  ///   [expectedColumns] the columns the screen loaded; the save is refused
  ///                     when the stored columns differ.
  ///   [columns]         the columns to write, or null when unchanged. The
  ///                     table's names are never written here.
  ///   [rowCount]        rows the table holds after the save.
  ///
  /// Returns: [Either<Failure, TableRowsSaveResult>] — [ConflictFailure] when
  /// someone else saved first or changed the columns.
  Future<Either<Failure, TableRowsSaveResult>> saveRowChanges({
    required String databaseId,
    required String tableId,
    required List<TableDataRow> created,
    required List<TableDataRow> updated,
    required Set<String> deletedIds,
    required int expectedVersion,
    required List<TableColumn> expectedColumns,
    List<TableColumn>? columns,
    required int rowCount,
  });

  // ── Comments (Figma 7398:8232 / 8311 / 8587) ─────────────────────────────

  /// One table's thread, OLDEST first — a conversation is read top to bottom.
  ///
  /// An unwritten table (empty id) reports an empty list rather than a failure,
  /// the same tolerance [fetchTableGrants] shows: "nothing has been said yet" is
  /// the honest state for one, not an error banner.
  Future<Either<Failure, List<TableComment>>> fetchComments({
    required String databaseId,
    required String tableId,
  });

  /// Posts one message and returns it with the id and the server timestamp the
  /// write resolved.
  ///
  /// The AUTHOR is taken from [comment] rather than looked up here: the screen
  /// already knows who is signed in, and a repository reaching into the employee
  /// directory would make this contract untestable without one.
  Future<Either<Failure, TableComment>> addComment({
    required String databaseId,
    required TableComment comment,
  });

  /// Removes one message. Hard delete — see the data source for why a retracted
  /// sentence is not soft-deleted the way a database record is.
  Future<Either<Failure, void>> deleteComment({
    required String databaseId,
    required String tableId,
    required String commentId,
  });

  /// Applies, switches or clears [employeeId]'s thumb on one comment and returns
  /// the comment as it stands afterwards.
  ///
  /// [reaction] null clears whatever was there. Both arrays move in ONE write,
  /// which is what keeps a person from being counted on both sides at once.
  Future<Either<Failure, TableComment>> setCommentReaction({
    required String databaseId,
    required String tableId,
    required String commentId,
    required String employeeId,
    required TableCommentReaction? reaction,
  });
}
