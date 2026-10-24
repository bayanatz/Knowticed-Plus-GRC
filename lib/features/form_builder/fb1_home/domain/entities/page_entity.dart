/// Module: form_builder_module/f1_home
///
///*************************** FILE INFO ****************************///
/// File Name: page_entity.dart
/// Description: `PageEntity`, one page of a form (a list of rows).
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:knowticed_plus/features/form_builder/fb1_home/domain/entities/row_entity.dart';

/// One page of a form.
class PageEntity {
  /// List of rows in the page
  final List<RowEntity> rows;

  /// Constructor for initializing the PageEntity instance
  PageEntity({required this.rows});

  /// Method Name: [duplicate]
  ///
  /// Purpose: copies the page and its rows (without answers).
  ///
  /// Returns: the copy.
  PageEntity duplicate() {
    List<RowEntity> newRows = [];
    for (var row in rows) {
      newRows.add(row.duplicate());
    }
    return PageEntity(rows: newRows);
  }
}
