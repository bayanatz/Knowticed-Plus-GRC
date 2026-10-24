/// Module: knowledge_hub/kh3_view_knowledge_details/data/repository
/// ************************* FILE INFO *************************** ///
/// File Name: comments_repository.dart
/// Description: Firestore implementation of [CommentsBaseRepository].
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/create_comment_firebase_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh3_view_knowledge_details/domain/base_repository/comments_base_repository.dart';

class CommentsRepository implements CommentsBaseRepository {
  CommentsRepository(this._comments, this._knowledge);

  final CommentsFirebaseServices _comments;
  final KnowledgeHubFirebaseServices _knowledge;

  @override
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) => _comments.fetchCommentsByKnowledgeId(knowledgeId);

  @override
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
    String knowledgeId,
  ) => _comments.streamCommentsByKnowledgeId(knowledgeId);

  @override
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) => _comments.fetchMultipleUserData(userIds);

  @override
  Future<EmployeeData?> fetchUserDataByUserId(String userId) =>
      _comments.fetchUserDataByUserId(userId);

  @override
  Future<Map<String, dynamic>?> uploadCommentAttachment(File file) =>
      _comments.uploadCommentAttachment(file);

  @override
  Future<bool> createComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
    String? attachmentUrl,
    String? attachmentName,
  }) => _comments.createComment(
    knowledgeId: knowledgeId,
    commentText: commentText,
    createdById: createdById,
    createdByEmail: createdByEmail,
    attachmentExtension: attachmentExtension,
    attachmentSize: attachmentSize,
    attachmentUrl: attachmentUrl,
    attachmentName: attachmentName,
  );

  @override
  Future<bool> deleteComment(String commentId) =>
      _comments.deleteComment(commentId);

  @override
  Future<int> getCommentCount(String knowledgeId) =>
      _comments.getCommentCount(knowledgeId);

  @override
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) => _comments.recordFileAction(
    knowledgeId: knowledgeId,
    typeOfAction: typeOfAction,
    employeeId: employeeId,
  );

  @override
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  ) => _comments.fetchFileActionsByKnowledgeId(knowledgeId);

  @override
  Stream<List<DocumentUtilizationModel>> streamFileActionsByKnowledgeId(
    String knowledgeId,
  ) => _comments.streamFileActionsByKnowledgeId(knowledgeId);

  @override
  Future<CreateKnowledgeModel?> fetchKnowledgeByKnowledgeId(
    String knowledgeId,
  ) => _knowledge.fetchKnowledgeByKnowledgeId(knowledgeId);
}
