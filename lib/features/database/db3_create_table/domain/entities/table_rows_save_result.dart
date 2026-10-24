/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: table_rows_save_result.dart
/// Description: Declares `TableRowsSaveResult`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// What a row save hands back (DB-TABLE-01): the real document id of every row
/// that was created, keyed by the local id it had on screen, and the table's
/// new rows version for the next save to check against.
///
/// It also carries the table as the save left it, read inside the same
/// transaction, so the screen never keeps a stale copy of the columns.
library;

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';

class TableRowsSaveResult {
  const TableRowsSaveResult({
    required this.createdIds,
    required this.rowsVersion,
    required this.table,
  });

  /// The table document after the save: the stored names and columns, with
  /// the columns this save wrote, if any, and the new row count.
  final DatabaseTableEntity table;

  /// Local row id -> Firestore document id, for the rows this save created.
  final Map<String, String> createdIds;

  /// The table's `rows_version` after the save.
  final int rowsVersion;
}
