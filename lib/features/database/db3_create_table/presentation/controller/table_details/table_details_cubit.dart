/// Module: database / db3_create_table / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: table_details_cubit.dart
/// Description: Declares `TableDetailsCubit`.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// State for "Table Name Details" — Figma 7398:4102 / 4300 / 4841 (open,
/// iPad H 1024), 7398:4690 (collapsed), 7398:4498 / 5039 / 17048 / 17240
/// (the 768 twins).
///
/// It holds three things and does one write:
///
///   * the table itself, which the card and the four tiles render
///   * whether the info card is expanded (the "Hide" / "Expand" link)
///   * the search text narrowing the rows grid
///   * delete, which is the only mutation this screen owns
///
/// WHY THE TABLE IS HANDED IN RATHER THAN RE-READ
/// ----------------------------------------------
/// The card the user tapped already carries the whole record — the details page
/// one level up read it — and a spinner over data somebody is already looking at
/// buys nothing. Same opening move as `DatabaseDetailsCubit`.
///
/// EDIT AND ACCESS ARE NOT HERE
/// ----------------------------
/// Both open a flow that owns its own cubit and hands a saved table back, and
/// the page folds that in through [tableChanged]. Duplicating those writes here
/// would give one record two writers.
library;

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/base_repository/create_table_base_repository.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/database_session_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/use_cases/table_access_rule.dart';

part './table_details_state.dart';

class TableDetailsCubit extends Cubit<TableDetailsState> {
  TableDetailsCubit({
    required DatabaseTableEntity table,
    required DatabaseEntity database,
    required DatabaseSessionBaseRepository session,
    required CreateTableBaseRepository repository,
    TableAccessRule rule = const TableAccessRule(),
  })  : _repository = repository,
        _database = database,
        _session = session,
        _rule = rule,
        super(TableDetailsState(table: table));

  final CreateTableBaseRepository _repository;
  final DatabaseEntity _database;
  final DatabaseSessionBaseRepository _session;
  final TableAccessRule _rule;

  /// Function Name: [access]
  ///
  /// Purpose: What the signed-in employee may do with this table today
  /// (DB-TABLE-03). Re-read on every call.
  ///
  /// Returns: [DatabaseAccess].
  DatabaseAccess get access => _rule.resolve(
        _database,
        state.table,
        viewerId: _session.signedInEmployeeId,
        today: DateTime.now(),
      );

  @override
  void emit(TableDetailsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Function Name: [toggleExpanded]
  ///
  /// Purpose: Flip the info card between the two states of Figma 7398:4102 and
  /// 7398:4690.
  ///
  /// Not a `setState` on the page: the link that flips it and the card that
  /// reads it are in different widgets, and threading a bool between them
  /// through two constructors is how the two end up disagreeing.
  void toggleExpanded() => emit(state.copyWith(isExpanded: !state.isExpanded));

  /// Narrows the rows grid. In memory rather than a refetch — the columns are
  /// already here, and there is nothing to re-read.
  void searchChanged(String value) => emit(state.copyWith(query: value));

  /// Function Name: [tableChanged]
  ///
  /// Purpose: Fold a table saved by the Edit card or the Access flow back into
  /// this screen.
  ///
  /// Marks the screen CHANGED, which is what makes [TableDetailsOutcome] carry
  /// the record back to the card grid — without it the card behind this screen
  /// would still show the old name until the module was reopened.
  void tableChanged(DatabaseTableEntity table) =>
      emit(state.copyWith(table: table, isChanged: true));

  /// Function Name: [delete]
  ///
  /// Purpose: Delete this table; true when it is gone.
  ///
  /// The repository takes the parent's `tables_count` down in the same batch, so
  /// there is nothing to decrement here — but the PAGE still has to tell the
  /// screen behind it, because that screen is holding its own copy of the parent
  /// database. See `TableDetailsOutcome.deleted`.
  Future<bool> delete() async {
    if (state.isDeleting || !access.canManage) return false;
    emit(state.copyWith(isDeleting: true, clearErrorMessage: true));

    final Either<Failure, void> result = await _repository.deleteTable(
      databaseId: state.table.databaseId,
      tableId: state.table.id,
    );

    return result.fold(
      (Failure failure) {
        emit(
          state.copyWith(isDeleting: false, errorMessage: failure.errMessage),
        );
        return false;
      },
      (_) {
        emit(state.copyWith(isDeleting: false, clearErrorMessage: true));
        return true;
      },
    );
  }

  /// Function Name: [clearMessages]
  ///
  /// Purpose: Clear the error and success messages once the screen has shown them, so a rebuild does not show them twice.
  void clearMessages() => emit(state.copyWith(clearErrorMessage: true));
}
