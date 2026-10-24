/// Module: knowledge_hub/presentation/controller/analytics
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_cubit_methods.dart
/// Description: Methods of `AnalyticsCubit` — split out of `analytics_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of 'analytics_cubit.dart';

// Split from analytics_cubit.dart to keep every file under 700 lines.

mixin AnalyticsCubitMethods on AnalyticsCubitBase {
  /// Fetch and process analytics data for a specific knowledge document
  Future<void> fetchAnalytics(String knowledgeId, {bool silent = false}) async {
    try {
      khLog(
        '🔍 [AnalyticsCubit] Starting fetchAnalytics for knowledgeId: $knowledgeId',
      );
      if (!silent) emit(FetchingAnalyticsLoadingState());

      // Fetch all file actions for this document
      khLog('📡 [AnalyticsCubit] Calling fetchFileActionsByKnowledgeId...');
      _allActions = await _repository.fetchFileActionsByKnowledgeId(
        knowledgeId,
      );

      khLog('📊 [AnalyticsCubit] Fetched ${_allActions.length} actions');

      // Live: any new view/download of this document refreshes the charts.
      _watchedKnowledgeId = knowledgeId;
      _live.watchPaths(
        [getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization)],
        () {
          final String? id = _watchedKnowledgeId;
          if (id != null) fetchAnalytics(id, silent: true);
        },
      );

      if (_allActions.isEmpty) {
        khLog('⚠️ [AnalyticsCubit] No actions found - emitting empty state');
        emit(FetchingAnalyticsEmptyState());
        return;
      }

      // Fetch user data for all actions
      khLog('👥 [AnalyticsCubit] Fetching user data for actions...');
      await _fetchUsersForActions(_allActions);
      khLog(
        '✅ [AnalyticsCubit] User data fetching complete. Cache size: ${_usersCache.length}',
      );

      // Fetch department names (both Arabic and English)
      khLog('🏢 [AnalyticsCubit] Fetching department names...');
      await _fetchDepartmentsForUsers();
      khLog(
        '✅ [AnalyticsCubit] Department data fetching complete. EN: ${_departmentsEnglishCache.length}, AR: ${_departmentsArabicCache.length}',
      );

      // Process the data AFTER user data and department data are loaded
      khLog('⚙️ [AnalyticsCubit] Processing department counts...');
      _processDepartmentCounts();

      khLog('⚙️ [AnalyticsCubit] Processing monthly data...');
      _processMonthlyData();

      khLog('⚙️ [AnalyticsCubit] Calculating totals...');
      _calculateTotals();

      khLog('✅ [AnalyticsCubit] Emitting success state');
      emit(
        FetchingAnalyticsSuccessState(
          departmentCounts: _departmentCounts,
          monthlyDownloads: _monthlyDownloads,
          monthlyViews: _monthlyViews,
          totalDownloads: _totalDownloads,
          totalViews: _totalViews,
        ),
      );

      khLog(
        '✅ [AnalyticsCubit] Analytics processed successfully: ${_allActions.length} actions, ${_departmentCounts.length} departments',
      );
    } catch (e, stackTrace) {
      khLog('❌ [AnalyticsCubit] Error in fetchAnalytics: $e');
      khLog('📚 [AnalyticsCubit] Stack trace: $stackTrace');
      if (!silent) emit(FetchingAnalyticsErrorState(e.toString()));
    }
  }

  /// Caches the employee behind every action's employee ID.
  ///
  /// KH-CREATE-14 / KH-SUBMIT-07: new rows store the employee ID; rows saved
  /// before the change may still hold an e-mail, so both are resolved.
  Future<void> _fetchUsersForActions(
    List<DocumentUtilizationModel> actions,
  ) async {
    try {
      final MainCoreEmployeeController? controller = people.employeesOrNull;
      final List<String> keys = actions
          .map((action) => action.currentEmployeeId)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();
      if (keys.isEmpty) return;

      for (final String key in keys) {
        final EmployeeEntityPro? employee = controller == null
            ? null
            : _findEmployee(controller, key);
        if (employee != null) {
          _usersCache[key] = _employeeDataFrom(employee);
          continue;
        }
        final EmployeeData? userData = await _repository.fetchUserDataByUserId(
          key,
        );
        if (userData == null) {
          khLog('[AnalyticsCubit] No employee found for an action row');
          continue;
        }
        _usersCache[key] = userData;
        final String deptId = userData.currentemployeeDepartment;
        if (deptId.isNotEmpty &&
            !_departmentsEnglishCache.containsKey(deptId)) {
          await _fetchDepartmentNamesById(deptId);
        }
      }
    } catch (e) {
      khLog('❌ [AnalyticsCubit] Error fetching users for actions: $e');
    }
  }

  /// The employee whose ID — or, on rows saved before KH-CREATE-14, e-mail —
  /// is [key], from the employee list loaded at app start.
  EmployeeEntityPro? _findEmployee(
    MainCoreEmployeeController controller,
    String key,
  ) {
    final String wanted = key.toLowerCase().trim();
    final bool isEmail = wanted.contains('@');
    if (isEmail) {
      final EmployeeEntityPro? exact =
          controller.mapOfEmployeesWithEmailKey[key];
      if (exact != null) return exact;
    }
    for (final EmployeeEntityPro emp
        in controller.allEmployeesEntities ?? const <EmployeeEntityPro>[]) {
      final String value =
          (isEmail ? emp.email : emp.id)?.toLowerCase().trim() ?? '';
      if (value == wanted) return emp;
    }
    return null;
  }

  /// [EmployeeData] for the statistics table, built from the app's employee
  /// list.
  EmployeeData _employeeDataFrom(EmployeeEntityPro employee) {
    return EmployeeData.createNew(
      employeeId: employee.id ?? '',
      employeeName: '${employee.firstName ?? ''} ${employee.lastName ?? ''}'
          .trim(),
      employeeNameArabic:
          '${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}'
              .trim(),
      employeeEmail: employee.email ?? '',
      employeePhoto: employee.photo,
      employeeDepartment: employee.departmentId ?? '',
      employeeRole: employee.title ?? '',
      // KH vertical report p.18: createNew falls back to [employeeRole] when
      // the Arabic job title is empty.
      employeeRoleArabic: (employee.titleInArabic ?? '').trim().isEmpty
          ? null
          : employee.titleInArabic,
      employeeJobTitle: employee.title ?? '',
      employeePhone: employee.mobilePhone?.phone,
      employeeSupervisor: employee.supervisor ?? '',
    );
  }

  /// Process monthly downloads and views with Arabic numeral conversion
  void _processMonthlyData() {
    _monthlyDownloads.clear();
    _monthlyViews.clear();

    khLog('⚙️ [AnalyticsCubit] Starting _processMonthlyData');
    khLog(
      '📊 [AnalyticsCubit] Total actions to process: ${_allActions.length}',
    );

    for (var action in _allActions) {
      if (action.timestamp.isEmpty) {
        khLog('   ⚠️ Action has no timestamps, skipping');
        continue;
      }

      final DateTime? date = KhLocale.parseStoredTime(action.timestamp.last);
      if (date == null) {
        khLog('   Unreadable timestamp: ${action.timestamp.last}');
        continue;
      }

      khLog('   📆 Parsed date: ${date.year}-${date.month}-${date.day}');

      // Month bucket, year included (e.g. "2026-03").
      String monthKey = _monthKey(date);
      khLog('   📅 Month key: $monthKey');

      String actionType = action.currentTypeOfAction.toLowerCase();
      khLog('   🎯 Action type: $actionType');

      if (actionType == 'download') {
        _monthlyDownloads[monthKey] = (_monthlyDownloads[monthKey] ?? 0) + 1;
        khLog(
          '   ⬇️ Download count for $monthKey: ${_monthlyDownloads[monthKey]}',
        );
      } else if (actionType == 'view') {
        _monthlyViews[monthKey] = (_monthlyViews[monthKey] ?? 0) + 1;
        khLog('   👁️ View count for $monthKey: ${_monthlyViews[monthKey]}');
      }
    }

    khLog('📥 [AnalyticsCubit] Final monthly downloads: $_monthlyDownloads');
    khLog('👁️ [AnalyticsCubit] Final monthly views: $_monthlyViews');
  }
}
