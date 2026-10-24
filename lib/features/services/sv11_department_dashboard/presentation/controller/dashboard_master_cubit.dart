/// Module: services / sv11_department_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: dashboard_master_cubit.dart
/// Purpose: The department dashboard (an employee's own department, or the
///          department the Admin Dashboard picked). Reads every request and
///          service ONCE through the injected repository and computes every
///          chart, the table rows and the provider statistics from them.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Revision History:
///   - 18/10/2026: SVC-DASH-02/03/04/06/07/11/12/13/14/15/17/21.
///   - 22/10/2026 (Amr Mesbah): one class (the part + extension split is
///     gone, suggestion 1); the repository is required, never created here
///     (Dashboards rule 3); provider and status from the shared rules (rules
///     5, 6); field names from ServicesHistoryKeys (rule 28); the empty chart
///     settings loader, the unused status copy and the no-op chart loaders
///     removed (rules 26, 27); no English fallback text (rule 14).
library;

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart' show Color;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_provider.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/sv11_department_dashboard/presentation/controller/dashboard_master_state.dart';

class DashboardMasterCubit extends Cubit<DashboardMasterState> {
  // B5 FIX: guard against emit-after-close (StateError).
  @override
  void emit(DashboardMasterState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final CreateServicesRepository _repository;
  final MainCoreDepartmentCubit departmentCubit;
  final MainCoreEmployeeController employeeController;

  DashboardMasterCubit({
    required this.departmentCubit,
    required this.employeeController,
    required CreateServicesRepository repository,
  })  : _repository = repository,
        super(DashboardMasterState.initial());

  /// Year the monthly charts show (SVC-DASH-02). Defaults to this year.
  int selectedYear = DateTime.now().year;

  /// Requests / services loaded ONCE (SVC-DASH-15).
  List<MapEntry<String, Map<String, dynamic>>> _docs = const [];
  Map<String, ServicesHistoryModel> _servicesById = const {};
  String? _filterDepartment;
  bool _dataLoaded = false;

  static const List<Color> _departmentPalette = [
    AppColors.chartGoldDeep,
    AppColors.chartGoldPale,
    AppColors.chartGoldBright,
    AppColors.chartOlive,
    AppColors.chartAmberDeep,
    AppColors.chartGreyOlive,
    AppColors.chartGrey,
    AppColors.chartLightGrey,
    AppColors.chartTaupe,
    AppColors.chartMocha,
    AppColors.chartYellow,
  ];

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> bootstrap({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) async {
    // SVC-DASH-21: a load that downloads (first load, Retry) shows the
    // spinner until the data or the error is ready — not empty charts.
    emit(
      state.copyWith(
        bootstrapping: true,
        bootstrapped: _dataLoaded ? state.bootstrapped : false,
        loadError: false,
        noDepartment: false,
      ),
    );

    try {
      await departmentCubit.getAllDepartments();
      _initializeDepartmentData();

      _filterDepartment = _getFilterDepartment(
        isAdmin: isAdmin,
        adminSelectedDepartment: adminSelectedDepartment,
      );

      // SVC-DASH-07: an employee with no department sees an empty dashboard
      // with a message — never the whole company.
      if (!isAdmin && _filterDepartment == null) {
        emit(
          state.copyWith(
            bootstrapping: false,
            bootstrapped: true,
            noDepartment: true,
            statusCounts: const {},
            filteredItems: const [],
            displayedItems: const [],
            isLoading: false,
            isLoadingFirst: false,
            isLoadingDepartments: false,
            isLoadingServicesName: false,
            isLoadingRejectedCanceled: false,
          ),
        );
        return;
      }

      // SVC-DASH-15: requests and services are downloaded once; picking
      // another department only recounts the cached lists.
      if (!_dataLoaded) {
        final results = await Future.wait([
          _repository.getAllRequestServiceDocs(),
          _repository.getAllRequestServices(),
        ]);
        _docs = results[0] as List<MapEntry<String, Map<String, dynamic>>>;
        _servicesById = {
          for (final svc in results[1] as List<ServicesHistoryModel>)
            svc.currentId: svc,
        };
        _dataLoaded = true;
      }

      _recompute();
      emit(state.copyWith(bootstrapping: false, bootstrapped: true));
    } catch (e, st) {
      // SVC-DASH-01: error with Retry instead of cards that spin forever.
      svcLog('[DashboardMasterCubit] load failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          bootstrapping: false,
          bootstrapped: true,
          loadError: true,
          isLoading: false,
          isLoadingFirst: false,
          isLoadingDepartments: false,
          isLoadingServicesName: false,
          isLoadingRejectedCanceled: false,
        ),
      );
    }
  }

  void toggleTab(bool showRequested) =>
      emit(state.copyWith(showRequestedServices: showRequested));

  /// Both series are computed on load, so switching is instant.
  void toggleChartMode({required bool showCount}) =>
      emit(state.copyWith(isHoursMode: !showCount, isLoading: false));

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

  double getPercentage(String key) {
    final total = state.statusCounts.values.fold<int>(0, (a, b) => a + b);
    final value = state.statusCounts[key] ?? 0;
    return total == 0 ? 0.0 : (value / total) * 100.0;
  }

  // ─── Provider Stats ────────────────────────────────────────────────────────

  List<String> getUniqueProviderNames(List<Map<String, dynamic>> items) {
    final names = <String>{};
    for (final item in items) {
      final provider = item['provider']?.toString() ?? '';
      if (provider.isNotEmpty) names.add(provider);
    }
    return names.toList();
  }

  /// The provider's numbers; text fields are '' when unknown (the card
  /// shows its translated "not available").
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

      // SVC-DASH-04: planned hours of completed requests.
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
          final dept = departmentCubit.getDepartmentName(departmentId, true);
          if (dept.isNotEmpty) department = dept;
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

  // ─── Initialization ────────────────────────────────────────────────────────

  void _initializeDepartmentData() {
    final en = departmentCubit.departmentsEnglishName;
    final ar = departmentCubit.departmentsArabicName;
    final enToAr = <String, String>{};
    final colors = <String, Color>{};
    for (var i = 0; i < en.length; i++) {
      if (i < ar.length) enToAr[en[i]] = ar[i];
      colors[en[i]] = _departmentPalette[i % _departmentPalette.length];
    }
    emit(
      state.copyWith(
        enToArDepartments: enToAr,
        departmentColors: colors,
        knownDepartments: en,
        knownDepartmentsArabic: ar,
      ),
    );
  }

  String? _getFilterDepartment({
    required bool isAdmin,
    required String? adminSelectedDepartment,
  }) {
    if (isAdmin) {
      if (adminSelectedDepartment == null || adminSelectedDepartment == 'All') {
        return null;
      }
      return adminSelectedDepartment;
    }
    final deptId = employeeController.employeeEntity?.departmentId;
    if (deptId == null || deptId.isEmpty) return null;
    final name = departmentCubit.getDepartmentName(deptId, true);
    return name.isEmpty ? null : name;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// SVC-DASH-11 (bug report p33): department names compare case-
  /// insensitively everywhere.
  bool _sameDepartment(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  String _normalizeDepartmentValue(dynamic departmentValue) {
    final value = DashboardMetrics.current(departmentValue).trim();
    if (value.isEmpty) return '';
    if (int.tryParse(value) != null) {
      return departmentCubit.getEnglishDepartmentNameFromDepartmentId(
            departmentId: value,
          ) ??
          value;
    }
    return value;
  }

  String? _getDepartmentFromEmail(String email) {
    final departmentId =
        employeeController.mapOfEmployeesWithEmailKey[email]?.departmentId;
    if (departmentId == null) return null;
    return departmentCubit.getEnglishDepartmentNameFromDepartmentId(
      departmentId: departmentId,
    );
  }

  /// Department (English name) of a request: the requester's department.
  String _requestDepartment(Map<String, dynamic> data) {
    final email = DashboardMetrics.current(
      data[ServicesHistoryKeys.kEmailRequester],
    );
    final fromEmployee = email.isEmpty ? null : _getDepartmentFromEmail(email);
    if (fromEmployee != null && fromEmployee.isNotEmpty) return fromEmployee;
    return _normalizeDepartmentValue(
      data[ServicesHistoryKeys.kDepartmentRequester],
    );
  }

  // ─── Computation (from the requests loaded once) ──────────────────────────

  void _recompute() {
    final filter = _filterDepartment;

    final statusCounts = <String, int>{for (final s in RequestStatus.all) s: 0};
    final monthCounts = DashboardMetrics.emptyMonths();
    final monthHours = DashboardMetrics.emptyMonths();
    final monthRejected = DashboardMetrics.emptyMonths();
    final monthCanceled = DashboardMetrics.emptyMonths();
    final usage = <String, int>{};
    final allDepartmentCounts = <String, int>{
      for (final d in departmentCubit.departmentsEnglishName) d: 0,
    };
    final items = <Map<String, dynamic>>[];
    var skipped = 0;

    for (final entry in _docs) {
      final data = entry.value;
      final docId = entry.key;
      try {
        final department = _requestDepartment(data);

        // SVC-DASH-06: with no filter, the department charts count every
        // department; with a filter, only that department (below).
        if (department.isNotEmpty) {
          final key = allDepartmentCounts.keys.firstWhere(
            (d) => _sameDepartment(d, department),
            orElse: () => department,
          );
          allDepartmentCounts[key] = (allDepartmentCounts[key] ?? 0) + 1;
        }

        if (filter != null && !_sameDepartment(department, filter)) continue;

        final status = DashboardMetrics.finalState(data);
        if (statusCounts.containsKey(status)) {
          statusCounts[status] = statusCounts[status]! + 1;
        }

        final parentId = DashboardMetrics.current(
          data[ServicesHistoryKeys.kParentServiceId],
        );
        final service = _servicesById[parentId];

        // SVC-DASH-02/03/04: month the request was MADE, selected year only.
        final month = DashboardMetrics.monthIndex(data, selectedYear);
        if (month != null) {
          if (DashboardMetrics.countsAsService(status)) {
            monthCounts[month] = monthCounts[month]! + 1;
          }
          if (status == RequestStatus.rejected) {
            monthRejected[month] = monthRejected[month]! + 1;
          }
          if (status == RequestStatus.cancel) {
            monthCanceled[month] = monthCanceled[month]! + 1;
          }
          monthHours[month] = monthHours[month]! +
              DashboardMetrics.plannedHoursIfDone(
                state: status,
                request: data,
                service: service?.toJson(),
              );
        }

        // SVC-DASH-17: group by service id.
        final usageKey = parentId.isNotEmpty ? parentId : docId;
        usage[usageKey] = (usage[usageKey] ?? 0) + 1;

        items.add(
          _buildItem(
            docId: docId,
            data: data,
            department: department,
            status: status,
            service: service,
          ),
        );
      } catch (e) {
        skipped++;
        svcLog('[DashboardMasterCubit] request $docId unreadable: $e');
      }
    }
    if (skipped > 0) {
      svcLog('[DashboardMasterCubit] $skipped request(s) could not be read');
    }

    // SVC-DASH-11: the whole department's requests, newest first by the
    // date the request was made.
    items.sort((a, b) {
      final da = (a['requestDate'] as Timestamp?)?.toDate();
      final db = (b['requestDate'] as Timestamp?)?.toDate();
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    for (var i = 0; i < items.length; i++) {
      items[i]['no'] = i + 1;
    }

    final names = <String>[];
    final namesAr = <String>[];
    final usageCounts = <int, double>{};
    var index = 0;
    for (final entry in usage.entries) {
      final service = _servicesById[entry.key];
      final en = service?.currentServiceNameEnglish ?? '';
      final ar = service?.currentServiceNameArabic ?? '';
      // '' when unknown: the chart shows its translated "Unknown".
      names.add(en.isEmpty ? ar : en);
      namesAr.add(ar.isEmpty ? en : ar);
      usageCounts[index++] = entry.value.toDouble();
    }

    final departmentCounts = filter == null
        ? allDepartmentCounts
        : {
            filter: allDepartmentCounts.entries
                .where((e) => _sameDepartment(e.key, filter))
                .fold<int>(0, (s, e) => s + e.value),
          };

    final next = state.copyWith(
      statusCounts: statusCounts,
      monthCounts: monthCounts,
      monthHours: monthHours,
      monthRejected: monthRejected,
      monthCanceled: monthCanceled,
      serviceNames: names,
      serviceNamesArabic: namesAr,
      serviceUsageCounts: usageCounts,
      departmentCounts: departmentCounts,
      filteredItems: items,
      isLoading: false,
      isLoadingFirst: false,
      isLoadingDepartments: false,
      isLoadingServicesName: false,
      isLoadingRejectedCanceled: false,
    );
    emit(next.copyWith(displayedItems: _computeDisplayedItems(next)));
  }

  Map<String, dynamic> _buildItem({
    required String docId,
    required Map<String, dynamic> data,
    required String department,
    required String status,
    required ServicesHistoryModel? service,
  }) {
    final emailRequester = DashboardMetrics.current(
      data[ServicesHistoryKeys.kEmailRequester],
    );
    final employee =
        employeeController.mapOfEmployeesWithEmailKey[emailRequester];
    final provider = DashboardProvider.resolve(
      data: data,
      requesterEmail: emailRequester,
      employees: employeeController.mapOfEmployeesWithEmailKey,
    );
    final created = RequestDates.createdAtFromRaw(data);

    return {
      'no': 0,
      'department': department,
      // SVC-DASH-14: the service's CURRENT names.
      'serviceName': service?.currentServiceNameEnglish ??
          DashboardMetrics.current(
            data[ServicesHistoryKeys.kServiceNameEnglish],
          ),
      'serviceNameArabic': service?.currentServiceNameArabic ??
          DashboardMetrics.current(
            data[ServicesHistoryKeys.kServiceNameArabic],
          ),
      'gender': employee?.gender ?? '',
      'requestor':
          '${employee?.firstName ?? ''} ${employee?.lastName ?? ''}'.trim(),
      'requestorArabic':
          '${employee?.firstNameInArabic ?? ''} ${employee?.lastNameInArabic ?? ''}'
              .trim(),
      // SVC-DASH-13: the date the request was MADE (null → "-").
      'requestDate': created == null ? null : Timestamp.fromDate(created),
      'status': status,
      'provider': provider.name,
      'docId': docId,
      'model': ServicesHistoryModel.fromJson(data, docId),
      'raw': data,
      'selectedProvider': provider.map,
      'jobTitleRequester': employee?.title ?? '',
      'jobTitleRequesterArabic': employee?.titleInArabic ?? '',
      'duration': service?.currentDurationOfServices ??
          DashboardMetrics.current(
            data[ServicesHistoryKeys.kDurationOfServices],
          ),
      'unit': service?.currentSelectedDurationUnit ??
          DashboardMetrics.current(
            data[ServicesHistoryKeys.kSelectedDurationUnit],
          ),
    };
  }

  List<Map<String, dynamic>> _computeDisplayedItems(DashboardMasterState s) {
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
          _sameDepartment(
            item['department']?.toString() ?? '',
            s.activeDepartment!,
          );

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
