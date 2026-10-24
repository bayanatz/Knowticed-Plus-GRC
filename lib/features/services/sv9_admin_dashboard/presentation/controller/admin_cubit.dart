/// Module: services / sv9_admin_dashboard / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: admin_cubit.dart
/// Purpose: The Admin Dashboard. Reads every request and service ONCE per
///          load through CreateServicesRepository and computes every number
///          from those lists: status cards, department chips, monthly
///          requests / planned hours, services offered, the monthly
///          cancelled / rejected series, the table rows and the service
///          cards of one department.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
/// Revision History:
///   - 18/10/2026: SVC-DASH-01/02/03/04/05/13/14/15/16/17/21.
///   - 22/10/2026 (Amr Mesbah): no Firestore here — both reads go through
///     the injected repository (Dashboards rule 1); one class, the part +
///     extension split is gone (suggestion 1); the provider comes from the
///     shared DashboardProvider and the status from DashboardMetrics (rules
///     5, 6); field names from ServicesHistoryKeys (rule 28); unused
///     resolveFinalStateFromData removed (rule 27); the comparison chart's
///     numbers are computed here (rule 2).
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_keys.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_metrics.dart';
import 'package:knowticed_plus/features/services/data/utils/dashboard_provider.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/data/utils/request_status.dart';
import 'package:knowticed_plus/features/services/domain/base_repository/service_repository.dart';
import 'package:knowticed_plus/features/services/helpers/services_log.dart';
import 'package:knowticed_plus/features/services/sv9_admin_dashboard/presentation/controller/admin_state.dart';

/// One request as the dashboard needs it, resolved once per load.
class _AdminRequest {
  final String docId;
  final Map<String, dynamic> data;
  final String state;
  final String department;
  final String parentId;
  final String requesterEmail;

  const _AdminRequest({
    required this.docId,
    required this.data,
    required this.state,
    required this.department,
    required this.parentId,
    required this.requesterEmail,
  });
}

class DashboardAdminCubit extends Cubit<DashboardAdminState> {
  final LiveRefresh _live = LiveRefresh();

  // B5 FIX: guard against emit-after-close (StateError).
  @override
  void emit(DashboardAdminState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// The department filter key meaning "every department".
  static const String allDepartments = 'All';

  final MainCoreDepartmentCubit departmentCubit;
  final MainCoreEmployeeController employeeController;
  final CreateServicesRepository repository;

  DashboardAdminCubit({
    required this.departmentCubit,
    required this.employeeController,
    required this.repository,
  }) : super(DashboardAdminState.initial());

  /// Year the monthly charts show (SVC-DASH-02). Defaults to this year.
  int selectedYear = DateTime.now().year;

  List<_AdminRequest> _requests = const [];

  /// CreateServices documents by id.
  Map<String, Map<String, dynamic>> _services = const {};

  /// Department (English name) of each service's creator, by service id.
  Map<String, String> _serviceDepartment = const {};

  // ─── Public API ────────────────────────────────────────────────────────────

  Future<void> bootstrap() async {
    // SVC-DASH-21: a (re)load marks the page as not loaded, so Retry shows
    // the spinner until the data or the error is ready — not 0 everywhere.
    emit(
      state.copyWith(
        bootstrapping: true,
        bootstrapped: false,
        loadError: false,
      ),
    );
    try {
      await _load();
      _recompute(state.selectStatus);
      emit(
        state.copyWith(
          bootstrapping: false,
          bootstrapped: true,
          loadError: false,
        ),
      );
      // Live refresh: the dashboard follows new and changed requests.
      _live.watchPaths([
        getBaseUrl(FirestoreCollections.requestServicesRoot),
        getBaseUrl(FirestoreCollections.createServicesRoot),
      ], _silentRefresh);
    } catch (e, st) {
      svcLog('[AdminCubit] load failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          bootstrapping: false,
          bootstrapped: true,
          loadError: true,
          isLoading: false,
          isLoadingFirst: false,
          isLoadingRequests: false,
          isLoadingServicesName: false,
          isLoadingDepartments: false,
          isServiceListLoading: false,
        ),
      );
    }
  }

  /// Live refresh: reads everything again without clearing the table or
  /// showing spinners.
  Future<void> _silentRefresh() async {
    if (isClosed || state.bootstrapping) return;
    try {
      await _load();
      _recompute(state.selectStatus);
    } catch (e) {
      svcLog('[AdminCubit] live refresh ignored: $e');
    }
  }

  Future<void> onDepartmentChanged(String newStatus) async {
    emit(state.copyWith(selectStatus: newStatus));
    if (state.loadError) {
      await bootstrap();
      return;
    }
    _recompute(newStatus);
  }

  void toggleShowAll() => emit(state.copyWith(showAll: !state.showAll));

  /// Both series are computed on every load, so switching is instant.
  void toggleServiceCount(bool showCount) =>
      emit(state.copyWith(showServiceCount: showCount, isLoading: false));

  void toggleShowRequests(bool show) =>
      emit(state.copyWith(showRequests: show));

  /// Changes the year of the monthly charts.
  void setYear(int year) {
    selectedYear = year;
    _recompute(state.selectStatus);
  }

  // ─── Loading ───────────────────────────────────────────────────────────────

  String _departmentOf(String email) {
    final departmentId =
        employeeController.mapOfEmployeesWithEmailKey[email]?.departmentId;
    if (departmentId == null || departmentId.isEmpty) return '';
    return departmentCubit.getEnglishDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        ) ??
        '';
  }

  Future<void> _load() async {
    final results = await Future.wait([
      repository.getAllRequestServiceDocs(),
      repository.getCreateServiceDocEntries(),
    ]);

    final services = <String, Map<String, dynamic>>{};
    final serviceDepartment = <String, String>{};
    for (final doc in results[1]) {
      services[doc.key] = doc.value;
      serviceDepartment[doc.key] = _departmentOf(
        DashboardMetrics.current(
          doc.value[ServicesHistoryKeys.kEmailRequester],
        ),
      );
    }

    final requests = <_AdminRequest>[];
    var skipped = 0;
    for (final doc in results[0]) {
      try {
        final data = doc.value;
        final email = DashboardMetrics.current(
          data[ServicesHistoryKeys.kEmailRequester],
        );
        requests.add(
          _AdminRequest(
            docId: doc.key,
            data: data,
            state: DashboardMetrics.finalState(data),
            department: _departmentOf(email),
            parentId: DashboardMetrics.current(
              data[ServicesHistoryKeys.kParentServiceId],
            ),
            requesterEmail: email,
          ),
        );
      } catch (e) {
        skipped++;
        svcLog('[AdminCubit] request ${doc.key} unreadable: $e');
      }
    }
    if (skipped > 0) {
      svcLog('[AdminCubit] $skipped request(s) could not be read');
    }

    _requests = requests;
    _services = services;
    _serviceDepartment = serviceDepartment;
  }

  // ─── Computation (synchronous, from the loaded lists) ─────────────────────

  void _recompute(String department) {
    final isAll = department == allDepartments;
    final reqs = isAll
        ? _requests
        : _requests.where((r) => r.department == department).toList();

    // Status cards.
    final statusCounts = <String, int>{for (final s in RequestStatus.all) s: 0};
    for (final r in reqs) {
      if (statusCounts.containsKey(r.state)) {
        statusCounts[r.state] = statusCounts[r.state]! + 1;
      }
    }

    // SVC-DASH-05: chips and "All" both count REQUESTS per department.
    final departmentCounts = <String, int>{};
    for (final r in _requests) {
      if (r.department.isEmpty) continue;
      departmentCounts[r.department] =
          (departmentCounts[r.department] ?? 0) + 1;
    }

    // SVC-DASH-02/03/04: monthly series.
    final monthCounts = DashboardMetrics.emptyMonths();
    final monthHours = DashboardMetrics.emptyMonths();
    for (final r in reqs) {
      final month = DashboardMetrics.monthIndex(r.data, selectedYear);
      if (month == null) continue;
      if (DashboardMetrics.countsAsService(r.state)) {
        monthCounts[month] = monthCounts[month]! + 1;
      }
      monthHours[month] = monthHours[month]! +
          DashboardMetrics.plannedHoursIfDone(
            state: r.state,
            request: r.data,
            service: _services[r.parentId],
          );
    }

    // SVC-DASH-17: "Services offered", grouped by service id.
    final usage = <String, int>{};
    for (final r in reqs) {
      final key = r.parentId.isNotEmpty ? r.parentId : r.docId;
      usage[key] = (usage[key] ?? 0) + 1;
    }
    final serviceNames = <String>[];
    final serviceNamesArabic = <String>[];
    final usageCounts = <int, double>{};
    var index = 0;
    for (final entry in usage.entries) {
      final names = _serviceNames(entry.key);
      serviceNames.add(names.en);
      serviceNamesArabic.add(names.ar);
      usageCounts[index++] = entry.value.toDouble();
    }

    // Monthly cancelled / rejected, per department and for all (comparison
    // chart, SVC-DASH-15: from the loaded list, never downloaded again).
    final cancelled = <String, List<int>>{'': List.filled(12, 0)};
    final rejected = <String, List<int>>{'': List.filled(12, 0)};
    for (final r in _requests) {
      final isCancel = r.state == RequestStatus.cancel;
      if (!isCancel && r.state != RequestStatus.rejected) continue;
      final month = DashboardMetrics.monthIndex(r.data, selectedYear);
      if (month == null) continue;
      final target = isCancel ? cancelled : rejected;
      for (final key in {'', r.department}) {
        final series = target.putIfAbsent(key, () => List.filled(12, 0));
        series[month]++;
      }
    }

    emit(
      state.copyWith(
        statusCounts: statusCounts,
        departmentCounts: departmentCounts,
        totalServices: departmentCounts.values.fold<int>(0, (s, v) => s + v),
        monthCounts: monthCounts,
        monthHours: monthHours,
        serviceNames: serviceNames,
        serviceNamesArabic: serviceNamesArabic,
        serviceUsageCounts: usageCounts,
        cancelledByMonth: cancelled,
        rejectedByMonth: rejected,
        displayedItems: _tableRows(reqs),
        allServices: isAll ? const [] : _serviceCards(department),
        isLoading: false,
        isLoadingFirst: false,
        isLoadingRequests: false,
        isLoadingServicesName: false,
        isLoadingDepartments: false,
        isServiceListLoading: false,
      ),
    );
  }

  /// Current (last) English / Arabic name of a service; empty when it cannot
  /// be found (the widgets show their translated "Unknown").
  ({String en, String ar}) _serviceNames(
    String serviceId, {
    Map<String, dynamic>? fallback,
  }) {
    final service = _services[serviceId] ?? fallback;
    final en = DashboardMetrics.current(
      service?[ServicesHistoryKeys.kServiceNameEnglish],
    );
    final ar = DashboardMetrics.current(
      service?[ServicesHistoryKeys.kServiceNameArabic],
    );
    return (en: en.isEmpty ? ar : en, ar: ar.isEmpty ? en : ar);
  }

  List<Map<String, dynamic>> _tableRows(List<_AdminRequest> reqs) {
    final dateFormat = DateFormat('yyyy-MM-dd – kk:mm');
    final rows = <Map<String, dynamic>>[];

    for (final r in reqs) {
      final employee =
          employeeController.mapOfEmployeesWithEmailKey[r.requesterEmail];
      if (employee == null) continue;

      final names = _serviceNames(r.parentId, fallback: r.data);
      final provider = DashboardProvider.resolve(
        data: r.data,
        requesterEmail: r.requesterEmail,
        employees: employeeController.mapOfEmployeesWithEmailKey,
      );
      final created = RequestDates.createdAtFromRaw(r.data);

      rows.add({
        'no': rows.length + 1,
        'department': r.department,
        'serviceName': names.en,
        'serviceNameArabic': names.ar,
        'gender': employee.gender ?? '',
        'requestor':
            '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim(),
        'firstNameRequester': employee.firstName ?? '',
        'lastNameRequester': employee.lastName ?? '',
        'firstNameRequesterArabic': employee.firstNameInArabic ?? '',
        'lastNameRequesterArabic': employee.lastNameInArabic ?? '',
        'provider': provider.name,
        'firstNameProvider': provider.firstName,
        'lastNameProvider': provider.lastName,
        'firstNameProviderArabic': provider.firstNameArabic,
        'lastNameProviderArabic': provider.lastNameArabic,
        'jobTitleRequester': employee.title ?? '',
        'jobTitleRequesterArabic': employee.titleInArabic ?? '',
        // SVC-DASH-13: the date the request was MADE ('-' when unknown).
        'requestDate': created == null ? '-' : dateFormat.format(created),
        'status': r.state,
        'docId': r.docId,
        'raw': r.data,
        'selectedProvider': provider.map,
      });
    }
    return rows;
  }

  /// Service cards for one department: its services, how many requests were
  /// completed, and their planned hours.
  List<Map<String, dynamic>> _serviceCards(String department) {
    final cards = <Map<String, dynamic>>[];
    for (final entry in _services.entries) {
      if (_serviceDepartment[entry.key] != department) continue;
      if (entry.value[ServicesHistoryKeys.kIsDeleted] == true) continue;

      final names = _serviceNames(entry.key);
      var done = 0;
      var hours = 0.0;
      DateTime? earliest;
      for (final r in _requests) {
        if (r.parentId != entry.key) continue;
        if (DashboardMetrics.completedStates.contains(r.state)) done++;
        hours += DashboardMetrics.plannedHoursIfDone(
          state: r.state,
          request: r.data,
          service: entry.value,
        );
        final created = RequestDates.createdAtFromRaw(r.data);
        if (created != null &&
            (earliest == null || created.isBefore(earliest))) {
          earliest = created;
        }
      }
      earliest ??= RequestDates.createdAtFromRaw(entry.value);

      cards.add({
        'title': names.en,
        'titleEnglish': names.en,
        'titleArabic': names.ar,
        // A DateTime: the card formats it in the reader's language.
        'startDate': earliest,
        'done': done.toString(),
        'total': hours.toStringAsFixed(1),
      });
    }
    return cards;
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
