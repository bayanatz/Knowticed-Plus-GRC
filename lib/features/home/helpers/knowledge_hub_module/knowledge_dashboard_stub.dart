// [module-file:knowledge_hub] — deleted when the knowledge_hub module is split out
/// Module: home/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_dashboard_stub.dart
/// Description: Declares the home-page Knowledge Hub cubit (`DashboardCubit`)
///              and its states, read by the Knowledge Hub home cards.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 15/10/2026 - Reads the real Knowledge Hub documents.
library;

// ============================================================================
// CHANGED 15/10/2026 — KH large-screen report p.29 / vertical p.25 "widgets
// not work". This file used to be a stub left over from the demo copy of the
// app: the cubit always stayed EMPTY, so the Knowledge Hub and Approvals home
// cards always said "No data available". The module is part of this app now,
// so the cubit loads the documents through the Knowledge Hub dashboard
// repository (KnowledgeHubDI) — the same source the KH Dashboard screen uses.
//
// The class names are kept so the home cards did not need renaming.
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/knowledge_hub_get_it.dart';

// ---- States ---------------------------------------------------------------
abstract class DashboardStates {}

class DashboardInitial extends DashboardStates {}

class DashboardLoading extends DashboardStates {}

class DashboardEmpty extends DashboardStates {}

class DashboardError extends DashboardStates {}

class DashboardLoaded extends DashboardStates {
  // Read by the home widgets as `state.statusCounts`: current status -> count.
  final Map<String, int> statusCounts;
  DashboardLoaded({this.statusCounts = const {}});
}

// ---- Cubit ----------------------------------------------------------------
class DashboardCubit extends Cubit<DashboardStates> {
  DashboardCubit() : super(DashboardInitial());

  List<CreateKnowledgeModel> _documents = <CreateKnowledgeModel>[];

  @override
  void emit(DashboardStates state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Loads every Knowledge Hub document. The repository throws on failure
  /// (data layer), so the error state is the cubit's answer to that.
  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    try {
      _documents =
          await KnowledgeHubDI.dashboardRepository.fetchAllKnowledgeDocuments();
    } catch (_) {
      emit(DashboardError());
      return;
    }
    if (_documents.isEmpty) {
      emit(DashboardEmpty());
      return;
    }
    final Map<String, int> counts = <String, int>{};
    for (final CreateKnowledgeModel doc in _documents) {
      final String status = doc.currentStatus.toLowerCase();
      if (status.isEmpty) continue;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    emit(DashboardLoaded(statusCounts: counts));
  }

  List<CreateKnowledgeModel> getAllDocuments() =>
      List<CreateKnowledgeModel>.unmodifiable(_documents);
}
