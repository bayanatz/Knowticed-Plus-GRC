/// Module: database / db1_create_database / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: database_access_type.dart
/// Description: Declares `DatabaseAccessType`.
/// Author: Amr Mesbah
/// Created at: 15/8/2026
///
/// The three access levels the "Access Management" dropdown offers on the
/// Create New Database screen (Figma 7398:6180 / 7398:6265).
///
/// Domain layer: no Flutter imports, no colours. The labels live here because
/// they are the enum's own vocabulary, not presentation styling — the page
/// picks one by locale.
library;

enum DatabaseAccessType {
  /// Opened to whole DEPARTMENTS — the wizard's By Department step is where
  /// they are chosen, and a database of this type always carries at least one
  /// grant.
  open,

  /// Visible only to the individual employees granted access — chosen on the
  /// Add Members step.
  restricted,

  /// The creator's own database. Nobody else is granted access, so the wizard
  /// creates it straight from the details card with no access step and no
  /// grants.
  personal;

  /// Value written to / read from Firestore. Kept independent of the enum's
  /// Dart name so renaming the enum never silently orphans existing records.
  String get storageKey {
    switch (this) {
      case DatabaseAccessType.open:
        return 'open_access';
      case DatabaseAccessType.restricted:
        return 'restricted_access';
      case DatabaseAccessType.personal:
        return 'personal_access';
    }
  }

  /// Parses a stored value back to the enum, defaulting to [restricted] —
  /// the value the Figma screen shows pre-selected, and the safe fallback for
  /// an unknown/corrupt record (least exposure, not most).
  static DatabaseAccessType fromStorageKey(String? key) {
    return DatabaseAccessType.values.firstWhere(
      (DatabaseAccessType type) => type.storageKey == key,
      orElse: () => DatabaseAccessType.restricted,
    );
  }
}
