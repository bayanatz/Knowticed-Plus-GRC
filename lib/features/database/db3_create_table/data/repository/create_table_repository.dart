/// Module: database / db3_create_table / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_repository.dart
/// Description: Declares `CreateTableRepository`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// Turns the data source's throws into `Either<Failure, T>`. This is the only
/// layer that catches — the cubits fold, the UI renders, neither catches.
library;

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/entities/database_access_record.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/data_source/remote_data_source/create_table_remote_data_source.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/database_table_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/table_comment_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_comment.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_rows_save_result.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CreateTableRepository implements CreateTableBaseRepository {
  CreateTableRepository({CreateTableRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? CreateTableRemoteDataSource();

  final CreateTableRemoteDataSource _remoteDataSource;

  /// Every method funnels through this, so the two failure shapes — a Firebase
  /// error with a code and everything else — are mapped once instead of in five
  /// near-identical try/catch blocks that can drift apart.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right<Failure, T>(await run());
    } on FirebaseException catch (error) {
      return Left<Failure, T>(FirebaseFailure(error.message ?? error.code));
    } catch (error) {
      return Left<Failure, T>(FeatureFailure(error.toString()));
    }
  }

  /// An empty parent id means the caller is holding a database that was never
  /// written. Passing it through calls `doc('')`, which throws a bare assertion
  /// from the Firestore SDK rather than anything the UI can show.
  Either<Failure, T>? _rejectEmptyDatabaseId<T>(String databaseId) {
    if (databaseId.isNotEmpty) return null;
    return Left<Failure, T>(FeatureFailure(S.current.dbTableNoDatabaseId));
  }

  @override
  Future<Either<Failure, List<DatabaseTableEntity>>> fetchTables(
    String databaseId,
  ) async {
    // A record with no id has no subcollection either. Reporting an empty list
    // rather than a failure is right here: the details screen's honest state
    // for an unsaved database is "no tables yet", not an error banner.
    if (databaseId.isEmpty) {
      return const Right<Failure, List<DatabaseTableEntity>>(
        <DatabaseTableEntity>[],
      );
    }

    final Either<Failure, List<DatabaseTableEntity>> tables =
        await _guard<List<DatabaseTableEntity>>(
      () => _remoteDataSource.fetchTables(databaseId),
    );
    if (tables.isLeft()) return tables;
    return Right<Failure, List<DatabaseTableEntity>>(
      await _withCreators(
        databaseId,
        tables.getOrElse(() => const <DatabaseTableEntity>[]),
      ),
    );
  }

  /// Tables made before the creator was saved get the database's creator,
  /// stored once so their Private comments can be posted on (DB-TABLE-02).
  /// A failed fill keeps the tables as read; the list still loads.
  Future<List<DatabaseTableEntity>> _withCreators(
    String databaseId,
    List<DatabaseTableEntity> tables,
  ) async {
    final List<String> missing = <String>[
      for (final DatabaseTableEntity t in tables)
        if ((t.createdBy ?? '').isEmpty && t.id.isNotEmpty) t.id,
    ];
    if (missing.isEmpty) return tables;

    final Either<Failure, String?> filled = await _guard<String?>(
      () => _remoteDataSource.fillMissingCreators(
        databaseId: databaseId,
        tableIds: missing,
      ),
    );
    final String? creator = filled.fold((Failure failure) {
      if (kDebugMode) {
        debugPrint(
          '🔴 [CreateTableRepository] creator fill failed: '
          '${failure.errMessage}',
        );
      }
      return null;
    }, (String? id) => id);
    if (creator == null) return tables;
    return <DatabaseTableEntity>[
      for (final DatabaseTableEntity t in tables)
        (t.createdBy ?? '').isEmpty ? t.copyWith(createdBy: creator) : t,
    ];
  }

  @override
  Future<Either<Failure, DatabaseTableEntity>> createTable(
    DatabaseTableEntity table,
  ) async {
    final Either<Failure, DatabaseTableEntity>? rejected =
        _rejectEmptyDatabaseId<DatabaseTableEntity>(table.databaseId);
    if (rejected != null) return rejected;

    return _guard<DatabaseTableEntity>(
      () => _remoteDataSource.createTable(DatabaseTableModel.fromEntity(table)),
    );
  }

  @override
  Future<Either<Failure, DatabaseTableEntity>> updateTable(
    DatabaseTableEntity table,
  ) async {
    final Either<Failure, DatabaseTableEntity>? rejected =
        _rejectEmptyDatabaseId<DatabaseTableEntity>(table.databaseId);
    if (rejected != null) return rejected;

    if (table.id.isEmpty) {
      return Left<Failure, DatabaseTableEntity>(
        FeatureFailure(S.current.dbTableNoIdCannotSave),
      );
    }

    return _guard<DatabaseTableEntity>(
      () => _remoteDataSource.updateTable(DatabaseTableModel.fromEntity(table)),
    );
  }

  @override
  Future<Either<Failure, int>> cleanColumnValues({
    required String databaseId,
    required String tableId,
    required Set<String> removedColumnIds,
    required Map<String, TableColumnType> retypedColumns,
  }) {
    if (databaseId.isEmpty || tableId.isEmpty) {
      return Future<Either<Failure, int>>.value(const Right<Failure, int>(0));
    }
    return _guard<int>(
      () => _remoteDataSource.cleanColumnValues(
        databaseId: databaseId,
        tableId: tableId,
        removedColumnIds: removedColumnIds,
        retypedColumns: retypedColumns,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteTable({
    required String databaseId,
    required String tableId,
  }) async {
    final Either<Failure, void>? rejected = _rejectEmptyDatabaseId<void>(
      databaseId,
    );
    if (rejected != null) return rejected;

    if (tableId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure(S.current.dbTableNoIdCannotDelete),
      );
    }

    return _guard<void>(
      () => _remoteDataSource.deleteTable(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> tableNameExists({
    required String databaseId,
    required String nameEn,
    required String nameAr,
    required String excludeId,
  }) async {
    // No parent, no siblings — so no name can be taken. Reporting "free" rather
    // than a failure keeps the create card usable against a database that has
    // not been written yet, which is the same tolerance `fetchTables` shows.
    if (databaseId.isEmpty) return const Right<Failure, bool>(false);

    return _guard<bool>(
      () => _remoteDataSource.tableNameExists(
        databaseId: databaseId,
        nameEn: nameEn,
        nameAr: nameAr,
        excludeId: excludeId,
      ),
    );
  }

  @override
  Future<Either<Failure, List<DatabaseAccessGrantRecord>>> fetchTableGrants({
    required String databaseId,
    required String tableId,
  }) async {
    // A table that was never written has no subcollection either. An empty list
    // is the honest answer — "nobody has access yet" — not an error banner.
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, List<DatabaseAccessGrantRecord>>(
        <DatabaseAccessGrantRecord>[],
      );
    }

    return _guard<List<DatabaseAccessGrantRecord>>(
      () => _remoteDataSource.fetchTableGrants(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> replaceTableGrants({
    required String databaseId,
    required String tableId,
    required List<DatabaseAccessGrantRecord> records,
    String? grantedBy,
    String? grantedByNameEn,
    String? grantedByNameAr,
  }) async {
    final Either<Failure, void>? rejected = _rejectEmptyDatabaseId<void>(
      databaseId,
    );
    if (rejected != null) return rejected;

    if (tableId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure(S.current.dbTableNoIdCannotSaveAccess),
      );
    }

    return _guard<void>(
      () => _remoteDataSource.replaceTableGrants(
        databaseId: databaseId,
        tableId: tableId,
        records: records,
        grantedBy: grantedBy,
        grantedByNameEn: grantedByNameEn,
        grantedByNameAr: grantedByNameAr,
      ),
    );
  }

  // ── Rows (Figma 7398:3042 / 15076 / 15210) ───────────────────────────────

  @override
  Future<Either<Failure, List<TableDataRow>>> fetchRows({
    required String databaseId,
    required String tableId,
  }) async {
    // A table with no id has no subcollection. "Nothing has been filled in yet"
    // is the honest state for one, not an error banner — same reading
    // `fetchComments` takes one method down.
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, List<TableDataRow>>(<TableDataRow>[]);
    }

    return _guard<List<TableDataRow>>(
      () =>
          _remoteDataSource.fetchRows(databaseId: databaseId, tableId: tableId),
    );
  }

  @override
  Future<Either<Failure, DatabaseTableEntity>> fetchTable({
    required String databaseId,
    required String tableId,
  }) async {
    if (databaseId.isEmpty || tableId.isEmpty) {
      return Left<Failure, DatabaseTableEntity>(
        FeatureFailure(S.current.dbTableNotSavedYet),
      );
    }
    return _guard<DatabaseTableEntity>(
      () => _remoteDataSource.fetchTable(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, int>> fetchRowsVersion({
    required String databaseId,
    required String tableId,
  }) async {
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, int>(0);
    }
    return _guard<int>(
      () => _remoteDataSource.fetchRowsVersion(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
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
  }) async {
    final Either<Failure, TableRowsSaveResult>? rejected =
        _rejectEmptyDatabaseId<TableRowsSaveResult>(databaseId);
    if (rejected != null) return rejected;
    if (tableId.isEmpty) {
      return Left<Failure, TableRowsSaveResult>(
        FeatureFailure(S.current.dbTableNotSavedRows),
      );
    }

    try {
      return Right<Failure, TableRowsSaveResult>(
        await _remoteDataSource.saveRowChanges(
          databaseId: databaseId,
          tableId: tableId,
          created: created,
          updated: updated,
          deletedIds: deletedIds,
          expectedVersion: expectedVersion,
          expectedColumns: expectedColumns,
          columns: columns,
          rowCount: rowCount,
        ),
      );
    } on StaleRowsException {
      return const Left<Failure, TableRowsSaveResult>(
        ConflictFailure('the rows or columns changed since they were loaded'),
      );
    } on FirebaseException catch (error) {
      return Left<Failure, TableRowsSaveResult>(
        FirebaseFailure(error.message ?? error.code),
      );
    } catch (error) {
      return Left<Failure, TableRowsSaveResult>(
        FeatureFailure(error.toString()),
      );
    }
  }

  // ── Comments ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<TableComment>>> fetchComments({
    required String databaseId,
    required String tableId,
  }) async {
    // A table that was never written has no subcollection either. An empty
    // thread is the honest answer, not an error banner — same tolerance
    // `fetchTableGrants` shows.
    if (databaseId.isEmpty || tableId.isEmpty) {
      return const Right<Failure, List<TableComment>>(<TableComment>[]);
    }

    return _guard<List<TableComment>>(
      () => _remoteDataSource.fetchComments(
        databaseId: databaseId,
        tableId: tableId,
      ),
    );
  }

  @override
  Future<Either<Failure, TableComment>> addComment({
    required String databaseId,
    required TableComment comment,
  }) async {
    final Either<Failure, TableComment>? rejected =
        _rejectEmptyDatabaseId<TableComment>(databaseId);
    if (rejected != null) return rejected;

    if (comment.tableId.isEmpty) {
      return Left<Failure, TableComment>(
        FeatureFailure(S.current.dbTableNoIdCannotComment),
      );
    }

    return _guard<TableComment>(
      () => _remoteDataSource.addComment(
        databaseId: databaseId,
        comment: TableCommentModel.fromEntity(comment),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required String databaseId,
    required String tableId,
    required String commentId,
  }) async {
    final Either<Failure, void>? rejected = _rejectEmptyDatabaseId<void>(
      databaseId,
    );
    if (rejected != null) return rejected;

    if (tableId.isEmpty || commentId.isEmpty) {
      return Left<Failure, void>(
        FeatureFailure(S.current.dbCommentNoIdCannotDelete),
      );
    }

    return _guard<void>(
      () => _remoteDataSource.deleteComment(
        databaseId: databaseId,
        tableId: tableId,
        commentId: commentId,
      ),
    );
  }

  @override
  Future<Either<Failure, TableComment>> setCommentReaction({
    required String databaseId,
    required String tableId,
    required String commentId,
    required String employeeId,
    required TableCommentReaction? reaction,
  }) async {
    final Either<Failure, TableComment>? rejected =
        _rejectEmptyDatabaseId<TableComment>(databaseId);
    if (rejected != null) return rejected;

    if (tableId.isEmpty || commentId.isEmpty) {
      return Left<Failure, TableComment>(
        FeatureFailure(S.current.dbCommentNoIdCannotReact),
      );
    }

    // An anonymous reaction cannot be undone — there would be no id to remove
    // from the array — so it is refused rather than written. The screen keeps
    // the buttons out of reach when nobody is signed in; this is the backstop.
    if (employeeId.isEmpty) {
      return Left<Failure, TableComment>(
        FeatureFailure(S.current.dbTableSignInToReact),
      );
    }

    return _guard<TableComment>(
      () => _remoteDataSource.setCommentReaction(
        databaseId: databaseId,
        tableId: tableId,
        commentId: commentId,
        employeeId: employeeId,
        reaction: reaction,
      ),
    );
  }
}
