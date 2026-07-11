# Policy Bulk Upload Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user upload an Excel sheet of policies from `GrcModuleDetailsPage`, review/edit the parsed rows in an inline-editable table, and best-effort create them as real Policy documents via the existing `CreatePolicyUseCase`.

**Architecture:** A new, self-contained slice under `lib/features/grc/presentation/ui/pages/policy_bulk_upload/` — pure parsing/validation helpers, a `PolicyBulkUploadCubit` that owns the editable row list and drives submission, and two pages (upload, preview/table). No existing GRC domain/data files change; the only existing file touched is `grc_module_details_page.dart`, whose "Policy" button becomes a 2-choice menu.

**Tech Stack:** Flutter, `flutter_bloc` (Cubit), `excel: ^4.0.6`, `file_picker: ^9.0.2`, `desktop_drop: ^0.6.1`, `dartz` (`Either`/`Failure`), `flutter_screenutil`.

## Global Constraints

- Design spec: `docs/superpowers/specs/2026-07-11-policy-bulk-upload-design.md` — every requirement in this plan traces back to it.
- No changes to `PolicyEntity`, `PolicyModel`, `CreatePolicyUseCase`, `PolicyCubit`, `PolicyRepository`, or the single-policy `Add Policy` flow.
- No changes to the unrelated `lib/features/roles/user_management/` bulk-import feature — it is prior art to mirror, not code to share/refactor.
- Bulk-created policies always have `controls: []` and `status: PolicyStatus.active`.
- Expected sheet headers, in order: `Policy Number, Policy Number Ar, Policy Name, اسم السياسة, Policy Description, وصف السياسة, Start Date, End Date, Policy Weight, Policy Document`.
- Dates in the sheet/table are `dd-MM-yyyy` text.
- This repo has no mocking library (`flutter_test` + plain `test()` only, see `test/features/grc/policy_model_nested_array_test.dart`) and no existing Cubit/widget tests — automated tests target pure logic only; Cubit and page code is verified via `flutter analyze` per-task and a full manual click-through in the final task, matching existing repo convention.

---

### Task 1: Bulk-upload date format helpers

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart`
- Test: `test/features/grc/policy_bulk_upload/policy_bulk_date_format_test.dart`

**Interfaces:**
- Produces: `DateTime? parsePolicyBulkDate(String text)`, `String formatPolicyBulkDate(DateTime date)` — used by Task 2 (excel → string) and Task 3 (string → DateTime for validation).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePolicyBulkDate', () {
    test('parses a valid dd-MM-yyyy string', () {
      expect(parsePolicyBulkDate('23-04-2024'), DateTime(2024, 4, 23));
    });

    test('accepts single-digit day/month', () {
      expect(parsePolicyBulkDate('3-4-2024'), DateTime(2024, 4, 3));
    });

    test('returns null for an empty string', () {
      expect(parsePolicyBulkDate(''), isNull);
    });

    test('returns null for garbage input', () {
      expect(parsePolicyBulkDate('not a date'), isNull);
    });

    test('returns null for an out-of-range day', () {
      expect(parsePolicyBulkDate('31-04-2024'), isNull); // April has 30 days
    });
  });

  group('formatPolicyBulkDate', () {
    test('formats with zero-padded day/month', () {
      expect(formatPolicyBulkDate(DateTime(2024, 4, 3)), '03-04-2024');
    });

    test('round-trips through parsePolicyBulkDate', () {
      final date = DateTime(2026, 12, 31);
      expect(parsePolicyBulkDate(formatPolicyBulkDate(date)), date);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_bulk_date_format_test.dart`
Expected: FAIL — `policy_bulk_date_format.dart` does not exist yet (import error).

- [ ] **Step 3: Write the implementation**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: Shared dd-MM-yyyy date parsing/formatting for the bulk
///              upload sheet and its editable preview table. Both the Excel
///              parser (Task 2) and the per-row validator (Task 3) need the
///              same format so a value round-trips unchanged.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_date_format.dart
/// Purpose: Contains parsePolicyBulkDate() and formatPolicyBulkDate(), the
///          single source of truth for the bulk upload sheet's date format.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

final RegExp _policyBulkDatePattern = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$');

/// function name: [parsePolicyBulkDate]
///
/// purpose: parse a dd-MM-yyyy string (as typed in the bulk upload sheet or
///          preview table) into a [DateTime], rejecting anything that isn't
///          a real calendar date.
///
/// parameters:
///            [String] text: the raw cell/field text
///
/// return type: [DateTime?] - the parsed date, or null if [text] isn't a valid dd-MM-yyyy date
DateTime? parsePolicyBulkDate(String text) {
  final match = _policyBulkDatePattern.firstMatch(text.trim());
  if (match == null) return null;

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  final date = DateTime(year, month, day);
  // DateTime normalizes out-of-range days (e.g. 31 April -> 1 May); reject those.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

/// function name: [formatPolicyBulkDate]
///
/// purpose: format a [DateTime] back into the bulk upload sheet's
///          dd-MM-yyyy text representation.
///
/// parameters:
///            [DateTime] date: the date to format
///
/// return type: [String] - the dd-MM-yyyy formatted date
String formatPolicyBulkDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}-${two(date.month)}-${date.year}';
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_bulk_date_format_test.dart`
Expected: PASS (7 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart test/features/grc/policy_bulk_upload/policy_bulk_date_format_test.dart
git commit -m "feat(grc): add shared date format helpers for policy bulk upload"
```

---

### Task 2: Excel parser

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart`
- Test: `test/features/grc/policy_bulk_upload/policy_excel_parser_test.dart`

**Interfaces:**
- Consumes: `formatPolicyBulkDate(DateTime)` from Task 1.
- Produces: `PolicyBulkRow` (fields: `policyNumberEn, policyNumberAr, policyNameEn, policyNameAr, policyDescriptionEn, policyDescriptionAr, startDate, endDate, policyWeight, policyDocument` — all `String`), `policyBulkUploadExpectedHeaders` (`List<String>`), sealed `PolicyExcelParseResult` with `PolicyExcelParseSuccess(List<PolicyBulkRow> rows)`, `PolicyExcelParseHeaderMismatch(String message)`, `PolicyExcelParseEmpty()`, and `PolicyExcelParseResult parsePolicyExcel(List<int> bytes)` — used by Task 7 (upload page).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;
import 'package:flutter_test/flutter_test.dart';

List<int> _buildWorkbook(List<String> headers, List<List<String>> dataRows) {
  final excel = Excel.createExcel();
  final sheet = excel['Sheet1'];
  sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
  for (final row in dataRows) {
    sheet.appendRow(row.map((cell) => TextCellValue(cell)).toList());
  }
  return excel.save()!;
}

void main() {
  test('parses valid rows with matching headers', () {
    final bytes = _buildWorkbook(policyBulkUploadExpectedHeaders, [
      [
        'P-1',
        'س-1',
        'Access Control Policy',
        'سياسة التحكم في الوصول',
        'Description EN',
        'وصف',
        '23-04-2024',
        '23-04-2025',
        '50',
        'https://example.com/doc.pdf',
      ],
    ]);

    final result = parsePolicyExcel(bytes);

    expect(result, isA<PolicyExcelParseSuccess>());
    final rows = (result as PolicyExcelParseSuccess).rows;
    expect(rows, hasLength(1));
    expect(rows.first.policyNumberEn, 'P-1');
    expect(rows.first.policyNumberAr, 'س-1');
    expect(rows.first.policyNameEn, 'Access Control Policy');
    expect(rows.first.startDate, '23-04-2024');
    expect(rows.first.policyWeight, '50');
    expect(rows.first.policyDocument, 'https://example.com/doc.pdf');
  });

  test('skips fully blank trailing rows', () {
    final bytes = _buildWorkbook(policyBulkUploadExpectedHeaders, [
      ['P-1', 'س-1', 'N', 'س', 'D', 'و', '23-04-2024', '', '50', ''],
      ['', '', '', '', '', '', '', '', '', ''],
    ]);

    final result = parsePolicyExcel(bytes) as PolicyExcelParseSuccess;

    expect(result.rows, hasLength(1));
  });

  test('reports a header mismatch when a column is missing', () {
    final wrongHeaders = List<String>.from(policyBulkUploadExpectedHeaders)
      ..removeLast();
    final bytes = _buildWorkbook(wrongHeaders, []);

    final result = parsePolicyExcel(bytes);

    expect(result, isA<PolicyExcelParseHeaderMismatch>());
  });

  test('reports empty when there are no data rows', () {
    final bytes = _buildWorkbook(policyBulkUploadExpectedHeaders, []);

    final result = parsePolicyExcel(bytes);

    expect(result, isA<PolicyExcelParseEmpty>());
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_excel_parser_test.dart`
Expected: FAIL — `policy_excel_parser.dart` does not exist yet.

- [ ] **Step 3: Write the implementation**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: Parses an uploaded Excel (.xlsx/.xls) workbook of policies
///              into raw [PolicyBulkRow] values. Validates the header row
///              against the fixed expected column list before reading any
///              data, mirroring the header-check approach already used by
///              lib/features/roles/user_management/ui/widgets/import_page_methods1.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: excel package, policy_bulk_date_format.dart

import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:excel/excel.dart' hide Border, BorderStyle;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_excel_parser.dart
/// Purpose: Contains PolicyBulkRow, PolicyExcelParseResult and its variants,
///          and parsePolicyExcel(), the entry point that turns uploaded
///          workbook bytes into rows ready for the editable preview table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// The sheet's header row must match this list exactly, in order.
const List<String> policyBulkUploadExpectedHeaders = [
  'Policy Number',
  'Policy Number Ar',
  'Policy Name',
  'اسم السياسة',
  'Policy Description',
  'وصف السياسة',
  'Start Date',
  'End Date',
  'Policy Weight',
  'Policy Document',
];

/// class name: [PolicyBulkRow]
///
/// purpose: one raw, unvalidated data row parsed from the uploaded sheet.
///          Every field is the cell's plain text — conversion to typed
///          values (DateTime, double) happens later in the editable table
///          (Task 3), not here.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkRow {
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyNameEn;
  final String policyNameAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final String startDate;
  final String endDate;
  final String policyWeight;
  final String policyDocument;

  const PolicyBulkRow({
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.policyDocument,
  });
}

/// class name: [PolicyExcelParseResult]
///
/// purpose: result of [parsePolicyExcel] — exactly one of a successful row
///          list, a header mismatch, or an empty file.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
sealed class PolicyExcelParseResult {}

class PolicyExcelParseSuccess extends PolicyExcelParseResult {
  final List<PolicyBulkRow> rows;
  PolicyExcelParseSuccess(this.rows);
}

class PolicyExcelParseHeaderMismatch extends PolicyExcelParseResult {
  final String message;
  PolicyExcelParseHeaderMismatch(this.message);
}

class PolicyExcelParseEmpty extends PolicyExcelParseResult {}

/// function name: [parsePolicyExcel]
///
/// purpose: decode an uploaded workbook's bytes, validate its header row
///          against [policyBulkUploadExpectedHeaders], and parse every
///          non-blank data row into a [PolicyBulkRow].
///
/// parameters:
///            [List<int>] bytes: the raw workbook file bytes
///
/// return type: [PolicyExcelParseResult] - success with rows, a header mismatch, or empty
PolicyExcelParseResult parsePolicyExcel(List<int> bytes) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) return PolicyExcelParseEmpty();

  for (final tableName in excel.tables.keys) {
    final sheet = excel.tables[tableName];
    if (sheet == null || sheet.rows.isEmpty) continue;

    final rows = sheet.rows;
    final actualHeaders = rows.first.map((cell) => _cellText(cell?.value)).toList();
    while (actualHeaders.isNotEmpty && actualHeaders.last.isEmpty) {
      actualHeaders.removeLast();
    }

    if (!_headersMatch(actualHeaders)) {
      return PolicyExcelParseHeaderMismatch(
        'Expected columns: ${policyBulkUploadExpectedHeaders.join(', ')}',
      );
    }

    final parsedRows = <PolicyBulkRow>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      String valueAt(String header) {
        final colIndex = policyBulkUploadExpectedHeaders.indexOf(header);
        if (colIndex >= row.length) return '';
        return _cellText(row[colIndex]?.value);
      }

      final parsed = PolicyBulkRow(
        policyNumberEn: valueAt('Policy Number'),
        policyNumberAr: valueAt('Policy Number Ar'),
        policyNameEn: valueAt('Policy Name'),
        policyNameAr: valueAt('اسم السياسة'),
        policyDescriptionEn: valueAt('Policy Description'),
        policyDescriptionAr: valueAt('وصف السياسة'),
        startDate: valueAt('Start Date'),
        endDate: valueAt('End Date'),
        policyWeight: valueAt('Policy Weight'),
        policyDocument: valueAt('Policy Document'),
      );

      final isBlankRow = [
        parsed.policyNumberEn,
        parsed.policyNumberAr,
        parsed.policyNameEn,
        parsed.policyNameAr,
        parsed.policyDescriptionEn,
        parsed.policyDescriptionAr,
        parsed.startDate,
        parsed.endDate,
        parsed.policyWeight,
        parsed.policyDocument,
      ].every((value) => value.isEmpty);
      if (isBlankRow) continue;

      parsedRows.add(parsed);
    }

    return parsedRows.isEmpty ? PolicyExcelParseEmpty() : PolicyExcelParseSuccess(parsedRows);
  }

  return PolicyExcelParseEmpty();
}

bool _headersMatch(List<String> actualHeaders) {
  if (actualHeaders.length != policyBulkUploadExpectedHeaders.length) return false;
  for (var i = 0; i < actualHeaders.length; i++) {
    if (actualHeaders[i].trim() != policyBulkUploadExpectedHeaders[i]) return false;
  }
  return true;
}

/// Extracts plain display text from any [CellValue], using the type-safe
/// accessors the excel package documents (e.g. TextCellValue.value.toPlainText())
/// rather than CellValue.toString(), which is not guaranteed to return
/// plain text for a TextSpan-backed TextCellValue.
String _cellText(CellValue? value) {
  return switch (value) {
    null => '',
    TextCellValue() => value.value.toPlainText().trim(),
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

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_excel_parser_test.dart`
Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart test/features/grc/policy_bulk_upload/policy_excel_parser_test.dart
git commit -m "feat(grc): add Excel parser for policy bulk upload"
```

---

### Task 3: Editable row form + per-row validation

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart`
- Test: `test/features/grc/policy_bulk_upload/policy_bulk_row_form_test.dart`

**Interfaces:**
- Consumes: `PolicyBulkRow` (Task 2), `parsePolicyBulkDate` (Task 1).
- Produces: `PolicyBulkRowForm` — one `TextEditingController` per field (`policyNumberEnController, policyNumberArController, policyNameEnController, policyNameArController, policyDescriptionEnController, policyDescriptionArController, startDateController, endDateController, policyWeightController, policyDocumentController`), `Map<String, FocusNode> focusNodes` (same keys as errors below), `GlobalKey key`, `Map<String, String> errors`, `Map<String, String> validate()`, `double get weightValue`, `void dispose()`. Error map keys: `policyNumberEn, policyNumberAr, policyNameEn, policyNameAr, policyDescriptionEn, policyDescriptionAr, startDate, endDate, policyWeight` — used by Task 4 (row collection) and Task 6 (preview page).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:flutter_test/flutter_test.dart';

PolicyBulkRow _validRawRow() => const PolicyBulkRow(
      policyNumberEn: 'P-1',
      policyNumberAr: 'س-1',
      policyNameEn: 'Access Policy',
      policyNameAr: 'سياسة الوصول',
      policyDescriptionEn: 'desc',
      policyDescriptionAr: 'وصف',
      startDate: '23-04-2024',
      endDate: '23-04-2025',
      policyWeight: '50',
      policyDocument: 'https://example.com/doc.pdf',
    );

void main() {
  test('a fully valid row has no errors', () {
    final row = PolicyBulkRowForm.fromParsedRow(_validRawRow());
    expect(row.validate(), isEmpty);
    row.dispose();
  });

  test('flags empty required fields', () {
    final row = PolicyBulkRowForm.fromParsedRow(_validRawRow());
    row.policyNameEnController.text = '';
    final errors = row.validate();
    expect(errors['policyNameEn'], isNotNull);
    row.dispose();
  });

  test('flags Start Date not before End Date', () {
    final row = PolicyBulkRowForm.fromParsedRow(_validRawRow());
    row.startDateController.text = '23-04-2025';
    row.endDateController.text = '23-04-2024';
    final errors = row.validate();
    expect(errors['startDate'], isNotNull);
    expect(errors['endDate'], isNotNull);
    row.dispose();
  });

  test('allows an empty End Date', () {
    final row = PolicyBulkRowForm.fromParsedRow(_validRawRow());
    row.endDateController.text = '';
    expect(row.validate(), isEmpty);
    row.dispose();
  });

  test('flags a non-positive Policy Weight', () {
    final row = PolicyBulkRowForm.fromParsedRow(_validRawRow());
    row.policyWeightController.text = '0';
    expect(row.validate()['policyWeight'], isNotNull);
    row.policyWeightController.text = 'abc';
    expect(row.validate()['policyWeight'], isNotNull);
    row.dispose();
  });

  test('weightValue parses the current Policy Weight text', () {
    final row = PolicyBulkRowForm.fromParsedRow(_validRawRow());
    expect(row.weightValue, 50);
    row.dispose();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_bulk_row_form_test.dart`
Expected: FAIL — `policy_bulk_row_form.dart` does not exist yet.

- [ ] **Step 3: Write the implementation**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: One editable row in the bulk upload preview table. Wraps a
///              TextEditingController per field (so the user can edit any
///              cell in place, mirroring the pattern already used by
///              lib/features/roles/user_management/ui/widgets/upload_build_page.dart),
///              plus the FocusNode/GlobalKey needed for the "jump to next
///              error" navigation and its own required-field / date-order /
///              weight validation.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter/material.dart, policy_excel_parser.dart, policy_bulk_date_format.dart

import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:flutter/material.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_row_form.dart
/// Purpose: Contains PolicyBulkRowForm, the editable-row view-model backing
///          one row of the bulk upload preview table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkRowForm]
///
/// purpose: hold the live-editable state of one bulk-upload policy row and
///          validate it against the same rules as the single-policy Add
///          Policy flow (required fields, Start < End Date, positive
///          Weight).
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkRowForm {
  PolicyBulkRowForm({
    String policyNumberEn = '',
    String policyNumberAr = '',
    String policyNameEn = '',
    String policyNameAr = '',
    String policyDescriptionEn = '',
    String policyDescriptionAr = '',
    String startDate = '',
    String endDate = '',
    String policyWeight = '',
    String policyDocument = '',
  })  : policyNumberEnController = TextEditingController(text: policyNumberEn),
        policyNumberArController = TextEditingController(text: policyNumberAr),
        policyNameEnController = TextEditingController(text: policyNameEn),
        policyNameArController = TextEditingController(text: policyNameAr),
        policyDescriptionEnController =
            TextEditingController(text: policyDescriptionEn),
        policyDescriptionArController =
            TextEditingController(text: policyDescriptionAr),
        startDateController = TextEditingController(text: startDate),
        endDateController = TextEditingController(text: endDate),
        policyWeightController = TextEditingController(text: policyWeight),
        policyDocumentController = TextEditingController(text: policyDocument);

  /// function name: [fromParsedRow]
  ///
  /// purpose: build an editable row pre-filled from a parsed sheet row.
  ///
  /// parameters:
  ///            [PolicyBulkRow] row: the raw parsed row from [parsePolicyExcel]
  ///
  /// return type: [PolicyBulkRowForm] - the editable row, not yet validated
  factory PolicyBulkRowForm.fromParsedRow(PolicyBulkRow row) => PolicyBulkRowForm(
        policyNumberEn: row.policyNumberEn,
        policyNumberAr: row.policyNumberAr,
        policyNameEn: row.policyNameEn,
        policyNameAr: row.policyNameAr,
        policyDescriptionEn: row.policyDescriptionEn,
        policyDescriptionAr: row.policyDescriptionAr,
        startDate: row.startDate,
        endDate: row.endDate,
        policyWeight: row.policyWeight,
        policyDocument: row.policyDocument,
      );

  final TextEditingController policyNumberEnController;
  final TextEditingController policyNumberArController;
  final TextEditingController policyNameEnController;
  final TextEditingController policyNameArController;
  final TextEditingController policyDescriptionEnController;
  final TextEditingController policyDescriptionArController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController policyWeightController;
  final TextEditingController policyDocumentController;

  /// Scroll target for the "jump to next error" navigation.
  final GlobalKey key = GlobalKey();

  /// One [FocusNode] per editable field, keyed the same as [errors].
  final Map<String, FocusNode> focusNodes = {
    'policyNumberEn': FocusNode(),
    'policyNumberAr': FocusNode(),
    'policyNameEn': FocusNode(),
    'policyNameAr': FocusNode(),
    'policyDescriptionEn': FocusNode(),
    'policyDescriptionAr': FocusNode(),
    'startDate': FocusNode(),
    'endDate': FocusNode(),
    'policyWeight': FocusNode(),
    'policyDocument': FocusNode(),
  };

  /// The result of the most recent [validate] call.
  Map<String, String> errors = {};

  /// function name: [validate]
  ///
  /// purpose: recompute [errors] from the controllers' current text:
  ///          required fields must be non-empty, Start Date must parse and
  ///          be strictly before End Date (when End Date is filled in), and
  ///          Policy Weight must parse as a number > 0. End Date and Policy
  ///          Document are optional.
  ///
  /// parameters: none
  ///
  /// return type: [Map<String, String>] - the recomputed [errors] map (field key -> message)
  Map<String, String> validate() {
    final next = <String, String>{};

    void requireField(String key, String value) {
      if (value.trim().isEmpty) next[key] = 'Required';
    }

    requireField('policyNumberEn', policyNumberEnController.text);
    requireField('policyNumberAr', policyNumberArController.text);
    requireField('policyNameEn', policyNameEnController.text);
    requireField('policyNameAr', policyNameArController.text);
    requireField('policyDescriptionEn', policyDescriptionEnController.text);
    requireField('policyDescriptionAr', policyDescriptionArController.text);
    requireField('startDate', startDateController.text);

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

    final weight = double.tryParse(policyWeightController.text.trim());
    if (weight == null || weight <= 0) {
      next['policyWeight'] = 'Must be a positive number';
    }

    errors = next;
    return errors;
  }

  /// The current Policy Weight as a number, or 0 if it doesn't parse.
  double get weightValue => double.tryParse(policyWeightController.text.trim()) ?? 0;

  /// function name: [dispose]
  ///
  /// purpose: release every controller and focus node owned by this row.
  ///          Must be called whenever a row is removed from the table or
  ///          the bulk upload page closes.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    policyNumberEnController.dispose();
    policyNumberArController.dispose();
    policyNameEnController.dispose();
    policyNameArController.dispose();
    policyDescriptionEnController.dispose();
    policyDescriptionArController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    policyWeightController.dispose();
    policyDocumentController.dispose();
    for (final node in focusNodes.values) {
      node.dispose();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_bulk_row_form_test.dart`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart test/features/grc/policy_bulk_upload/policy_bulk_row_form_test.dart
git commit -m "feat(grc): add editable row form and validation for policy bulk upload"
```

---

### Task 4: Row collection (selection, add/remove/duplicate, batch weight rule)

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart`
- Test: `test/features/grc/policy_bulk_upload/policy_bulk_upload_rows_test.dart`

**Interfaces:**
- Consumes: `PolicyBulkRow` (Task 2), `PolicyBulkRowForm` (Task 3).
- Produces: `PolicyBulkUploadRows` — `List<PolicyBulkRowForm> rows`, `Set<int> selectedRows`, `void toggleSelected(int index)`, `void addBlankRow()`, `bool removeSelected()`, `bool duplicateSelected()`, `void removeAt(int index)`, `double get totalWeight`, `bool get totalWeightValid`, `int get errorCount`, `List<(int, String)> get errorLocations`, `bool get isValid`, `void dispose()` — used by Task 5 (Cubit) and Task 6 (preview page).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:flutter_test/flutter_test.dart';

PolicyBulkRow _rawRow({String weight = '50'}) => PolicyBulkRow(
      policyNumberEn: 'P-1',
      policyNumberAr: 'س-1',
      policyNameEn: 'Access Policy',
      policyNameAr: 'سياسة الوصول',
      policyDescriptionEn: 'desc',
      policyDescriptionAr: 'وصف',
      startDate: '23-04-2024',
      endDate: '23-04-2025',
      policyWeight: weight,
      policyDocument: '',
    );

void main() {
  test('validates every row on construction', () {
    final rows = PolicyBulkUploadRows([_rawRow(weight: '0')]);
    expect(rows.errorCount, greaterThan(0));
    rows.dispose();
  });

  test('totalWeight sums Policy Weight across rows', () {
    final rows = PolicyBulkUploadRows([_rawRow(weight: '60'), _rawRow(weight: '40')]);
    expect(rows.totalWeight, 100);
    expect(rows.totalWeightValid, isTrue);
    rows.dispose();
  });

  test('totalWeightValid is false unless the sum is exactly 100', () {
    final rows = PolicyBulkUploadRows([_rawRow(weight: '60'), _rawRow(weight: '30')]);
    expect(rows.totalWeightValid, isFalse);
    rows.dispose();
  });

  test('addBlankRow appends an unvalidated-but-checked row', () {
    final rows = PolicyBulkUploadRows([_rawRow(weight: '100')]);
    rows.addBlankRow();
    expect(rows.rows, hasLength(2));
    expect(rows.rows.last.errors, isNotEmpty); // blank row fails required fields
    rows.dispose();
  });

  test('removeSelected removes only selected rows and clears selection', () {
    final rows = PolicyBulkUploadRows([_rawRow(), _rawRow(), _rawRow()]);
    rows.toggleSelected(0);
    rows.toggleSelected(2);
    final removed = rows.removeSelected();
    expect(removed, isTrue);
    expect(rows.rows, hasLength(1));
    expect(rows.selectedRows, isEmpty);
    rows.dispose();
  });

  test('removeSelected is a no-op when nothing is selected', () {
    final rows = PolicyBulkUploadRows([_rawRow()]);
    expect(rows.removeSelected(), isFalse);
    expect(rows.rows, hasLength(1));
    rows.dispose();
  });

  test('duplicateSelected copies field text into a new row', () {
    final rows = PolicyBulkUploadRows([_rawRow(weight: '50')]);
    rows.toggleSelected(0);
    final duplicated = rows.duplicateSelected();
    expect(duplicated, isTrue);
    expect(rows.rows, hasLength(2));
    expect(rows.rows[1].policyNameEnController.text, 'Access Policy');
    expect(rows.selectedRows, isEmpty);
    rows.dispose();
  });

  test('duplicateSelected is a no-op unless exactly one row is selected', () {
    final rows = PolicyBulkUploadRows([_rawRow(), _rawRow()]);
    expect(rows.duplicateSelected(), isFalse);
    rows.toggleSelected(0);
    rows.toggleSelected(1);
    expect(rows.duplicateSelected(), isFalse);
    expect(rows.rows, hasLength(2));
    rows.dispose();
  });

  test('isValid requires zero errors, totalWeightValid, and at least one row', () {
    final rows = PolicyBulkUploadRows([_rawRow(weight: '100')]);
    expect(rows.isValid, isTrue);
    rows.dispose();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_bulk_upload_rows_test.dart`
Expected: FAIL — `policy_bulk_upload_rows.dart` does not exist yet.

- [ ] **Step 3: Write the implementation**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: In-memory collection of the bulk upload preview table's
///              rows: row selection, add/remove/duplicate, and the derived
///              Total Weight / error-count / error-location values the
///              preview page and Cubit need. Deliberately has no dependency
///              on CreatePolicyUseCase or Firestore, so it can be unit
///              tested directly.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: policy_bulk_row_form.dart, policy_excel_parser.dart

import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_row_form.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_rows.dart
/// Purpose: Contains PolicyBulkUploadRows, the row-management model behind
///          the bulk upload preview table.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkUploadRows]
///
/// purpose: own the editable row list, row selection, and the batch-level
///          Total Weight rule (sum of every row's Policy Weight must equal
///          100) that gates the Activate action.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadRows {
  PolicyBulkUploadRows(List<PolicyBulkRow> parsedRows)
      : rows = parsedRows.map(PolicyBulkRowForm.fromParsedRow).toList() {
    for (final row in rows) {
      row.validate();
    }
  }

  final List<PolicyBulkRowForm> rows;
  final Set<int> selectedRows = {};

  /// function name: [toggleSelected]
  ///
  /// purpose: select [index] if unselected, or deselect it if already selected.
  ///
  /// parameters:
  ///            [int] index: index into [rows]
  ///
  /// return type: [void]
  void toggleSelected(int index) {
    if (!selectedRows.remove(index)) {
      selectedRows.add(index);
    }
  }

  /// function name: [addBlankRow]
  ///
  /// purpose: append one empty, freshly-validated row (the "+ Row" action).
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void addBlankRow() {
    final row = PolicyBulkRowForm();
    row.validate();
    rows.add(row);
  }

  /// function name: [removeSelected]
  ///
  /// purpose: remove every currently-selected row (the "Remove Selection"
  ///          action) and clear the selection. No-op if nothing is selected.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if any row was removed, false if the selection was empty
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

  /// function name: [duplicateSelected]
  ///
  /// purpose: append a copy of the single selected row (the "Duplication"
  ///          action) and clear the selection. No-op unless exactly one row
  ///          is selected.
  ///
  /// parameters: none
  ///
  /// return type: [bool] - true if a row was duplicated, false otherwise
  bool duplicateSelected() {
    if (selectedRows.length != 1) return false;
    final source = rows[selectedRows.first];
    final copy = PolicyBulkRowForm(
      policyNumberEn: source.policyNumberEnController.text,
      policyNumberAr: source.policyNumberArController.text,
      policyNameEn: source.policyNameEnController.text,
      policyNameAr: source.policyNameArController.text,
      policyDescriptionEn: source.policyDescriptionEnController.text,
      policyDescriptionAr: source.policyDescriptionArController.text,
      startDate: source.startDateController.text,
      endDate: source.endDateController.text,
      policyWeight: source.policyWeightController.text,
      policyDocument: source.policyDocumentController.text,
    );
    copy.validate();
    rows.add(copy);
    selectedRows.clear();
    return true;
  }

  /// function name: [removeAt]
  ///
  /// purpose: remove a single row by index (used after a successful bulk
  ///          create, to drop rows that don't need to be re-submitted).
  ///
  /// parameters:
  ///            [int] index: index into [rows]
  ///
  /// return type: [void]
  void removeAt(int index) {
    rows[index].dispose();
    rows.removeAt(index);
    selectedRows.remove(index);
  }

  /// Sum of every row's Policy Weight.
  double get totalWeight => rows.fold<double>(0, (sum, row) => sum + row.weightValue);

  /// The batch-level rule: the sum of every row's Policy Weight must be exactly 100.
  bool get totalWeightValid => totalWeight == 100;

  /// Total number of per-cell errors across every row.
  int get errorCount => rows.fold<int>(0, (sum, row) => sum + row.errors.length);

  /// Every (rowIndex, fieldKey) pair currently in error, in row/field order —
  /// used to drive the "Error: N" prev/next navigation.
  List<(int, String)> get errorLocations {
    final locations = <(int, String)>[];
    for (var i = 0; i < rows.length; i++) {
      for (final fieldKey in rows[i].errors.keys) {
        locations.add((i, fieldKey));
      }
    }
    return locations;
  }

  /// Whether Activate should be enabled: no per-cell errors, Total Weight is
  /// exactly 100, and there is at least one row.
  bool get isValid => errorCount == 0 && totalWeightValid && rows.isNotEmpty;

  /// function name: [dispose]
  ///
  /// purpose: dispose every row's controllers/focus nodes.
  ///
  /// parameters: none
  ///
  /// return type: [void]
  void dispose() {
    for (final row in rows) {
      row.dispose();
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/grc/policy_bulk_upload/policy_bulk_upload_rows_test.dart`
Expected: PASS (9 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart test/features/grc/policy_bulk_upload/policy_bulk_upload_rows_test.dart
git commit -m "feat(grc): add row collection model for policy bulk upload"
```

---

### Task 5: `PolicyBulkUploadCubit`

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart`
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_state.dart`

**Interfaces:**
- Consumes: `PolicyBulkUploadRows` (Task 4), `PolicyBulkRow` (Task 2), `parsePolicyBulkDate` (Task 1), `CreatePolicyUseCase`/`CreatePolicyParams` (existing, `lib/features/grc/domain/use_cases/create_policy_usecase.dart`), `PolicyStatus.active` (existing), `Constant`/`MainCoreEmployeeController` (existing, `lib/features/employee/presentation/controller/main_core_employee_controller.dart`).
- Produces: `PolicyBulkUploadCubit(createPolicyUseCase, parsedRows)` with `PolicyBulkUploadRows get rowsData`, `void toggleRowSelected(int)`, `void addRow()`, `void removeSelectedRows()`, `void duplicateSelectedRow()`, `void revalidateRow(int)`, `Future<void> submit({required String moduleId})`; sealed `PolicyBulkUploadState` with `PolicyBulkUploadEditing`, `PolicyBulkUploadSubmitting`, `PolicyBulkUploadSubmitResult(succeededCount, failed)`; `PolicyBulkRowFailure(reason)` — used by Task 6 and Task 7 (pages), Task 8 (entry point, only the constructor).

No automated test for this task: it calls the real `CreatePolicyUseCase`/Firestore in `submit()` and this repo has no mocking library (see Global Constraints); its row-management methods are thin one-line forwards to the already-tested `PolicyBulkUploadRows`, and `submit()` is covered by Task 8's manual click-through.

- [ ] **Step 1: Write the state file**

```dart
part of 'policy_bulk_upload_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_state.dart
/// Purpose: Contains all state classes emitted by [PolicyBulkUploadCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

sealed class PolicyBulkUploadState {}

/// State while the user is reviewing/editing rows (also emitted after
/// every row-management action, to trigger a table rebuild).
final class PolicyBulkUploadEditing extends PolicyBulkUploadState {}

/// State while [PolicyBulkUploadCubit.submit] is running.
final class PolicyBulkUploadSubmitting extends PolicyBulkUploadState {}

/// State emitted once [PolicyBulkUploadCubit.submit] finishes. Rows that
/// succeeded have already been removed from [PolicyBulkUploadCubit.rowsData];
/// [failed] is parallel, in order, to the rows that remain.
final class PolicyBulkUploadSubmitResult extends PolicyBulkUploadState {
  final int succeededCount;
  final List<PolicyBulkRowFailure> failed;

  PolicyBulkUploadSubmitResult({
    required this.succeededCount,
    required this.failed,
  });
}

/// One row's create-policy failure reason, in [PolicyBulkUploadSubmitResult.failed].
class PolicyBulkRowFailure {
  final String reason;
  const PolicyBulkRowFailure({required this.reason});
}
```

- [ ] **Step 2: Write the cubit**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: BLoC Cubit driving the bulk upload preview table: owns the
///              editable [PolicyBulkUploadRows], forwards row-management
///              actions to it, and on submit calls the existing
///              [CreatePolicyUseCase] once per row, best-effort (one row's
///              failure doesn't stop the rest).
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter_bloc, get, CreatePolicyUseCase, PolicyBulkUploadRows
library;

import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/features/grc/domain/entities/policy_status.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

part 'policy_bulk_upload_state.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_cubit.dart
/// Purpose: Contains PolicyBulkUploadCubit, the presentation-layer state
///          manager for the bulk upload preview table and its submit flow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkUploadCubit]
///
/// purpose: manage the bulk upload preview table's state and drive
///          best-effort creation of every valid row via [CreatePolicyUseCase].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadCubit extends Cubit<PolicyBulkUploadState> {
  PolicyBulkUploadCubit({
    required CreatePolicyUseCase createPolicyUseCase,
    required List<PolicyBulkRow> parsedRows,
  })  : _createUseCase = createPolicyUseCase,
        _rows = PolicyBulkUploadRows(parsedRows),
        super(PolicyBulkUploadEditing());

  final CreatePolicyUseCase _createUseCase;
  final PolicyBulkUploadRows _rows;

  /// The editable row collection backing the preview table.
  PolicyBulkUploadRows get rowsData => _rows;

  /// Resolves the currently logged-in user's id (same lookup as [PolicyCubit]).
  String get _currentUserId {
    final fromConstant = Constant.idUser;
    if (fromConstant != null && fromConstant.isNotEmpty) return fromConstant;
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final id = Get.find<MainCoreEmployeeController>().employeeEntity?.id;
      if (id != null && id.isNotEmpty) return id;
    }
    return '';
  }

  void toggleRowSelected(int index) {
    _rows.toggleSelected(index);
    emit(PolicyBulkUploadEditing());
  }

  void addRow() {
    _rows.addBlankRow();
    emit(PolicyBulkUploadEditing());
  }

  void removeSelectedRows() {
    _rows.removeSelected();
    emit(PolicyBulkUploadEditing());
  }

  void duplicateSelectedRow() {
    _rows.duplicateSelected();
    emit(PolicyBulkUploadEditing());
  }

  /// Re-runs validation for one row (called on every cell edit) and
  /// triggers a rebuild so the Error counter / Total Weight footer / row
  /// border stay in sync as the user types.
  void revalidateRow(int index) {
    _rows.rows[index].validate();
    emit(PolicyBulkUploadEditing());
  }

  /// function name: [submit]
  ///
  /// purpose: create every row as a real Policy via [CreatePolicyUseCase],
  ///          best-effort — one row's failure does not stop the others.
  ///          Rows that succeed are removed from [rowsData]; rows that fail
  ///          stay, in order, so [PolicyBulkUploadSubmitResult.failed] lines
  ///          up 1:1 with the remaining rows in [rowsData] afterward.
  ///
  /// parameters:
  ///            [String] moduleId: id of the parent GRC Module every row is created under
  ///
  /// return type: [Future<void>]
  Future<void> submit({required String moduleId}) async {
    emit(PolicyBulkUploadSubmitting());

    var succeededCount = 0;
    final failed = <PolicyBulkRowFailure>[];
    final indexesToRemove = <int>[];
    final editorId = _currentUserId;

    for (var i = 0; i < _rows.rows.length; i++) {
      final row = _rows.rows[i];
      final start = parsePolicyBulkDate(row.startDateController.text);
      final endText = row.endDateController.text.trim();
      final end = endText.isEmpty ? start : parsePolicyBulkDate(endText);
      final weight = double.tryParse(row.policyWeightController.text.trim());

      if (start == null || end == null || weight == null) {
        failed.add(const PolicyBulkRowFailure(reason: 'Invalid row data'));
        continue;
      }

      final document = row.policyDocumentController.text.trim();
      final result = await _createUseCase.call(
        CreatePolicyParams(
          policyNameEn: row.policyNameEnController.text.trim(),
          policyNameAr: row.policyNameArController.text.trim(),
          policyNumberEn: row.policyNumberEnController.text.trim(),
          policyNumberAr: row.policyNumberArController.text.trim(),
          policyDescriptionEn: row.policyDescriptionEnController.text.trim(),
          policyDescriptionAr: row.policyDescriptionArController.text.trim(),
          startDate: start,
          endDate: end,
          policyWeight: weight,
          editorId: editorId,
          moduleId: moduleId,
          controls: const [],
          status: PolicyStatus.active,
          policyDocumentUrl: document.isEmpty ? null : document,
        ),
      );

      result.fold(
        (failure) => failed.add(PolicyBulkRowFailure(reason: failure.message)),
        (_) {
          succeededCount++;
          indexesToRemove.add(i);
        },
      );
    }

    indexesToRemove.sort((a, b) => b.compareTo(a));
    for (final index in indexesToRemove) {
      _rows.removeAt(index);
    }

    emit(PolicyBulkUploadSubmitResult(succeededCount: succeededCount, failed: failed));
  }

  @override
  Future<void> close() {
    _rows.dispose();
    return super.close();
  }
}
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/grc/presentation/ui/pages/policy_bulk_upload/`
Expected: No errors (existing repo lint warnings elsewhere are not this task's concern).

- [ ] **Step 4: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_state.dart
git commit -m "feat(grc): add PolicyBulkUploadCubit"
```

---

### Task 6: Preview/table page

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_preview_page.dart`

**Interfaces:**
- Consumes: `PolicyBulkUploadCubit`/state (Task 5), `PolicyBulkRowForm` (Task 3, via `cubit.rowsData.rows`), `customButton` (existing, `lib/features/settings/core_widgets/main_widget/custom_button_widget.dart`), `PaginationAppBar` (existing, `lib/features/home/core_widgets/main_widget/pagination_app_bar.dart`), `AppColors`/`StyleText` (existing, `lib/core/theme/app_colors.dart` / `lib/core/theme/app_theme.dart`).
- Produces: `PolicyBulkUploadPreviewPage({required String moduleId})` — a widget expected to be built under an existing `BlocProvider<PolicyBulkUploadCubit>` — used by Task 7 (upload page navigates to it) and Task 8 (manual verification).

No automated test (page/widget code, matches this repo's existing convention of no widget tests — see Global Constraints); verified by `flutter analyze` here and by the full manual click-through in Task 8.

- [ ] **Step 1: Write the implementation**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: Editable preview table for the bulk upload flow. One row
///              per parsed policy, each field backed by a TextEditingController
///              so the user can fix flagged data before creating anything;
///              row selection drives Remove Selection / Duplication; the
///              footer enforces the Total Weight == 100 batch rule; Activate
///              is disabled until every row is valid and Total Weight is 100.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: flutter_bloc, PolicyBulkUploadCubit, PolicyBulkRowForm

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_rows.dart';
import 'package:demo_app/features/home/core_widgets/main_widget/pagination_app_bar.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_preview_page.dart
/// Purpose: Contains PolicyBulkUploadPreviewPage, the editable table screen
///          the user reviews/fixes/activates from.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

const List<_ColumnSpec> _columns = [
  _ColumnSpec('policyNumberEn', 'Policy Number', 110),
  _ColumnSpec('policyNumberAr', 'Policy Number Ar', 110),
  _ColumnSpec('policyNameEn', 'Policy Name', 150),
  _ColumnSpec('policyNameAr', 'اسم السياسة', 150),
  _ColumnSpec('policyDescriptionEn', 'Policy Description', 180),
  _ColumnSpec('policyDescriptionAr', 'وصف السياسة', 180),
  _ColumnSpec('startDate', 'Start Date', 110),
  _ColumnSpec('endDate', 'End Date', 110),
  _ColumnSpec('policyWeight', 'Policy Weight', 100),
  _ColumnSpec('policyDocument', 'Policy Document', 160),
];

class _ColumnSpec {
  final String fieldKey;
  final String label;
  final double width;
  const _ColumnSpec(this.fieldKey, this.label, this.width);
}

/// class name: [PolicyBulkUploadPreviewPage]
///
/// purpose: render the bulk upload's editable table (mockup: "Policy Bulk
///          Upload Preview") for a [PolicyBulkUploadCubit] already provided
///          above it in the widget tree.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadPreviewPage extends StatefulWidget {
  final String moduleId;

  const PolicyBulkUploadPreviewPage({super.key, required this.moduleId});

  @override
  State<PolicyBulkUploadPreviewPage> createState() =>
      _PolicyBulkUploadPreviewPageState();
}

class _PolicyBulkUploadPreviewPageState
    extends State<PolicyBulkUploadPreviewPage> {
  int _currentErrorIndex = -1;

  void _jumpToError(bool next, PolicyBulkUploadRows rowsData) {
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

  Future<void> _onActivate(PolicyBulkUploadCubit cubit) async {
    if (!cubit.rowsData.isValid) {
      _jumpToError(true, cubit.rowsData);
      return;
    }
    await cubit.submit(moduleId: widget.moduleId);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PolicyBulkUploadCubit>();

    return BlocConsumer<PolicyBulkUploadCubit, PolicyBulkUploadState>(
      listener: (context, state) {
        if (state is PolicyBulkUploadSubmitResult) {
          if (state.succeededCount > 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.succeededCount} ${'polic(y/ies) created'.tr}',
                ),
              ),
            );
          }
          if (state.failed.isEmpty) {
            Navigator.pop(context);
          }
        }
      },
      builder: (context, state) {
        final submitting = state is PolicyBulkUploadSubmitting;
        final rowsData = cubit.rowsData;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PaginationAppBar(
                    screensTitles: ['GRC'.tr, 'Policy Bulk Upload Preview'.tr],
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildTotalWeight(rowsData),
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
                        color: submitting ? AppColors.secondaryText : AppColors.primary,
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
    PolicyBulkUploadCubit cubit,
    PolicyBulkUploadRows rowsData,
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
      ],
    );
  }

  Widget _buildRow(
    PolicyBulkUploadCubit cubit,
    PolicyBulkUploadRows rowsData,
    int index,
  ) {
    final row = rowsData.rows[index];
    final controllers = <String, TextEditingController>{
      'policyNumberEn': row.policyNumberEnController,
      'policyNumberAr': row.policyNumberArController,
      'policyNameEn': row.policyNameEnController,
      'policyNameAr': row.policyNameArController,
      'policyDescriptionEn': row.policyDescriptionEnController,
      'policyDescriptionAr': row.policyDescriptionArController,
      'startDate': row.startDateController,
      'endDate': row.endDateController,
      'policyWeight': row.policyWeightController,
      'policyDocument': row.policyDocumentController,
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

  Widget _buildTotalWeight(PolicyBulkUploadRows rowsData) {
    final valid = rowsData.totalWeightValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: valid ? AppColors.green : AppColors.red),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            '${'Total Weight'.tr} : ${rowsData.totalWeight.toStringAsFixed(0)}',
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
          ),
        ),
        if (!valid) ...[
          SizedBox(height: 4.h),
          Text(
            'Total Weight should be 100'.tr,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
          ),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/grc/presentation/ui/pages/policy_bulk_upload/`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_preview_page.dart
git commit -m "feat(grc): add policy bulk upload preview/table page"
```

---

### Task 7: Upload (drag & drop) page

**Files:**
- Create: `lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_page.dart`

**Interfaces:**
- Consumes: `parsePolicyExcel`/`PolicyExcelParseResult` (Task 2), `PolicyBulkUploadCubit` (Task 5), `PolicyBulkUploadPreviewPage` (Task 6), `CreatePolicyUseCase` (existing, resolved via `GetIt.instance`), `navigateTo` (existing, `lib/core/custom/37-custom_navigate.dart`).
- Produces: `PolicyBulkUploadPage({required String moduleId})` — used by Task 8 (entry-point menu).

No automated test (page/widget code, matches this repo's existing convention — see Global Constraints); verified by `flutter analyze` here and by the full manual click-through in Task 8.

- [ ] **Step 1: Write the implementation**

```dart
/// Module: GRC Policy Bulk Upload
/// Description: The "Policy Bulk Upload" drag & drop / browse screen.
///              Parses the selected workbook via parsePolicyExcel() and, on
///              success, opens the editable preview table under a fresh
///              PolicyBulkUploadCubit; on a header mismatch or empty file
///              it shows an inline error instead of navigating.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: desktop_drop, file_picker, PolicyBulkUploadCubit, policy_excel_parser.dart

import 'dart:io';

import 'package:demo_app/core/custom/37-custom_navigate.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/domain/use_cases/create_policy_usecase.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_cubit.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_preview_page.dart';
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_excel_parser.dart';
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

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_upload_page.dart
/// Purpose: Contains PolicyBulkUploadPage, the drag & drop / browse entry
///          screen for the Policy Bulk Upload flow.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

/// class name: [PolicyBulkUploadPage]
///
/// purpose: let the user pick or drop an Excel workbook of policies, parse
///          it, and open the editable preview table on success.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 11/7/2026
class PolicyBulkUploadPage extends StatefulWidget {
  final String moduleId;

  const PolicyBulkUploadPage({super.key, required this.moduleId});

  @override
  State<PolicyBulkUploadPage> createState() => _PolicyBulkUploadPageState();
}

class _PolicyBulkUploadPageState extends State<PolicyBulkUploadPage> {
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

    final result = parsePolicyExcel(bytes);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    switch (result) {
      case PolicyExcelParseSuccess(:final rows):
        navigateTo(
          context,
          BlocProvider<PolicyBulkUploadCubit>(
            create: (_) => PolicyBulkUploadCubit(
              createPolicyUseCase: GetIt.instance<CreatePolicyUseCase>(),
              parsedRows: rows,
            ),
            child: PolicyBulkUploadPreviewPage(moduleId: widget.moduleId),
          ),
        );
      case PolicyExcelParseHeaderMismatch(:final message):
        setState(() => _errorMessage = message);
      case PolicyExcelParseEmpty():
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
                screensTitles: ['GRC'.tr, 'Policy Bulk Upload'.tr],
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

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/features/grc/presentation/ui/pages/policy_bulk_upload/`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_page.dart
git commit -m "feat(grc): add policy bulk upload drag-and-drop page"
```

---

### Task 8: Wire the "Add Policy / Bulk Upload" menu into `GrcModuleDetailsPage`

**Files:**
- Modify: `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart:318-334` (tablet "Policy" button) and `:351-369` (mobile "Policy" button)

**Interfaces:**
- Consumes: `PolicyBulkUploadPage` (Task 7).

- [ ] **Step 1: Add the import**

In `lib/features/grc/presentation/ui/pages/grc_module_details_page.dart`, add this import alongside the existing `create_new_policy.dart` import (currently line 35):

```dart
import 'package:demo_app/features/grc/presentation/ui/pages/policy_bulk_upload/policy_bulk_upload_page.dart';
```

- [ ] **Step 2: Add the menu key and menu method**

In `_GrcModuleDetailsBodyState` (the class already holding `_searchController`, `_searchQuery`, etc.), add:

```dart
final GlobalKey _addPolicyButtonKey = GlobalKey();

Future<void> _showPolicyCreationMenu(BuildContext context) async {
  final buttonBox =
      _addPolicyButtonKey.currentContext?.findRenderObject() as RenderBox?;
  if (buttonBox == null) return;
  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      buttonBox.localToGlobal(Offset(0, buttonBox.size.height), ancestor: overlayBox),
      buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero), ancestor: overlayBox),
    ),
    Offset.zero & overlayBox.size,
  );

  final choice = await showMenu<String>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(value: 'add', child: Text('Add Policy'.tr)),
      PopupMenuItem(value: 'bulk', child: Text('Bulk Upload'.tr)),
    ],
  );

  if (!context.mounted) return;
  if (choice == 'add') {
    navigateTo(context, CreateNewPolicyPage(moduleId: widget.module.id));
  } else if (choice == 'bulk') {
    navigateTo(context, PolicyBulkUploadPage(moduleId: widget.module.id));
  }
}
```

- [ ] **Step 3: Wire the tablet "Policy" button (currently lines 318-334)**

Replace:

```dart
              customButtonWithSvg(
                colorBorder: AppColors.primary,
                space: 10.w,
                widthImage: 16.w,
                heightImage: 16.h,
                function: () => navigateTo(
                  context,
                  CreateNewPolicyPage(moduleId: widget.module.id),
                ),
                title: 'Policy',
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
                image:
                    'assets/icons_assets/database_builder_assets/plus_head.svg',
                color: AppColors.primary,
                svgColor: AppColors.textButton,
              ),
```

with:

```dart
              Container(
                key: _addPolicyButtonKey,
                child: customButtonWithSvg(
                  colorBorder: AppColors.primary,
                  space: 10.w,
                  widthImage: 16.w,
                  heightImage: 16.h,
                  function: () => _showPolicyCreationMenu(context),
                  title: 'Policy',
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  image:
                      'assets/icons_assets/database_builder_assets/plus_head.svg',
                  color: AppColors.primary,
                  svgColor: AppColors.textButton,
                ),
              ),
```

- [ ] **Step 4: Wire the mobile "Policy" button (currently lines 351-369)**

Replace:

```dart
              customButtonWithSvg(
                colorBorder: AppColors.primary,
                space: 10.w,
                radius: 8.r,
                widthImage: 16.w,
                heightImage: 16.h,
                function: () => navigateTo(
                  context,
                  CreateNewPolicyPage(moduleId: widget.module.id),
                ),
                title: 'Policy',
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
                image: 'assets/icons/add.svg',
                color: AppColors.primary,
                width: double.infinity,
                height: 36.h,
                svgColor: AppColors.textButton,
              ),
```

with:

```dart
              Container(
                key: _addPolicyButtonKey,
                child: customButtonWithSvg(
                  colorBorder: AppColors.primary,
                  space: 10.w,
                  radius: 8.r,
                  widthImage: 16.w,
                  heightImage: 16.h,
                  function: () => _showPolicyCreationMenu(context),
                  title: 'Policy',
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  image: 'assets/icons/add.svg',
                  color: AppColors.primary,
                  width: double.infinity,
                  height: 36.h,
                  svgColor: AppColors.textButton,
                ),
              ),
```

- [ ] **Step 5: Verify it compiles**

Run: `flutter analyze lib/features/grc/`
Expected: No errors.

- [ ] **Step 6: Run the full automated suite**

Run: `flutter test test/features/grc/`
Expected: PASS (all bulk-upload unit tests from Tasks 1-4, plus the existing `policy_model_nested_array_test.dart`).

- [ ] **Step 7: Manual end-to-end verification**

1. Run the app, open a GRC Module's details page, tap the "Policy" button — confirm the "Add Policy" / "Bulk Upload" menu appears anchored under the button.
2. Tap "Add Policy" — confirm it still opens `CreateNewPolicyPage` exactly as before (no regression).
3. Go back, tap "Policy" → "Bulk Upload" — confirm `PolicyBulkUploadPage` opens.
4. Prepare a small `.xlsx` with the header row `Policy Number, Policy Number Ar, Policy Name, اسم السياسة, Policy Description, وصف السياسة, Start Date, End Date, Policy Weight, Policy Document` and 2 data rows whose Policy Weight values sum to 100 (e.g. 60 and 40), dates in `dd-MM-yyyy`.
5. Browse/drop that file — confirm it navigates to `PolicyBulkUploadPreviewPage` with 2 editable rows, footer shows `Total Weight : 100` with a green border, no error badges, and Activate is enabled.
6. Edit one row's Policy Name to blank — confirm a red border/error icon appears on that cell, the "Error" counter shows `1/1`, and clicking Activate jumps focus to that cell instead of submitting. Restore the value.
7. Change one row's weight so the sum isn't 100 — confirm the footer turns red with "Total Weight should be 100" and Activate is blocked; restore it.
8. Click Activate — confirm a loading state appears, then a snackbar reports "2 polic(y/ies) created" and the page pops back to the module details page, whose policy list/counts now include the 2 new policies.
9. In Firestore, confirm both new documents live under `GRC Modules/{moduleId}/Policies/{policyId}` with `Status: Active`, `Controls: []`, and the correct field values.
10. Repeat the upload with a workbook missing one expected header column — confirm `PolicyBulkUploadPage` shows an inline error and does not navigate.
11. Repeat with a workbook whose Policy Document column contains a URL — confirm the created policy's document field stores that URL directly (no Storage upload/spinner for that field).

- [ ] **Step 8: Commit**

```bash
git add lib/features/grc/presentation/ui/pages/grc_module_details_page.dart
git commit -m "feat(grc): wire Add Policy / Bulk Upload menu into module details page"
```

---

## Self-Review Notes

- **Spec coverage:** entry-point menu (Task 8), header validation (Task 2), editable table with required/date-order/weight validation (Task 3), row selection + Remove Selection/Duplication/+Row (Task 4), error-nav counter (Task 6), Total Weight == 100 batch rule (Task 4/6), best-effort submit via existing `CreatePolicyUseCase` with `controls: []`/`status: active`/`policyDocumentUrl` (Task 5), post-submit UI reaction (Task 6) — all covered.
- **Placeholder scan:** no TBD/TODO; every step has complete, concrete code.
- **Type consistency:** field-key strings (`policyNumberEn`, `policyNumberAr`, `policyNameEn`, `policyNameAr`, `policyDescriptionEn`, `policyDescriptionAr`, `startDate`, `endDate`, `policyWeight`, `policyDocument`) are identical across `PolicyBulkRow` (Task 2), `PolicyBulkRowForm.errors`/`focusNodes` (Task 3), `PolicyBulkUploadRows.errorLocations` (Task 4), and the preview page's `_columns`/`controllers` map (Task 6). `PolicyBulkUploadCubit.rowsData` (Task 5) is the single accessor every page uses to reach `PolicyBulkUploadRows`.
