/// Module: knowledge_hub/kh6_approvals/data/repository
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_repository.dart
/// Description: Firestore implementation of [ApprovalsBaseRepository].
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh6_approvals/domain/base_repository/approvals_base_repository.dart';

class ApprovalsRepository implements ApprovalsBaseRepository {
  ApprovalsRepository({
    required ApprovalsFirebaseServices approvalsServices,
    required KnowledgeHubFirebaseServices knowledgeHubServices,
  }) : _approvals = approvalsServices,
       _knowledgeHub = knowledgeHubServices;

  final ApprovalsFirebaseServices _approvals;
  final KnowledgeHubFirebaseServices _knowledgeHub;

  @override
  Future<Either<Failure, KnowledgeFetchResult>> fetchAllKnowledgeResult() =>
      _approvals.fetchAllKnowledgeResult();

  @override
  Future<List<EmployeeData>> fetchAllEmployees() =>
      _approvals.fetchAllEmployees();

  @override
  Future<EmployeeData?> fetchUserDataByEmail(String email) =>
      _approvals.fetchUserDataByEmail(email);

  @override
  Future<EmployeeData?> fetchUserDataByUserId(String userId) =>
      _approvals.fetchUserDataByUserId(userId);

  @override
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) => _approvals.fetchMultipleUserData(userIds);

  @override
  Future<String> fetchDepartmentNameById(String departmentId) =>
      _approvals.fetchDepartmentNameById(departmentId);

  @override
  Future<Map<String, String>> fetchMultipleDepartmentNames(
    List<String> departmentIds,
  ) => _approvals.fetchMultipleDepartmentNames(departmentIds);

  @override
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) => _approvals.fetchCommentsByKnowledgeId(knowledgeId);

  @override
  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  }) => _approvals.addCommentToKnowledge(
    knowledgeId: knowledgeId,
    comment: comment,
  );

  @override
  Future<bool> approveKnowledge({
    required String knowledgeId,
    required String approvalJustification,
  }) => _approvals.approveKnowledge(
    knowledgeId: knowledgeId,
    approvalJustification: approvalJustification,
  );

  @override
  Future<bool> rejectKnowledge({
    required String knowledgeId,
    required String rejectionReason,
  }) => _approvals.rejectKnowledge(
    knowledgeId: knowledgeId,
    rejectionReason: rejectionReason,
  );

  @override
  Future<bool> requestRevision({
    required String knowledgeId,
    required String notes,
  }) => _approvals.requestRevision(knowledgeId: knowledgeId, notes: notes);

  @override
  Future<bool> createOrUpdateApproval({
    required String knowledgeId,
    required String status,
    String? rejectionReason,
    String? approvalJustification,
  }) => _approvals.createOrUpdateApproval(
    knowledgeId: knowledgeId,
    status: status,
    rejectionReason: rejectionReason,
    approvalJustification: approvalJustification,
  );

  @override
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) => _approvals.updateSubmissionStatus(
    knowledgeId: knowledgeId,
    newStatus: newStatus,
  );

  @override
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) => _approvals.recordFileAction(
    knowledgeId: knowledgeId,
    typeOfAction: typeOfAction,
    employeeId: employeeId,
  );

  @override
  Future<Map<String, int>> getFileActionStats(String knowledgeId) =>
      _approvals.getFileActionStats(knowledgeId);

  @override
  Future<String?> getRemovalReason(String knowledgeId) =>
      _knowledgeHub.getRemovalReason(knowledgeId);
}
