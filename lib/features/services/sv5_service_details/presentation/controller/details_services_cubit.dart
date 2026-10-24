/// Module: services / sv5_service_details / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: details_services_cubit.dart
/// Purpose: Details services cubit — declares DetailsServicesCubit.
/// Author: Amr Mesbah
/// Created At: 18/10/2026
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:knowticed_plus/core/helper/csv_helper.dart';
import 'package:knowticed_plus/features/services/data/utils/request_dates.dart';
import 'package:knowticed_plus/features/services/data/models/service_employee_model.dart';
import 'package:knowticed_plus/features/services/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services/presentation/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/data/models/service_stats_model.dart';
import 'package:knowticed_plus/features/services/sv5_service_details/presentation/controller/details_services_state.dart';

import 'package:knowticed_plus/features/services/presentation/controller/request_details_lookup.dart';

class DetailsServicesCubit extends Cubit<DetailsServicesState> {
  final LiveRefresh _live = LiveRefresh();

  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Exact department-name → id lookup (either language). Used so the
  /// department filter compares ids, not display names (SVC-HOME-18).
  final String? Function(String departmentName)? departmentNameToId;

  /// Rule "No BuildContext in cubits": the collaborators are passed in once
  /// instead of being read from a BuildContext on every load.
  final ServicesManagerCubit _manager;
  final RequestDetailsLookup _lookup;

  DetailsServicesCubit({
    required ServicesManagerCubit manager,
    required RequestDetailsLookup lookup,
    this.departmentNameToId,
  })  : _manager = manager,
        _lookup = lookup,
        super(DetailsServicesInitial());

  static DetailsServicesCubit get(BuildContext context) =>
      BlocProvider.of(context);

  // Core Data
  List<Map<String, dynamic>> _filteredItems = [];
  List<Map<String, dynamic>> _displayedItems = [];
  // SVC-HOME-08: the Employees tab shows only this service's team.
  List<ServiceEmployeeModel> _serviceTeam = [];
  bool _hasLoaded = false;
  String _employeeQuery = '';
  ServiceStatsModel _stats = ServiceStatsModel.empty();

  // ✅ Filter State - Multi-select support
  List<String>? _filterDepartments;
  List<String>? _filterStatuses;
  DateTime? _filterDate;
  String? _filterSortBy; // ✅ NEW: For employees tab sorting

  // Tab State
  bool _isEmployeesTab = false;

  // Getters
  List<Map<String, dynamic>> get filteredItems => _filteredItems;
  List<Map<String, dynamic>> get displayedItems => _displayedItems;

  /// The people shown on the Employees tab: this service's providers and
  /// approvers.
  List<ServiceEmployeeModel> get allEmployees => _serviceTeam;

  /// True once the first load finished (successfully or not), so an empty
  /// list shows the empty state instead of a shimmer forever.
  bool get hasLoaded => _hasLoaded;
  ServiceStatsModel get stats => _stats;
  bool get isEmployeesTab => _isEmployeesTab;

  // ✅ Filter state getters
  List<String>? get selectedDepartments => _filterDepartments;
  List<String>? get selectedStatuses => _filterStatuses;
  DateTime? get selectedDate => _filterDate;
  String? get selectedSortBy => _filterSortBy; // ✅ NEW

  Future<void> initialize(
    String serviceId,
    ServicesHistoryModel serviceModel, {
    bool silent = false,
  }) async {
    if (silent && isClosed) return;
    if (!silent) emit(DetailsServicesLoading());

    try {
      // SVC-HOME-08: the company-wide employee load was removed. It wrote the
      // same list as the service-team load below, in parallel, so the
      // Employees tab showed whichever finished last.
      await Future.wait([
        _loadFilteredItems(serviceId, serviceModel),
        _manager.loadProviderPerDocument(),
      ]);

      _hasLoaded = true;
      emit(
        DetailsServicesLoaded(
          filteredItems: _filteredItems,
          displayedItems: _displayedItems,
          allEmployees: _serviceTeam,
          stats: _stats,
        ),
      );
      // Live refresh: the request table follows new and changed requests.
      _live.watchPaths([
        getBaseUrl(FirestoreCollections.requestServicesRoot),
        getBaseUrl(FirestoreCollections.createServicesRoot),
      ], () => initialize(serviceId, serviceModel, silent: true));
    } catch (e) {
      _hasLoaded = true;
      if (!silent) emit(DetailsServicesError(e.toString()));
    }
  }

  Future<void> _loadFilteredItems(
    String serviceId,
    ServicesHistoryModel serviceModel,
  ) async {
    final result = await _manager.loadFilteredItems(
      parentServiceId: serviceId,
      parentService: serviceModel,
      requesterOf: _lookup.requesterInfo,
    );

    _filteredItems = result['filteredItems'] as List<Map<String, dynamic>>;
    _displayedItems = _filteredItems;
    _serviceTeam = result['allEmployees'] as List<ServiceEmployeeModel>;
    _stats = ServiceStatsModel.fromMap(
      result['localStats'] as Map<String, int>,
    );
  }

  void applySearch(String query) {
    final searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      _employeeQuery = '';
      _displayedItems = _filteredItems;
      emit(DetailsServicesSearchApplied());
      return;
    }

    if (_isEmployeesTab) {
      // SVC-HOME-18: the Employees tab search is applied in
      // [filterEmployeeStats], so store the query and rebuild.
      _employeeQuery = searchQuery;
      emit(DetailsServicesSearchApplied());
      return;
    }

    _displayedItems = _filteredItems.where((item) {
      final model = item["model"] as ServicesHistoryModel;

      // ✅ FIX: Extract actual values from lists
      String extractFromList(dynamic value) {
        if (value == null) return "";
        if (value is List) {
          // Join non-empty values from the list
          return value
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .map((e) => e.toString())
              .join(" ");
        }
        return value.toString();
      }

      final firstName = extractFromList(model.firstNameRequester).toLowerCase();
      final lastName = extractFromList(model.lastNameRequester).toLowerCase();
      final firstNameAr =
          extractFromList(model.firstNameRequesterArabic).toLowerCase();
      final lastNameAr =
          extractFromList(model.lastNameRequesterArabic).toLowerCase();
      final department =
          extractFromList(model.departmentRequester).toLowerCase();
      final departmentAr =
          extractFromList(model.departmentRequesterArabic).toLowerCase();
      final email = extractFromList(model.currentEmailRequester).toLowerCase();

      // Combine all searchable text
      final searchableText = [
        firstName,
        lastName,
        firstNameAr,
        lastNameAr,
        department,
        departmentAr,
        email,
      ].join(" ").toLowerCase();

      return searchableText.contains(searchQuery);
    }).toList();

    emit(DetailsServicesSearchApplied());
  }

  // ✅ UPDATED: Multi-select filter + sorting support
  void applyFilter({
    List<String>? departments,
    List<String>? statuses,
    DateTime? date,
    String? sortBy, // ✅ NEW parameter
  }) {
    _filterDepartments = departments;
    _filterStatuses = statuses;
    _filterDate = date;
    _filterSortBy = sortBy; // ✅ NEW

    if (_isEmployeesTab) {
      // SVC-HOME-18: the Employees tab shows EMPLOYEES, so department and
      // sort are applied to them in [filterEmployeeStats]; the request list
      // is left as it is.
      _displayedItems = _filteredItems;
    } else {
      // REQUESTED SERVICES TAB: Filter by department, status, and date
      _displayedItems = _filteredItems.where((item) {
        final model = item["model"] as ServicesHistoryModel;

        final matchesDepartment = _matchesDepartment(
          item["department"]?.toString() ?? '',
        );

        final matchesStatus = _filterStatuses == null ||
            _filterStatuses!.isEmpty ||
            _filterStatuses!.any(
              (status) =>
                  item["status"]?.toString().toLowerCase() ==
                  status.toLowerCase(),
            );

        final DateTime modelDate =
            model.currentDurationOfServicesTimestamp.toDate();

        final matchesDate = _filterDate == null ||
            (modelDate.year == _filterDate!.year &&
                modelDate.month == _filterDate!.month &&
                modelDate.day == _filterDate!.day);

        return matchesDepartment && matchesStatus && matchesDate;
      }).toList();
    }

    emit(DetailsServicesFilterApplied(_displayedItems));
  }

  /// Normalises a department value (id, English or Arabic name) to its id.
  String _deptId(String value) {
    final v = value.trim();
    if (v.isEmpty) return '';
    return departmentNameToId?.call(v) ?? v;
  }

  /// True when no department filter is set, or [department] (id or name in
  /// either language) is one of the selected departments.
  bool _matchesDepartment(String department) {
    final selected = _filterDepartments;
    if (selected == null || selected.isEmpty) return true;
    final id = _deptId(department);
    if (id.isEmpty) return false;
    return selected.any((d) => _deptId(d) == id);
  }

  /// Applies the Employees-tab search, department filter and sort to the
  /// per-employee stats rows built by the tab (SVC-HOME-18).
  List<Map<String, dynamic>> filterEmployeeStats(
    List<Map<String, dynamic>> stats,
  ) {
    var rows = stats.where((emp) {
      if (!_matchesDepartment(emp['departmentId']?.toString() ?? '')) {
        return false;
      }
      if (_employeeQuery.isEmpty) return true;
      final name = (emp['name'] ?? '').toString().toLowerCase();
      final dept = (emp['department'] ?? '').toString().toLowerCase();
      final title = (emp['title'] ?? '').toString().toLowerCase();
      return name.contains(_employeeQuery) ||
          dept.contains(_employeeQuery) ||
          title.contains(_employeeQuery);
    }).toList();

    if (_filterSortBy == "Done") {
      rows.sort(
        (a, b) =>
            ((b['done'] as int?) ?? 0).compareTo((a['done'] as int?) ?? 0),
      );
    } else if (_filterSortBy == "Breached SLA") {
      rows.sort(
        (a, b) => ((b['breached'] as int?) ?? 0).compareTo(
          (a['breached'] as int?) ?? 0,
        ),
      );
    }
    return rows;
  }

  void clearFilters() {
    _filterDepartments = null;
    _filterStatuses = null;
    _filterDate = null;
    _filterSortBy = null;
    _employeeQuery = '';
    _displayedItems = _filteredItems;
    emit(DetailsServicesFilterApplied(_displayedItems));
  }

  // ✅ UPDATED: Include sortBy in active filters check
  bool get hasActiveFilters =>
      (_filterDepartments?.isNotEmpty ?? false) ||
      (_filterStatuses?.isNotEmpty ?? false) ||
      _filterDate != null ||
      (_filterSortBy?.isNotEmpty ?? false);

  void changeTab(bool isEmployees) {
    _isEmployeesTab = isEmployees;
    clearFilters(); // ✅ Clear filters when switching tabs
    emit(DetailsServicesTabChanged(isEmployees));
  }

  /// H8: builds the Requested Services CSV from the rows on screen and saves
  /// it (it used to be built inside the page). The page passes the translated
  /// [headers] and the reader-specific formatters, so no text is hardcoded.
  ///
  /// Returns Left = error message; Right = saved path.
  Future<Either<String, String>> exportRequests({
    required String fileName,
    required List<String> headers,
    required String Function(ServicesHistoryModel model) requesterName,
    required String Function(String departmentIdOrName) departmentName,
    required String Function(String rawStatus) statusLabel,
    required String Function(String english, String arabic) pick,
  }) {
    String orDash(String v) => v.trim().isEmpty ? "-" : v;
    final rows = <List<dynamic>>[headers];
    for (var i = 0; i < _displayedItems.length; i++) {
      final item = _displayedItems[i];
      final model = item["model"] as ServicesHistoryModel;
      rows.add([
        i + 1,
        requesterName(model),
        departmentName(model.currentDepartmentRequester),
        orDash(
          pick(
            item["jobtitleEn"]?.toString() ?? '',
            item["jobtitleAr"]?.toString() ?? '',
          ),
        ),
        RequestDates.format(RequestDates.createdAt(model)),
        statusLabel((item["status"] ?? "").toString()),
        orDash(
          pick(
            item["provider"]?.toString() ?? '',
            item["providerAr"]?.toString() ?? '',
          ),
        ),
      ]);
    }
    return CSVHelper().exportRowsForUser(fileName: fileName, rows: rows);
  }

  Future<void> refresh(
    String serviceId,
    ServicesHistoryModel serviceModel,
  ) async {
    await initialize(serviceId, serviceModel);
  }

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
