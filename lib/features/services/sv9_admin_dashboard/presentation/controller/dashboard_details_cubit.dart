/// Module: services / sv9_admin_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_details_cubit.dart
/// Purpose: The Admin Dashboard's page for ONE service: its requests, the
///          status / department / monthly counts and the provider
///          statistics. Reads requests and services once through the
///          injected repository.
/// Author: Amr Mesbah / Knowticed Team
/// Created At: 02/07/2026
/// Revision History:
///   - 18/10/2026: SVC-DASH-02/04/08/12/13/14/15/20/21.
///   - 22/10/2026 (Amr Mesbah): moved out of request_statistics_cubit.dart
///     so the file is named after its class (Dashboards rule 19); one class
///     (the part + extension split is gone, suggestion 1); the status comes
///     from DashboardMetrics — the own copy that returned "canceled" is gone
///     (rule 5) — and the provider from DashboardProvider (rule 6); field
///     names from ServicesHistoryKeys (rule 28); no silent catches (rule 9);
///     no English fallback text (rule 14).
library;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_provider.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/dashboard_details_state.dart';

class DashboardDetailsCubit extends Cubit<DashboardDetailsState> {
  // B5 FIX: guard against emit-after-close (StateError).
  @override
  void emit(DashboardDetailsState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Department key of requests whose department is unknown.
  static const String otherKey = 'Other';

  final CreateServicesRepository _repository;
  final MainCoreDepartmentCubit departmentCubit;
  final MainCoreEmployeeController employeeController;

  DashboardDetailsCubit({
    required CreateServicesRepository repository,
    required this.departmentCubit,
    required this.employeeController,
  })  : _repository = repository,
        super(DashboardDetailsState.initial());

  /// Year the monthly charts show (SVC-DASH-02). Defaults to this year.
  int selectedYear = DateTime.now().year;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// SVC-DASH-15: requests and services are read ONCE; every number is
  /// computed from them. SVC-DASH-01: a failure sets `loadError`.
  Future<void> bootstrap({required String selectedServiceName}) async {
    // SVC-DASH-21: not loaded again until the reload ends.
    emit(
      state.copyWith(
        bootstrapping: true,
        bootstrapped: false,
        loadError: false,
      ),
    );
    _initializeDepartmentData();
    try {
      await _loadFilteredItems(selectedServiceName: selectedServiceName);
      _computeCharts();
      emit(
        state.copyWith(
          bootstrapping: false,
          bootstrapped: true,
          loadError: false,
        ),
      );
    } catch (e, st) {
      svcLog('[DashboardDetailsCubit] load failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          bootstrapping: false,
          bootstrapped: true,
          loadError: true,
          isLoading: false,
          isLoadingFirst: false,
          isLoadingDepartments: false,
        ),
      );
    }
  }

  void toggleTab(bool showRequested) =>
      emit(state.copyWith(showRequestedServices: showRequested));

  /// Both series are computed on load, so switching is instant.
  void toggleChartMode(bool showCount, {required String selectedServiceName}) =>
      emit(state.copyWith(showServiceCount: showCount, isLoading: false));

  void applyFilters({
    String? department,
    String? status,
    DateTime? date,
    bool clearDepartment = false,
    bool clearStatus = false,
    bool clearDate = false,
    String? searchQuery,
  }) {
    final next = state.copyWith(
      activeDepartment: department,
      activeStatus: status,
      activeDate: date,
      clearActiveDepartment: clearDepartment,
      clearActiveStatus: clearStatus,
      clearActiveDate: clearDate,
      searchQuery: searchQuery,
    );
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  void onSearchChanged(String query) {
    final next = state.copyWith(searchQuery: query);
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  // ─── Provider Stats (called from UI widgets) ───────────────────────────────

  List<String> getUniqueProviderNames(List<Map<String, dynamic>> items) {
    final names = <String>{};
    for (final item in items) {
      final provider = item['provider']?.toString() ?? '';
      if (provider.isNotEmpty) names.add(provider);
    }
    return names.toList();
  }

  /// The provider's numbers; text fields are '' when unknown (the card shows
  /// its translated "not available").
  Map<String, dynamic> calculateProviderStats(String providerName) {
    var done = 0;
    var breached = 0;
    var totalHours = 0.0;
    String? name;
    String? department;
    String? jobTitle;

    for (final item in state.filteredItems) {
      if ((item['provider'] ?? '') != providerName) continue;

      final status = DashboardMetrics.normalizeState(
        item['status']?.toString() ?? '',
      );
      if (status == RequestStatus.done) done++;
      if (status == RequestStatus.breachedSla) breached++;

      // SVC-DASH-04: hours only for COMPLETED requests.
      if (DashboardMetrics.completedStates.contains(status)) {
        final val = double.tryParse(item['duration']?.toString() ?? '') ?? 0;
        totalHours += DashboardMetrics.toHours(
          val,
          item['unit']?.toString() ?? '',
        );
      }

      name ??= item['provider'];
      // SVC-DASH-12: the PROVIDER's own department and title.
      final provider = item['selectedProvider'];
      if (provider is Map) {
        final departmentId = provider['departmentId']?.toString() ?? '';
        if (department == null && departmentId.isNotEmpty) {
          department = departmentCubit.getDepartmentName(departmentId, true);
        }
        final title = provider['title']?.toString() ?? '';
        if (jobTitle == null && title.isNotEmpty) jobTitle = title;
      }
    }

    return {
      'name': name ?? '',
      'department': department ?? '',
      'jobTitle': jobTitle ?? '',
      'done': done,
      'breached': breached,
      'hours': totalHours,
    };
  }

  double getPercentage(String key) {
    final total = state.statusCounts.values.fold<int>(0, (a, b) => a + b);
    final value = state.statusCounts[key] ?? 0;
    return total == 0 ? 0.0 : (value / total) * 100.0;
  }

  Map<String, int> getTop5Departments() {
    final sorted = state.departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initializeDepartmentData() {
    final enToAr = <String, String>{};
    final known = <String>[];
    for (final id in departmentCubit.departmentIds) {
      final en = departmentCubit.getEnglishDepartmentNameFromDepartmentId(
        departmentId: id,
      );
      final ar = departmentCubit.getArabicDepartmentNameFromDepartmentId(
        departmentId: id,
      );
      if (en != null && ar != null) {
        enToAr[en] = ar;
        known.add(en);
      }
    }
    enToAr[otherKey] = MainCoreDepartmentCubit.otherAr;
    emit(state.copyWith(enToArDepartments: enToAr, knownDepartments: known));
  }

  // ─── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadFilteredItems({required String selectedServiceName}) async {
    // One read of each collection (SVC-DASH-15).
    final results = await Future.wait([
      _repository.getAllRequestServiceDocs(),
      _repository.getAllRequestServices(),
    ]);
    final docs = results[0] as List<MapEntry<String, Map<String, dynamic>>>;
    final services = results[1] as List<ServicesHistoryModel>;

    // SVC-DASH-14: the service's CURRENT (last) name and duration.
    final servicesById = {for (final svc in services) svc.currentId: svc};
    final selectedIds = {
      for (final svc in services)
        if (svc.currentServiceNameEnglish == selectedServiceName) svc.currentId,
    };

    final items = <Map<String, dynamic>>[];
    var skipped = 0;

    for (final entry in docs) {
      final data = entry.value;
      final docId = entry.key;
      try {
        final emailRequester = DashboardMetrics.current(
          data[ServicesHistoryKeys.kEmailRequester],
        );
        if (emailRequester.isEmpty) continue;

        final parentServiceId = DashboardMetrics.current(
          data[ServicesHistoryKeys.kParentServiceId],
        );
        final service = servicesById[parentServiceId];
        final serviceNameEn = service?.currentServiceNameEnglish ??
            DashboardMetrics.current(
              data[ServicesHistoryKeys.kServiceNameEnglish],
            );
        final serviceNameAr = service?.currentServiceNameArabic ??
            DashboardMetrics.current(
              data[ServicesHistoryKeys.kServiceNameArabic],
            );

        final belongs = selectedIds.contains(parentServiceId) ||
            (service == null && serviceNameEn == selectedServiceName);
        if (!belongs) continue;

        final employee =
            employeeController.mapOfEmployeesWithEmailKey[emailRequester];
        if (employee == null) continue;

        final department = (employee.departmentId?.isNotEmpty == true)
            ? (departmentCubit.getEnglishDepartmentNameFromDepartmentId(
                  departmentId: employee.departmentId!,
                ) ??
                '')
            : '';

        final provider = DashboardProvider.resolve(
          data: data,
          requesterEmail: emailRequester,
          employees: employeeController.mapOfEmployeesWithEmailKey,
        );

        // SVC-DASH-13 / SVC-DASH-20: the date the request was MADE; a missing
        // date stays null (shown as "-"), never today.
        final created = RequestDates.createdAtFromRaw(data);

        items.add({
          'no': items.length + 1,
          'department': department,
          'serviceName': serviceNameEn,
          'serviceNameArabic': serviceNameAr,
          'gender': employee.gender ?? '',
          'requestor':
              '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
          'requestorArabic':
              '${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'
                  .trim(),
          'firstNameRequester': employee.firstName ?? '',
          'lastNameRequester': employee.lastName ?? '',
          'firstNameRequesterArabic': employee.firstNameInArabic ?? '',
          'lastNameRequesterArabic': employee.lastNameInArabic ?? '',
          'jobTitleRequester': employee.title ?? '',
          'jobTitleRequesterArabic': employee.titleInArabic ?? '',
          'requestDate': created == null ? null : Timestamp.fromDate(created),
          'status': DashboardMetrics.finalState(data),
          'provider': provider.name,
          'firstNameProvider': provider.firstName,
          'lastNameProvider': provider.lastName,
          'firstNameProviderArabic': provider.firstNameArabic,
          'lastNameProviderArabic': provider.lastNameArabic,
          'docId': docId,
          'raw': data,
          'selectedProvider': provider.map,
          'duration': service?.currentDurationOfServices ??
              DashboardMetrics.current(
                data[ServicesHistoryKeys.kDurationOfServices],
              ),
          'unit': service?.currentSelectedDurationUnit ??
              DashboardMetrics.current(
                data[ServicesHistoryKeys.kSelectedDurationUnit],
              ),
        });
      } catch (e) {
        skipped++;
        svcLog('[DashboardDetailsCubit] request $docId unreadable: $e');
      }
    }
    if (skipped > 0) {
      svcLog('[DashboardDetailsCubit] $skipped request(s) could not be read');
    }

    emit(state.copyWith(filteredItems: items, displayedItems: items));
  }

  /// The known department an item belongs to, or [otherKey].
  String _departmentKey(String? raw) {
    final dept = (raw ?? '').trim();
    if (dept.isEmpty) return otherKey;
    final lower = dept.toLowerCase();
    for (final k in state.knownDepartments) {
      if (k.toLowerCase() == lower) return k;
    }
    final en = departmentCubit.getDepartmentEnglishNameFromArabicName(
      arabicName: dept,
    );
    if (en != null && state.knownDepartments.contains(en)) return en;
    return otherKey;
  }

  /// Status cards, monthly series and department counts — all from the
  /// loaded items (SVC-DASH-02/03/04/15).
  void _computeCharts() {
    final statusCounts = <String, int>{for (final s in RequestStatus.all) s: 0};
    final monthCounts = DashboardMetrics.emptyMonths();
    final Map<int, num> monthHours = DashboardMetrics.emptyMonths();
    final departmentCounts = <String, int>{
      for (final dept in state.knownDepartments) dept: 0,
      otherKey: 0,
    };

    for (final item in state.filteredItems) {
      final status = DashboardMetrics.normalizeState(
        item['status']?.toString() ?? '',
      );
      if (statusCounts.containsKey(status)) {
        statusCounts[status] = statusCounts[status]! + 1;
      }

      final deptKey = _departmentKey(item['department']);
      departmentCounts[deptKey] = (departmentCounts[deptKey] ?? 0) + 1;

      final raw = item['raw'] as Map<String, dynamic>;
      final month = DashboardMetrics.monthIndex(raw, selectedYear);
      if (month == null) continue;
      if (DashboardMetrics.countsAsService(status)) {
        monthCounts[month] = monthCounts[month]! + 1;
      }
      if (DashboardMetrics.completedStates.contains(status)) {
        final val = double.tryParse(item['duration']?.toString() ?? '') ?? 0;
        monthHours[month] = monthHours[month]! +
            DashboardMetrics.toHours(val, item['unit']?.toString() ?? '');
      }
    }

    emit(
      state.copyWith(
        statusCounts: statusCounts,
        monthCounts: monthCounts,
        monthHours: monthHours,
        departmentCounts: departmentCounts,
        isLoading: false,
        isLoadingFirst: false,
        isLoadingDepartments: false,
      ),
    );
  }

  // ─── Filter / search ───────────────────────────────────────────────────────

  List<Map<String, dynamic>> _computeDisplayedItems(DashboardDetailsState s) {
    final query = s.searchQuery.toLowerCase().trim();
    return s.filteredItems.where((item) {
      final matchesQuery = query.isEmpty ||
          [
            item['department'],
            item['serviceName'],
            item['serviceNameArabic'],
            item['requestor'],
            item['requestorArabic'],
            item['status'],
            item['provider'],
          ].join(' ').toLowerCase().contains(query);

      final matchesDept = s.activeDepartment == null ||
          s.activeDepartment!.isEmpty ||
          item['department'] == s.activeDepartment;

      // SVC-DASH-08: one status vocabulary on both sides.
      final matchesStatus = s.activeStatus == null ||
          s.activeStatus!.isEmpty ||
          DashboardMetrics.normalizeState(item['status']?.toString() ?? '') ==
              DashboardMetrics.normalizeState(s.activeStatus!);

      final modelDate = (item['requestDate'] as Timestamp?)?.toDate();
      final matchesDate = s.activeDate == null ||
          (modelDate != null &&
              modelDate.year == s.activeDate!.year &&
              modelDate.month == s.activeDate!.month &&
              modelDate.day == s.activeDate!.day);

      return matchesQuery && matchesDept && matchesStatus && matchesDate;
    }).toList();
  }
}
