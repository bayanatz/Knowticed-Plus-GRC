/// Module: knowledge_hub/kh1_create_new_knowledge/data/repository
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_repository.dart
/// Description: Firestore implementation of [CreateKnowledgeBaseRepository].
/// Author: Amr Mesbah
/// Created at: 15/10/2026
library;

import 'dart:io';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';

import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/knowledge_seed_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/base_repository/create_knowledge_base_repository.dart';
import 'package:knowticed_plus/features/knowledge_hub/kh1_create_new_knowledge/domain/entities/knowledge_draft.dart';

class CreateKnowledgeRepository implements CreateKnowledgeBaseRepository {
  CreateKnowledgeRepository(this._services, this._seed);

  final KnowledgeHubFirebaseServices _services;
  final KnowledgeSeedService _seed;

  @override
  Future<List<CreateKnowledgeModel>> fetchVisibleKnowledge({
    required String? userDepartment,
  }) => _services.fetchVisibleKnowledge(userDepartment: userDepartment);

  @override
  int get lastUnreadableCount => _services.lastUnreadableCount;

  @override
  Future<List<DepartmentModelPro>> fetchAllDepartments() =>
      _services.fetchAllDepartments();

  @override
  Future<CreateKnowledgeModel?> fetchKnowledgeByKnowledgeId(
    String knowledgeId,
  ) => _services.fetchKnowledgeByKnowledgeId(knowledgeId);

  @override
  Future<String?> getSupervisorEmail({
    String? employeeId,
    String? departmentId,
  }) => _services.getSupervisorEmailFromFirestore(
    employeeId: employeeId,
    departmentId: departmentId,
  );

  @override
  Future<String?> uploadImage(File image) => _services.uploadImage(image);

  @override
  Future<String?> uploadDocument(File document, String fileName) =>
      _services.uploadDocument(document, fileName);

  @override
  Future<String?> createKnowledge(KnowledgeDraft draft) =>
      _services.createKnowledgeHubFromParams(
        knowledgeImage: draft.imageUrl ?? '',
        nameEnglish: draft.nameEnglish,
        nameArabic: draft.nameArabic,
        descriptionEnglish: draft.descriptionEnglish,
        descriptionArabic: draft.descriptionArabic,
        knowledgeDocumentType: draft.documentType,
        owningDepartment: draft.owningDepartment,
        limitedDepartments: draft.limitedDepartments,
        schedulePublishing: draft.schedulePublishing,
        startDateTime: draft.startDateTime,
        endDateTime: draft.endDateTime,
        startTime: draft.startTime,
        endTime: draft.endTime,
        imageUrl: draft.imageUrl ?? '',
        documentUrl: draft.documentUrl ?? '',
        documentFileName: draft.documentFileName,
        documentExtension: draft.documentExtension,
        documentSize: draft.documentSize,
        createdByEmail: draft.createdByEmail,
        timeStamp: DateTime.now().toIso8601String(),
        status: draft.status,
      );

  @override
  Future<bool> updateKnowledge(String knowledgeId, KnowledgeDraft draft) =>
      _services.updateKnowledgeHub(
        knowledgeId: knowledgeId,
        knowledgeImage: draft.imageUrl,
        nameEnglish: draft.nameEnglish,
        nameArabic: draft.nameArabic,
        descriptionEnglish: draft.descriptionEnglish,
        descriptionArabic: draft.descriptionArabic,
        knowledgeDocumentType: draft.documentType,
        owningDepartment: draft.owningDepartment,
        limitedDepartments: draft.limitedDepartments,
        schedulePublishing: draft.schedulePublishing,
        startDateTime: draft.startDateTime,
        endDateTime: draft.endDateTime,
        startTime: draft.startTime,
        endTime: draft.endTime,
        imageUrl: draft.imageUrl,
        documentUrl: draft.documentUrl,
        documentFileName: draft.documentFileName,
        documentExtension: draft.documentExtension,
        documentSize: draft.documentSize,
        createdByEmail: draft.createdByEmail,
        timeStamp: DateTime.now().toIso8601String(),
        status: draft.status,
      );

  @override
  Future<bool> attachEditReason({
    required String documentId,
    required String reason,
  }) => _services.attachEditReason(documentId: documentId, reason: reason);

  @override
  Future<int> seedSampleDocuments({
    required String createdByEmail,
    required String owningDepartment,
  }) => _seed.seedAllStates(
    createdByEmail: createdByEmail,
    owningDepartment: owningDepartment,
  );

  @override
  Future<int> backfillVisibilityFields() =>
      _services.backfillVisibilityFields();

  @override
  Future<int> migrateFileActionEmployeeIds(
    Map<String, String> employeeIdByEmail,
  ) => _services.migrateFileActionEmployeeIds(employeeIdByEmail);
}
