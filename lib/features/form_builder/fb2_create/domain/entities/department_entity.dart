/// Module: form_builder_module/f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: department_entity.dart
/// Description: `DepartmentEntity` data model.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
library;

/// A department the form is shared with.
class DepartmentEntity {
  final String name, nameAr, id;

  DepartmentEntity({
    required this.name,
    required this.nameAr,
    required this.id,
  });

  /// Method Name: [displayName]
  ///
  /// Purpose: the name in the UI language; the Arabic name falls back to
  /// the English one when it is missing.
  ///
  /// Parameters:
  /// - [arabic]: whether the UI is Arabic (passed in, so the domain does
  ///   not read the locale — Home rule 2).
  ///
  /// Returns: the name to show.
  String displayName({required bool arabic}) =>
      arabic && nameAr.isNotEmpty ? nameAr : name;
}
