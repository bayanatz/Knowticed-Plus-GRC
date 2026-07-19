// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart
/// Module: GRC Control Bulk Upload
/// Description: In-memory collection of the Control bulk upload preview
///              table's rows — mirrors
///              lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart,
///              minus the batch-level Total Weight getters (Control has no
///              cross-row weight requirement).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: control_bulk_row_form.dart, control_excel_parser.dart
library;

import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';

class ControlBulkUploadRows {
  ControlBulkUploadRows(
    List<ControlBulkRow> parsedRows, {
    required this.knownEmployeeEmails,
    required this.knownDepartmentNames,
  }) : rows = parsedRows.map(ControlBulkRowForm.fromParsedRow).toList() {
    for (final row in rows) {
      _validateRow(row);
    }
  }

  final List<ControlBulkRowForm> rows;
  final Set<int> selectedRows = {};
  final Set<String> knownEmployeeEmails;
  final Set<String> knownDepartmentNames;

  void _validateRow(ControlBulkRowForm row) {
    row.validate(
      knownEmployeeEmails: knownEmployeeEmails,
      knownDepartmentNames: knownDepartmentNames,
    );
  }

  void toggleSelected(int index) {
    if (!selectedRows.remove(index)) {
      selectedRows.add(index);
    }
  }

  void addBlankRow() {
    final row = ControlBulkRowForm();
    _validateRow(row);
    rows.add(row);
  }

  bool removeSelected() {
    if (selectedRows.isEmpty) return false;
    final sortedDescending = selectedRows.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedDescending) {
      rows[index].dispose();
      rows.removeAt(index);
    }
    selectedRows.clear();
    return true;
  }

  bool duplicateSelected() {
    if (selectedRows.length != 1) return false;
    final source = rows[selectedRows.first];
    final copy = ControlBulkRowForm(
      controlNameEn: source.controlNameEnController.text,
      controlNameAr: source.controlNameArController.text,
      controlNumberEn: source.controlNumberEnController.text,
      controlNumberAr: source.controlNumberArController.text,
      controlDescriptionEn: source.controlDescriptionEnController.text,
      controlDescriptionAr: source.controlDescriptionArController.text,
      startDate: source.startDateController.text,
      endDate: source.endDateController.text,
      controlWeight: source.controlWeightController.text,
      frequency: source.frequencyController.text,
      controlChampion: source.controlChampionController.text,
      controlOwner: source.controlOwnerController.text,
      appliedDepartments: source.appliedDepartmentsController.text,
      departmentWeight: source.departmentWeightController.text,
    );
    _validateRow(copy);
    rows.add(copy);
    selectedRows.clear();
    return true;
  }

  void removeAt(int index) {
    rows[index].dispose();
    rows.removeAt(index);
    selectedRows.remove(index);
  }

  /// Total number of per-cell errors across every row.
  int get errorCount => rows.fold<int>(0, (sum, row) => sum + row.errors.length);

  /// Every (rowIndex, fieldKey) pair currently in error, in row/field order.
  List<(int, String)> get errorLocations {
    final locations = <(int, String)>[];
    for (var i = 0; i < rows.length; i++) {
      for (final fieldKey in rows[i].errors.keys) {
        locations.add((i, fieldKey));
      }
    }
    return locations;
  }

  /// Whether Activate should be enabled: no per-cell errors and at least one row.
  bool get isValid => errorCount == 0 && rows.isNotEmpty;

  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
