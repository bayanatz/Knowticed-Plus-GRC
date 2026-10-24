/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_list_cubit.dart
/// Description: Declares `TableListCubit`.
/// Author: Amr Mesbah
/// Created at: 16/8/2026
///
/// The list of tables drawn on the database details screen — the region that
/// was a hard-coded "No tables in this database yet" until this section landed
/// (Figma 7398:4102 / 7398:4690 landscape, 7398:17048 / 7398:17240 portrait).
///
/// Owned by the details page, not by the Creating Table screen: the list
/// outlives every visit to that card, and rebuilding it from scratch each time
/// the card closed would flash an empty table at the user on the way back.
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
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/use_cases/table_access_rule.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/models/create_table_collections.dart';

part './table_list_state.dart';

class TableListCubit extends Cubit<TableListState> {
  TableListCubit({
    required DatabaseEntity database,
    required DatabaseSessionBaseRepository session,
    required CreateTableBaseRepository repository,
    TableAccessRule rule = const TableAccessRule(),
  })  : _repository = repository,
        _database = database,
        _session = session,
        _rule = rule,
        super(TableListState(databaseId: database.id));

  final CreateTableBaseRepository _repository;
  final DatabaseEntity _database;
  final DatabaseSessionBaseRepository _session;
  final TableAccessRule _rule;
  final LiveRefresh _live = LiveRefresh();

  @override
  void emit(TableListState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [load]
  ///
  /// Purpose: Read every table under the database.
  ///
  /// Called once when the details screen opens and again after any write. The
  /// search text is deliberately NOT cleared: a reload triggered by creating a
  /// table should leave the user's filter where they put it.
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    }

    final Either<Failure, List<DatabaseTableEntity>> result =
        await _repository.fetchTables(state.databaseId);
    if (silent && result.isLeft()) return;

    emit(
      result.fold(
        (Failure failure) =>
            state.copyWith(isLoading: false, errorMessage: failure.errMessage),
        (List<DatabaseTableEntity> tables) => state.copyWith(
          isLoading: false,
          // A table with its own grants is hidden from everyone it does not
          // name (DB-TABLE-03).
          tables: tables
              .where(
                (DatabaseTableEntity t) => _rule
                    .resolve(
                      _database,
                      t,
                      viewerId: _session.signedInEmployeeId,
                      today: DateTime.now(),
                    )
                    .canView,
              )
              .toList(growable: false),
          clearErrorMessage: true,
        ),
      ),
    );
    _live.watchPaths(<String>[
      '${getBaseUrl(CreateDatabaseCollections.databases)}/${state.databaseId}/'
          '${CreateTableCollections.tables}',
    ], () => load(silent: true));
  }

  /// Function Name: [searchChanged]
  ///
  /// Purpose: Store the search text; the visible list is filtered from it.
  void searchChanged(String value) => emit(state.copyWith(query: value));

  /// Function Name: [tableSaved]
  ///
  /// Purpose: Fold a created or edited table into the list without a refetch.
  ///
  /// A new table goes to the FRONT, which is where `fetchTables` would put it
  /// too — it orders by creation date descending — so the optimistic list and
  /// the next real read agree about where it sits. An edited one is replaced in
  /// place, because editing does not change when it was created.
  void tableSaved(DatabaseTableEntity table) {
    final int index = state.tables.indexWhere(
      (DatabaseTableEntity existing) => existing.id == table.id,
    );

    final List<DatabaseTableEntity> tables = <DatabaseTableEntity>[
      ...state.tables,
    ];
    if (index < 0) {
      tables.insert(0, table);
    } else {
      tables[index] = table;
    }

    emit(
      state.copyWith(tables: List<DatabaseTableEntity>.unmodifiable(tables)),
    );
  }

  /// Function Name: [tableRemoved]
  ///
  /// Purpose: Drop a deleted table out of the list without a refetch.
  ///
  /// ADDED 17/8/2026 with the Table Name Details screen, which is where Delete
  /// now lives. Matched by ID rather than by identity: the record handed back
  /// by that screen may have been edited before it was deleted, so it is not
  /// the object this list is holding.
  void tableRemoved(String tableId) {
    emit(
      state.copyWith(
        tables: List<DatabaseTableEntity>.unmodifiable(
          state.tables.where(
            (DatabaseTableEntity table) => table.id != tableId,
          ),
        ),
      ),
    );
  }

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
