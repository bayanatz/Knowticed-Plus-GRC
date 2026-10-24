/// Module: services / data / helper
///
///*************************** FILE INFO ****************************///
/// File Name: service_owning_department.dart
/// Description: The one rule for "which department owns this service".
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// A service stores its creator's department id (`Department_Requester`).
/// A company owner / Master Admin has no department, so every service they
/// (or a bulk upload) created showed an empty "Owning Department" and every
/// department tab counted 0 — and the tab counts came from a hard-coded list
/// of departments this company does not have. The owning department is now:
/// the stored id when it is a real department of this company, otherwise the
/// department of the first service provider (the team that delivers it).
library;

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';

abstract final class ServiceOwningDepartment {
  const ServiceOwningDepartment._();

  /// The owning department id, or '' when neither source names one.
  static String idOf(
      ServicesHistoryModel service, MainCoreDepartmentCubit departments) {
    final Set<String> known = departments.departmentIds.toSet();
    final String stored = service.currentDepartmentRequester.trim();
    if (known.contains(stored)) return stored;
    for (final provider in service.currentProviderServices) {
      final String id = (provider.departmentId ?? '').trim();
      if (known.contains(id)) return id;
    }
    return '';
  }

  /// The owning department's display name ('' when unknown).
  static String nameOf(
      ServicesHistoryModel service, MainCoreDepartmentCubit departments,
      {required bool english}) {
    final String id = idOf(service, departments);
    return id.isEmpty ? '' : departments.getDepartmentName(id, english);
  }

  /// Count of [services] per department display name, for every department
  /// of the company (zero included), in the company's department order.
  static Map<String, int> countByDepartment(
      List<ServicesHistoryModel> services, MainCoreDepartmentCubit departments,
      {required bool english}) {
    final Map<String, int> counts = <String, int>{};
    final List<String> ids = departments.departmentIds;
    for (final id in ids) {
      counts[departments.getDepartmentName(id, english)] = 0;
    }
    for (final service in services) {
      final String name = nameOf(service, departments, english: english);
      if (counts.containsKey(name)) counts[name] = counts[name]! + 1;
    }
    return counts;
  }
}
