/// Module: core/helper/form_builder
///
///*************************** FILE INFO ****************************///
/// File Name: department_display_name.dart
/// Description: The one place that picks a department's Arabic or English
///              name for the form builder's lists and filters.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';

/// Department names come in both languages from Firestore (they are data,
/// not translation keys); this picks the one for the UI language.
extension DepartmentDisplayName on DepartmentModelPro {
  /// Function Name: [displayName]
  ///
  /// Purpose: The department's name in the UI language. The Arabic name
  /// falls back to the English one when it is missing.
  ///
  /// Parameters:
  /// - [arabic]: whether the UI is Arabic; defaults to the current locale.
  String displayName({bool? arabic}) {
    final bool ar = arabic ?? Intl.getCurrentLocale().startsWith('ar');
    if (ar && (departmentNameInArabic?.isNotEmpty ?? false)) {
      return departmentNameInArabic!;
    }
    return FormatHelper.capitalize(departmentName ?? '');
  }
}
