/// Module: database / db3_create_table / domain / usecases
///
///*************************** FILE INFO ****************************///
/// File Name: table_rows_diff.dart
/// Description: Declares `TableRowsDiff`.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
///
/// What a save of the editing grid has to write: the rows as they will be
/// stored, and how they differ from the rows last read or written
/// (DB-TABLE-01). Moved out of `TableDataCubit` so the cubit keeps to the
/// editing and the write itself (rule 7). Plain Dart over entities.
library;

import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_data_row.dart';

/// What one save of the editing grid writes: the rows as they will be stored,
/// and which of them are new, changed or removed.
class TableRowsDiff {
  const TableRowsDiff._({
    required this.namedColumns,
    required this.payload,
    required this.created,
    required this.updated,
    required this.deletedIds,
  });

  /// Function Name: [TableRowsDiff.of]
  ///
  /// Purpose: Compare the grid's [rows] under [columns] with the [stored]
  /// rows, by id.
  ///
  /// EMPTY ROWS ARE DROPPED, and so are values under unnamed or removed
  /// columns: nothing can be filled into a column with no heading.
  ///
  /// Parameters: [columns] the grid's columns; [rows] the grid's rows;
  /// [stored] the rows as last read or written, by id.
  ///
  /// Returns: [TableRowsDiff].
  factory TableRowsDiff.of({
    required List<TableColumn> columns,
    required List<TableDataRow> rows,
    required Map<String, TableDataRow> stored,
  }) {
    final List<TableColumn> named =
        columns.where((TableColumn c) => c.isNamed).toList(growable: false);
    final List<TableColumn> namedColumns = <TableColumn>[
      for (int i = 0; i < named.length; i++) named[i].copyWith(order: i),
    ];
    final Set<String> liveColumnIds =
        namedColumns.map((TableColumn c) => c.id).toSet();

    final List<TableDataRow> kept = <TableDataRow>[
      for (final TableDataRow row in rows)
        if (!row.isEmpty)
          row.copyWith(
            values: <String, String>{
              for (final MapEntry<String, String> entry in row.values.entries)
                if (liveColumnIds.contains(entry.key)) entry.key: entry.value,
            },
          ),
    ];
    // `order` is the position on screen, numbered here so a moved row counts
    // as changed.
    final List<TableDataRow> payload = <TableDataRow>[
      for (int i = 0; i < kept.length; i++) kept[i].copyWith(order: i),
    ];

    // A row that was never loaded is never in [deletedIds].
    final Set<String> payloadIds =
        payload.map((TableDataRow row) => row.id).toSet();

    return TableRowsDiff._(
      namedColumns: namedColumns,
      payload: payload,
      created: <TableDataRow>[
        for (final TableDataRow row in payload)
          if (!stored.containsKey(row.id)) row,
      ],
      updated: <TableDataRow>[
        for (final TableDataRow row in payload)
          if (stored.containsKey(row.id) && !sameContent(stored[row.id]!, row))
            row,
      ],
      deletedIds: <String>{
        for (final String id in stored.keys)
          if (!payloadIds.contains(id)) id,
      },
    );
  }

  /// The named columns, `order` re-stamped from position.
  final List<TableColumn> namedColumns;

  /// Every row that will be stored, in screen order.
  final List<TableDataRow> payload;

  /// Rows not stored before.
  final List<TableDataRow> created;

  /// Stored rows whose cells or position changed.
  final List<TableDataRow> updated;

  /// Stored rows no longer on the grid.
  final Set<String> deletedIds;

  /// Function Name: [sameColumns]
  ///
  /// Purpose: Whether two column lists describe the same named columns — same
  /// ids, names and types, in the same order (DB-TABLE-01). Unnamed columns
  /// and stored `order` values are ignored; position is what counts.
  ///
  /// Parameters: [a], [b] the two lists.
  ///
  /// Returns: [bool].
  static bool sameColumns(List<TableColumn> a, List<TableColumn> b) {
    final List<TableColumn> left =
        a.where((TableColumn c) => c.isNamed).toList(growable: false);
    final List<TableColumn> right =
        b.where((TableColumn c) => c.isNamed).toList(growable: false);
    if (left.length != right.length) return false;
    for (int i = 0; i < left.length; i++) {
      if (left[i].id != right[i].id ||
          left[i].name.trim() != right[i].name.trim() ||
          left[i].type != right[i].type) {
        return false;
      }
    }
    return true;
  }

  /// Function Name: [sameContent]
  ///
  /// Purpose: Whether two rows hold the same cells at the same position.
  /// `TableDataRow ==` compares ids only.
  ///
  /// Parameters: [a], [b] the two rows.
  ///
  /// Returns: [bool].
  static bool sameContent(TableDataRow a, TableDataRow b) {
    if (a.order != b.order || a.values.length != b.values.length) return false;
    for (final MapEntry<String, String> entry in a.values.entries) {
      if (b.values[entry.key] != entry.value) return false;
    }
    return true;
  }
}
