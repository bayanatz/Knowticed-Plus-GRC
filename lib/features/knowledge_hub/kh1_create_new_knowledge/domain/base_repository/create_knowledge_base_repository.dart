/// Module: knowledge_hub/kh1_create_new_knowledge/domain/base_repository
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_base_repository.dart
/// Description: Contract the create / hub cubit reads and writes through.
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/entities/knowledge_draft.dart';

abstract class CreateKnowledgeBaseRepository {
  /// Published documents the user may see. Throws when the read fails.
  Future<List<CreateKnowledgeModel>> fetchVisibleKnowledge({
    required String? userDepartment,
  });

  /// Documents the last [fetchVisibleKnowledge] could not read.
  int get lastUnreadableCount;

  Future<List<DepartmentModelPro>> fetchAllDepartments();

  Future<CreateKnowledgeModel?> fetchKnowledgeByKnowledgeId(String knowledgeId);

  Future<String?> getSupervisorEmail({
    String? employeeId,
    String? departmentId,
  });

  /// Download URL of the uploaded file, or null when the upload failed.
  Future<String?> uploadImage(File image);

  Future<String?> uploadDocument(File document, String fileName);

  /// The new document's knowledgeId, or null when it could not be saved.
  Future<String?> createKnowledge(KnowledgeDraft draft);

  Future<bool> updateKnowledge(String knowledgeId, KnowledgeDraft draft);

  Future<bool> attachEditReason({
    required String documentId,
    required String reason,
  });

  /// Debug tool: writes the sample documents. Returns how many were written.
  /// Throws when the write fails.
  Future<int> seedSampleDocuments({
    required String createdByEmail,
    required String owningDepartment,
  });

  /// One-off fix (KH-CREATE-06): adds the visibility fields to older
  /// documents. Returns how many were updated. Throws when it fails.
  Future<int> backfillVisibilityFields();

  /// One-off fix (KH-CREATE-14): gives older file actions an employee ID,
  /// using [employeeIdByEmail] (lower-case e-mail → employee ID). Returns how
  /// many were updated. Throws when it fails.
  Future<int> migrateFileActionEmployeeIds(
    Map<String, String> employeeIdByEmail,
  );
}
