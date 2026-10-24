/// Module: knowledge_hub/kh7_dashboard/data/repository
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_repository.dart
/// Description: Firestore implementation of [DashboardBaseRepository].
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/dashboard_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh7_dashboard/domain/base_repository/dashboard_base_repository.dart';

class DashboardRepository implements DashboardBaseRepository {
  DashboardRepository(this._services);

  final DashboardFirebaseServices _services;

  @override
  Future<List<CreateKnowledgeModel>> fetchAllKnowledgeDocuments() =>
      _services.fetchAllKnowledgeDocuments();

  @override
  Future<List<DocumentUtilizationModel>> fetchAllDocumentUtilization() =>
      _services.fetchAllDocumentUtilization();

  @override
  int get lastUnreadableCount =>
      _services.unreadableDocuments + _services.unreadableUsageRecords;
}
