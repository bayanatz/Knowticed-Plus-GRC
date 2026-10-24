/// Module: knowledge_hub/kh4_submissions/data/repository
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_repository.dart
/// Description: Implements [SubmissionsBaseRepository] over the shared
///              Knowledge Hub Firebase services and notification service.
/// Author: Amr Mesbah
/// Created at: 11/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/notifications/knowledge_hub_notification_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/submissions_firebase_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh4_submissions/domain/base_repository/submissions_base_repository.dart';
import 'package:knowticed_plus/features/notification/domain/enums/knowledge_hub/knowledge_hub_notification_pages.dart';

class SubmissionsRepository implements SubmissionsBaseRepository {
  SubmissionsRepository({
    required SubmissionsFirebaseServices submissionsServices,
    required KnowledgeHubFirebaseServices knowledgeHubServices,
    required ApprovalsFirebaseServices approvalsServices,
  }) : _submissions = submissionsServices,
       _knowledgeHub = knowledgeHubServices,
       _approvals = approvalsServices;

  final SubmissionsFirebaseServices _submissions;
  final KnowledgeHubFirebaseServices _knowledgeHub;
  final ApprovalsFirebaseServices _approvals;

  @override
  Future<List<CreateKnowledgeModel>> fetchSubmissionsByCreator(
    String creatorEmail,
  ) => _submissions.fetchSubmissionsByCreator(creatorEmail);

  @override
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) => _submissions.updateSubmissionStatus(
    knowledgeId: knowledgeId,
    newStatus: newStatus,
  );

  @override
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) => _submissions.fetchCommentsByKnowledgeId(knowledgeId);

  @override
  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  }) => _submissions.addCommentToKnowledge(
    knowledgeId: knowledgeId,
    comment: comment,
  );

  @override
  Future<bool> updateComment({
    required String knowledgeId,
    required String commentId,
    required CreateNewCommentModel updatedComment,
  }) => _submissions.updateComment(
    knowledgeId: knowledgeId,
    commentId: commentId,
    updatedComment: updatedComment,
  );

  @override
  Future<bool> deleteComment({
    required String knowledgeId,
    required String commentId,
  }) => _submissions.deleteComment(
    knowledgeId: knowledgeId,
    commentId: commentId,
  );

  @override
  Future<EmployeeData?> fetchUserDataByUserId(String userId) =>
      _submissions.fetchUserDataByUserId(userId);

  @override
  Future<EmployeeData?> fetchUserDataByEmail(String email) =>
      _approvals.fetchUserDataByEmail(email);

  @override
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) => _submissions.fetchMultipleUserData(userIds);

  @override
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) => _submissions.recordFileAction(
    knowledgeId: knowledgeId,
    typeOfAction: typeOfAction,
    employeeId: employeeId,
  );

  @override
  Future<void> saveNotificationRecord(Map<String, dynamic> data) =>
      _knowledgeHub.saveNotificationRecord(data);

  @override
  Future<bool> remindOfPendingReview({
    required String documentId,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    required String documentNameEn,
    required String documentNameAr,
  }) => KnowledgeHubNotificationService.remindOfPendingReview(
    documentId: documentId,
    // Sent to the reviewer, so View opens the document for approval.
    page: KnowledgeHubNotificationPage.approvalsDetails,
    senderEmail: senderEmail,
    receiverEmail: receiverEmail,
    isArabic: isArabic,
    documentNameEn: documentNameEn,
    documentNameAr: documentNameAr,
  );

  @override
  Future<RemoveKnowledgeReasonResult?> removeKnowledgeWithReason({
    required String documentId,
    required String currentUserEmail,
    required String justification,
  }) => _knowledgeHub.removeKnowledgeWithReason(
    documentId: documentId,
    currentUserEmail: currentUserEmail,
    justification: justification,
  );

  @override
  Future<bool> notifyOfRemoval({
    required String documentId,
    required String senderEmail,
    required String receiverEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) => KnowledgeHubNotificationService.notifyOfRemoval(
    documentId: documentId,
    senderEmail: senderEmail,
    receiverEmail: receiverEmail,
    documentNameEn: documentNameEn,
    documentNameAr: documentNameAr,
    isArabic: isArabic,
  );

  @override
  Future<bool> notifyOwnerOfArchival({
    required String documentId,
    required String senderEmail,
    required String ownerEmail,
    required String documentNameEn,
    required String documentNameAr,
    required bool isArabic,
  }) => KnowledgeHubNotificationService.notifyOwnerOfArchival(
    documentId: documentId,
    senderEmail: senderEmail,
    ownerEmail: ownerEmail,
    documentNameEn: documentNameEn,
    documentNameAr: documentNameAr,
    isArabic: isArabic,
  );

  @override
  Future<String?> getRemovalReason(String knowledgeId) =>
      _knowledgeHub.getRemovalReason(knowledgeId);

  @override
  Future<String?> getApprovalReason(String knowledgeId) =>
      _knowledgeHub.getApprovalReason(knowledgeId);

  @override
  Future<String?> uploadCommentAttachment({
    required File file,
    required String knowledgeId,
    required String fileName,
  }) => _knowledgeHub.uploadCommentAttachment(
    file: file,
    knowledgeId: knowledgeId,
    fileName: fileName,
  );
}
