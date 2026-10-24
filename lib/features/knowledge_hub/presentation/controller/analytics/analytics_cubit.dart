/// Module: knowledge_hub/presentation/controller/analytics
/// ************************* FILE INFO *************************** ///
/// File Name: analytics_cubit.dart
/// Description: Manages analytics data and calculations for published documents
/// Author: Amr Mesbah
/// Created at: 20/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_people.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_locale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/knowledge_hub/domain/base_repository/analytics_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/presentation/controller/analytics/analytics_states.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

part 'analytics_cubit_methods.dart';

/// Analytics for one published document. The loading and processing live in
/// the [AnalyticsCubitMethods] mixin (its own file) on [AnalyticsCubitBase].
class AnalyticsCubit extends AnalyticsCubitBase with AnalyticsCubitMethods {
  AnalyticsCubit(super.repository, super.people);
}

/// The state and helpers shared with [AnalyticsCubitMethods].
abstract class AnalyticsCubitBase extends Cubit<AnalyticsStates> {
  final AnalyticsBaseRepository _repository;

  /// Signed-in employee + employee / department lookups (injected).
  final KhPeople people;

  List<DocumentUtilizationModel> _allActions = [];
  List<EmployeeData> _employees = [];

  // Cache for user data
  Map<String, EmployeeData> _usersCache = {};

  // Separate caches for Arabic and English department names
  Map<String, String> _departmentsEnglishCache = {};
  Map<String, String> _departmentsArabicCache = {};

  Map<String, int> _departmentCounts = {};
  Map<String, int> _monthlyDownloads = {};
  Map<String, int> _monthlyViews = {};
  int _totalDownloads = 0;
  int _totalViews = 0;

  List<EmployeeData> get employeesList => _employees;

  AnalyticsCubitBase(this._repository, this.people) : super(AnalyticsInitial());

  /// Rule Bug 5 — "check isClosed before emit": a result that arrives after
  /// the screen closed the cubit is dropped instead of throwing.
  @override
  void emit(AnalyticsStates state) {
    if (isClosed) return;
    super.emit(state);
  }

  final LiveRefresh _live = LiveRefresh();
  String? _watchedKnowledgeId;

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  List<DocumentUtilizationModel> get allActions => _allActions;

  // Getters
  Map<String, EmployeeData> get usersCache => _usersCache;
  Map<String, String> get departmentsEnglishCache => _departmentsEnglishCache;
  Map<String, String> get departmentsArabicCache => _departmentsArabicCache;
  Map<String, int> get departmentCounts => _departmentCounts;
  Map<String, int> get monthlyDownloads => _monthlyDownloads;
  Map<String, int> get monthlyViews => _monthlyViews;
  int get totalDownloads => _totalDownloads;
  int get totalViews => _totalViews;
  int get totalActions => _totalDownloads + _totalViews;

  /// Helper: Fetch department names (both Arabic and English) for all cached users
  Future<void> _fetchDepartmentsForUsers() async {
    try {
      // Extract unique department IDs from cached users
      final departmentIds = _usersCache.values
          .map((user) => user.currentemployeeDepartment)
          .where(
            (id) => id.isNotEmpty && !_departmentsEnglishCache.containsKey(id),
          )
          .toSet()
          .toList();

      if (departmentIds.isEmpty) {
        khLog('ℹ️ [AnalyticsCubit] No new departments to fetch');
        return;
      }

      khLog(
        '🏢 [AnalyticsCubit] Fetching names for ${departmentIds.length} departments',
      );

      if (people.departmentsOrNull == null) {
        khLog('❌ [AnalyticsCubit] MainCoreDepartmentCubit not registered!');
        return;
      }

      // Fetch both English and Arabic names for each department
      for (String deptId in departmentIds) {
        await _fetchDepartmentNamesById(deptId);
      }

      khLog(
        '✅ [AnalyticsCubit] Cached ${_departmentsEnglishCache.length} English department names',
      );
      khLog(
        '✅ [AnalyticsCubit] Cached ${_departmentsArabicCache.length} Arabic department names',
      );
    } catch (e, stackTrace) {
      khLog('❌ [AnalyticsCubit] Error fetching departments: $e');
      khLog('📚 [AnalyticsCubit] Stack trace: $stackTrace');
    }
  }

  /// The department's name in English (or Arabic), or '' when it is not
  /// known — the widget shows its own translated "unknown department" text.
  String getDepartmentName(String departmentId, {bool isEnglish = true}) {
    if (departmentId.isEmpty) return '';
    return (isEnglish
            ? _departmentsEnglishCache[departmentId]
            : _departmentsArabicCache[departmentId]) ??
        '';
  }

  /// Helper to fetch both English and Arabic names for a single department
  Future<void> _fetchDepartmentNamesById(String departmentId) async {
    try {
      final MainCoreDepartmentCubit? deptController = people.departmentsOrNull;
      if (deptController == null) {
        khLog('❌ [AnalyticsCubit] MainCoreDepartmentCubit not registered!');
        return;
      }

      final englishName = deptController
          .getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);

      final arabicName = deptController.getArabicDepartmentNameFromDepartmentId(
        departmentId: departmentId,
      );

      if (englishName != null) {
        _departmentsEnglishCache[departmentId] = englishName;
        khLog(
          '✅ [AnalyticsCubit] Cached English dept: $departmentId → $englishName',
        );
      }

      if (arabicName != null) {
        _departmentsArabicCache[departmentId] = arabicName;
        khLog(
          '✅ [AnalyticsCubit] Cached Arabic dept: $departmentId → $arabicName',
        );
      }
    } catch (e) {
      khLog(
        '❌ [AnalyticsCubit] Error fetching department names for $departmentId: $e',
      );
    }
  }

  /// Process department counts
  /// Uses department NAMES (English) instead of IDs for consistency
  void _processDepartmentCounts() {
    _departmentCounts.clear();

    khLog('🔍 [AnalyticsCubit] Starting _processDepartmentCounts');
    khLog('📊 [AnalyticsCubit] Total actions: ${_allActions.length}');
    khLog('👥 [AnalyticsCubit] Users in cache: ${_usersCache.length}');
    khLog(
      '🏢 [AnalyticsCubit] Departments in cache: EN=${_departmentsEnglishCache.length}, AR=${_departmentsArabicCache.length}',
    );

    for (var action in _allActions) {
      String userId = action.currentEmployeeId;
      EmployeeData? user = _usersCache[userId];

      if (user != null) {
        String departmentId = user.currentemployeeDepartment;
        // Get department NAME (English) for counting
        String departmentName = getDepartmentName(
          departmentId,
          isEnglish: true,
        );

        khLog(
          '   ✅ User: ${user.currentemployeeName}, Dept ID: "$departmentId", Dept Name: "$departmentName"',
        );

        _departmentCounts[departmentName] =
            (_departmentCounts[departmentName] ?? 0) + 1;
        khLog(
          '   📈 Department "$departmentName" count: ${_departmentCounts[departmentName]}',
        );
      } else {
        khLog('   ❌ User data NOT FOUND in cache for userId: "$userId"');
      }
    }

    khLog('📊 [AnalyticsCubit] Final department counts: $_departmentCounts');
    khLog('📊 [AnalyticsCubit] Total departments: ${_departmentCounts.length}');
  }

  /// Calculate totals
  void _calculateTotals() {
    _totalDownloads = 0;
    _totalViews = 0;

    for (var action in _allActions) {
      String actionType = action.currentTypeOfAction.toLowerCase();
      if (actionType == 'download') {
        _totalDownloads++;
      } else if (actionType == 'view') {
        _totalViews++;
      }
    }

    khLog(
      '📊 [AnalyticsCubit] Total downloads: $_totalDownloads, Total views: $_totalViews',
    );
  }

  /// The month bucket for [date]: 'yyyy-MM', so the same month of two
  /// different years never adds up into one bar (same fix as KH-DASH-01).
  /// The widget turns the key into a localized month label.
  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Get data for last N months
  Map<String, int> getLastNMonthsDownloads(int n) {
    Map<String, int> result = {};
    DateTime now = DateTime.now();

    for (int i = n - 1; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = _monthKey(month);
      result[monthKey] = _monthlyDownloads[monthKey] ?? 0;
    }

    return result;
  }

  /// Get data for last N months (views)
  Map<String, int> getLastNMonthsViews(int n) {
    Map<String, int> result = {};
    DateTime now = DateTime.now();

    for (int i = n - 1; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String monthKey = _monthKey(month);
      result[monthKey] = _monthlyViews[monthKey] ?? 0;
    }

    return result;
  }

  /// Get top N departments by action count
  Map<String, int> getTopDepartments(int n) {
    var sorted = _departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, int> result = {};
    int othersCount = 0;

    for (int i = 0; i < sorted.length; i++) {
      if (i < n - 1) {
        result[sorted[i].key] = sorted[i].value;
      } else {
        othersCount += sorted[i].value;
      }
    }

    if (othersCount > 0) {
      result['Others'] = othersCount;
    }

    return result;
  }

  // ===========================================================================
  // STATISTICS TAB — FILTERS, SEARCH AND EXPORT
  // ---------------------------------------------------------------------------
  // The Statistics tab shipped with three dead controls: the
  // Export button's `onTap` was `() {}`, `FilterStatisticsDialog.applyFilters`
  // was a commented-out body, and the search field's `onSearchChanged` was
  // `(query) {}`. The table always rendered `allActions` whatever the user did.
  //
  // The filter state lives here rather than in the dialog because the table,
  // the search field and the export all have to agree on which rows are in
  // play — the export in particular must write what is on screen, not the
  // unfiltered set.
  // ===========================================================================

  /// `'view'` / `'download'`, or null for no action filter.
  String? statisticsActionFilter;

  /// A department ID (the key used by [getDepartmentName]), or null for all.
  String? statisticsDepartmentFilter;

  /// Free-text query from the search field above the table.
  String statisticsSearchQuery = '';

  /// The rows the Statistics tab should show: [allActions] narrowed by the
  /// action filter, the department filter and the search query.
  List<DocumentUtilizationModel> get filteredActions {
    final String query = statisticsSearchQuery.trim().toLowerCase();

    return _allActions.where((action) {
      final EmployeeData? user = _usersCache[action.currentEmployeeId];

      if (statisticsActionFilter != null &&
          action.currentTypeOfAction.toLowerCase() !=
              statisticsActionFilter!.toLowerCase()) {
        return false;
      }

      if (statisticsDepartmentFilter != null &&
          (user?.currentemployeeDepartment ?? '') !=
              statisticsDepartmentFilter) {
        return false;
      }

      if (query.isEmpty) return true;

      // Searched across everything the table actually displays, so a user
      // typing what they can see always gets a hit.
      final String departmentId = user?.currentemployeeDepartment ?? '';
      final List<String> haystack = <String>[
        user?.currentemployeeName ?? '',
        user?.currentemployeeNameArabic ?? '',
        user?.currentemployeeEmail ?? '',
        user?.currentemployeeRole ?? '',
        if (departmentId.isNotEmpty) getDepartmentName(departmentId),
        if (departmentId.isNotEmpty)
          getDepartmentName(departmentId, isEnglish: false),
        action.currentTypeOfAction,
      ];

      return haystack.any((field) => field.toLowerCase().contains(query));
    }).toList();
  }

  /// The departments that actually appear in this document's statistics, as
  /// `departmentId -> localized name`. Built from the rows rather than from
  /// the full company list so the dropdown cannot offer a department that
  /// would return nothing.
  Map<String, String> statisticsDepartmentOptions({bool isEnglish = true}) {
    final Map<String, String> options = <String, String>{};

    for (final action in _allActions) {
      final EmployeeData? user = _usersCache[action.currentEmployeeId];
      final String departmentId = user?.currentemployeeDepartment ?? '';
      if (departmentId.isEmpty || options.containsKey(departmentId)) continue;
      options[departmentId] = getDepartmentName(
        departmentId,
        isEnglish: isEnglish,
      );
    }

    return options;
  }

  void applyStatisticsFilters({String? action, String? departmentId}) {
    statisticsActionFilter = action;
    statisticsDepartmentFilter = departmentId;
    _emitCurrentAnalytics();
  }

  void resetStatisticsFilters({bool clearSearch = true}) {
    statisticsActionFilter = null;
    statisticsDepartmentFilter = null;
    if (clearSearch) statisticsSearchQuery = '';
    _emitCurrentAnalytics();
  }

  /// Re-emits the CURRENT data so the tab rebuilds after a filter change.
  ///
  /// It re-emits `FetchingAnalyticsSuccessState` rather than a state of its
  /// own on purpose: the Analytics and Statistics tabs sit in one
  /// `IndexedStack` and both rebuild on every emit, and the Analytics tab
  /// falls through to a spinner for any state it does not recognise. A
  /// filter-specific state would blank that tab out. The state classes are not
  /// value types, so a fresh instance always reaches the listeners.
  void _emitCurrentAnalytics() {
    emit(
      FetchingAnalyticsSuccessState(
        departmentCounts: _departmentCounts,
        monthlyDownloads: _monthlyDownloads,
        monthlyViews: _monthlyViews,
        totalDownloads: _totalDownloads,
        totalViews: _totalViews,
      ),
    );
  }

  /// The statistics table as rows for a CSV export — header row first, then
  /// one row per VISIBLE action ([filteredActions]), in the order and wording
  /// the table shows.
  List<List<dynamic>> buildStatisticsExportRows({
    required List<String> headers,
    required bool isArabic,
  }) {
    final rows = <List<dynamic>>[headers];
    final actions = filteredActions;

    final MainCoreEmployeeController? employeeController =
        people.employeesOrNull;

    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];
      final EmployeeData? user = _usersCache[action.currentEmployeeId];

      final String name = user == null
          ? action.currentEmployeeId
          : (isArabic
                ? (user.currentemployeeNameArabic.isNotEmpty
                      ? user.currentemployeeNameArabic
                      : user.currentemployeeName)
                : user.currentemployeeName);

      final String departmentId = user?.currentemployeeDepartment ?? '';
      final String department = departmentId.isEmpty
          ? ''
          : getDepartmentName(departmentId, isEnglish: !isArabic);

      final String email = user?.currentemployeeEmail ?? '';
      final String jobTitle = (employeeController != null && email.isNotEmpty)
          ? employeeController.getEmployeeJobTitle(email)
          : (user?.currentemployeeRole ?? '');

      final DateTime? dateTime = _parseActionTimestamp(action.currentTimestamp);

      rows.add(<dynamic>[
        i + 1,
        name,
        department,
        jobTitle,
        // KH-SUBMIT-06: an unreadable time shows "—", never the export time.
        dateTime == null
            ? '—'
            : KhLocale.formatDateNow(dateTime, 'dd MMM yyyy'),
        dateTime == null ? '—' : KhLocale.formatDateNow(dateTime, 'h:mm a'),
        action.currentTypeOfAction,
      ]);
    }

    return rows;
  }

  /// An ISO string, else epoch millis, else NULL.
  ///
  /// KH-SUBMIT-06: this returned DateTime.now() for an
  /// empty or unreadable time, so the exported table showed the EXPORT time
  /// as the moment someone viewed or downloaded the document.
  DateTime? _parseActionTimestamp(String raw) => KhLocale.parseStoredTime(raw);

  /// Fetch employee data for a specific employee ID
  Future<void> fetchEmployees(String employeeId) async {
    emit(EmployeesLoading());
    try {
      khLog('🔍 [AnalyticsCubit] Fetching employee data for ID: $employeeId');

      final employee = await _repository.fetchUserDataByUserId(employeeId);

      if (employee == null) {
        khLog('⚠️ [AnalyticsCubit] No employee found with ID: $employeeId');
        _employees = [];
        emit(EmployeesLoadedSuccess([]));
        return;
      }

      // Store in list for compatibility with existing code
      _employees = [employee];

      // Also fetch department names
      final deptId = employee.currentemployeeDepartment;
      if (deptId.isNotEmpty && !_departmentsEnglishCache.containsKey(deptId)) {
        await _fetchDepartmentNamesById(deptId);
        khLog(
          '🏢 [AnalyticsCubit] Cached department: $deptId → EN: ${_departmentsEnglishCache[deptId]}, AR: ${_departmentsArabicCache[deptId]}',
        );
      }

      khLog(
        '✅ [AnalyticsCubit] Successfully fetched employee: ${employee.currentemployeeName}',
      );
      emit(EmployeesLoadedSuccess([employee]));
    } catch (e) {
      khLog('❌ [AnalyticsCubit] Error in fetchEmployees: $e');
      _employees = [];
      emit(EmployeesLoadingFailure(e.toString()));
    }
  }
}
