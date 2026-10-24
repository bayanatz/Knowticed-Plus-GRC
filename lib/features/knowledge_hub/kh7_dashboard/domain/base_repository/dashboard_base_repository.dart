/// Module: knowledge_hub/kh7_dashboard/domain/base_repository
/// ************************* FILE INFO *************************** ///
/// File Name: dashboard_base_repository.dart
/// Description: Contract the dashboard cubit reads its data through.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';

/// Read side of the dashboard. A failure is thrown to the caller (the cubit),
/// which shows the error state with Retry.
abstract class DashboardBaseRepository {
  Future<List<CreateKnowledgeModel>> fetchAllKnowledgeDocuments();

  Future<List<DocumentUtilizationModel>> fetchAllDocumentUtilization();

  /// Records the last two reads skipped because they could not be parsed
  /// (KH-DASH-09).
  int get lastUnreadableCount;
}
