/// Module: database / db1_create_database / domain / base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_session_base_repository.dart
/// Description: Declares `DatabaseSessionBaseRepository`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Who is signed in, for every record the Database module stamps with a
/// person: `created_by` on databases and tables, `granted_by` on access
/// grants, and the author of a table comment (DB-CREATE-02, DB-TABLE-02).
///
/// Injected into the cubits that write those records instead of being passed
/// down page by page as an optional `String?`. A missing argument used to
/// save an empty value silently; a missing session does not compile.
library;

/// The signed-in employee, as the Database module needs it.
abstract interface class DatabaseSessionBaseRepository {
  /// Function Name: [signedInEmployeeId]
  ///
  /// Purpose: The signed-in employee's id, read at the moment it is used.
  ///
  /// Returns: [String?] the id, or null when nobody is signed in yet.
  String? get signedInEmployeeId;
}
