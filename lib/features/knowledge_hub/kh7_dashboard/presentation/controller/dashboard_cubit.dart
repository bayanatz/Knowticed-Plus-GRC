/// Module: knowledge_hub/kh7_dashboard/presentation/controller
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_cubit.dart
/// Description: Loads the dashboard data and applies the department filter.
/// Author: Amr Mesbah
/// Created at: 28/10/2025
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/base_repository/dashboard_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/use_cases/dashboard_statistics.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/presentation/controller/dashboard_states.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';

class DashboardCubit extends Cubit<DashboardStates> {
  DashboardCubit(this._repository, this._departments)
      : super(DashboardInitial());

  final DashboardBaseRepository _repository;
  final MainCoreDepartmentCubit _departments;

  List<CreateKnowledgeModel> _documents = [];
  List<DocumentUtilizationModel> _utilization = [];
  List<String> _selectedDepartmentIds = [];

  @override
  void emit(DashboardStates state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future<void> fetchDashboardData({bool silent = false}) async {
    if (!silent) emit(DashboardLoading());
    try {
      _documents = await _repository.fetchAllKnowledgeDocuments();
      _utilization = await _repository.fetchAllDocumentUtilization();
      await _departments.getAllDepartments();
    } catch (e) {
      khLog('fetchDashboardData failed: $e', name: 'DashboardCubit');
      if (!silent) emit(DashboardError());
      return;
    }
    if (_documents.isEmpty) {
      emit(DashboardEmpty());
    } else {
      _emitLoaded();
    }
    _live.watchPaths([
      getBaseUrl(FirebaseCollections.createKnowledge),
      getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
    ], () => fetchDashboardData(silent: true));
  }

  final LiveRefresh _live = LiveRefresh();

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }

  /// Applies the department filter (department ids; empty = all).
  void selectDepartments(List<String> departmentIds) {
    _selectedDepartmentIds = List<String>.unmodifiable(departmentIds);
    if (_documents.isNotEmpty) _emitLoaded();
  }

  /// The department id for a stored owning-department value: older
  /// documents hold the English or Arabic name instead of the id.
  String departmentIdOf(String stored) {
    final String key = stored.trim().toLowerCase();
    if (key.isEmpty) return '';
    for (final DepartmentModelPro dept in _departments.departmentModels) {
      if ((dept.departmentID ?? '').toLowerCase() == key ||
          (dept.departmentName ?? '').toLowerCase() == key ||
          (dept.departmentNameInArabic ?? '').toLowerCase() == key) {
        return dept.departmentID ?? stored.trim();
      }
    }
    return stored.trim();
  }

  void _emitLoaded() {
    final List<CreateKnowledgeModel> documents = _selectedDepartmentIds.isEmpty
        ? _documents
        : _documents
            .where(
              (d) => _selectedDepartmentIds.contains(
                departmentIdOf(d.currentOwningDepartment),
              ),
            )
            .toList();
    final DashboardFigures figures = DashboardStatistics(
      now: DateTime.now(),
      departmentIdOf: departmentIdOf,
    ).compute(documents, _utilization);

    final Map<String, String> namesEn = {};
    final Map<String, String> namesAr = {};
    for (final DepartmentModelPro dept in _departments.departmentModels) {
      final String? id = dept.departmentID;
      if (id == null || id.isEmpty) continue;
      namesEn[id] = dept.departmentName ?? id;
      namesAr[id] = dept.departmentNameInArabic ?? '';
    }

    emit(
      DashboardLoaded(
        figures: figures,
        departmentNamesEn: namesEn,
        departmentNamesAr: namesAr,
        selectedDepartmentIds: _selectedDepartmentIds,
        unreadableRecords: _repository.lastUnreadableCount,
      ),
    );
  }
}
