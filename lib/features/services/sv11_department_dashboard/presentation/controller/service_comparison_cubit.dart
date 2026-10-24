/// Module: services / sv11_department_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: service_comparison_cubit.dart
/// Purpose: Loads the monthly cancelled / rejected counts of the user's
///          department (optionally for one service) and the service names
///          for the filter. All reads go through CreateServicesRepository.
/// Author: Knowticed Team
/// Created At: 02/07/2026
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/service_comparison_state.dart';

import 'package:knowticed_plus/features/services/helpers/services_log.dart';

class ServiceComparisonCubit extends Cubit<ServiceComparisonState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository repository;

  ServiceComparisonCubit({required this.repository})
      : super(const ServiceComparisonLoading());

  /// Mirrors the original widget's `_loadData()`: fetches all CreateServices
  /// docs (for the dropdown), fetches all RequestServices docs, resolves
  /// department + parent-service name per doc, filters by [userDepartmentName]
  /// and [selectedServiceName] (English or Arabic name match), and buckets
  /// canceled/rejected counts by month.
  /// Year the chart shows (SVC-DASH-02). Defaults to this year.
  int selectedYear = DateTime.now().year;

  Future<void> loadData({
    required MainCoreDepartmentCubit departmentController,
    required MainCoreEmployeeController employeeController,
    String? userDepartmentName,
    String? selectedServiceName,
  }) async {
    emit(const ServiceComparisonLoading());
    try {
      emit(
        ServiceComparisonLoaded(
          await _load(
            departmentController: departmentController,
            employeeController: employeeController,
            userDepartmentName: userDepartmentName,
            selectedServiceName: selectedServiceName,
          ),
        ),
      );
    } catch (e, st) {
      // SVC-DASH-01: the spinner used to run forever on any failure.
      svcLog('[ServiceComparisonCubit] load failed: $e\n$st');
      emit(ServiceComparisonError(e.toString()));
    }
  }

  Future<ServiceComparisonData> _load({
    required MainCoreDepartmentCubit departmentController,
    required MainCoreEmployeeController employeeController,
    String? userDepartmentName,
    String? selectedServiceName,
  }) async {
    // One read of each collection (SVC-DASH-15).
    final results = await Future.wait([
      repository.getAllRequestServices(),
      repository.getAllRequestServiceDocs(),
    ]);
    final services = results[0] as List<ServicesHistoryModel>;
    final requestDocs =
        results[1] as List<MapEntry<String, Map<String, dynamic>>>;

    // SVC-DASH-14: the dropdown shows each service's CURRENT name.
    final servicesById = <String, ServicesHistoryModel>{};
    final Set<String> allServicesSetEnglish = {};
    final Set<String> allServicesSetArabic = {};
    for (final svc in services) {
      servicesById[svc.currentId] = svc;
      if (svc.isDeleted) continue;
      if (svc.currentServiceNameEnglish.isNotEmpty) {
        allServicesSetEnglish.add(svc.currentServiceNameEnglish);
      }
      if (svc.currentServiceNameArabic.isNotEmpty) {
        allServicesSetArabic.add(svc.currentServiceNameArabic);
      }
    }

    final Map<int, Map<String, int>> monthlyData = {
      for (int i = 1; i <= 12; i++)
        i: {
          ServiceComparisonData.canceledKey: 0,
          ServiceComparisonData.rejectedKey: 0,
        },
    };

    // SVC-DASH-07: no department → nothing (never the whole company).
    final wantDepartment = userDepartmentName?.trim().toLowerCase() ?? '';
    if (wantDepartment.isEmpty) {
      return ServiceComparisonData(
        monthlyData: monthlyData,
        allServicesEnglish: allServicesSetEnglish.toList()..sort(),
        allServicesArabic: allServicesSetArabic.toList()..sort(),
      );
    }

    for (final entry in requestDocs) {
      final docData = entry.value;

      String department = '';
      final emailRequester = DashboardMetrics.current(
        docData[ServicesHistoryKeys.kEmailRequester],
      );
      final departmentId = employeeController
          .mapOfEmployeesWithEmailKey[emailRequester]?.departmentId;
      if (departmentId != null && departmentId.isNotEmpty) {
        department =
            departmentController.getEnglishDepartmentNameFromDepartmentId(
                  departmentId: departmentId,
                ) ??
                '';
      }
      if (department.isEmpty) {
        department = _normalizeDepartmentValue(
          docData[ServicesHistoryKeys.kDepartmentRequester] ??
              docData['departmentRequester'],
          departmentController,
        );
      }
      if (department.trim().toLowerCase() != wantDepartment) continue;

      final parentId = DashboardMetrics.current(
        docData[ServicesHistoryKeys.kParentServiceId],
      );
      final service = servicesById[parentId];
      final nameEn = service?.currentServiceNameEnglish ??
          DashboardMetrics.current(
            docData[ServicesHistoryKeys.kServiceNameEnglish],
          );
      final nameAr = service?.currentServiceNameArabic ??
          DashboardMetrics.current(
            docData[ServicesHistoryKeys.kServiceNameArabic],
          );

      if (selectedServiceName != null && selectedServiceName.isNotEmpty) {
        if (nameEn != selectedServiceName && nameAr != selectedServiceName) {
          continue;
        }
      }

      // SVC-DASH-02/08: month the request was MADE, this year, one status
      // vocabulary.
      final status = DashboardMetrics.finalState(docData);
      if (status != RequestStatus.cancel && status != RequestStatus.rejected) {
        continue;
      }
      final monthIndex = DashboardMetrics.monthIndex(docData, selectedYear);
      if (monthIndex == null) continue;
      final month = monthIndex + 1;
      final key = status == RequestStatus.cancel
          ? ServiceComparisonData.canceledKey
          : ServiceComparisonData.rejectedKey;
      monthlyData[month]![key] = (monthlyData[month]![key] ?? 0) + 1;
    }

    return ServiceComparisonData(
      monthlyData: monthlyData,
      allServicesEnglish: allServicesSetEnglish.toList()..sort(),
      allServicesArabic: allServicesSetArabic.toList()..sort(),
    );
  }

  String _normalizeDepartmentValue(
    dynamic departmentValue,
    MainCoreDepartmentCubit departmentController,
  ) {
    if (departmentValue == null) return '';
    String value = '';

    if (departmentValue is List && departmentValue.isNotEmpty) {
      value = departmentValue.last?.toString().trim() ?? '';
    } else {
      value = departmentValue.toString().trim();
    }

    if (value.isEmpty) return '';

    // Check if it's a department ID (numeric).
    if (int.tryParse(value) != null) {
      final departmentName = departmentController
          .getEnglishDepartmentNameFromDepartmentId(departmentId: value);
      if (departmentName != null && departmentName.isNotEmpty) {
        return departmentName;
      }
    }

    // ✅ FIX (bug report p7): non-numeric values were returned verbatim, so a
    // doc storing the plain department name was compared against the canonical
    // name produced by getDepartmentName() — any difference in casing, spacing
    // or abbreviation made the comparison fail and the department filter let
    // other departments' services through.
    //
    // Resolve the name back to its id and out to the canonical English name so
    // both sides of the comparison are in the same form.
    final resolvedId = departmentController.getDepartmentIdFromDepartmentName(
      departmentName: value,
    );
    if (resolvedId != null) {
      final canonical = departmentController
          .getEnglishDepartmentNameFromDepartmentId(departmentId: resolvedId);
      if (canonical != null && canonical.isNotEmpty) {
        return canonical;
      }
    }

    return value;
  }
}
