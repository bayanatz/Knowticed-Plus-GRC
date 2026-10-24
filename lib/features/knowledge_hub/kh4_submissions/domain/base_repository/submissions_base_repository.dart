/// Module: knowledge_hub/kh4_submissions/domain/base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_base_repository.dart
/// Description: Domain contract for everything the Submissions screens read
///              and write — the cubit depends on this, never on a service.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_hub_firebase_services.dart'
    show RemoveKnowledgeReasonResult;

abstract class SubmissionsBaseRepository {
  /// The documents created by [creatorEmail] only.
  Future<List<CreateKnowledgeModel>> fetchSubmissionsByCreator(
    String creatorEmail,
  );

  /// Appends [newStatus] to the document's status history.
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  });

  /// Comments on [knowledgeId]; throws when the read fails.
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  );

  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  });

  Future<bool> updateComment({
    required String knowledgeId,
    required String commentId,
    required CreateNewCommentModel updatedComment,
  });

  Future<bool> deleteComment({
    required String knowledgeId,
    required String commentId,
  });

  Future<EmployeeData?> fetchUserDataByUserId(String userId);

  Future<EmployeeData?> fetchUserDataByEmail(String email);

  Future<Map<String, EmployeeData>> fetchMultipleUserData(List<String> userIds);

  /// Saves one view or download of [knowledgeId] by [employeeId].
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  });

  /// Writes one in-app notification document.
  Future<void> saveNotificationRecord(Map<String, dynamic> data);

  /// Asks the reviewer ([receiverEmail]) to look at a pending document.
  Future<bool> remindOfPendingReview({
    required String documentId,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentNameEn,
    required String documentNameAr,
  });

  /// Marks the document `removed` with [justification]; null when it cannot
  /// be found or the write fails.
  Future<RemoveKnowledgeReasonResult?> removeKnowledgeWithReason({
    required String documentId,
    required String currentUserEmail,
    required String justification,
  });

  /// "Document withdrawn" (bilingual template) to [receiverEmail].
  Future<bool> notifyOfRemoval({
    required String documentId,
    required String senderEmail,
    required String receiverEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  });

  /// "Document archived" (bilingual template) to its owner.
  Future<bool> notifyOwnerOfArchival({
    required String documentId,
    required String senderEmail,
    required String ownerEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  });

  /// Why the document was last removed / approved, or null.
  Future<String?> getRemovalReason(String knowledgeId);
  Future<String?> getApprovalReason(String knowledgeId);

  /// Uploads a comment attachment; returns its download URL or null.
  Future<String?> uploadCommentAttachment({
    required File file,
    required String knowledgeId,
    required String fileName,
  });
}
