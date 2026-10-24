/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_data_cubit.dart
/// Description: Declares `TableDataCubit`.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// The Form Builder's state — the section every earlier file in this module
/// deferred to. It backs three screens, which is why it is one cubit and not
/// three:
///
///   Table Name Details   the filled card    (Figma 7398:3042 / 3246)
///   Editing Table Name   the editable grid  (Figma 7398:15076)
///   Preview              the rendered table (Figma 7398:15210)
///
/// All three read the same rows, and the editing screen hands its result to the
/// details screen the moment it saves. Splitting them would mean the same
/// documents had three owners and the details screen would show yesterday's
/// values until it was reopened.
///
/// WHY ROWS ARE SEEDED WHEN THE SUBCOLLECTION IS EMPTY
/// ---------------------------------------------------
/// A table is created with "Enter Row Number" — `row_count` — and no row
/// documents at all; nothing has been filled in yet. The Figma still draws that
/// table as four labelled, empty rows rather than as blank space, because those
/// rows are what the user asked for and what they are about to type into.
/// [_seed] materialises them locally. They are NOT written until Save, so a
/// table that is opened and closed again costs no writes.
///
/// UNDO IS A STACK OF WHOLE SNAPSHOTS
/// ----------------------------------
/// Undo/Redo (7398:15076) covers typing, adding and removing rows, and adding
/// and removing columns. A command log would need an inverse for each of those
/// and would have to keep the inverses correct as the screen grows; a snapshot
/// of the columns and rows is correct by construction. A table is bounded at
/// `maxRows` * `maxColumns` short strings, and the stack is capped at
/// [_historyLimit], so the memory is bounded too.
library;

import 'package:knowticed_plus/features/database/db1_create_database/data/models/create_database_collections.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_column_type.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_rows_save_result.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/use_cases/table_access_rule.dart';

import 'dart:io';
import 'dart:typed_data';

import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/create_table_collections.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/usecases/table_rows_diff.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/usecases/parse_table_import_use_case.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_import_outcome.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_data/table_data_state.dart';

export 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_data/table_data_state.dart';

/// How an export ended (DB-TABLE-12).
enum TableExportStatus { done, empty, failed }

class TableDataCubit extends Cubit<TableDataState> {
  TableDataCubit({
    required DatabaseEntity database,
    required DatabaseTableEntity table,
    required DatabaseSessionBaseRepository session,
    required CreateTableBaseRepository repository,
    TableAccessRule rule = const TableAccessRule(),
    ParseTableImportUseCase parseImport = const ParseTableImportUseCase(),
    CSVHelper? csvHelper,
  })  : _repository = repository,
        _parseImport = parseImport,
        _database = database,
        _session = session,
        _rule = rule,
        _csv = csvHelper ?? CSVHelper(),
        _loadedColumns = table.columns,
        super(
          TableDataState(
            table: table,
            visibleColumnIds: rule
                .resolve(
                  database,
                  table,
                  viewerId: session.signedInEmployeeId,
                  today: DateTime.now(),
                )
                .visibleColumnIds,
          ),
        );

  final CreateTableBaseRepository _repository;
  final DatabaseEntity _database;
  final DatabaseSessionBaseRepository _session;
  final TableAccessRule _rule;
  final ParseTableImportUseCase _parseImport;
  final CSVHelper _csv;
  final LiveRefresh _live = LiveRefresh();

  /// Function Name: [access]
  ///
  /// Purpose: What the signed-in employee may do with this table today
  /// (DB-TABLE-03), worked out here rather than in the pages. Save and Import
  /// refuse without [DatabaseAccess.canEditRows]; the pages read it to decide
  /// which buttons to draw.
  ///
  /// Returns: [DatabaseAccess].
  DatabaseAccess get access => _rule.resolve(
        _database,
        state.table,
        viewerId: _session.signedInEmployeeId,
        today: DateTime.now(),
      );

  /// Function Name: [exportVisibleRows]
  ///
  /// Purpose: Write the rows on screen to a CSV (DB-TABLE-12): the search is
  /// applied and only the columns this viewer may see are included.
  ///
  /// Parameters: [fileName] without the extension.
  ///
  /// Returns: [Future<(TableExportStatus, File?)>] — the file when done.
  Future<(TableExportStatus, File?)> exportVisibleRows({
    required String fileName,
  }) async {
    if (!access.canExport) return (TableExportStatus.failed, null);
    final List<TableColumn> columns = state.namedColumns;
    final List<TableDataRow> rows = state.visibleRows;
    if (rows.isEmpty || columns.isEmpty) return (TableExportStatus.empty, null);

    try {
      final File file = await _csv.exportToCSV(<List<String>>[
        <String>[for (final TableColumn c in columns) c.name.trim()],
        for (final TableDataRow row in rows)
          <String>[for (final TableColumn c in columns) row.valueFor(c)],
      ], fileName);
      return (TableExportStatus.done, file);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('🔴 [TableDataCubit] export failed: $error');
      }
      return (TableExportStatus.failed, null);
    }
  }

  /// Snapshots older than the current one, newest last. Undo pops from here.
  final List<TableDataSnapshot> _past = <TableDataSnapshot>[];

  /// Snapshots undone away, newest last. Redo pops from here, and any fresh
  /// edit clears it — the branch the user did not take is gone the moment they
  /// take a different one, which is what every editor does.
  final List<TableDataSnapshot> _future = <TableDataSnapshot>[];

  /// How far back Undo reaches. Deep enough that no realistic editing session
  /// hits it, bounded so a long one cannot grow without limit.
  static const int _historyLimit = 50;

  /// Counter behind the locally-minted ids of rows added on this screen.
  ///
  /// Prefixed and counted rather than random: the id has to be unique within
  /// this session. A row whose id is not in [_stored] is CREATED by the next
  /// save (`TableRowsDiff`), and the real Firestore id the save returns
  /// replaces this one on screen.
  int _localRowSeq = 0;

  /// The rows as last read from or written to Firestore, by id. A save is the
  /// difference between these and the screen, never a replace (DB-TABLE-01).
  final Map<String, TableDataRow> _stored = <String, TableDataRow>{};

  /// The table's `rows_version` when [_stored] was taken.
  int _rowsVersion = 0;

  /// The columns as last read from or written to Firestore. A save is refused
  /// when the stored columns no longer match them, so an old screen cannot
  /// undo someone else's column change (DB-TABLE-01).
  List<TableColumn> _loadedColumns;

  @override
  void emit(TableDataState state) {
    if (isClosed) return;
    super.emit(state);
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  /// Function Name: [load]
  ///
  /// Purpose: Read the table and its rows, seeding empty rows when it has
  /// none. The table is read again too, so the columns on screen are the
  /// stored ones, not the copy the screen was opened with (DB-TABLE-01).
  ///
  /// A FAILED read shows the error and no rows, and Save stays off
  /// ([TableDataState.loadFailed]). Seeding blank rows here used to look like
  /// an empty table, and saving it deleted every stored row (DB-TABLE-01).
  ///
  /// Returns: [Future<void>]; the result arrives as a new state.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(
        state.copyWith(
          isLoading: true,
          clearErrorMessage: true,
          loadFailed: false,
          saveConflict: false,
        ),
      );
    }

    // Version first, rows second: see `fetchRowsVersion`.
    final Either<Failure, int> version = await _repository.fetchRowsVersion(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
    );
    // A table that was never written has nothing newer to read.
    final Either<Failure, DatabaseTableEntity> table = state.table.id.isEmpty
        ? Right<Failure, DatabaseTableEntity>(state.table)
        : await _repository.fetchTable(
            databaseId: state.table.databaseId,
            tableId: state.table.id,
          );
    final Either<Failure, List<TableDataRow>> result = await _repository
        .fetchRows(databaseId: state.table.databaseId, tableId: state.table.id);

    final Failure? failure = version.fold((Failure f) => f, (_) => null) ??
        table.fold((Failure f) => f, (_) => null) ??
        result.fold((Failure f) => f, (_) => null);
    if (failure != null) {
      if (silent) return;
      emit(
        state.copyWith(
          isLoading: false,
          rows: const <TableDataRow>[],
          loadFailed: true,
          errorMessage: failure.errMessage,
        ),
      );
      return;
    }

    final List<TableDataRow> rows = result.getOrElse(
      () => const <TableDataRow>[],
    );
    _rowsVersion = version.getOrElse(() => 0);
    _remember(rows);
    final DatabaseTableEntity current = table.getOrElse(() => state.table);
    _loadedColumns = current.columns;

    emit(
      state.copyWith(
        table: current,
        isLoading: false,
        rows: rows.isEmpty ? _seed(current.rowCount) : rows,
        clearErrorMessage: true,
      ),
    );

    // Rows changed elsewhere refresh the grid, but never over unsaved edits.
    _live.watchPaths(
      <String>[
        '${getBaseUrl(CreateDatabaseCollections.databases)}/'
            '${state.table.databaseId}/${CreateTableCollections.tables}/'
            '${state.table.id}/${CreateTableCollections.rows}',
      ],
      () {
        if (state.isDirty || state.isSaving || state.isLoading) return;
        load(silent: true);
      },
    );
  }

  /// Function Name: [tableSaved]
  ///
  /// Purpose: Take the table the editor saved — its columns and row count —
  /// so the next Edit starts from them (DB-TABLE-13). Without this the screen
  /// kept the columns it opened with, and a second edit saved those back over
  /// the columns the first edit added. Call [load] after it for the rows.
  ///
  /// Parameters: [table] the record the editor returned.
  void tableSaved(DatabaseTableEntity table) {
    _loadedColumns = table.columns;
    emit(state.copyWith(table: table));
  }

  void _remember(List<TableDataRow> rows) {
    _stored
      ..clear()
      ..addAll(<String, TableDataRow>{
        for (final TableDataRow row in rows) row.id: row,
      });
  }

  /// The empty rows a table starts life with — `row_count` of them, in order.
  ///
  /// Local ids, because none of these exist in Firestore yet.
  List<TableDataRow> _seed(int rowCount) => <TableDataRow>[
        for (int i = 0; i < rowCount; i++) _blankRow(i),
      ];

  TableDataRow _blankRow(int order) =>
      TableDataRow(id: 'local-${_localRowSeq++}', order: order);

  // ── Reading ──────────────────────────────────────────────────────────────

  /// Function Name: [searchChanged]
  ///
  /// Purpose: Narrow the grid, in memory — the rows are already here.
  ///
  /// Parameters: [value] the search text.
  ///
  /// Returns: void; the change arrives as a new state.
  void searchChanged(String value) => emit(state.copyWith(query: value));

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  // ── Editing cells ────────────────────────────────────────────────────────

  /// Function Name: [cellChanged]
  ///
  /// Purpose: Put [value] in one cell.
  ///
  /// NOT VALIDATED HERE. `TableColumnType.accepts` is the whole-value check and
  /// it only makes sense on a finished value — running it per keystroke would
  /// reject `2` on the way to `25/12/2026`. The field installs the type's
  /// keystroke filter as the user types and [invalidCells] is what the save
  /// guard reads.
  ///
  /// One snapshot per cell, not per keystroke: undoing a cell should restore the
  /// value that was there before the user started typing in it, not walk back
  /// through the word letter by letter.
  void cellChanged({
    required String rowId,
    required String columnId,
    required String value,
  }) {
    final int index = state.rows.indexWhere((TableDataRow r) => r.id == rowId);
    if (index < 0) return;

    final TableDataRow row = state.rows[index];
    if ((row.values[columnId] ?? '') == value) return;

    _pushHistoryIfNewCell(rowId: rowId, columnId: columnId);

    final List<TableDataRow> next = List<TableDataRow>.of(state.rows);
    next[index] = row.withValue(columnId, value);

    emit(state.copyWith(rows: next, isDirty: true, canUndo: true));
  }

  /// The cell the last snapshot was taken for, so a run of keystrokes in one box
  /// produces one undo step.
  String? _lastEditedCell;

  void _pushHistoryIfNewCell({
    required String rowId,
    required String columnId,
  }) {
    final String key = '$rowId/$columnId';
    if (_lastEditedCell == key) return;
    _lastEditedCell = key;
    _pushHistory();
  }

  // ── Editing rows ─────────────────────────────────────────────────────────

  /// Function Name: [addRow]
  ///
  /// Purpose: "+ Row" (Figma 7398:15076) — append one empty row at the end.
  ///
  /// Returns: void; the change arrives as a new state.
  void addRow() {
    _pushHistory();
    emit(
      state.copyWith(
        rows: <TableDataRow>[...state.rows, _blankRow(state.rows.length)],
        isDirty: true,
        canUndo: true,
      ),
    );
  }

  /// Function Name: [toggleRowSelected]
  ///
  /// Purpose: The tick in the leading column — select or unselect one row.
  ///
  /// Parameters: [rowId] the row ticked.
  ///
  /// Returns: void; the change arrives as a new state.
  void toggleRowSelected(String rowId) {
    final Set<String> next = Set<String>.of(state.selectedRowIds);
    if (!next.remove(rowId)) next.add(rowId);
    emit(state.copyWith(selectedRowIds: next));
  }

  /// Function Name: [removeSelection]
  ///
  /// Purpose: "Remove Selection" (Figma 7398:15076) — drop every ticked row.
  /// Nothing happens when nothing is ticked.
  ///
  /// Returns: void; the change arrives as a new state.
  void removeSelection() {
    if (!state.hasSelection) return;
    _pushHistory();

    final List<TableDataRow> next = state.rows
        .where((TableDataRow row) => !state.selectedRowIds.contains(row.id))
        .toList(growable: false);

    emit(
      state.copyWith(
        rows: next,
        selectedRowIds: const <String>{},
        isDirty: true,
        canUndo: true,
      ),
    );
  }

  // ── Editing columns ──────────────────────────────────────────────────────

  /// Function Name: [addColumn]
  ///
  /// Purpose: "+ Column" (Figma 7398:15076) — append one unnamed General
  /// column; the user types its heading next.
  ///
  /// Returns: void; the change arrives as a new state.
  void addColumn() {
    _pushHistory();

    final List<TableColumn> next = <TableColumn>[
      ...state.table.columns,
      TableColumn(
        id: 'local-col-${_localRowSeq++}',
        order: state.table.columns.length,
      ),
    ];

    emit(
      state.copyWith(
        table: state.table.copyWith(columns: next),
        isDirty: true,
        canUndo: true,
      ),
    );
  }

  /// Function Name: [columnNameChanged]
  ///
  /// Purpose: Rename one column in the working copy of the grid.
  void columnNameChanged({required String columnId, required String name}) =>
      _mutateColumn(columnId, (TableColumn c) => c.copyWith(name: name));

  /// Function Name: [columnTypeChanged]
  ///
  /// Purpose: The "Data Type" dropdown on a heading.
  ///
  /// Cells that no longer fit the new type ARE cleared, on screen and under
  /// Undo (DB-TABLE-08): leaving them made Save refuse until the user fixed
  /// cells they never touched. Cells that still fit are kept as they are.
  ///
  /// Parameters: [columnId] the column; [type] its new type.
  void columnTypeChanged({
    required String columnId,
    required TableColumnType type,
  }) {
    _mutateColumn(columnId, (TableColumn c) => c.copyWith(type: type));
    // Cells that no longer fit the new type are cleared here, on screen and
    // under Undo, instead of blocking Save until the user fixes cells they
    // never touched (DB-TABLE-08).
    // The fields re-read their text, so a cleared cell shows empty — the
    // value Save will store (DB-TABLE-17).
    emit(
      state.copyWith(
        rows: <TableDataRow>[
          for (final TableDataRow row in state.rows)
            type.accepts(row.values[columnId] ?? '')
                ? row
                : row.withValue(columnId, ''),
        ],
        cellsRevision: state.cellsRevision + 1,
      ),
    );
  }

  /// Function Name: [removeColumn]
  ///
  /// Purpose: The red circle on a heading — remove the column. Its values stay
  /// in each row until the save, so Undo brings the column back with its data.
  ///
  /// Parameters: [columnId] the column to remove.
  ///
  /// Returns: void; the change arrives as a new state.
  void removeColumn(String columnId) {
    _pushHistory();

    final List<TableColumn> next = <TableColumn>[
      for (final TableColumn column in state.table.columns)
        if (column.id != columnId) column,
    ];

    emit(
      state.copyWith(
        table: state.table.copyWith(columns: _reordered(next)),
        isDirty: true,
        canUndo: true,
      ),
    );
  }

  void _mutateColumn(String columnId, TableColumn Function(TableColumn) apply) {
    final int index = state.table.columns.indexWhere(
      (TableColumn c) => c.id == columnId,
    );
    if (index < 0) return;

    _pushHistoryIfNewCell(rowId: 'heading', columnId: columnId);

    final List<TableColumn> next = List<TableColumn>.of(state.table.columns);
    next[index] = apply(next[index]);

    emit(
      state.copyWith(
        table: state.table.copyWith(columns: next),
        isDirty: true,
        canUndo: true,
      ),
    );
  }

  /// `order` rewritten from list position, so removing the second of four
  /// columns does not leave the remaining three numbered 0, 2, 3.
  List<TableColumn> _reordered(List<TableColumn> columns) => <TableColumn>[
        for (int i = 0; i < columns.length; i++) columns[i].copyWith(order: i),
      ];

  // ── Importing ────────────────────────────────────────────────────────────

  /// Function Name: [parseImport]
  ///
  /// Purpose: Read an import file into rows for this table's columns, OFF the
  /// UI thread (DB-TABLE-04), through [ParseTableImportUseCase].
  ///
  /// Parameters: [bytes] the file; [fileName] decides CSV or Excel.
  ///
  /// Returns: [Future<TableImportOutcome>] — the rows, or why the file was
  /// refused. Never throws.
  Future<TableImportOutcome> parseImport({
    required Uint8List bytes,
    required String fileName,
  }) =>
      compute(
        _runImport,
        _ImportRequest(
          parse: _parseImport,
          bytes: bytes,
          fileName: fileName,
          columns: state.namedColumns,
        ),
      );

  /// Runs in the background isolate.
  static TableImportOutcome _runImport(_ImportRequest request) => request.parse(
        bytes: request.bytes,
        fileName: request.fileName,
        columns: request.columns,
      );

  /// Function Name: [applyImportedRows]
  ///
  /// Purpose: Fold rows read from a file into the table (Figma 7398:4041).
  ///
  /// [overwrite] true replaces every row; false appends after the ones already
  /// there — the two values of "Type Of Import".
  ///
  /// NOT WRITTEN HERE. The rows land in state exactly as if they had been
  /// typed, which means the user sees what they imported before it is stored,
  /// Undo takes it back, and Save is still the one place rows reach Firestore.
  /// An import that wrote straight through would be the only action on this
  /// screen the user could not reconsider.
  ///
  /// The imported ids are re-minted so a file imported twice cannot produce two
  /// rows claiming the same id — the parser numbers them from zero every time.
  void applyImportedRows(
    List<TableDataRow> imported, {
    required bool overwrite,
  }) {
    if (imported.isEmpty || !access.canEditRows) return;
    _pushHistory();

    final List<TableDataRow> incoming = <TableDataRow>[
      for (final TableDataRow row in imported)
        row.copyWith(id: 'local-${_localRowSeq++}'),
    ];

    // Overwrite drops the EXISTING rows, not the empty ones among them: a
    // table seeded with four blank rows and then overwritten should hold the
    // file's rows and nothing else.
    final List<TableDataRow> next = overwrite
        ? incoming
        : <TableDataRow>[
            // Appending after blank seeded rows would leave gaps in the middle
            // of the table, so the blanks go: they were placeholders for data
            // that has now arrived.
            ...state.rows.where((TableDataRow row) => !row.isEmpty),
            ...incoming,
          ];

    emit(
      state.copyWith(
        rows: <TableDataRow>[
          for (int i = 0; i < next.length; i++) next[i].copyWith(order: i),
        ],
        selectedRowIds: const <String>{},
        isDirty: true,
        canUndo: true,
      ),
    );
  }

  // ── Undo / Redo ──────────────────────────────────────────────────────────

  void _pushHistory() {
    _past.add(
      TableDataSnapshot(columns: state.table.columns, rows: state.rows),
    );
    if (_past.length > _historyLimit) _past.removeAt(0);
    // Any new edit abandons the redo branch.
    _future.clear();
  }

  /// Function Name: [undo]
  ///
  /// Purpose: Step the grid back to the edit before the last one.
  void undo() {
    if (_past.isEmpty) return;

    _future.add(
      TableDataSnapshot(columns: state.table.columns, rows: state.rows),
    );
    final TableDataSnapshot previous = _past.removeLast();
    _lastEditedCell = null;

    emit(
      state.copyWith(
        table: state.table.copyWith(columns: previous.columns),
        rows: previous.rows,
        isDirty: true,
        canUndo: _past.isNotEmpty,
        canRedo: true,
        cellsRevision: state.cellsRevision + 1,
      ),
    );
  }

  /// Function Name: [redo]
  ///
  /// Purpose: Re-apply the edit the last [undo] reverted.
  void redo() {
    if (_future.isEmpty) return;

    _past.add(
      TableDataSnapshot(columns: state.table.columns, rows: state.rows),
    );
    final TableDataSnapshot next = _future.removeLast();
    _lastEditedCell = null;

    emit(
      state.copyWith(
        table: state.table.copyWith(columns: next.columns),
        rows: next.rows,
        isDirty: true,
        canUndo: true,
        canRedo: _future.isNotEmpty,
        cellsRevision: state.cellsRevision + 1,
      ),
    );
  }

  // ── Saving ───────────────────────────────────────────────────────────────

  /// Every cell whose text does not fit its column's type, as `rowId/columnId`.
  ///
  /// Computed rather than stored: it is a function of the rows and the columns,
  /// and a stored copy is one that can be stale for exactly as long as it takes
  /// somebody to forget to recompute it.
  Set<String> get invalidCells {
    final Set<String> out = <String>{};
    for (final TableDataRow row in state.rows) {
      for (final TableColumn column in state.table.columns) {
        if (!column.isNamed) continue;
        if (!column.type.accepts(row.valueFor(column))) {
          out.add('${row.id}/${column.id}');
        }
      }
    }
    return out;
  }

  /// Function Name: [save]
  ///
  /// Purpose: Write the rows back; true when they are stored.
  ///
  /// EMPTY ROWS ARE DROPPED and orphaned values with them. "+ Row" adds a row
  /// eagerly, so a user who taps it three times and fills one should get one
  /// document, not three. A table whose rows are ALL empty still saves — that is
  /// how a user clears a table — and the row_count the repository writes then
  /// says zero, which is the truth.
  ///
  /// Unnamed columns are dropped from the write for the same reason the details
  /// grid does not draw them: nothing can be filled into a column with no
  /// heading, so persisting one only makes a heading that has to be explained
  /// on every screen that reads it.
  Future<bool> save() async {
    if (state.isSaving || state.loadFailed || !access.canEditRows) {
      return false;
    }
    emit(
      state.copyWith(
        isSaving: true,
        clearErrorMessage: true,
        saveConflict: false,
      ),
    );

    // Only the difference from what was loaded (DB-TABLE-01); see
    // `TableRowsDiff`.
    final TableRowsDiff diff = TableRowsDiff.of(
      columns: state.table.columns,
      rows: state.rows,
      stored: _stored,
    );
    final List<TableColumn> namedColumns = diff.namedColumns;
    final List<TableDataRow> payload = diff.payload;

    // The columns are written only when this screen changed them, in the
    // same transaction as the rows, and the table's names never are: the old
    // second write (`updateTable`) sent this screen's whole copy of the table
    // and undid any change made elsewhere meanwhile (DB-TABLE-01).
    final bool columnsChanged = !TableRowsDiff.sameColumns(
      namedColumns,
      _loadedColumns,
    );

    final Either<Failure, TableRowsSaveResult> rowsWritten =
        await _repository.saveRowChanges(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
      created: diff.created,
      updated: diff.updated,
      deletedIds: diff.deletedIds,
      expectedVersion: _rowsVersion,
      expectedColumns: _loadedColumns,
      columns: columnsChanged ? namedColumns : null,
      rowCount: payload.length,
    );

    return rowsWritten.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
            saveConflict: failure is ConflictFailure,
          ),
        );
        return false;
      },
      (TableRowsSaveResult written) {
        // The real document ids go back on screen, so the next save updates
        // these rows instead of creating them again.
        final List<TableDataRow> saved = <TableDataRow>[
          for (final TableDataRow row in payload)
            row.copyWith(id: written.createdIds[row.id] ?? row.id),
        ];
        _rowsVersion = written.rowsVersion;
        _remember(saved);
        _loadedColumns = written.table.columns;
        _past.clear();
        _future.clear();
        _lastEditedCell = null;
        emit(
          state.copyWith(
            table: written.table,
            rows: saved,
            isSaving: false,
            isDirty: false,
            canUndo: false,
            canRedo: false,
            selectedRowIds: const <String>{},
            clearErrorMessage: true,
          ),
        );
        return true;
      },
    );
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}

/// The one message `compute` sends to the import isolate.
class _ImportRequest {
  const _ImportRequest({
    required this.parse,
    required this.bytes,
    required this.fileName,
    required this.columns,
  });

  final ParseTableImportUseCase parse;
  final Uint8List bytes;
  final String fileName;
  final List<TableColumn> columns;
}
