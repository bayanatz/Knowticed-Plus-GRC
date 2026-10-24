/// Module: form_builder_module/f6_result
///
///*************************** FILE INFO ****************************///
/// File Name: result_table_builder.dart
/// Description: `buildResultTableColumns()`, `buildResultTableRows()`, `buildResultTableHeaders()`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/table_row_data.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder/fb5_result/presentation/utils/result_table_headers.dart';

/// Function Name: [buildResultTableColumns]
///
/// Returns: the table's header cells.
List<DataColumn> buildResultTableColumns(ResultLoaded state) {
  return List<DataColumn>.from(
      buildResultTableHeaders(state.formEntity!).map((header) {
    return DataColumn(
      label: Text(header,
          style:
              StyleText.fontSize16Weight400.copyWith(color: AppColors.white)),
    );
  }));
}

/// Function Name: [buildResultTableRows]
///
/// Returns: one striped row per submitted person shown.
List<DataRow> buildResultTableRows(ResultLoaded state) {
  List<DataRow> rows = [];
  for (int userIndex = 0;
      userIndex < state.filteredSubmittedUsers.length;
      userIndex++) {
    TableRowData tableRowData =
        TableRowData.fromUserGridItem(state.filteredSubmittedUsers[userIndex]);
    List<DataCell> cells = [];
    for (var answer in tableRowData.getTableList()) {
      cells.add(DataCell(
        Text(answer,
            style: StyleText.fontSize12Weight500
                .copyWith(color: AppColors.fullBlack)),
      ));
    }
    rows.add(DataRow(
      cells: cells,
      color: WidgetStatePropertyAll(
        userIndex % 2 == 0 ? AppColors.evenRowColor : AppColors.oddRowColor,
      ),
    ));
  }
  return rows;
}
