# Control Bulk Upload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the `_onBulkUploadControls()` stub on the Policy Details page with a real Excel bulk-upload flow for Controls — parse, edit/validate in a table, create, and assign Champions/Owners by email — mirroring the existing Policy Bulk Upload feature.

**Architecture:** A new `control_bulk_upload/` sibling of `policy_bulk_upload/`, same pipeline (parser → row-form → rows model → cubit → two pages), reusing the existing dd-MM-yyyy date helpers directly. Two things Policy's version doesn't have: per-row Applied Departments/Department Weight validation (names must be real departments, weights must sum to 100), and per-row Control Champion/Owner assignment by comma-separated employee email, applied via the same find-existing-or-create logic already built for `AddEditControlPage`.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), `excel` package, `desktop_drop`/`file_picker` (already dependencies), existing `CreateControlUseCase`/`ChampionCubit`/`OwnerCubit`.

## Global Constraints

- Header row (exact, in order): `Control Name`, `اسم ضابط`, `Control Number`, `رقم ضابط`, `Control Description`, `وصف ضابط`, `Start Date`, `End Date`, `Control Weight`, `Frequency`, `Control Champion`, `Control Owner`, `Applied Departments`, `Department Weight`.
- Date format: `dd-MM-yyyy`, via the existing `parsePolicyBulkDate`/`formatPolicyBulkDate` (`lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart`) — imported directly, not duplicated.
- No batch-level weight check across rows — Control Weight is just required + positive, per row, independently.
- Frequency must case-insensitively match one of: `Weekly`, `Bi weekly`, `Monthly`, `Quarterly`, `Semi Annual`, `Annually`; the row stores the canonical-cased value, not whatever casing was typed.
- Control Champion/Owner: optional, comma-separated employee emails; any email not matching a real employee blocks the row (same severity as a missing required field).
- Applied Departments/Department Weight: optional as a pair (both empty is valid — no departments); once either is filled, names must be real departments, counts must match, weights must parse as numbers and sum to exactly 100 — any violation blocks the row. Per the reference mockup, a bad department **name or count** renders as a red-bordered `Applied Departments` cell with the per-row Total Weight box hidden; a bad **sum** (names/count otherwise fine) renders as a red-bordered `Department Weight` cell *and* a red Total Weight box reading "Total Weight should be 100" — a green box when everything about the pair is valid.
- **Testability decomposition (locked in here, not in the spec doc):** `ControlBulkRowForm.validate()` takes `knownEmployeeEmails`/`knownDepartmentNames` as explicit `Set<String>` parameters rather than reaching into `Get.find<MainCoreEmployeeController>()`/`Get.find<MainCoreDepartmentController>()` itself. This makes the row-form a pure, directly-unit-testable function of its inputs; `ControlBulkUploadCubit` resolves the two sets once (from GetX) and threads them through `ControlBulkUploadRows` to every `validate()` call.
- **Cross-row assignment correctness:** `ControlBulkUploadCubit.submit()` must NOT re-read `championCubit.state`/`ownerCubit.state` between rows to look up "does this email already have a Champion/Owner doc" — every `createChampion`/`updateChampion` call changes the Cubit's state away from `ChampionListLoaded`, so a second row assigning the *same* email would see `state is! ChampionListLoaded` and wrongly call `createChampion` again (overwriting the first row's assignment instead of appending to it). Submit keeps its own local `Map<String, List<AssigningControlEntity>>` snapshot, seeded once from the loaded state before the row loop starts, updated in place after every assignment.
- This sandbox has no `flutter` binary — verification is `dart analyze <path>` (no `flutter test`). Where a test step is written, it is pure-Dart (no Firebase, no GetX registration needed, consistent with `knownEmployeeEmails`/`knownDepartmentNames` being plain parameters).

---

### Task 1: `control_excel_parser.dart`

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart`
- Test: `test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser_test.dart`

**Interfaces:**
- Produces: `controlBulkUploadExpectedHeaders` (the 14-column list above); `ControlBulkRow` (14 raw `String` fields: `controlNameEn`, `controlNameAr`, `controlNumberEn`, `controlNumberAr`, `controlDescriptionEn`, `controlDescriptionAr`, `startDate`, `endDate`, `controlWeight`, `frequency`, `controlChampion`, `controlOwner`, `appliedDepartments`, `departmentWeight`); `parseControlExcel(List<int> bytes) -> ControlExcelParseResult` (sealed: `ControlExcelParseSuccess(rows)` / `ControlExcelParseHeaderMismatch(message)` / `ControlExcelParseEmpty()`). Task 2's `ControlBulkRowForm.fromParsedRow` consumes `ControlBulkRow`; Tasks 5/6 consume the parse-result types.

- [ ] **Step 1: Write the parser**

```dart
// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart
/// Module: GRC Control Bulk Upload
/// Description: Parses an uploaded Excel (.xlsx/.xls) workbook of Controls
///              into raw [ControlBulkRow] values, scoped to a single
///              Policy. Validates the header row against the fixed
///              expected column list before reading any data — mirrors
///              lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: excel package, policy_bulk_date_format.dart

import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;

/// The sheet's header row must match this list exactly, in order.
const List<String> controlBulkUploadExpectedHeaders = [
  'Control Name',
  'اسم ضابط',
  'Control Number',
  'رقم ضابط',
  'Control Description',
  'وصف ضابط',
  'Start Date',
  'End Date',
  'Control Weight',
  'Frequency',
  'Control Champion',
  'Control Owner',
  'Applied Departments',
  'Department Weight',
];

/// class name: [ControlBulkRow]
///
/// purpose: one raw, unvalidated data row parsed from the uploaded sheet.
class ControlBulkRow {
  final String controlNameEn;
  final String controlNameAr;
  final String controlNumberEn;
  final String controlNumberAr;
  final String controlDescriptionEn;
  final String controlDescriptionAr;
  final String startDate;
  final String endDate;
  final String controlWeight;
  final String frequency;
  final String controlChampion;
  final String controlOwner;
  final String appliedDepartments;
  final String departmentWeight;

  const ControlBulkRow({
    required this.controlNameEn,
    required this.controlNameAr,
    required this.controlNumberEn,
    required this.controlNumberAr,
    required this.controlDescriptionEn,
    required this.controlDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.controlWeight,
    required this.frequency,
    required this.controlChampion,
    required this.controlOwner,
    required this.appliedDepartments,
    required this.departmentWeight,
  });
}

sealed class ControlExcelParseResult {}

class ControlExcelParseSuccess extends ControlExcelParseResult {
  final List<ControlBulkRow> rows;
  ControlExcelParseSuccess(this.rows);
}

class ControlExcelParseHeaderMismatch extends ControlExcelParseResult {
  final String message;
  ControlExcelParseHeaderMismatch(this.message);
}

class ControlExcelParseEmpty extends ControlExcelParseResult {}

/// function name: [parseControlExcel]
///
/// purpose: decode an uploaded workbook's bytes, validate its header row
///          against [controlBulkUploadExpectedHeaders], and parse every
///          non-blank data row into a [ControlBulkRow].
ControlExcelParseResult parseControlExcel(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return ControlExcelParseEmpty();

  for (final tableName in excel.tables.keys) {
    final sheet = excel.tables[tableName];
    if (sheet == null || sheet.rows.isEmpty) continue;

    final rows = sheet.rows;
    final actualHeaders = rows.first.map((cell) => _cellText(cell?.value)).toList();
    while (actualHeaders.isNotEmpty && actualHeaders.last.isEmpty) {
      actualHeaders.removeLast();
    }

    if (!_headersMatch(actualHeaders)) {
      return ControlExcelParseHeaderMismatch(
        'Expected columns: ${controlBulkUploadExpectedHeaders.join(', ')}',
      );
    }

    final parsedRows = <ControlBulkRow>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      String valueAt(String header) {
        final colIndex = controlBulkUploadExpectedHeaders.indexOf(header);
        if (colIndex >= row.length) return '';
        return _cellText(row[colIndex]?.value);
      }

      final parsed = ControlBulkRow(
        controlNameEn: valueAt('Control Name'),
        controlNameAr: valueAt('اسم ضابط'),
        controlNumberEn: valueAt('Control Number'),
        controlNumberAr: valueAt('رقم ضابط'),
        controlDescriptionEn: valueAt('Control Description'),
        controlDescriptionAr: valueAt('وصف ضابط'),
        startDate: valueAt('Start Date'),
        endDate: valueAt('End Date'),
        controlWeight: valueAt('Control Weight'),
        frequency: valueAt('Frequency'),
        controlChampion: valueAt('Control Champion'),
        controlOwner: valueAt('Control Owner'),
        appliedDepartments: valueAt('Applied Departments'),
        departmentWeight: valueAt('Department Weight'),
      );

      final isBlankRow = [
        parsed.controlNameEn,
        parsed.controlNameAr,
        parsed.controlNumberEn,
        parsed.controlNumberAr,
        parsed.controlDescriptionEn,
        parsed.controlDescriptionAr,
        parsed.startDate,
        parsed.endDate,
        parsed.controlWeight,
        parsed.frequency,
        parsed.controlChampion,
        parsed.controlOwner,
        parsed.appliedDepartments,
        parsed.departmentWeight,
      ].every((value) => value.isEmpty);
      if (isBlankRow) continue;

      parsedRows.add(parsed);
    }

    return parsedRows.isEmpty ? ControlExcelParseEmpty() : ControlExcelParseSuccess(parsedRows);
  }

  return ControlExcelParseEmpty();
}

bool _headersMatch(List<String> actualHeaders) {
  if (actualHeaders.length != controlBulkUploadExpectedHeaders.length) return false;
  for (var i = 0; i < actualHeaders.length; i++) {
    if (actualHeaders[i].trim() != controlBulkUploadExpectedHeaders[i]) return false;
  }
  return true;
}

/// Extracts plain display text from any [CellValue].
String _cellText(CellValue? value) {
  return switch (value) {
    null => '',
    TextCellValue() => value.value.toString().trim(),
    IntCellValue() => value.value.toString(),
    DoubleCellValue() => _trimTrailingZero(value.value),
    BoolCellValue() => value.value.toString(),
    FormulaCellValue() => value.formula.trim(),
    DateCellValue() => formatPolicyBulkDate(value.asDateTimeLocal()),
    DateTimeCellValue() =>
      formatPolicyBulkDate(DateTime(value.year, value.month, value.day)),
    TimeCellValue() => value.toString(),
  };
}

String _trimTrailingZero(double value) {
  return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}
```

- [ ] **Step 2: Write the test**

```dart
// test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser_test.dart
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';

List<int> _buildWorkbook(List<List<String>> rows) {
  final excel = Excel.createExcel();
  // appendRow lives on Excel itself (takes the sheet name), not on Sheet —
  // getDefaultSheet() avoids hardcoding a sheet name that might not match
  // what Excel.createExcel() actually names its first sheet.
  final sheetName = excel.getDefaultSheet()!;
  for (final row in rows) {
    excel.appendRow(sheetName, row.map((v) => TextCellValue(v)).toList());
  }
  return excel.encode()!;
}

void main() {
  group('parseControlExcel', () {
    test('valid header + one data row parses correctly', () {
      final bytes = _buildWorkbook([
        controlBulkUploadExpectedHeaders,
        [
          'Access Review', 'مراجعة الوصول', 'C-001', 'ك-001',
          'Quarterly access review', 'مراجعة ربع سنوية للوصول',
          '01-01-2026', '31-12-2026', '25', 'Quarterly',
          'amro@example.com', 'mona@example.com',
          'Marketing,HR', '60,40',
        ],
      ]);

      final result = parseControlExcel(bytes);
      expect(result, isA<ControlExcelParseSuccess>());
      final rows = (result as ControlExcelParseSuccess).rows;
      expect(rows.length, 1);
      expect(rows.first.controlNameEn, 'Access Review');
      expect(rows.first.controlChampion, 'amro@example.com');
      expect(rows.first.appliedDepartments, 'Marketing,HR');
    });

    test('wrong header is rejected', () {
      final bytes = _buildWorkbook([
        ['Wrong', 'Header'],
        ['a', 'b'],
      ]);

      final result = parseControlExcel(bytes);
      expect(result, isA<ControlExcelParseHeaderMismatch>());
    });

    test('a fully-blank data row is skipped', () {
      final bytes = _buildWorkbook([
        controlBulkUploadExpectedHeaders,
        List.filled(controlBulkUploadExpectedHeaders.length, ''),
      ]);

      final result = parseControlExcel(bytes);
      expect(result, isA<ControlExcelParseEmpty>());
    });
  });
}
```

- [ ] **Step 3: Run the test**

Run: `flutter test test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser_test.dart`
Expected: PASS (3 tests)

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser_test.dart
git commit -m "feat(grc): add control_excel_parser for Control Bulk Upload"
```

---

### Task 2: `control_bulk_row_form.dart`

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart`
- Test: `test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form_test.dart`

**Interfaces:**
- Consumes: `ControlBulkRow` (Task 1); `parsePolicyBulkDate` (existing, `policy_bulk_date_format.dart`).
- Produces: `controlBulkUploadFrequencyOptions`; `ControlBulkRowForm` with 14 `TextEditingController`s (field names as in Task 1), `key`, `focusNodes: Map<String, FocusNode>`, `errors: Map<String, String>`, `resolvedFrequency: String?`, `championEmails`/`ownerEmails: List<String>`, `departmentNames: List<String>`, `departmentWeights: List<double>`, `validate({required Set<String> knownEmployeeEmails, required Set<String> knownDepartmentNames}) -> Map<String, String>`, `weightValue: double`, `dispose()`. Task 3 depends on this exact `validate` signature and every field/getter name above.

- [ ] **Step 1: Write the row form**

```dart
// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart
/// Module: GRC Control Bulk Upload
/// Description: One editable row in the Control bulk upload preview table.
///              Wraps a TextEditingController per field plus per-field
///              validation, mirroring
///              lib/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart,
///              extended with Frequency matching, Control Champion/Owner
///              email lookup, and Applied Departments/Department Weight
///              validation. [validate] takes the known employee emails and
///              department names as plain parameters (not fetched via
///              GetX internally) so this class is a pure, directly
///              unit-testable function of its inputs.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: policy_bulk_date_format.dart, control_excel_parser.dart

import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:flutter/material.dart';

/// The Frequency sheet cell must case-insensitively match one of these;
/// the matching entry (canonical casing) is what gets persisted.
const List<String> controlBulkUploadFrequencyOptions = [
  'Weekly',
  'Bi weekly',
  'Monthly',
  'Quarterly',
  'Semi Annual',
  'Annually',
];

/// class name: [ControlBulkRowForm]
///
/// purpose: hold the live-editable state of one bulk-upload Control row and
///          validate it: required fields, Start < End Date, Weight > 0,
///          Frequency match, Champion/Owner email lookup, and the Applied
///          Departments/Department Weight pair.
class ControlBulkRowForm {
  ControlBulkRowForm({
    String controlNameEn = '',
    String controlNameAr = '',
    String controlNumberEn = '',
    String controlNumberAr = '',
    String controlDescriptionEn = '',
    String controlDescriptionAr = '',
    String startDate = '',
    String endDate = '',
    String controlWeight = '',
    String frequency = '',
    String controlChampion = '',
    String controlOwner = '',
    String appliedDepartments = '',
    String departmentWeight = '',
  })  : controlNameEnController = TextEditingController(text: controlNameEn),
        controlNameArController = TextEditingController(text: controlNameAr),
        controlNumberEnController = TextEditingController(text: controlNumberEn),
        controlNumberArController = TextEditingController(text: controlNumberAr),
        controlDescriptionEnController =
            TextEditingController(text: controlDescriptionEn),
        controlDescriptionArController =
            TextEditingController(text: controlDescriptionAr),
        startDateController = TextEditingController(text: startDate),
        endDateController = TextEditingController(text: endDate),
        controlWeightController = TextEditingController(text: controlWeight),
        frequencyController = TextEditingController(text: frequency),
        controlChampionController = TextEditingController(text: controlChampion),
        controlOwnerController = TextEditingController(text: controlOwner),
        appliedDepartmentsController =
            TextEditingController(text: appliedDepartments),
        departmentWeightController =
            TextEditingController(text: departmentWeight);

  factory ControlBulkRowForm.fromParsedRow(ControlBulkRow row) => ControlBulkRowForm(
        controlNameEn: row.controlNameEn,
        controlNameAr: row.controlNameAr,
        controlNumberEn: row.controlNumberEn,
        controlNumberAr: row.controlNumberAr,
        controlDescriptionEn: row.controlDescriptionEn,
        controlDescriptionAr: row.controlDescriptionAr,
        startDate: row.startDate,
        endDate: row.endDate,
        controlWeight: row.controlWeight,
        frequency: row.frequency,
        controlChampion: row.controlChampion,
        controlOwner: row.controlOwner,
        appliedDepartments: row.appliedDepartments,
        departmentWeight: row.departmentWeight,
      );

  final TextEditingController controlNameEnController;
  final TextEditingController controlNameArController;
  final TextEditingController controlNumberEnController;
  final TextEditingController controlNumberArController;
  final TextEditingController controlDescriptionEnController;
  final TextEditingController controlDescriptionArController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController controlWeightController;
  final TextEditingController frequencyController;
  final TextEditingController controlChampionController;
  final TextEditingController controlOwnerController;
  final TextEditingController appliedDepartmentsController;
  final TextEditingController departmentWeightController;

  /// Scroll target for the "jump to next error" navigation.
  final GlobalKey key = GlobalKey();

  /// One [FocusNode] per editable field, keyed the same as [errors].
  final Map<String, FocusNode> focusNodes = {
    'controlNameEn': FocusNode(),
    'controlNameAr': FocusNode(),
    'controlNumberEn': FocusNode(),
    'controlNumberAr': FocusNode(),
    'controlDescriptionEn': FocusNode(),
    'controlDescriptionAr': FocusNode(),
    'startDate': FocusNode(),
    'endDate': FocusNode(),
    'controlWeight': FocusNode(),
    'frequency': FocusNode(),
    'controlChampion': FocusNode(),
    'controlOwner': FocusNode(),
    'appliedDepartments': FocusNode(),
    'departmentWeight': FocusNode(),
  };

  /// The result of the most recent [validate] call.
  Map<String, String> errors = {};

  /// The canonical-cased Frequency value to persist, set by [validate]
  /// whenever there's no 'frequency' error.
  String? resolvedFrequency;

  /// Parsed, validated Champion/Owner emails — empty unless [validate] has
  /// run and found no error on the matching field.
  List<String> championEmails = [];
  List<String> ownerEmails = [];

  /// Parsed, validated department names/weights (same length, same
  /// order) — empty unless [validate] has run and the Applied Departments
  /// cell itself has no error (a bad *sum* still leaves these populated;
  /// see 'departmentWeight' in [errors] for that case).
  List<String> departmentNames = [];
  List<double> departmentWeights = [];

  /// function name: [validate]
  ///
  /// purpose: recompute [errors] (and the derived [resolvedFrequency] /
  ///          [championEmails] / [ownerEmails] / [departmentNames] /
  ///          [departmentWeights]) from the controllers' current text.
  ///
  /// parameters:
  ///            [Set<String>] knownEmployeeEmails: every real employee email, for Champion/Owner lookup
  ///            [Set<String>] knownDepartmentNames: every real department name (English + Arabic), for Applied Departments lookup
  ///
  /// return type: [Map<String, String>] - the recomputed [errors] map (field key -> message)
  Map<String, String> validate({
    required Set<String> knownEmployeeEmails,
    required Set<String> knownDepartmentNames,
  }) {
    final next = <String, String>{};

    void requireField(String key, String value) {
      if (value.trim().isEmpty) next[key] = 'Required';
    }

    requireField('controlNameEn', controlNameEnController.text);
    requireField('controlNameAr', controlNameArController.text);
    requireField('controlNumberEn', controlNumberEnController.text);
    requireField('controlNumberAr', controlNumberArController.text);
    requireField('controlDescriptionEn', controlDescriptionEnController.text);
    requireField('controlDescriptionAr', controlDescriptionArController.text);
    requireField('startDate', startDateController.text);
    requireField('frequency', frequencyController.text);

    final start = parsePolicyBulkDate(startDateController.text);
    if (!next.containsKey('startDate') && start == null) {
      next['startDate'] = 'Invalid date (dd-MM-yyyy)';
    }

    final endText = endDateController.text.trim();
    final end = endText.isEmpty ? null : parsePolicyBulkDate(endText);
    if (endText.isNotEmpty && end == null) {
      next['endDate'] = 'Invalid date (dd-MM-yyyy)';
    }

    if (start != null && end != null && !start.isBefore(end)) {
      next['startDate'] = 'Start Date must be before End Date';
      next['endDate'] = 'Start Date must be before End Date';
    }

    final weight = double.tryParse(controlWeightController.text.trim());
    if (weight == null || weight <= 0) {
      next['controlWeight'] = 'Must be a positive number';
    }

    resolvedFrequency = null;
    if (!next.containsKey('frequency')) {
      final typed = frequencyController.text.trim();
      for (final option in controlBulkUploadFrequencyOptions) {
        if (option.toLowerCase() == typed.toLowerCase()) {
          resolvedFrequency = option;
          break;
        }
      }
      if (resolvedFrequency == null) {
        next['frequency'] =
            'Must be one of: ${controlBulkUploadFrequencyOptions.join(', ')}';
      }
    }

    championEmails = _validateEmails(
      fieldKey: 'controlChampion',
      text: controlChampionController.text,
      knownEmployeeEmails: knownEmployeeEmails,
      errors: next,
    );
    ownerEmails = _validateEmails(
      fieldKey: 'controlOwner',
      text: controlOwnerController.text,
      knownEmployeeEmails: knownEmployeeEmails,
      errors: next,
    );

    _validateDepartments(next, knownDepartmentNames);

    errors = next;
    return errors;
  }

  List<String> _splitList(String text) => text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  List<String> _validateEmails({
    required String fieldKey,
    required String text,
    required Set<String> knownEmployeeEmails,
    required Map<String, String> errors,
  }) {
    final emails = _splitList(text);
    if (emails.isEmpty) return [];

    final unknown = emails.where((e) => !knownEmployeeEmails.contains(e)).toList();
    if (unknown.isNotEmpty) {
      errors[fieldKey] = 'Unknown employee email(s): ${unknown.join(', ')}';
      return [];
    }
    return emails;
  }

  /// function name: [_validateDepartments]
  ///
  /// purpose: validate the Applied Departments/Department Weight pair.
  ///          Structural problems (missing one side, count mismatch,
  ///          unknown department name) error 'appliedDepartments' (and, for
  ///          the first two, 'departmentWeight' too, since neither cell is
  ///          trustworthy in those cases). Once the names/count are known
  ///          good, a non-numeric or non-100-summing weight list errors
  ///          only 'departmentWeight' — the Applied Departments cell stays
  ///          clean, matching the reference mockup (bad sum = red Total
  ///          Weight box, not a red Applied Departments cell).
  void _validateDepartments(
    Map<String, String> errors,
    Set<String> knownDepartmentNames,
  ) {
    final namesText = appliedDepartmentsController.text.trim();
    final weightsText = departmentWeightController.text.trim();
    departmentNames = [];
    departmentWeights = [];

    if (namesText.isEmpty && weightsText.isEmpty) return;

    final names = _splitList(namesText);
    final weightStrings = _splitList(weightsText);

    if (names.isEmpty || weightStrings.isEmpty) {
      const message = 'Applied Departments and Department Weight must both be filled in';
      errors['appliedDepartments'] = message;
      errors['departmentWeight'] = message;
      return;
    }

    if (names.length != weightStrings.length) {
      const message = 'Applied Departments and Department Weight must have the same count';
      errors['appliedDepartments'] = message;
      errors['departmentWeight'] = message;
      return;
    }

    final unknown = names.where((n) => !knownDepartmentNames.contains(n)).toList();
    if (unknown.isNotEmpty) {
      errors['appliedDepartments'] = 'Unknown department(s): ${unknown.join(', ')}';
      return;
    }

    final weights = weightStrings.map(double.tryParse).toList();
    if (weights.any((w) => w == null)) {
      errors['departmentWeight'] = 'Department Weight must be numbers';
      return;
    }

    departmentNames = names;
    departmentWeights = weights.map((w) => w!).toList();

    final total = departmentWeights.fold<double>(0, (sum, w) => sum + w);
    if (total != 100) {
      errors['departmentWeight'] =
          'Department Weight must sum to 100 (currently ${total.toStringAsFixed(0)})';
    }
  }

  /// The current Control Weight as a number, or 0 if it doesn't parse.
  double get weightValue => double.tryParse(controlWeightController.text.trim()) ?? 0;

  /// function name: [dispose]
  ///
  /// purpose: release every controller and focus node owned by this row.
  void dispose() {
    controlNameEnController.dispose();
    controlNameArController.dispose();
    controlNumberEnController.dispose();
    controlNumberArController.dispose();
    controlDescriptionEnController.dispose();
    controlDescriptionArController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    controlWeightController.dispose();
    frequencyController.dispose();
    controlChampionController.dispose();
    controlOwnerController.dispose();
    appliedDepartmentsController.dispose();
    departmentWeightController.dispose();
    for (final node in focusNodes.values) {
      node.dispose();
    }
  }
}
```

- [ ] **Step 2: Write the test**

```dart
// test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';

ControlBulkRowForm _validRow({
  String controlWeight = '25',
  String frequency = 'Weekly',
  String controlChampion = '',
  String controlOwner = '',
  String appliedDepartments = '',
  String departmentWeight = '',
}) =>
    ControlBulkRowForm(
      controlNameEn: 'Access Review',
      controlNameAr: 'مراجعة الوصول',
      controlNumberEn: 'C-001',
      controlNumberAr: 'ك-001',
      controlDescriptionEn: 'desc',
      controlDescriptionAr: 'وصف',
      startDate: '01-01-2026',
      endDate: '31-12-2026',
      controlWeight: controlWeight,
      frequency: frequency,
      controlChampion: controlChampion,
      controlOwner: controlOwner,
      appliedDepartments: appliedDepartments,
      departmentWeight: departmentWeight,
    );

void main() {
  const knownEmails = {'amro@example.com', 'mona@example.com'};
  const knownDepartments = {'Marketing', 'HR', 'Design'};

  group('ControlBulkRowForm.validate', () {
    test('required fields error when empty', () {
      final row = ControlBulkRowForm();
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['controlNameEn'], 'Required');
      expect(errors['frequency'], 'Required');
    });

    test('Start Date must be before End Date', () {
      final row = _validRow()
        ..startDateController.text = '10-01-2026'
        ..endDateController.text = '01-01-2026';
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['startDate'], contains('before'));
      expect(errors['endDate'], contains('before'));
    });

    test('Control Weight must be a positive number', () {
      final row = _validRow(controlWeight: '0');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['controlWeight'], isNotNull);
    });

    test('Frequency matches case-insensitively and resolves to canonical casing', () {
      final row = _validRow(frequency: 'weekly');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['frequency'], isNull);
      expect(row.resolvedFrequency, 'Weekly');
    });

    test('unmatched Frequency errors', () {
      final row = _validRow(frequency: 'Daily');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['frequency'], isNotNull);
      expect(row.resolvedFrequency, isNull);
    });

    test('unknown Champion email errors', () {
      final row = _validRow(controlChampion: 'nobody@example.com');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['controlChampion'], isNotNull);
      expect(row.championEmails, isEmpty);
    });

    test('multiple valid, comma-separated Owner emails pass', () {
      final row = _validRow(controlOwner: 'amro@example.com, mona@example.com');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['controlOwner'], isNull);
      expect(row.ownerEmails, ['amro@example.com', 'mona@example.com']);
    });

    test('empty Applied Departments/Department Weight pair is valid', () {
      final row = _validRow();
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['appliedDepartments'], isNull);
      expect(errors['departmentWeight'], isNull);
      expect(row.departmentNames, isEmpty);
    });

    test('unknown department name errors appliedDepartments only, box stays hidden (empty departmentNames)', () {
      final row = _validRow(appliedDepartments: 'Marketing,Finance', departmentWeight: '50,50');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['appliedDepartments'], isNotNull);
      expect(errors['departmentWeight'], isNull);
      expect(row.departmentNames, isEmpty);
    });

    test('count mismatch errors both fields', () {
      final row = _validRow(appliedDepartments: 'Marketing,HR', departmentWeight: '50');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['appliedDepartments'], isNotNull);
      expect(errors['departmentWeight'], isNotNull);
    });

    test('valid names but sum != 100 errors departmentWeight only, names still populate', () {
      final row = _validRow(appliedDepartments: 'Marketing,HR,Design', departmentWeight: '50,50,20');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['appliedDepartments'], isNull);
      expect(errors['departmentWeight'], contains('100'));
      expect(row.departmentNames, ['Marketing', 'HR', 'Design']);
      expect(row.departmentWeights, [50, 50, 20]);
    });

    test('valid names summing to 100 pass with no errors', () {
      final row = _validRow(appliedDepartments: 'Marketing,HR,Design', departmentWeight: '30,30,40');
      final errors = row.validate(
        knownEmployeeEmails: knownEmails,
        knownDepartmentNames: knownDepartments,
      );
      expect(errors['appliedDepartments'], isNull);
      expect(errors['departmentWeight'], isNull);
      expect(row.departmentNames, ['Marketing', 'HR', 'Design']);
    });
  });
}
```

- [ ] **Step 3: Run the test**

Run: `flutter test test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form_test.dart`
Expected: PASS (12 tests)

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form_test.dart
git commit -m "feat(grc): add ControlBulkRowForm with Frequency/Champion/Owner/Departments validation"
```

---

### Task 3: `control_bulk_upload_rows.dart`

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart`
- Test: `test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows_test.dart`

**Interfaces:**
- Consumes: `ControlBulkRowForm`, `ControlBulkRow` (Task 2/1).
- Produces: `ControlBulkUploadRows(List<ControlBulkRow> parsedRows, {required Set<String> knownEmployeeEmails, required Set<String> knownDepartmentNames})` with `rows: List<ControlBulkRowForm>`, `selectedRows: Set<int>`, `toggleSelected`, `addBlankRow`, `removeSelected`, `duplicateSelected`, `removeAt`, `errorCount`, `errorLocations: List<(int, String)>`, `isValid`, `dispose()`. Task 4 depends on this exact shape (mirrors `PolicyBulkUploadRows` minus the batch weight getters).

- [ ] **Step 1: Write the rows model**

```dart
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
```

- [ ] **Step 2: Write the test**

```dart
// test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';

ControlBulkRow _row({String weight = '25', String frequency = 'Weekly'}) => ControlBulkRow(
      controlNameEn: 'Name',
      controlNameAr: 'اسم',
      controlNumberEn: 'C-1',
      controlNumberAr: 'ك-1',
      controlDescriptionEn: 'desc',
      controlDescriptionAr: 'وصف',
      startDate: '01-01-2026',
      endDate: '',
      controlWeight: weight,
      frequency: frequency,
      controlChampion: '',
      controlOwner: '',
      appliedDepartments: '',
      departmentWeight: '',
    );

void main() {
  group('ControlBulkUploadRows', () {
    test('constructor validates every row immediately', () {
      final rows = ControlBulkUploadRows(
        [_row(), _row(weight: '0')],
        knownEmployeeEmails: const {},
        knownDepartmentNames: const {},
      );
      expect(rows.rows[0].errors, isEmpty);
      expect(rows.rows[1].errors['controlWeight'], isNotNull);
      expect(rows.isValid, isFalse);
    });

    test('isValid is true only when every row is error-free and rows exist', () {
      final rows = ControlBulkUploadRows(
        [_row()],
        knownEmployeeEmails: const {},
        knownDepartmentNames: const {},
      );
      expect(rows.isValid, isTrue);
    });

    test('addBlankRow appends a validated empty row', () {
      final rows = ControlBulkUploadRows(
        [_row()],
        knownEmployeeEmails: const {},
        knownDepartmentNames: const {},
      );
      rows.addBlankRow();
      expect(rows.rows.length, 2);
      expect(rows.rows[1].errors['controlNameEn'], 'Required');
    });

    test('toggleSelected then removeSelected removes the row', () {
      final rows = ControlBulkUploadRows(
        [_row(), _row()],
        knownEmployeeEmails: const {},
        knownDepartmentNames: const {},
      );
      rows.toggleSelected(0);
      final removed = rows.removeSelected();
      expect(removed, isTrue);
      expect(rows.rows.length, 1);
      expect(rows.selectedRows, isEmpty);
    });

    test('duplicateSelected requires exactly one selected row', () {
      final rows = ControlBulkUploadRows(
        [_row(), _row()],
        knownEmployeeEmails: const {},
        knownDepartmentNames: const {},
      );
      expect(rows.duplicateSelected(), isFalse);
      rows.toggleSelected(0);
      expect(rows.duplicateSelected(), isTrue);
      expect(rows.rows.length, 3);
    });

    test('errorLocations lists every (rowIndex, fieldKey) error pair', () {
      final rows = ControlBulkUploadRows(
        [_row(weight: '0')],
        knownEmployeeEmails: const {},
        knownDepartmentNames: const {},
      );
      expect(rows.errorLocations, contains((0, 'controlWeight')));
    });
  });
}
```

- [ ] **Step 3: Run the test**

Run: `flutter test test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart test/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows_test.dart
git commit -m "feat(grc): add ControlBulkUploadRows row-management model"
```

---

### Task 4: `control_bulk_upload_cubit.dart` + state

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart`
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_state.dart`

**Interfaces:**
- Consumes: `ControlBulkUploadRows` (Task 3); `CreateControlUseCase`/`CreateControlParams` (existing, `lib/features/grc/control/domain/use_cases/create_control_usecase.dart`); `ControlStatus` (existing); `ChampionCubit`/`ChampionState`/`ChampionListLoaded`/`ChampionEntity` and `OwnerCubit`/`OwnerState`/`OwnerListLoaded`/`OwnerEntity` (existing, `lib/features/grc/control_champion/...` / `lib/features/grc/control_owner/...`); `AssigningControlEntity` (existing, `lib/features/grc/control/domain/entities/assigning_control.dart`); `MainCoreEmployeeController`/`MainCoreDepartmentController` (existing).
- Produces: `ControlBulkUploadCubit({required createControlUseCase, required championCubit, required ownerCubit, required parsedRows})`, `.rowsData`, `.toggleRowSelected`/`.addRow`/`.removeSelectedRows`/`.duplicateSelectedRow`/`.revalidateRow`, `.submit({required moduleId, required policyId})`; states `ControlBulkUploadEditing`/`ControlBulkUploadSubmitting`/`ControlBulkUploadSubmitResult(succeededCount, failed)`; `ControlBulkRowFailure(reason)`. Tasks 5/6 depend on these exact names.

No test for this task — it's Firestore/GetX-integration code with no existing precedent for testing in this codebase (same as `PolicyBulkUploadCubit`, which also has none). Verify via `dart analyze` only.

- [ ] **Step 1: Write the state file**

```dart
// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_state.dart
part of 'control_bulk_upload_cubit.dart';

sealed class ControlBulkUploadState {}

/// State while the user is reviewing/editing rows (also emitted after
/// every row-management action, to trigger a table rebuild).
final class ControlBulkUploadEditing extends ControlBulkUploadState {}

/// State while [ControlBulkUploadCubit.submit] is running.
final class ControlBulkUploadSubmitting extends ControlBulkUploadState {}

/// State emitted once [ControlBulkUploadCubit.submit] finishes. Rows that
/// succeeded have already been removed from
/// [ControlBulkUploadCubit.rowsData]; [failed] is parallel, in order, to
/// the rows that remain.
final class ControlBulkUploadSubmitResult extends ControlBulkUploadState {
  final int succeededCount;
  final List<ControlBulkRowFailure> failed;

  ControlBulkUploadSubmitResult({
    required this.succeededCount,
    required this.failed,
  });
}

/// One row's create-control failure reason.
class ControlBulkRowFailure {
  final String reason;
  const ControlBulkRowFailure({required this.reason});
}
```

- [ ] **Step 2: Write the cubit**

```dart
// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart
/// Module: GRC Control Bulk Upload
/// Description: BLoC Cubit driving the Control bulk upload preview table:
///              owns the editable [ControlBulkUploadRows], forwards
///              row-management actions to it, and on submit calls
///              [CreateControlUseCase] once per row (best-effort), then
///              assigns each row's Control Champion/Owner emails via
///              [ChampionCubit]/[OwnerCubit] using the same
///              find-existing-or-create logic already built for
///              AddEditControlPage — see the plan's Global Constraints for
///              why this keeps its own local assignment snapshot instead
///              of re-reading championCubit.state/ownerCubit.state between
///              rows.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, get, CreateControlUseCase, ChampionCubit,
///               OwnerCubit, ControlBulkUploadRows
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/department/presentation/controller/add_department_controller.dart';
import 'package:demo_app/features/grc/control/domain/entities/assigning_control.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:demo_app/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'control_bulk_upload_state.dart';

class ControlBulkUploadCubit extends Cubit<ControlBulkUploadState> {
  ControlBulkUploadCubit({
    required CreateControlUseCase createControlUseCase,
    required ChampionCubit championCubit,
    required OwnerCubit ownerCubit,
    required List<ControlBulkRow> parsedRows,
  })  : _createUseCase = createControlUseCase,
        _championCubit = championCubit,
        _ownerCubit = ownerCubit,
        _rows = ControlBulkUploadRows(
          parsedRows,
          knownEmployeeEmails: _resolveKnownEmployeeEmails(),
          knownDepartmentNames: _resolveKnownDepartmentNames(),
        ),
        super(ControlBulkUploadEditing());

  final CreateControlUseCase _createUseCase;
  final ChampionCubit _championCubit;
  final OwnerCubit _ownerCubit;
  final ControlBulkUploadRows _rows;

  /// The editable row collection backing the preview table.
  ControlBulkUploadRows get rowsData => _rows;

  static Set<String> _resolveKnownEmployeeEmails() {
    if (!Get.isRegistered<MainCoreEmployeeController>()) return {};
    final employees = Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
    return employees.map((e) => e.email ?? '').where((e) => e.isNotEmpty).toSet();
  }

  static Set<String> _resolveKnownDepartmentNames() {
    if (!Get.isRegistered<MainCoreDepartmentController>()) return {};
    final departmentController = Get.find<MainCoreDepartmentController>();
    final names = <String>{};
    for (final id in departmentController.departmentIds) {
      final en =
          departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: id);
      final ar =
          departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: id);
      if (en != null) names.add(en);
      if (ar != null) names.add(ar);
    }
    return names;
  }

  /// Resolves the currently logged-in user's email (same lookup as
  /// PolicyCubit/ChampionCubit/OwnerCubit).
  String get _currentUserEmail {
    final fromConstant = Constant.emailUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final email = Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.isNotEmpty) return email;
    }
    return '';
  }

  void toggleRowSelected(int index) {
    _rows.toggleSelected(index);
    emit(ControlBulkUploadEditing());
  }

  void addRow() {
    _rows.addBlankRow();
    emit(ControlBulkUploadEditing());
  }

  void removeSelectedRows() {
    _rows.removeSelected();
    emit(ControlBulkUploadEditing());
  }

  void duplicateSelectedRow() {
    _rows.duplicateSelected();
    emit(ControlBulkUploadEditing());
  }

  /// Re-runs validation for one row (called on every cell edit).
  void revalidateRow(int index) {
    _rows.rows[index].validate(
      knownEmployeeEmails: _rows.knownEmployeeEmails,
      knownDepartmentNames: _rows.knownDepartmentNames,
    );
    emit(ControlBulkUploadEditing());
  }

  /// function name: [submit]
  ///
  /// purpose: create every row as a real Control via [CreateControlUseCase],
  ///          best-effort, then assign that row's Champion/Owner emails.
  ///          Rows that succeed are removed from [rowsData]; rows that fail
  ///          stay, in order, so [ControlBulkUploadSubmitResult.failed]
  ///          lines up 1:1 with the remaining rows afterward.
  Future<void> submit({required String moduleId, required String policyId}) async {
    emit(ControlBulkUploadSubmitting());

    var succeededCount = 0;
    final failed = <ControlBulkRowFailure>[];
    final indexesToRemove = <int>[];
    final editorId = _currentUserEmail;

    // Snapshot the current Champion/Owner assignments once, before any
    // row's create/assign runs, into a local mutable map this loop keeps
    // updated — championCubit.state/ownerCubit.state change away from
    // ChampionListLoaded/OwnerListLoaded after every createChampion/
    // updateChampion/createOwner/updateOwner call, so re-reading them
    // mid-loop would miss earlier rows' assignments to the same email.
    final championState = _championCubit.state;
    final championAssignments = <String, List<AssigningControlEntity>>{
      if (championState is ChampionListLoaded)
        for (final c in championState.champions)
          c.championEmail: List.of(c.assigningControls),
    };
    final ownerState = _ownerCubit.state;
    final ownerAssignments = <String, List<AssigningControlEntity>>{
      if (ownerState is OwnerListLoaded)
        for (final o in ownerState.owners) o.ownerEmail: List.of(o.assigningControls),
    };

    for (var i = 0; i < _rows.rows.length; i++) {
      final row = _rows.rows[i];
      final start = parsePolicyBulkDate(row.startDateController.text);
      final endText = row.endDateController.text.trim();
      final end = endText.isEmpty ? start : parsePolicyBulkDate(endText);
      final weight = double.tryParse(row.controlWeightController.text.trim());

      if (start == null || end == null || weight == null || row.resolvedFrequency == null) {
        failed.add(const ControlBulkRowFailure(reason: 'Invalid row data'));
        continue;
      }

      final result = await _createUseCase.call(
        CreateControlParams(
          moduleId: moduleId,
          policyId: policyId,
          editorId: editorId,
          controlsNameEn: row.controlNameEnController.text.trim(),
          controlsNameAr: row.controlNameArController.text.trim(),
          controlsNumberEn: row.controlNumberEnController.text.trim(),
          controlsNumberAr: row.controlNumberArController.text.trim(),
          controlsDescriptionEn: row.controlDescriptionEnController.text.trim(),
          controlsDescriptionAr: row.controlDescriptionArController.text.trim(),
          controlsWeight: weight,
          frequency: row.resolvedFrequency!,
          startDate: start,
          endDate: end,
          departments: row.departmentNames,
          departmentsWeights: row.departmentNames.isEmpty ? null : row.departmentWeights,
          equalWeights: false,
          score: 0,
          status: ControlStatus.active,
        ),
      );

      final control = result.fold((failure) {
        failed.add(ControlBulkRowFailure(reason: failure.message));
        return null;
      }, (created) => created);

      if (control == null) continue;

      for (final email in row.championEmails) {
        final pair = AssigningControlEntity(policyId: policyId, controlId: control.id);
        final existing = championAssignments[email];
        final updated = [...?existing, pair];
        championAssignments[email] = updated;
        if (existing != null) {
          await _championCubit.updateChampion(
            championEmail: email,
            moduleId: moduleId,
            assigningControls: updated,
          );
        } else {
          await _championCubit.createChampion(
            moduleId: moduleId,
            championEmail: email,
            assigningControls: updated,
          );
        }
      }

      for (final email in row.ownerEmails) {
        final pair = AssigningControlEntity(policyId: policyId, controlId: control.id);
        final existing = ownerAssignments[email];
        final updated = [...?existing, pair];
        ownerAssignments[email] = updated;
        if (existing != null) {
          await _ownerCubit.updateOwner(
            ownerEmail: email,
            moduleId: moduleId,
            assigningControls: updated,
          );
        } else {
          await _ownerCubit.createOwner(
            moduleId: moduleId,
            ownerEmail: email,
            assigningControls: updated,
          );
        }
      }

      succeededCount++;
      indexesToRemove.add(i);
    }

    indexesToRemove.sort((a, b) => b.compareTo(a));
    for (final index in indexesToRemove) {
      _rows.removeAt(index);
    }

    emit(ControlBulkUploadSubmitResult(succeededCount: succeededCount, failed: failed));
  }

  @override
  Future<void> close() {
    _rows.dispose();
    return super.close();
  }
}
```

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_state.dart`
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_state.dart
git commit -m "feat(grc): add ControlBulkUploadCubit with best-effort submit + Champion/Owner assignment"
```

---

### Task 5: `control_bulk_upload_page.dart`

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart`

**Interfaces:**
- Consumes: `parseControlExcel`/`ControlExcelParseSuccess`/`ControlExcelParseHeaderMismatch`/`ControlExcelParseEmpty` (Task 1); `ControlBulkUploadCubit` (Task 4); `ChampionCubit`/`OwnerCubit` (existing, resolved via `GetIt`); `ControlBulkUploadPreviewPage` (Task 6 — this task references it, Task 6 creates the file; if executed in this order the import will 404 until Task 6 lands, which is fine within one plan run before final verification, but do Task 6 immediately after this one).
- Produces: `ControlBulkUploadPage(moduleId, policyId)`, pushed via `navigateTo`. Task 7 depends on this constructor.

- [ ] **Step 1: Write the page**

```dart
// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart
/// Module: GRC Control Bulk Upload
/// Description: The "Control Bulk Upload" drag & drop / browse screen,
///              scoped to a single Policy. Parses the selected workbook
///              via parseControlExcel() and, on success, provides
///              ChampionCubit/OwnerCubit (loading their module-scoped
///              lists) plus a fresh ControlBulkUploadCubit, then opens the
///              editable preview table. Mirrors
///              policy_bulk_upload_page.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: desktop_drop, file_picker, ControlBulkUploadCubit,
///               ChampionCubit, OwnerCubit, control_excel_parser.dart

import 'dart:io';

import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/use_cases/create_control_usecase.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_excel_parser.dart';
import 'package:demo_app/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:demo_app/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:get_it/get_it.dart';

class ControlBulkUploadPage extends StatefulWidget {
  final String moduleId;
  final String policyId;

  const ControlBulkUploadPage({
    super.key,
    required this.moduleId,
    required this.policyId,
  });

  @override
  State<ControlBulkUploadPage> createState() => _ControlBulkUploadPageState();
}

class _ControlBulkUploadPageState extends State<ControlBulkUploadPage> {
  bool _isDragging = false;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _pickAndParseExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    var bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      setState(() => _errorMessage = 'Unable to read the selected file'.tr);
      return;
    }
    await _processBytes(bytes);
  }

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;

    final file = details.files.first;
    final lowerName = file.name.toLowerCase();
    if (!lowerName.endsWith('.xlsx') && !lowerName.endsWith('.xls')) {
      setState(() => _errorMessage = 'Please drop an Excel file (.xlsx or .xls)'.tr);
      return;
    }
    await _processBytes(await file.readAsBytes());
  }

  Future<void> _processBytes(List<int> bytes) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final result = parseControlExcel(bytes);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case ControlExcelParseSuccess(:final rows):
        navigateTo(
          context,
          MultiBlocProvider(
            providers: [
              BlocProvider<ChampionCubit>(
                create: (_) => GetIt.instance<ChampionCubit>()
                  ..getAllChampions(moduleId: widget.moduleId),
              ),
              BlocProvider<OwnerCubit>(
                create: (_) => GetIt.instance<OwnerCubit>()
                  ..getAllOwners(moduleId: widget.moduleId),
              ),
            ],
            child: Builder(
              builder: (innerContext) => BlocProvider<ControlBulkUploadCubit>(
                create: (_) => ControlBulkUploadCubit(
                  createControlUseCase: GetIt.instance<CreateControlUseCase>(),
                  championCubit: innerContext.read<ChampionCubit>(),
                  ownerCubit: innerContext.read<OwnerCubit>(),
                  parsedRows: rows,
                ),
                child: ControlBulkUploadPreviewPage(
                  moduleId: widget.moduleId,
                  policyId: widget.policyId,
                ),
              ),
            ),
          ),
        );
      case ControlExcelParseHeaderMismatch(:final message):
        setState(() => _errorMessage = message);
      case ControlExcelParseEmpty():
        setState(() => _errorMessage = 'No data rows found in the Excel file'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PaginationAppBar(
                screensTitles: ['GRC'.tr, 'Control Bulk Upload'.tr],
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: DropTarget(
                  onDragEntered: (_) => setState(() => _isDragging = true),
                  onDragExited: (_) => setState(() => _isDragging = false),
                  onDragDone: _onDragDone,
                  child: GestureDetector(
                    onTap: _pickAndParseExcel,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _isDragging
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: _isProcessing
                            ? CircularProgressIndicator(color: AppColors.primary)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons_assets/main_icons_assets/uploadfile.svg',
                                    width: 100.sp,
                                    height: 100.sp,
                                  ),
                                  SizedBox(height: 27.sp),
                                  Text(
                                    'Drag & Drop files here'.tr,
                                    style: StyleText.fontSize20Weight500
                                        .copyWith(color: AppColors.text),
                                  ),
                                  SizedBox(height: 8.sp),
                                  Text(
                                    'Or'.tr,
                                    style: StyleText.fontSize16Weight500
                                        .copyWith(color: AppColors.secondaryText),
                                  ),
                                  if (_errorMessage != null) ...[
                                    SizedBox(height: 16.sp),
                                    Text(
                                      _errorMessage!,
                                      style: StyleText.fontSize14Weight500
                                          .copyWith(color: AppColors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 26.h),
              Row(
                children: [
                  customButton(
                    title: 'Discard'.tr,
                    function: () => Navigator.pop(context),
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.secondaryText,
                    textStyle: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  const Spacer(),
                  customButton(
                    title: 'Browse Files'.tr,
                    function: _pickAndParseExcel,
                    width: 150.w,
                    height: 38.h,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.textButton),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `dart analyze lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart`
Expected: an import-resolution error on `control_bulk_upload_preview_page.dart` is EXPECTED at this point (Task 6 hasn't created it yet) — that's fine, do not treat it as a blocker for this task. Every other line should have no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart
git commit -m "feat(grc): add ControlBulkUploadPage upload screen"
```

---

### Task 6: `control_bulk_upload_preview_page.dart`

**Files:**
- Create: `lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart`

**Interfaces:**
- Consumes: `ControlBulkUploadCubit`/`ControlBulkUploadState`/`ControlBulkUploadEditing`/`ControlBulkUploadSubmitting`/`ControlBulkUploadSubmitResult` (Task 4); `ControlBulkUploadRows`/`ControlBulkRowForm` (Tasks 2/3).
- Produces: `ControlBulkUploadPreviewPage(moduleId, policyId)`. Task 5 (already written, Step 1) references this constructor; Task 7 does not touch this file directly.

- [ ] **Step 1: Write the preview page**

```dart
// lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart
/// Module: GRC Control Bulk Upload
/// Description: Editable preview table for the Control bulk upload flow.
///              Mirrors policy_bulk_upload_preview_page.dart's toolbar/
///              error-nav/per-cell structure; adds a per-row (not
///              page-footer) Applied Departments Total Weight box, shown
///              only once that row's Applied Departments cell itself has
///              no error (a bad sum still shows the box, in red, per the
///              'departmentWeight' error key — see ControlBulkRowForm).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-19
/// Dependencies: flutter_bloc, ControlBulkUploadCubit, ControlBulkRowForm

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_row_form.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_rows.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

const List<_ColumnSpec> _columns = [
  _ColumnSpec('controlNameEn', 'Control Name', 150),
  _ColumnSpec('controlNameAr', 'اسم ضابط', 150),
  _ColumnSpec('controlNumberEn', 'Control Number', 110),
  _ColumnSpec('controlNumberAr', 'رقم ضابط', 110),
  _ColumnSpec('controlDescriptionEn', 'Control Description', 180),
  _ColumnSpec('controlDescriptionAr', 'وصف ضابط', 180),
  _ColumnSpec('startDate', 'Start Date', 110),
  _ColumnSpec('endDate', 'End Date', 110),
  _ColumnSpec('controlWeight', 'Control Weight', 100),
  _ColumnSpec('frequency', 'Frequency', 110),
  _ColumnSpec('controlChampion', 'Control Champion', 180),
  _ColumnSpec('controlOwner', 'Control Owner', 180),
  _ColumnSpec('appliedDepartments', 'Applied Departments', 200),
  _ColumnSpec('departmentWeight', 'Department Weight', 150),
];

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

class ControlBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;
  final String policyId;

  const ControlBulkUploadPreviewPage({
    super.key,
    required this.moduleId,
    required this.policyId,
  });

  @override
  State<ControlBulkUploadPreviewPage> createState() =>
      _ControlBulkUploadPreviewPageState();
}

class _ControlBulkUploadPreviewPageState
    extends State<ControlBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, ControlBulkUploadRows rowsData) {
    final locations = rowsData.errorLocations;
    if (locations.isEmpty) return;

    setState(() {
      _currentErrorIndex = next
          ? (_currentErrorIndex + 1) % locations.length
          : (_currentErrorIndex - 1 + locations.length) % locations.length;
    });

    final (rowIndex, fieldKey) = locations[_currentErrorIndex];
    final row = rowsData.rows[rowIndex];
    final rowContext = row.key.currentContext;
    if (rowContext != null) {
      Scrollable.ensureVisible(
        rowContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
      );
    }
    row.focusNodes[fieldKey]?.requestFocus();
  }

  Future<void> _onActivate(ControlBulkUploadCubit cubit) async {
    final rowsData = cubit.rowsData;
    if (!rowsData.isValid) {
      if (rowsData.errorLocations.isNotEmpty) {
        _jumpToError(true, rowsData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Add at least one row'.tr)),
        );
      }
      return;
    }
    await cubit.submit(moduleId: widget.moduleId, policyId: widget.policyId);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ControlBulkUploadCubit>();

    return BlocConsumer<ControlBulkUploadCubit, ControlBulkUploadState>(
      listener: (context, state) {
        if (state is ControlBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.succeededCount} ${'control(s) created'.tr}',
                ),
              ),
            );
          }
          if (state.failed.isEmpty) {
            Navigator.pop(context, true);
          }
        }
      },
      builder: (context, state) {
        final submitting = state is ControlBulkUploadSubmitting;
        final rowsData = cubit.rowsData;
        final activateEnabled = !submitting && rowsData.isValid;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaginationAppBar(
                    screensTitles: ['GRC'.tr, 'Control Bulk Upload Preview'.tr],
                  ),
                  SizedBox(height: 15.h),
                  _buildToolbar(context, cubit, rowsData),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderRow(),
                            for (var i = 0; i < rowsData.rows.length; i++)
                              _buildRow(cubit, rowsData, i),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      customButton(
                        title: 'Discard'.tr,
                        function: () => Navigator.pop(context),
                        width: 150.w,
                        height: 38.h,
                        color: AppColors.secondaryText,
                        textStyle: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.text),
                      ),
                      const Spacer(),
                      customButton(
                        title: 'Activate'.tr,
                        function: submitting ? () {} : () => _onActivate(cubit),
                        width: 150.w,
                        height: 38.h,
                        color: activateEnabled ? AppColors.primary : AppColors.secondaryText,
                        textStyle: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.textButton),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
  ) {
    final errorCount = rowsData.errorCount;
    return Row(
      children: [
        Container(
          height: 30.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(false, rowsData),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${'Error'.tr}: '
                '${errorCount > 0 ? '${_currentErrorIndex + 1}/$errorCount' : '0'}',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: errorCount > 0 ? AppColors.red : AppColors.text,
                ),
              ),
              IconButton(
                iconSize: 16.sp,
                onPressed: () => _jumpToError(true, rowsData),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        const Spacer(),
        customButton(
          title: 'Remove Selection'.tr,
          function: () {
            if (rowsData.selectedRows.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Select at least one row'.tr)),
              );
              return;
            }
            cubit.removeSelectedRows();
          },
          width: 150.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: 'Duplication'.tr,
          function: () {
            if (rowsData.selectedRows.length != 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Select exactly one row to duplicate'.tr)),
              );
              return;
            }
            cubit.duplicateSelectedRow();
          },
          width: 100.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
        SizedBox(width: 10.w),
        customButton(
          title: '+ Row'.tr,
          function: cubit.addRow,
          width: 90.w,
          height: 30.h,
          color: AppColors.black,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        SizedBox(width: 40.w),
        for (final column in _columns)
          SizedBox(
            width: column.width.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                column.label,
                style: StyleText.fontSize14Weight600.copyWith(color: AppColors.text),
              ),
            ),
          ),
        SizedBox(width: 140.w),
      ],
    );
  }

  Widget _buildRow(
    ControlBulkUploadCubit cubit,
    ControlBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = <String, TextEditingController>{
      'controlNameEn': row.controlNameEnController,
      'controlNameAr': row.controlNameArController,
      'controlNumberEn': row.controlNumberEnController,
      'controlNumberAr': row.controlNumberArController,
      'controlDescriptionEn': row.controlDescriptionEnController,
      'controlDescriptionAr': row.controlDescriptionArController,
      'startDate': row.startDateController,
      'endDate': row.endDateController,
      'controlWeight': row.controlWeightController,
      'frequency': row.frequencyController,
      'controlChampion': row.controlChampionController,
      'controlOwner': row.controlOwnerController,
      'appliedDepartments': row.appliedDepartmentsController,
      'departmentWeight': row.departmentWeightController,
    };

    return Container(
      key: row.key,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Checkbox(
              value: rowsData.selectedRows.contains(index),
              activeColor: AppColors.primary,
              onChanged: (_) => cubit.toggleRowSelected(index),
            ),
          ),
          for (final column in _columns)
            _buildCell(
              width: column.width.w,
              controller: controllers[column.fieldKey]!,
              focusNode: row.focusNodes[column.fieldKey]!,
              error: row.errors[column.fieldKey],
              onChanged: () => cubit.revalidateRow(index),
            ),
          _buildRowTotalWeight(row),
        ],
      ),
    );
  }

  Widget _buildCell({
    required double width,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? error,
    required VoidCallback onChanged,
  }) {
    final borderColor = error != null ? AppColors.red : Colors.transparent;
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (_) => onChanged(),
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            suffixIcon: error != null
                ? Tooltip(
                    message: error,
                    child: Icon(Icons.error, color: AppColors.red, size: 16.sp),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  /// Renders the per-row Applied-Departments Total Weight box: hidden when
  /// the row has no departments at all ([ControlBulkRowForm.departmentNames]
  /// empty — either genuinely empty or the names/count themselves errored,
  /// in which case the red-bordered Applied Departments cell above already
  /// communicates the problem); green when the pair is fully valid; red
  /// (with a "should be 100" message) when the names/count are fine but the
  /// weights don't sum to 100 (['departmentWeight'] error present).
  Widget _buildRowTotalWeight(ControlBulkRowForm row) {
    if (row.departmentNames.isEmpty) return SizedBox(width: 140.w);

    final total = row.departmentWeights.fold<double>(0, (sum, w) => sum + w);
    final valid = !row.errors.containsKey('departmentWeight');

    return SizedBox(
      width: 140.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                border: Border.all(color: valid ? AppColors.green : AppColors.red),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '${'Total Weight'.tr} : ${total.toStringAsFixed(0)}',
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              ),
            ),
            if (!valid)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  'Total Weight should be 100'.tr,
                  style: StyleText.fontSize10Weight500.copyWith(color: AppColors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify**

Run: `dart analyze lib/features/grc/control/presentation/ui/pages/control_bulk_upload/`
Expected: no errors across the whole `control_bulk_upload/` directory now that both pages exist (the Task 5 import-resolution error from its own verify step should be gone).

- [ ] **Step 3: Manual check**

Skipped — no Flutter binary in this sandbox.

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_preview_page.dart
git commit -m "feat(grc): add ControlBulkUploadPreviewPage editable table"
```

---

### Task 7: Wire the entry point in `policy_details_page.dart`

**Files:**
- Modify: `lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`

**Interfaces:**
- Consumes: `ControlBulkUploadPage` (Task 5).
- Produces: a working "Bulk Upload" menu item.

- [ ] **Step 1: Add the import**

Add alongside the existing imports:
```dart
import 'package:demo_app/features/grc/control/presentation/ui/pages/control_bulk_upload/control_bulk_upload_page.dart';
```

- [ ] **Step 2: Replace the stub**

Replace:
```dart
  /// Placeholder hook for the "Bulk Upload" menu item. Wire this up to the
  /// real bulk-import flow (e.g. an Excel/CSV upload dialog) once that
  /// feature is ready.
  void _onBulkUploadControls() {
    // TODO: replace with the actual bulk-upload flow for Controls.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk upload coming soon'.tr)),
    );
  }
```
with:
```dart
  Future<void> _onBulkUploadControls() async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ControlBulkUploadPage(
          moduleId: widget.moduleId,
          policyId: widget.policyId,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    if (result == true && mounted) {
      context
          .read<PolicyCubit>()
          .getAllControls(moduleId: widget.moduleId, policyId: widget.policyId);
    }
  }
```

(this mirrors `_openAddEditControl`'s exact push/refresh pattern already in this same file.)

- [ ] **Step 3: Verify**

Run: `dart analyze lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart`
Expected: no errors.

- [ ] **Step 4: Manual check**

Skipped — no Flutter binary in this sandbox. Note in the report: once Flutter is available, open a Policy's details page, pick "Bulk Upload" from the Control menu, upload a sample sheet covering every column (including Champion/Owner emails and a valid Applied Departments/Department Weight pair, plus one deliberately-broken row), fix a flagged cell, Activate, and confirm: the valid rows create real Controls with the right department weights, the Champion/Owner people show up under the Module's Control Champions/Owners tabs for those Controls, and the broken row stays visible with its failure reason.

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/policy/presentation/ui/pages/policy_details_page.dart
git commit -m "feat(grc): wire Control Bulk Upload into the Policy Details page"
```

---

## Self-Review Notes

- **Spec coverage:** parser/header list → Task 1. Row-form validation (required fields, dates, weight, Frequency case-insensitive match, Champion/Owner email lookup, Applied Departments/Department Weight structural + sum validation with the split red-cell-vs-red-box visual mapping) → Task 2. Row-list management (no batch weight check, per the confirmed scope decision) → Task 3. Submit flow (best-effort per-row create, Champion/Owner assignment via the local-snapshot pattern that avoids the cross-row state-staleness bug, `ControlStatus.active`/`equalWeights: false`) → Task 4. Upload/preview screens (per-row Total Weight box, hidden/green/red per the reconciled mockup reading) → Tasks 5-6. Entry-point wiring → Task 7. Every "Out of scope" item from the spec (Control Document upload, `Control_Owners_Permissions`, single-Control flow changes, cross-row weight sum) is untouched by every task above.
- **Type consistency checked:** `ControlBulkRowForm.validate()`'s exact param names (`knownEmployeeEmails`, `knownDepartmentNames`) match every call site across Tasks 3 and 4. `ControlBulkUploadRows`'s constructor and field names match Task 4's usage exactly. `ControlBulkUploadCubit`'s `rowsData`/`toggleRowSelected`/`addRow`/`removeSelectedRows`/`duplicateSelectedRow`/`revalidateRow`/`submit` match Task 6's call sites exactly. `CreateControlParams` field names match the existing (unmodified) `create_control_usecase.dart` exactly. `ChampionCubit.createChampion`/`updateChampion` and `OwnerCubit.createOwner`/`updateOwner` param names match their existing definitions from the prior Control Champions & Owners plan.
- **Placeholder scan:** no TBD/TODO; every step shows complete code. Task 5's verify step explicitly calls out the one expected transient error (missing Task 6 file) rather than leaving it as an unexplained failure.
