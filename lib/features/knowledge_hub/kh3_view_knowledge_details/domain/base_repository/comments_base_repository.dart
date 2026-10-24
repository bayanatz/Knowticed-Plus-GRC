/// Module: knowledge_hub/kh3_view_knowledge_details/domain/base_repository
/// ************************* FILE INFO *************************** ///
/// File Name: comments_base_repository.dart
/// Description: Contract the comments cubit reads and writes through.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';

abstract class CommentsBaseRepository {
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  );

  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
    String knowledgeId,
  );

  Future<Map<String, EmployeeData>> fetchMultipleUserData(List<String> userIds);

  Future<EmployeeData?> fetchUserDataByUserId(String userId);

  /// {url, name, extension, size} of the uploaded file, or null on failure.
  Future<Map<String, dynamic>?> uploadCommentAttachment(File file);

  Future<bool> createComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
    String? attachmentUrl,
    String? attachmentName,
  });

  Future<bool> deleteComment(String commentId);

  Future<int> getCommentCount(String knowledgeId);

  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  });

  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  );

  Stream<List<DocumentUtilizationModel>> streamFileActionsByKnowledgeId(
    String knowledgeId,
  );

  Future<CreateKnowledgeModel?> fetchKnowledgeByKnowledgeId(String knowledgeId);
}
