/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/controller/create_knowledge_cubit
/// ************************* FILE INFO *************************** ///
/// File Name: create_knowledge_submission.dart
/// Description: Saving a new or edited document and the submission
///              notifications.
/// Author: Amr Mesbah
/// Created at: 15/10/2026

part of '../create_knowledge_cubit.dart';

mixin CreateKnowledgeSubmission
    on CreateKnowledgeCubitBase, CreateKnowledgeLoading {
  /// Uploads the new files, then creates the document (or updates
  /// [editingKnowledgeId]). True only when everything was saved
  /// (KH-CREATE-04). When [notifySupervisor] is set, the approver and the
  /// author are notified after a successful save.
  Future<bool> submitKnowledge({
    required KnowledgeDraft draft,
    File? newImage,
    File? newDocument,
    String? newDocumentFileName,
    String? editingKnowledgeId,
    required bool notifySupervisor,
  }) async {
    try {
      String? imageUrl = draft.imageUrl;
      String? documentUrl = draft.documentUrl;
      if (newImage != null) {
        imageUrl = await _repository.uploadImage(newImage);
        if (imageUrl == null) return false;
      }
      if (newDocument != null) {
        documentUrl = await _repository.uploadDocument(
          newDocument,
          newDocumentFileName ?? draft.documentFileName,
        );
        if (documentUrl == null) return false;
      }
      if (documentUrl == null || documentUrl.isEmpty) return false;

      final KnowledgeDraft saved = draft.withFiles(
        imageUrl: imageUrl,
        documentUrl: documentUrl,
      );
      final String? savedId = editingKnowledgeId == null
          ? await _repository.createKnowledge(saved)
          : (await _repository.updateKnowledge(editingKnowledgeId, saved)
                ? editingKnowledgeId
                : null);
      if (savedId == null) return false;

      if (notifySupervisor) {
        await sendNotificationToSupervisor(
          knowledgeId: savedId,
          documentNameEn: draft.nameEnglish,
          documentNameAr: draft.nameArabic,
          employeeEmail: draft.createdByEmail,
        );
      }
      return true;
    } catch (e) {
      khLog('submitKnowledge failed: $e', name: 'CreateKnowledgeCubit');
      return false;
    }
  }

  /// Stores the editor's reason on [documentId]. True when it was saved.
  Future<bool> attachEditReason({
    required String documentId,
    required String reason,
  }) async {
    try {
      return await _repository.attachEditReason(
        documentId: documentId,
        reason: reason,
      );
    } catch (e) {
      khLog('attachEditReason failed: $e', name: 'CreateKnowledgeCubit');
      return false;
    }
  }

  /// Confirms the submission to the author and assigns the review to the
  /// approver. True when the approver was notified.
  Future<bool> sendNotificationToSupervisor({
    required String knowledgeId,
    required String documentNameEn,
    required String documentNameAr,
    required String employeeEmail,
  }) async {
    try {
      final bool isArabic = KhLocale.isArabicNow;
      await KnowledgeHubNotificationService.notifyAuthorOfSubmission(
        documentId: knowledgeId,
        senderEmail: employeeEmail,
        authorEmail: employeeEmail,
        documentNameEn: documentNameEn,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );
      final String? supervisorEmail = await getSupervisorEmail();
      if (supervisorEmail == null) return false;
      return await KnowledgeHubNotificationService.notifyApproverOfReviewRequest(
        documentId: knowledgeId,
        senderEmail: employeeEmail,
        approverEmail: supervisorEmail,
        documentNameEn: documentNameEn,
        documentNameAr: documentNameAr,
        isArabic: isArabic,
      );
    } catch (e) {
      khLog(
        'submission notifications failed: $e',
        name: 'CreateKnowledgeCubit',
      );
      return false;
    }
  }
}
