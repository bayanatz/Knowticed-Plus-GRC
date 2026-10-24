/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: table_import_outcome.dart
/// Description: Declares `TableImportResult` and `TableImportOutcome`.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// The result of reading an import file (Figma 7398:4041): the rows it held,
/// or why it was refused.
library;

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_import_error.dart';

/// The rows an import file held, and the headings no column matched.
class TableImportResult {
  const TableImportResult({
    required this.rows,
    this.unmatchedHeadings = const <String>[],
  });

  final List<TableDataRow> rows;

  /// Headings in the file that no column in this table is called. Shown to the
  /// user after the import rather than thrown — the rows that DID match are
  /// still worth having.
  final List<String> unmatchedHeadings;
}

/// What [ParseTableImportUseCase] hands back: the rows, or why the file was
/// refused.
class TableImportOutcome {
  const TableImportOutcome.success(TableImportResult this.result)
      : error = null;
  const TableImportOutcome.failure(TableImportError this.error) : result = null;

  final TableImportResult? result;
  final TableImportError? error;
}
