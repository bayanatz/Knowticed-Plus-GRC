/// Module: database / db3_create_table / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_limits.dart
/// Description: Declares `CreateTableLimits`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The limits on a table's columns, rows, headings and cells.
library;

/// Hard limits enforced by both the cubit and the fields.
abstract final class CreateTableLimits {
  /// A table has to have at least one column to be a table.
  static const int minColumns = 1;

  /// Ceiling on "Enter Column Number".
  ///
  /// Not a Firestore limit — it is a rendering one. Each column draws an 84pt
  /// block with two live fields in it, so a mistyped `500` would build a
  /// thousand controllers and a 42 000pt scroll view before anyone could
  /// correct the typo. 50 is far past any table the Figma shows (4) and still
  /// bounded.
  static const int maxColumns = 50;

  static const int minRows = 0;

  /// Ceiling on "Enter Row Number". The rows are not rendered by this screen —
  /// they belong to the Form Builder — so this only has to stop a number that
  /// could not be a real table.
  static const int maxRows = 5000;

  /// Character ceiling on one column heading.
  static const int columnNameMaxLength = 60;

  /// Character ceiling on one CELL of table data (Figma 7398:3042).
  ///
  /// Larger than [columnNameMaxLength] because a heading names a thing and a
  /// cell holds one — a Point of contact cell in the Preview (7398:15210)
  /// carries a full name, and the box it is typed into is 250 wide, not 60
  /// characters wide. Still bounded: a cell is one value, and a paragraph in
  /// one means the column is the wrong shape.
  static const int cellMaxLength = 200;
}
