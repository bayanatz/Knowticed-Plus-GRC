/// ***************************** FILE INFO ***************************** ///
/// File Name: qiyas_bulk_rows_options_controller.dart
/// Purpose: Provides extension methods for validating and handling operations on Qiyas bulk vision rows.
/// Author: Abdelrahman Sobhy
/// Created At: Apr/21/2025
/// Description: This extension defines various methods for manipulating rows in the bulk vision data,
///              including selection, removal, duplication, and row validation. It integrates with the
///              QiyasBulkVisionsController to perform row operations and validation logic.
/// ********************************************************************* ///
library;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/modules/text_form_field_data.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_validation_controller.dart';
import 'package:knowticed_plus/features/qiyas/qy1_admin/bulk_upload/presentation/controller/qiyas_bulk_visions_controller.dart';

import 'package:knowticed_plus/features/qiyas/helpers/data_grc/feature/module_owner_grc/core/enums/csv_status.dart';

extension QiyasBulkRowsOptionsController on QiyasBulkVisionsController {
  /// function name: [toggleChecked]
  ///
  /// purpose: Toggles the selection of a row in the list. If the row is selected, it will be deselected,
  ///          and if it is not selected, it will be selected.
  ///
  /// parameters: [int rowIndex] - The index of the row to toggle.
  ///
  /// return type: [void]
  void toggleChecked(int rowIndex) {
    if (selectedRows.contains(rowIndex)) {
      selectedRows.remove(rowIndex);
      // toggleRowTextFields(rowIndex, false);
    } else {
      selectedRows.add(rowIndex);
      // toggleRowTextFields(rowIndex, true);
    }
  }

  /// function name: [isRowChecked]
  ///
  /// purpose: Checks if a row is selected or not.
  ///
  /// parameters: [int rowIndex] - The index of the row to check.
  ///
  /// return type: [bool] - Returns true if the row is selected, false otherwise.
  bool isRowChecked(int rowIndex) {
    return selectedRows.contains(rowIndex);
  }

  /// function name: [removeSelectedRows]
  ///
  /// purpose: Removes the selected rows from the vision data and the form field data. It also triggers
  ///          validation again after the rows are removed.
  ///
  /// parameters: [CsvStatus status] - The status of the CSV to determine validation behavior.
  ///
  /// return type: [void]
  void removeSelectedRows(CsvStatus status) {
    final remainingRows = <List<TextFormFieldData>>[];
    for (int i = 0; i < textFormFieldData.length; i++) {
      if (!selectedRows.contains(i)) {
        remainingRows.add(textFormFieldData[i]);
      }
      // selectedRows.remove(i);
    }
    if (selectedRows.isNotEmpty) {
      for (int i = 0; i < selectedRows.length; i++) {
        visionData.removeAt(selectedRows[i] + 1);
        // selectedRows.remove(i);
      }
    }
    textFormFieldData = remainingRows;
    errors.clear();
    makeAllValidations(visionData, status);
    log(errors.length.toString());
    log(errors.toString());
    update();
    selectedRows.clear();
  }

  /// function name: [addNewRow]
  ///
  /// purpose: Adds a new row to both the form field data and the vision data. It also revalidates the data
  ///          after adding the new row.
  ///
  /// parameters: [CsvStatus status] - The status of the CSV to determine validation behavior.
  ///
  /// return type: [void]
  void addNewRow(CsvStatus status) {
    final newRow = List.generate(
      textFormFieldData[0].length,
      (index) => TextFormFieldData(
          focusNode: FocusNode(),
          border: Colors.transparent,
          textFormFieldControllers: TextEditingController(text: ""),
          fieldKeys: GlobalKey<FormFieldState>()),
    );
    List<dynamic> newRecord = List.generate(
      newRow.length,
      (index) => newRow[index].textFormFieldControllers.text,
    );
    textFormFieldData.add(newRow);
    visionData.add(newRecord);
    errors.clear();
    makeAllValidations(visionData, status);
    update();
  }

  /// function name: [duplicateRow]
  ///
  /// purpose: Duplicates the selected rows and appends them to the vision data and the form field data.
  ///          It also revalidates the data after duplicating the rows.
  ///
  /// parameters: [CsvStatus status] - The status of the CSV to determine validation behavior.
  ///
  /// return type: [void]
  void duplicateRow(CsvStatus status) {
    if (selectedRows.isEmpty) {
      return; // Ensure there's at least one row selected
    }
    List<List<TextFormFieldData>> duplicatedRows = [];
    for (int index in selectedRows) {
      final newRow = textFormFieldData[index].map((field) {
        return TextFormFieldData(
          focusNode: FocusNode(),
          border: field.border,
          textFormFieldControllers:
              TextEditingController(text: field.textFormFieldControllers.text),
          fieldKeys: GlobalKey<FormFieldState>(),
        );
      }).toList();
      List<dynamic> newRecord = List.generate(
        newRow.length,
        (index) => newRow[index].textFormFieldControllers.text,
      );
      visionData.add(newRecord);
      duplicatedRows.add(newRow);
    }
    textFormFieldData.addAll(duplicatedRows);
    errors.clear();
    makeAllValidations(visionData, status);
    update();
  }
}
