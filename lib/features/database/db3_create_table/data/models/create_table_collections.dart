/// Module: database / db3_create_table / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_collections.dart
/// Description: Declares `CreateTableCollections`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The Firestore subcollection names under a database document. Only the
/// data layer reads them.
library;

/// Where a table document lives.
///
/// The parent path is db1's; this module only names the subcollection under it:
///
///     Demo/{companyId}/Modules/Database/Databases/{databaseId}/Tables/{tableId}
///
/// Nested under a document, so — like `CreateDatabaseCollections.accessGrants` —
/// this one is NOT tenant-prefixed. The tenant is already resolved by the
/// parent's path.
abstract final class CreateTableCollections {
  static const String tables = 'Tables';

  /// One table's comment thread (Figma 7398:8232):
  ///
  ///     …/Databases/{databaseId}/Tables/{tableId}/Comments/{commentId}
  ///
  /// Nested one level further than [tables] and, for the same reason, not
  /// tenant-prefixed.
  static const String comments = 'Comments';

  /// One table's own data (Figma 7398:3042 / 15076):
  ///
  ///     …/Databases/{databaseId}/Tables/{tableId}/Rows/{rowId}
  ///
  /// A subcollection and not an array on the table document — see
  /// `TableDataRowModel` for why the columns went the other way.
  static const String rows = 'Rows';
}
