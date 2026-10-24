/// Module: services_management_module
/// ******************* FILE INFO *******************
/// File Name: service_department_access.dart
/// Description: Decides whether an employee's department is in a service's
///              "limit availability" list, by DEPARTMENT ID (SVC-HOME-01).
///              The old check matched names with fuzzy text rules
///              ("Sales Operations" became Operations, anything containing
///              "dev" became Software), which let the wrong people see
///              restricted services.
/// Author: Amr Mesbah
/// Created at: 18/10/2026
/// *************************************************
library;

class ServiceDepartmentAccess {
  const ServiceDepartmentAccess._();

  /// True when [userDepartmentId] is one of [allowedDepartments].
  ///
  /// Each allowed entry may be a department id or an exact department name
  /// (services store the English name today). Names are turned into ids with
  /// [nameToId] — an exact lookup, never fuzzy matching.
  static bool isAllowed({
    required List<String> allowedDepartments,
    required String? userDepartmentId,
    required String? Function(String departmentName) nameToId,
  }) {
    final userId = (userDepartmentId ?? '').trim();
    if (userId.isEmpty || allowedDepartments.isEmpty) return false;

    for (final raw in allowedDepartments) {
      final entry = raw.trim();
      if (entry.isEmpty) continue;
      if (entry == userId) return true;
      if (nameToId(entry) == userId) return true;
    }
    return false;
  }
}
