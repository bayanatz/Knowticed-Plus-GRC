/// Module: GRC Policy Bulk Upload
/// Description: Parses an uploaded Excel (.xlsx/.xls) workbook of policies
///              into raw [PolicyBulkRow] values. Validates the header row
///              against the fixed expected column list before reading any
///              data, mirroring the header-check approach already used by
///              lib/features/roles/user_management/ui/widgets/import_page_methods1.dart.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11
/// Dependencies: excel package, policy_bulk_date_format.dart

import 'package:grc_module/features/grc/policy/presentation/ui/pages/policy_bulk_upload/policy_bulk_date_format.dart';
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

/// Extracts plain display text from any [CellValue]. The excel package's
/// TextCellValue.value is its own lightweight TextSpan (text + children +
/// style, defined in package:excel, unrelated to Flutter's TextSpan) whose
/// toString() already flattens text and children into plain text.
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
