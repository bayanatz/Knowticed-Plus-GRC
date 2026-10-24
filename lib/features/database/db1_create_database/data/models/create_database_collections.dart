/// Module: database / db1_create_database / data / models
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_collections.dart
/// Description: Declares `CreateDatabaseCollections`.
/// Author: Amr Mesbah
/// Created at: 24/10/2026
///
/// The Firestore and Storage paths the database records are written to.
/// Only the data layer reads them.
library;

/// Firestore location for the created records. Kept in the module rather than
/// `core/constants/firebase_collections.dart` so the core file stays the
/// shared vocabulary and this module owns its own storage.
abstract final class CreateDatabaseCollections {
  /// Records collection, RELATIVE TO THE TENANT ROOT.
  ///
  /// This was the top-level collection `Databases`, which put
  /// every company's databases in one global bucket. It now lives under the
  /// tenant, the same shape the services module uses
  /// (`Modules/services/CreateServices`):
  ///
  ///     Demo/{companyId}/Modules/database_builder/Databases/{recordId}
  ///
  /// The path stays RELATIVE here on purpose. `getBaseUrl` prepends
  /// `Demo/{companyId}` from `ApiConstants.baseUri`, which is set at login —
  /// so the tenant is resolved by the data source, and this constant never
  /// has to know about a company id.
  ///
  /// Note `Demo/{companyId}/Modules/database_builder` is a DOCUMENT, and it does not
  /// need to exist for the collection beneath it to work — Firestore is happy
  /// with a missing parent doc. It will show greyed-out in the console.
  static const String databases = 'Modules/database_builder/Databases';

  /// Subcollection under a database document holding its access grants.
  /// Nested under a document, so this one is NOT tenant-prefixed.
  static const String accessGrants = 'Access_Grants';

  /// Cloud STORAGE folder for cover images, also relative to the tenant root:
  /// `Demo/{companyId}/Modules/database_builder/covers/{timestamp}.{ext}`.
  ///
  /// Moved with the collection so one company's uploads are not mixed into
  /// another's. Already-uploaded covers keep working — records store the
  /// download URL, not the path.
  static const String coversFolder = 'Modules/database_builder/covers';

  /// One small document per lower-cased title, claimed in the same
  /// transaction as the save, so two databases cannot share a title
  /// (DB-CREATE-11).
  static const String titleIndex = 'Modules/database_builder/Database_Titles';
}
