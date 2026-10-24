/// Module: knowledge_hub/kh6_approvals/domain/base_repository
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_base_repository.dart
/// Description: Contract the approvals cubit reads and writes its data through.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.dart';

/// Everything the approvals queue and the approvals details screen need from
/// Firestore. The cubit depends on this, never on the Firebase service.
abstract class ApprovalsBaseRepository {
  /// The approver's queue source: readable documents plus the unreadable count.
  Future<Either<Failure, KnowledgeFetchResult>> fetchAllKnowledgeResult();

  Future<List<EmployeeData>> fetchAllEmployees();

  Future<EmployeeData?> fetchUserDataByEmail(String email);

  Future<EmployeeData?> fetchUserDataByUserId(String userId);

  Future<Map<String, EmployeeData>> fetchMultipleUserData(List<String> userIds);

  Future<String> fetchDepartmentNameById(String departmentId);

  /// Batch lookup: department id → display name.
  Future<Map<String, String>> fetchMultipleDepartmentNames(
    List<String> departmentIds,
  );

  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  );

  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  });

  Future<bool> approveKnowledge({
    required String knowledgeId,
    required String approvalJustification,
  });

  Future<bool> rejectKnowledge({
    required String knowledgeId,
    required String rejectionReason,
  });

  Future<bool> requestRevision({
    required String knowledgeId,
    required String notes,
  });

  Future<bool> createOrUpdateApproval({
    required String knowledgeId,
    required String status,
    String? rejectionReason,
    String? approvalJustification,
  });

  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  });

  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  });

  Future<Map<String, int>> getFileActionStats(String knowledgeId);

  /// The reason saved with the document's last "removed" status, or null.
  Future<String?> getRemovalReason(String knowledgeId);
}
