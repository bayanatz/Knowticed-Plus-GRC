/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_cubit.dart
/// Description: Declares `CreateTableCubit`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// The draft behind the Creating Table card — Figma 7398:6533 (iPad H) /
/// 7398:6732 (iPad V) — and behind its Editing Table Name variant
/// (7398:6934 / 7398:7121).
///
/// ONE CUBIT FOR BOTH, because they are one card with one field removed. The
/// difference is `state.original`: null while creating, the loaded record while
/// editing. Everything that differs between the two frames reads off that —
/// which breadcrumb, which button label, whether the row/column count fields
/// are drawn, whether [isDirty] means "anything typed" or "different from what
/// was loaded", and whether submit writes or updates.
///
/// A second cubit would be this file with `create` swapped for `update` and the
/// two would drift the first time a validation rule changed.
library;

import 'package:bloc/bloc.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/usecases/name_rules.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/database_notification_dispatcher.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/create_table_limits.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_comments_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/create_table/create_table_state.dart';
export 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/create_table/create_table_state.dart';

class CreateTableCubit extends Cubit<CreateTableState> {
  /// A blank card for a new table under [databaseId].
  CreateTableCubit.creating({
    required String databaseId,
    this.databaseNameEn = '',
    this.databaseNameAr = '',
    required DatabaseSessionBaseRepository session,
    required CreateTableBaseRepository repository,
    required CreateDatabaseBaseRepository databaseRepository,
  })  : _repository = repository,
        _databaseRepository = databaseRepository,
        _session = session,
        super(
          CreateTableState.creating(
            databaseId: databaseId,
            firstColumnId: _mintColumnId(),
          ),
        );

  /// The same card seeded from an existing table.
  CreateTableCubit.editing({
    required DatabaseTableEntity table,
    this.databaseNameEn = '',
    this.databaseNameAr = '',
    required DatabaseSessionBaseRepository session,
    required CreateTableBaseRepository repository,
    required CreateDatabaseBaseRepository databaseRepository,
  })  : _repository = repository,
        _databaseRepository = databaseRepository,
        _session = session,
        super(CreateTableState.from(table));

  final CreateTableBaseRepository _repository;

  /// Reads the database's grants to find who the table events go to.
  final CreateDatabaseBaseRepository _databaseRepository;

  /// Who is signed in. Read when a NEW table is written, for `created_by`
  /// (DB-CREATE-02); an edit keeps the original creator.
  final DatabaseSessionBaseRepository _session;

  /// Function Name: [retypedColumns]
  ///
  /// Purpose: The loaded columns whose type this edit changes, with their new
  /// type. The page warns before saving them, and the save clears the cells
  /// that no longer fit (DB-TABLE-08).
  ///
  /// Returns: [Map<String, TableColumnType>] column id -> new type.
  Map<String, TableColumnType> get retypedColumns {
    final DatabaseTableEntity? loaded = state.original;
    if (loaded == null) return const <String, TableColumnType>{};
    final Map<String, TableColumnType> before = <String, TableColumnType>{
      for (final TableColumn c in loaded.columns) c.id: c.type,
    };
    return <String, TableColumnType>{
      for (final TableColumn c in state.columns)
        if (before.containsKey(c.id) && before[c.id] != c.type) c.id: c.type,
    };
  }

  /// The parent database's bilingual title, carried only so the notifications
  /// this cubit raises can name it (spec §1.7 says "the table {{tableName}}
  /// within {{databaseName}}"). ADDED 17/8/2026.
  ///
  /// Names and not a `DatabaseEntity`: the entity would be a second copy of a
  /// record the page above already owns and renders, and it would go stale the
  /// moment that page edited the title. Two strings cannot.
  ///
  /// Defaulted to empty rather than required so a caller that does not care
  /// about notifications — a test, or the next screen to reuse this cubit —
  /// keeps compiling. An empty pair means the body falls back to the other
  /// language and, if both are empty, prints nothing for the database; the
  /// notification still goes out, because the table name is the part the
  /// recipient needs.
  final String databaseNameEn;
  final String databaseNameAr;

  @override
  void emit(CreateTableState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Ids for the column blocks.
  ///
  /// Monotonic within the process rather than random: the blocks are keyed by
  /// this in the widget tree, and two columns created in the same microsecond
  /// sharing an id would make Flutter reuse one block's controller for both.
  static int _columnSeq = 0;
  static String _mintColumnId() =>
      'col_${DateTime.now().microsecondsSinceEpoch}_${_columnSeq++}';

  // ── Fields ───────────────────────────────────────────────────────────────

  /// Function Name: [nameEnChanged]
  ///
  /// Purpose: Store the English name as typed.
  void nameEnChanged(String value) =>
      emit(state.copyWith(nameEn: value, clearNameEnError: true));

  /// Function Name: [nameArChanged]
  ///
  /// Purpose: Store the Arabic name as typed.
  void nameArChanged(String value) =>
      emit(state.copyWith(nameAr: value, clearNameArError: true));

  /// Function Name: [descriptionEnChanged]
  ///
  /// Purpose: Store the English description as typed.
  void descriptionEnChanged(String value) =>
      emit(state.copyWith(descriptionEn: value));

  /// Function Name: [descriptionArChanged]
  ///
  /// Purpose: Store the Arabic description as typed.
  void descriptionArChanged(String value) =>
      emit(state.copyWith(descriptionAr: value));

  /// Function Name: [commentsAccessChanged]
  ///
  /// Purpose: Store who may comment on the table.
  void commentsAccessChanged(TableCommentsAccess value) =>
      emit(state.copyWith(commentsAccess: value));

  /// Function Name: [rowCountChanged]
  ///
  /// Purpose: Take "Enter Row Number" as raw text and flag it when it is out of
  /// range.
  ///
  /// The text is stored either way, including when it is rejected: blanking the
  /// box the user is typing into would make the error impossible to read and
  /// the correction impossible to make.
  void rowCountChanged(String raw, {required String rangeMessage}) {
    final String trimmed = raw.trim();

    if (trimmed.isEmpty) {
      // Empty is zero rows, which is a legitimate table — not an error.
      emit(state.copyWith(rowCountText: raw, clearRowCountError: true));
      return;
    }

    final int? parsed = int.tryParse(trimmed);
    final bool valid = parsed != null &&
        parsed >= CreateTableLimits.minRows &&
        parsed <= CreateTableLimits.maxRows;

    emit(
      state.copyWith(
        rowCountText: raw,
        rowCountError: valid ? null : rangeMessage,
        clearRowCountError: valid,
      ),
    );
  }

  // ── Columns ──────────────────────────────────────────────────────────────

  /// Function Name: [columnCountRejected]
  ///
  /// Purpose: Record that the typed column number cannot be applied, without
  /// touching the blocks.
  ///
  /// Split from [applyColumnCount] because the page has to decide between the
  /// two: a number that would delete named columns needs a confirmation first,
  /// and only a widget with a BuildContext can ask for one.
  void columnCountRejected(String message) =>
      emit(state.copyWith(columnCountError: message));

  /// Function Name: [clearColumnCountError]
  ///
  /// Purpose: Remove the column-count error once the user edits the box again.
  void clearColumnCountError() =>
      emit(state.copyWith(clearColumnCountError: true));

  /// How many named columns would be lost by shrinking to [next].
  ///
  /// Only the TRAILING blocks are dropped — "Enter Column Number" resizes the
  /// list from the end — so this counts from [next] onwards rather than
  /// counting named columns in total.
  int namedColumnsLostBy(int next) {
    if (next >= state.columns.length) return 0;
    return state.columns
        .skip(next)
        .where((TableColumn column) => column.isNamed)
        .length;
  }

  /// Function Name: [applyColumnCount]
  ///
  /// Purpose: Grow or shrink the block list to [next].
  ///
  /// Growing APPENDS fresh columns and leaves the existing ones untouched, so
  /// raising the number from 2 to 4 does not disturb what is already typed.
  /// Shrinking drops from the end for the same reason — the user is answering
  /// "how many", and taking them off the front would move every remaining
  /// heading up one row.
  ///
  /// Out-of-range values are ignored rather than clamped: silently turning a
  /// typed 500 into 50 looks like the box refusing keystrokes. The page shows
  /// [CreateTableStrings.columnCountRange] instead.
  void applyColumnCount(int next) {
    if (next < CreateTableLimits.minColumns ||
        next > CreateTableLimits.maxColumns) {
      return;
    }
    if (next == state.columns.length) {
      emit(state.copyWith(clearColumnCountError: true));
      return;
    }

    final List<TableColumn> columns = <TableColumn>[...state.columns];

    if (next < columns.length) {
      columns.removeRange(next, columns.length);
    } else {
      for (int i = columns.length; i < next; i++) {
        columns.add(TableColumn(id: _mintColumnId(), order: i));
      }
    }

    emit(
      state.copyWith(columns: _reordered(columns), clearColumnCountError: true),
    );
  }

  void columnNameChanged(String columnId, String value) => _replaceColumn(
        columnId,
        (TableColumn column) => column.copyWith(name: value),
      );

  /// Function Name: [columnTypeChanged]
  ///
  /// Purpose: Change one column's data type.
  void columnTypeChanged(String columnId, TableColumnType type) =>
      _replaceColumn(
        columnId,
        (TableColumn column) => column.copyWith(type: type),
      );

  /// Function Name: [duplicateColumn]
  ///
  /// Purpose: Insert a copy of one column directly beneath it (the copy glyph
  /// on each block, Figma 7398:6608).
  ///
  /// The NAME is deliberately not copied, and still is as of 17/8/2026 — even
  /// though duplicate headings are now allowed. Two blocks arriving with the
  /// same heading is a copy the user has to undo; an empty one is a copy they
  /// have to fill in, which is what they were going to do anyway. What is worth
  /// duplicating is the Data Type, the part that takes a decision.
  void duplicateColumn(String columnId) {
    final int index = state.columns.indexWhere(
      (TableColumn column) => column.id == columnId,
    );
    if (index < 0) return;
    if (state.columns.length >= CreateTableLimits.maxColumns) return;

    final List<TableColumn> columns = <TableColumn>[...state.columns];
    columns.insert(
      index + 1,
      TableColumn(
        id: _mintColumnId(),
        order: index + 1,
        type: columns[index].type,
      ),
    );

    emit(
      state.copyWith(columns: _reordered(columns), clearColumnCountError: true),
    );
  }

  /// Function Name: [removeColumn]
  ///
  /// Purpose: Drop one column (the red minus on each block, Figma 7398:6613).
  ///
  /// Refuses to remove the last one: a table with no columns is not a table,
  /// and an empty card with no way back to a first block is a dead end. The
  /// page hides the minus at that point, so this is the second line of defence
  /// rather than the message the user sees.
  void removeColumn(String columnId) {
    if (state.columns.length <= CreateTableLimits.minColumns) return;

    final List<TableColumn> columns = state.columns
        .where((TableColumn column) => column.id != columnId)
        .toList();
    if (columns.length == state.columns.length) return;

    emit(
      state.copyWith(columns: _reordered(columns), clearColumnCountError: true),
    );
  }

  /// Re-stamps `order` from the list position.
  ///
  /// Every mutation above goes through this, so `order` can never disagree with
  /// where the block actually sits — which is what the "1st / 2nd / 3rd" labels
  /// and the stored array both read.
  static List<TableColumn> _reordered(List<TableColumn> columns) {
    return List<TableColumn>.unmodifiable(<TableColumn>[
      for (int i = 0; i < columns.length; i++) columns[i].copyWith(order: i),
    ]);
  }

  void _replaceColumn(
    String columnId,
    TableColumn Function(TableColumn column) update,
  ) {
    final int index = state.columns.indexWhere(
      (TableColumn column) => column.id == columnId,
    );
    if (index < 0) return;

    final List<TableColumn> columns = <TableColumn>[...state.columns];
    columns[index] = update(columns[index]);
    emit(state.copyWith(columns: List<TableColumn>.unmodifiable(columns)));
  }

  // ── Messages ─────────────────────────────────────────────────────────────

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  /// Puts every field back — "Discard" on the create card, "Discard Changes" on
  /// the edit one.
  ///
  /// Resets rather than pops, because the page also has to push these values
  /// back into its `TextEditingController`s; a cubit that only popped would
  /// leave the boxes showing the edits it had just thrown away.
  void discard() {
    final DatabaseTableEntity? loaded = state.original;
    emit(
      loaded != null
          ? CreateTableState.from(loaded)
          : CreateTableState.creating(
              databaseId: state.databaseId,
              firstColumnId: _mintColumnId(),
            ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  /// Function Name: [submit]
  ///
  /// Purpose: Validate the names, check the name is free inside this database,
  /// and write.
  ///
  /// The localized copy is passed in because a cubit has no BuildContext and
  /// the domain layer must not acquire one — the same arrangement db1 and db2
  /// use.
  ///
  /// There are no COLUMN guards left to re-run. The page used to check for an
  /// unnamed block, a heading that did not match its Data Type, and two blocks
  /// sharing a heading; all three were dropped on 17/8/2026 — see
  /// `TableColumnBlock._nameField`. Column headings are saved as typed.
  ///
  /// The TABLE name is still validated here, and ORDER MATTERS for it: local
  /// checks first (free, no network), then the duplicate-name query, then the
  /// write. Running the duplicate check on an empty name would spend a
  /// Firestore read to be told that "" is available.
  Future<void> submit({
    required String requiredEnMessage,
    required String requiredArMessage,
    required String tooShortMessage,
    required String duplicateMessage,
  }) async {
    final String nameEn = state.nameEn.trim();
    final String nameAr = state.nameAr.trim();

    // The same rules as a database title (db3 rule 3).
    final NamePairErrors errors = NameRules.validate(
      nameEn: nameEn,
      nameAr: nameAr,
      requiredEnMessage: requiredEnMessage,
      requiredArMessage: requiredArMessage,
      tooShortMessage: tooShortMessage,
    );
    final String? enError = errors.enError;
    final String? arError = errors.arError;

    if (enError != null || arError != null) {
      emit(
        state.copyWith(
          submitted: true,
          status: CreateTableStatus.initial,
          nameEnError: enError,
          nameArError: arError,
          clearNameEnError: enError == null,
          clearNameArError: arError == null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitted: true,
        status: CreateTableStatus.submitting,
        clearErrorMessage: true,
        clearNameEnError: true,
        clearNameArError: true,
      ),
    );

    final DatabaseTableEntity? loaded = state.original;

    // Only worth asking when a name changed, or on a create.
    if (NameRules.changed(
      nameEn: nameEn,
      nameAr: nameAr,
      previousEn: loaded?.nameEn,
      previousAr: loaded?.nameAr,
    )) {
      final Either<Failure, void> free = await NameRules.ensureFree(
        exists: () => _repository.tableNameExists(
          databaseId: state.databaseId,
          nameEn: nameEn,
          nameAr: nameAr,
          excludeId: loaded?.id ?? '',
        ),
        duplicateMessage: duplicateMessage,
      );
      final Failure? taken = free.fold((Failure f) => f, (_) => null);
      if (taken != null) {
        emit(
          state.copyWith(
            status: CreateTableStatus.failure,
            errorMessage: taken.errMessage,
          ),
        );
        return;
      }
    }

    final DatabaseTableEntity draft = (loaded ??
            DatabaseTableEntity(
              id: '',
              databaseId: state.databaseId,
              nameEn: nameEn,
              nameAr: nameAr,
            ))
        .copyWith(
      nameEn: nameEn,
      nameAr: nameAr,
      descriptionEn: state.descriptionEn.trim(),
      descriptionAr: state.descriptionAr.trim(),
      columns: state.columns,
      commentsAccess: state.commentsAccess,
      // Only a create sets these two: the row count is not editable from the
      // edit card, and re-stamping `created_by` on an edit would credit the
      // table to whoever last renamed it.
      rowCount: loaded == null ? state.rowCount : loaded.rowCount,
      createdBy:
          loaded == null ? _session.signedInEmployeeId : loaded.createdBy,
    );

    final Either<Failure, DatabaseTableEntity> result = loaded == null
        ? await _repository.createTable(draft)
        : await _repository.updateTable(draft);

    final CreateTableState next = result.fold(
      (Failure failure) => state.copyWith(
        status: CreateTableStatus.failure,
        errorMessage: failure.errMessage,
      ),
      // Seeded from what came BACK, not from what was sent: the server resolved
      // `created_at` / `updated_at`, and the next Discard has to return to the
      // saved state rather than to the pre-save one.
      (DatabaseTableEntity saved) => CreateTableState.from(saved)
          .copyWith(status: CreateTableStatus.success, savedTable: saved),
    );

    // The rows still hold values for removed columns, and values that no
    // longer fit a retyped one: clean them before the screen reports success,
    // so the details grid reloads clean rows (DB-TABLE-08). The table is
    // already saved, so a failed cleanup is not a failed save: it is logged and
    // flagged on the success state, and the page reports it after the success
    // dialog.
    CreateTableState reported = next;
    if (loaded != null && next.status == CreateTableStatus.success) {
      final Set<String> kept =
          state.columns.map((TableColumn c) => c.id).toSet();
      final Either<Failure, int> cleaned = await _repository.cleanColumnValues(
        databaseId: loaded.databaseId,
        tableId: loaded.id,
        removedColumnIds: <String>{
          for (final TableColumn c in loaded.columns)
            if (!kept.contains(c.id)) c.id,
        },
        retypedColumns: retypedColumns,
      );
      cleaned.fold((Failure failure) {
        if (kDebugMode) {
          debugPrint(
            '🔴 [CreateTableCubit] column cleanup failed: '
            '${failure.errMessage}',
          );
        }
        reported = next.copyWith(cleanupFailed: true);
      }, (_) {});
      if (isClosed) return;
    }

    emit(reported);

    if (next.status == CreateTableStatus.success) {
      _notify(saved: next.savedTable, before: loaded);
    }
  }

  /// Function Name: [_notify]
  ///
  /// Purpose: Raise the §1.7 events this save earned — after the emit, and
  /// never awaited. See `DatabaseNotificationDispatcher`.
  ///
  /// A CREATE is one event. An EDIT is up to three, because the card edits three
  /// unrelated things behind one button and the spec has a separate event for
  /// each: the details (name / description / comments access), the columns added,
  /// and the structure otherwise changing. Sending only "Table Details Updated"
  /// for a save that dropped two columns would understate it to exactly the
  /// people whose saved views are about to break.
  void _notify({
    required DatabaseTableEntity? saved,
    required DatabaseTableEntity? before,
  }) {
    if (saved == null) return;

    if (before == null) {
      DatabaseNotificationDispatcher.tableCreated(
        repository: _databaseRepository,
        databaseId: saved.databaseId,
        databaseNameEn: databaseNameEn,
        databaseNameAr: databaseNameAr,
        tableNameEn: saved.nameEn,
        tableNameAr: saved.nameAr,
      );
      return;
    }

    final bool detailsChanged = saved.nameEn != before.nameEn ||
        saved.nameAr != before.nameAr ||
        saved.descriptionEn != before.descriptionEn ||
        saved.descriptionAr != before.descriptionAr ||
        saved.commentsAccess != before.commentsAccess;

    // Columns are identified by `TableColumn.id`, so a column that was RENAMED
    // is the same column with different details — it belongs to
    // `structureChanged`, not to `addedColumnNames`, and announcing it as new
    // would tell people to look for a field that has been there all along.
    final Set<String> beforeIds =
        before.columns.map((TableColumn c) => c.id).toSet();

    final List<TableColumn> added = saved.columns
        .where((TableColumn c) => !beforeIds.contains(c.id))
        .toList(growable: false);

    final Set<String> savedIds =
        saved.columns.map((TableColumn c) => c.id).toSet();
    final bool removed = beforeIds.any((String id) => !savedIds.contains(id));

    // A retype or a reorder of columns that already existed. Both change how
    // the stored data reads, which is what `tableStructureUpdated` is about.
    bool reshaped = false;
    for (final TableColumn column in saved.columns) {
      for (final TableColumn was in before.columns) {
        if (was.id != column.id) continue;
        if (was.type != column.type ||
            was.order != column.order ||
            was.name != column.name) {
          reshaped = true;
        }
        break;
      }
      if (reshaped) break;
    }

    DatabaseNotificationDispatcher.tableSaved(
      repository: _databaseRepository,
      databaseId: saved.databaseId,
      databaseNameEn: databaseNameEn,
      databaseNameAr: databaseNameAr,
      tableNameEn: saved.nameEn,
      tableNameAr: saved.nameAr,
      detailsChanged: detailsChanged,
      structureChanged: removed || reshaped,
      addedColumnNames:
          added.map((TableColumn c) => c.name).toList(growable: false),
    );
  }
}
