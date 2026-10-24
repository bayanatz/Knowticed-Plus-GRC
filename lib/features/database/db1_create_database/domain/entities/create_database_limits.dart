/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_limits.dart
/// Description: Declares `CreateDatabaseLimits`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The length limits on a database's titles and descriptions. The table
/// names in db3 use the same limits, so both stay in step.
library;

/// Hard limits enforced by both the cubit and the text fields.
abstract final class CreateDatabaseLimits {
  /// Character ceiling on either description field — the "0/500" counter in
  /// the Figma card (7398:6196 / 7398:6197).
  static const int descriptionMaxLength = 500;

  /// Character ceiling on either title field.
  static const int titleMaxLength = 100;

  /// A title shorter than this is rejected as accidental.
  static const int titleMinLength = 2;
}
