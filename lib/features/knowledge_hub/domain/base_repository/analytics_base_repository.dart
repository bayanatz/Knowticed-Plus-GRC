/// Module: knowledge_hub/domain/base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_base_repository.dart
/// Description: Domain contract for the document analytics (views, downloads
///              and who made them) shared by the hub, details and submissions.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';

abstract class AnalyticsBaseRepository {
  /// Every view and download recorded for [knowledgeId].
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  );

  /// The employee whose id (or e-mail) is [userId], if found.
  Future<EmployeeData?> fetchUserDataByUserId(String userId);
}
