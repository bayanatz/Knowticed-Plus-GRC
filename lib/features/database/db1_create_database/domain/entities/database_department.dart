/// Module: database / db1_create_database / domain / entities
///
///*************************** FILE INFO ****************************///
/// File Name: database_department.dart
/// Description: Declares `DatabaseDepartment`.
/// Author: Amr Mesbah
/// Created at: 16/10/2026
///
/// Moved out of `create_database_state.dart` (rule 1): the directory
/// repository in the data layer builds these, and data must not import
/// presentation.
library;

import 'package:knowticed_plus/core/helper/format_title.dart';

/// A department, reduced to what the chips and dropdowns need.
///
/// Same reasoning as `DatabaseMember`: `DepartmentModelPro` carries a
/// Firestore `Timestamp` and an `addedBy` audit field, neither of which the
/// presentation layer should be handling.
class DatabaseDepartment {
  const DatabaseDepartment({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final String id;
  final String nameEn;
  final String nameAr;

  /// Function Name: [localizedName]
  ///
  /// Purpose: The department's display name, title-cased through
  /// `FormatHelper`.
  ///
  /// CAPITALIZED HERE, NOT AT EVERY CALL SITE. The directory
  /// stores what was typed into it — "customer support", "human resources" —
  /// and this one method feeds every department label in the module. Wrapping
  /// the dozen call sites instead would mean the thirteenth is lower case.
  /// `FormatHelper.capitalize` also fixes acronyms — "hr" becomes "HR".
  /// Arabic passes through unchanged: it has no letter case.
  ///
  /// Parameters: [isArabic] which language to show.
  ///
  /// Returns: [String] the name, falling back to the other language.
  String localizedName({required bool isArabic}) {
    if (isArabic) return nameAr.isNotEmpty ? nameAr : nameEn;
    return FormatHelper.capitalize(nameEn.isNotEmpty ? nameEn : nameAr);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DatabaseDepartment && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
