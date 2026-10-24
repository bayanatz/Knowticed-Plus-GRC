/// Module: services / sv4_bulk_upload_services / data
///
///*************************** FILE INFO ****************************///
/// File Name: service_excel_reader.dart
/// Purpose: Reads the bulk-upload Excel file into plain rows (rules C1/C8:
///          the decoding and its try/catch blocks moved out of the
///          UploadFile page). Cell validation stays with the page because
///          its messages are translated.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

import 'package:excel/excel.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';

/// Class Name: [ServiceExcelReadResult]
///
/// Purpose: What came out of reading the file.
sealed class ServiceExcelReadResult {
  const ServiceExcelReadResult();
}

/// The bytes are not a readable Excel workbook.
class ServiceExcelInvalidFile extends ServiceExcelReadResult {
  const ServiceExcelInvalidFile();
}

/// The workbook has no worksheets.
class ServiceExcelNoWorksheets extends ServiceExcelReadResult {
  const ServiceExcelNoWorksheets();
}

/// No worksheet has a header row followed by at least one data row.
class ServiceExcelNoValidData extends ServiceExcelReadResult {
  const ServiceExcelNoValidData();
}

/// Too many expected columns are missing, so the sheet is rejected.
class ServiceExcelTooManyMissingHeaders extends ServiceExcelReadResult {
  final List<String> missingHeaders;

  /// Columns the sheet has that the template does not.
  final List<String> unknownHeaders;

  const ServiceExcelTooManyMissingHeaders(
    this.missingHeaders, {
    this.unknownHeaders = const [],
  });
}

/// The sheet was read.
class ServiceExcelRows extends ServiceExcelReadResult {
  /// One map per data row, keyed by expected header; a `null` value is a
  /// column the row's sheet does not have. A `null` row could not be read;
  /// the page shows it as invalid instead of dropping it.
  final List<Map<String, String?>?> rows;

  /// Expected columns the sheet does not have (fewer than three).
  final List<String> missingHeaders;

  const ServiceExcelRows({required this.rows, required this.missingHeaders});
}

/// Class Name: [ServiceExcelReader]
///
/// Purpose: Turns the uploaded bytes into [ServiceExcelReadResult].
class ServiceExcelReader {
  const ServiceExcelReader();

  /// Function Name: [read]
  ///
  /// Purpose: Decodes [bytes] and reads the worksheets that have a header
  /// row and data, keyed by [expectedHeaders].
  ///
  /// Parameters:
  /// - [bytes]: the file content.
  /// - [expectedHeaders]: the column names the template uses.
  /// - [maxMissing]: how many missing columns reject the sheet.
  /// - [allSheets]: read every sheet (rows are added up) instead of only the
  ///   first one with data.
  ///
  /// Returns: the read result; never throws.
  ServiceExcelReadResult read(
    List<int> bytes,
    List<String> expectedHeaders, {
    int maxMissing = 3,
    bool allSheets = false,
  }) {
    final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (e, st) {
      svcLog('Excel decode failed', error: e, stackTrace: st);
      return const ServiceExcelInvalidFile();
    }
    if (excel.tables.isEmpty) return const ServiceExcelNoWorksheets();

    final parsed = <Map<String, String?>?>[];
    final missingAll = <String>{};
    var found = false;
    for (final sheet in excel.tables.values) {
      final rows = sheet.rows;
      if (rows.length < 2) continue;

      // Blank header cells are kept so positions still match the data rows
      // (bug report p36).
      final actualHeaders = rows[0].map(_cellText).toList();
      if (actualHeaders.every((h) => h.isEmpty)) continue;

      final missing =
          expectedHeaders.where((h) => !actualHeaders.contains(h)).toList();
      if (missing.length >= maxMissing) {
        return ServiceExcelTooManyMissingHeaders(
          missing,
          unknownHeaders: actualHeaders
              .where((h) => h.isNotEmpty && !expectedHeaders.contains(h))
              .toList(),
        );
      }
      missingAll.addAll(missing);
      found = true;

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;
        try {
          parsed.add({
            for (final header in expectedHeaders)
              header: actualHeaders.contains(header)
                  ? _valueAt(row, actualHeaders.indexOf(header))
                  : null,
          });
        } catch (e) {
          svcLog('Excel row ${i + 1} could not be read: $e');
          parsed.add(null);
        }
      }
      if (!allSheets) break;
    }
    if (!found) return const ServiceExcelNoValidData();
    return ServiceExcelRows(rows: parsed, missingHeaders: missingAll.toList());
  }

  String _valueAt(List<Data?> row, int index) {
    if (index < 0 || index >= row.length) return '';
    return _cellText(row[index]);
  }

  String _cellText(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';
    return value.toString().trim();
  }
}
