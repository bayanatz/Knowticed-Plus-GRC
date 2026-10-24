/// Module: database / db3_create_table / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: table_import_error.dart
/// Description: Declares `TableImportError`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Why an import file was refused (DB-TABLE-04). A key, not text: the dialog
/// turns it into a translated message, so no raw package error ever reaches
/// the user.
library;

enum TableImportError {
  /// The file has no rows at all.
  noRows,

  /// The first row has no headings.
  noHeadings,

  /// The file could not be read: corrupt, or not really .csv / .xlsx.
  unreadable,
}
