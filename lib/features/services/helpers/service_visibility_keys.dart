/// Module: services / helpers
///
///*************************** FILE INFO ****************************///
/// File Name: service_visibility_keys.dart
/// Purpose: Builds the department keys a user queries services with
///          (SVC-HOME-01): the user's department id and its English and
///          Arabic names, plus "everyone".
/// Author: Amr Mesbah
/// Created at: 22/10/2026
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/utils/service_visibility.dart';

/// Function Name: [serviceVisibilityKeys]
///
/// Purpose: Keys for ServiceVisibility queries.
///
/// Parameters:
/// - [departments]: the company's departments (id ↔ name lookups).
/// - [departmentId]: the signed-in user's department id.
List<String> serviceVisibilityKeys(
  MainCoreDepartmentCubit departments,
  String? departmentId,
) {
  final id = (departmentId ?? '').trim();
  if (id.isEmpty) return ServiceVisibility.userKeys();
  return ServiceVisibility.userKeys(
    departmentId: id,
    englishName: departments.getEnglishDepartmentNameFromDepartmentId(
      departmentId: id,
    ),
    arabicName: departments.getArabicDepartmentNameFromDepartmentId(
      departmentId: id,
    ),
  );
}
