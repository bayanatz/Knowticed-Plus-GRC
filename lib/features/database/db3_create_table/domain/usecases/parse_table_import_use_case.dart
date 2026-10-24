/// Module: database / db3_create_table / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: parse_table_import_use_case.dart
/// Description: Declares `ParseTableImportUseCase`.
/// Author: Amr Mesbah
/// Created at: 17/8/2026
///
/// Turns the file picked on the Import Table dialog (Figma 7398:4041) into rows
/// this table can hold.
///
/// CSV and XLSX, because those are the two things anyone actually exports a
/// table as, and both packages are already in the pubspec (`csv`, `excel`) for
/// the export side of other modules.
///
/// THE FILE'S HEADINGS ARE MATCHED TO THE TABLE'S COLUMNS BY NAME
/// -------------------------------------------------------------
/// Not by position. A spreadsheet somebody has been keeping will have its
/// columns in whatever order they grew in, and importing by position would put
/// the dates under Department the first time the two disagree — silently, and
/// into every row at once.
///
/// Matching is case-insensitive and ignores surrounding spaces, because
/// "Department", "department " and "DEPARTMENT" are one heading in every
/// spreadsheet ever exported. A file heading that matches nothing is REPORTED
/// rather than dropped quietly: the user picked that file believing it fitted,
/// and a silent drop is how half a table goes missing.
///
/// A LOCAL data source, and named as one. It reads a file the user handed over;
/// it does not touch Firestore, and nothing here knows the table's id.
///
/// A use case, not a local data source: it reads nothing from storage — it
/// turns bytes the user picked into rows. `TableDataCubit` runs it off the UI
/// thread (db3 rule 1).
library;

import 'dart:typed_data';
import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_import_outcome.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_import_error.dart';

/// Reads an Import Table file into rows. Stateless, so it can be sent to a
/// background isolate.
class ParseTableImportUseCase {
  /// Function Name: [ParseTableImportUseCase]
  ///
  /// Purpose: The import parser; it holds no state.
  const ParseTableImportUseCase();

  /// Extensions the picker offers. Kept here rather than at the call site so
  /// the filter and the parser cannot disagree about what this can read.
  /// No .xls: the reader only understands .xlsx, and every .xls failed with
  /// a raw package error (DB-TABLE-04).
  static const List<String> allowedExtensions = <String>['csv', 'xlsx'];

  /// Function Name: [call]
  ///
  /// Purpose: Read an import file into rows (DB-TABLE-04). Plain Dart, so the
  /// cubit can run it off the UI thread; every failure becomes a
  /// [TableImportError] key here, so nothing above has to catch.
  ///
  /// Parameters: [bytes] the file; [fileName] decides CSV or Excel;
  /// [columns] the table's columns, matched to the file's headings by name.
  ///
  /// Returns: [TableImportOutcome] — the rows, or why the file was refused.
  TableImportOutcome call({
    required Uint8List bytes,
    required String fileName,
    required List<TableColumn> columns,
  }) {
    try {
      return _parse(bytes: bytes, fileName: fileName, columns: columns);
    } on Object {
      return const TableImportOutcome.failure(TableImportError.unreadable);
    }
  }

  static TableImportOutcome _parse({
    required Uint8List bytes,
    required String fileName,
    required List<TableColumn> columns,
  }) {
    final List<List<String>> grid = fileName.toLowerCase().endsWith('.csv')
        ? _readCsv(bytes)
        : _readExcel(bytes);

    if (grid.isEmpty) {
      return const TableImportOutcome.failure(TableImportError.noRows);
    }

    final List<String> headings = grid.first;
    if (headings.every((String h) => h.trim().isEmpty)) {
      return const TableImportOutcome.failure(TableImportError.noHeadings);
    }

    // Heading text -> column id, for the columns this table actually has.
    final Map<String, String> byName = <String, String>{
      for (final TableColumn column in columns)
        if (column.isNamed) _key(column.name): column.id,
    };

    final List<String> unmatched = <String>[
      for (final String heading in headings)
        if (heading.trim().isNotEmpty && !byName.containsKey(_key(heading)))
          heading.trim(),
    ];

    final List<TableDataRow> rows = <TableDataRow>[];
    for (int r = 1; r < grid.length; r++) {
      final List<String> cells = grid[r];
      final Map<String, String> values = <String, String>{};

      for (int c = 0; c < headings.length && c < cells.length; c++) {
        final String? columnId = byName[_key(headings[c])];
        if (columnId == null) continue;

        final String value = cells[c].trim();
        if (value.isNotEmpty) values[columnId] = value;
      }

      // A blank line in the middle of a spreadsheet is a separator somebody
      // typed, not a record. Importing it would add an empty row that the save
      // path then drops anyway.
      if (values.isEmpty) continue;

      rows.add(
        TableDataRow(
          id: 'import-${rows.length}',
          order: rows.length,
          values: values,
        ),
      );
    }

    return TableImportOutcome.success(
      TableImportResult(rows: rows, unmatchedHeadings: unmatched),
    );
  }

  /// Case- and space-insensitive heading key. See this file's header.
  static String _key(String value) => value.trim().toLowerCase();

  static List<List<String>> _readCsv(Uint8List bytes) {
    // utf8.decode with allowMalformed, because a CSV exported from Excel on
    // Windows is frequently not clean UTF-8 and throwing on one stray byte
    // would reject a file whose 2000 other rows are fine.
    final String text = utf8.decode(bytes, allowMalformed: true);

    final List<List<dynamic>> parsed = Csv(
      autoDetect: false,
      skipEmptyLines: false,
    ).decode(text.replaceAll('\r\n', '\n'));

    return <List<String>>[
      for (final List<dynamic> row in parsed)
        <String>[for (final Object? cell in row) '${cell ?? ''}'],
    ];
  }

  static List<List<String>> _readExcel(Uint8List bytes) {
    final Excel workbook = Excel.decodeBytes(bytes);

    // The FIRST sheet. A workbook with several is a workbook where only the
    // author knows which one is the table, and asking would put a second
    // dropdown on a dialog that has one job.
    final String? first =
        workbook.tables.keys.isEmpty ? null : workbook.tables.keys.first;
    if (first == null) return const <List<String>>[];

    final Sheet sheet = workbook.tables[first]!;

    return <List<String>>[
      for (final List<Data?> row in sheet.rows)
        <String>[for (final Data? cell in row) '${cell?.value ?? ''}'],
    ];
  }
}
