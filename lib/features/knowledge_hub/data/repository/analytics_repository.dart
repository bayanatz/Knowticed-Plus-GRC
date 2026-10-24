/// Module: knowledge_hub/data/repository
///
///*************************** FILE INFO ****************************///
/// File Name: analytics_repository.dart
/// Description: Implements [AnalyticsBaseRepository] over the comments and
///              utilization Firebase service.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'package:knowticed_plus/features/knowledge_hub/domain/base_repository/analytics_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/create_comment_firebase_service.dart';

class AnalyticsRepository implements AnalyticsBaseRepository {
  AnalyticsRepository(this._services);

  final CommentsFirebaseServices _services;

  @override
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  ) => _services.fetchFileActionsByKnowledgeId(knowledgeId);

  @override
  Future<EmployeeData?> fetchUserDataByUserId(String userId) =>
      _services.fetchUserDataByUserId(userId);
}
