/// Module: knowledge_hub/data/data_source/remote_data_source/approvals_firebase_services.part.2
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_services_part2_methods.dart
/// Description: Methods of `ApprovalsFirebaseServices` — split out of `approvals_firebase_services.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../approvals_firebase_services.dart';

// Split from approvals_firebase_services.part.2.dart to keep every file under 700 lines.

mixin ApprovalsServicesPart2Methods2
    on
        ApprovalsFirebaseServicesBase,
        ApprovalsServicesPart1,
        ApprovalsServicesPart2 {
  /// Approve knowledge document - updates both Create_Knowledge and Approvals collections
  Future<bool> approveKnowledge({
    required String knowledgeId,
    required String approvalJustification,
  }) async {
    try {
      _debugPaths('approveKnowledge');

      khLog('🟢 Approving knowledge document: $knowledgeId');

      // ✅ STEP 1: Fetch the document to check scheduling settings
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        khLog('❌ Document not found: $knowledgeId');
        return false;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data[CreateKnowledgeKeys.pendingEdit] is Map) {
        final bool applied = await _applyPendingEdit(doc.reference, data);
        if (!applied) return false;
        khSystemLog(KhLogAction.approveDocument); // System Logs §3
        return await createOrUpdateApproval(
          knowledgeId: knowledgeId,
          status: 'published',
          approvalJustification: approvalJustification,
          rejectionReason: '',
        );
      }

      if (!_latestStatusIsPending(data)) {
        khLog('⛔ approveKnowledge refused: $knowledgeId is not pending');
        return false;
      }

      // ✅ STEP 2: Check if document has scheduled publishing enabled
      List<dynamic> schedulePublishingArray =
          data[CreateKnowledgeKeys.schedulePublishing] ?? [];
      // KH-APPROVE-11: the latest value (same as currentSchedulePublishing).
      bool schedulePublishing =
          schedulePublishingArray.isNotEmpty &&
          schedulePublishingArray.last == true;

      khLog('📅 schedulePublishing value: $schedulePublishing');

      // ✅ STEP 3: Determine the correct status based on scheduling
      String newStatus;
      if (schedulePublishing) {
        // Scheduling is enabled → set to 'approved' (will become 'published' when scheduled time arrives)
        newStatus = 'approved';
        khLog(
          '📅 Document has scheduled publishing enabled → Setting status to: approved',
        );
      } else {
        // NO scheduling → set to 'published' immediately
        newStatus = 'published';
        khLog(
          '✅ Document has NO scheduled publishing → Setting status to: published',
        );
      }

      khLog('🎯 Final status to be set: $newStatus');

      // ✅ STEP 4: Update status in Create_Knowledge collection
      bool statusUpdated = await updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: newStatus,
      );

      if (!statusUpdated) {
        khLog('❌ Failed to update status in Create_Knowledge');
        return false;
      }

      // ✅ STEP 5: Create/Update approval record in Approvals collection
      bool approvalCreated = await createOrUpdateApproval(
        knowledgeId: knowledgeId,
        status: newStatus,
        approvalJustification: approvalJustification,
        rejectionReason: '',
      );

      if (!approvalCreated) {
        khLog('❌ Failed to create approval record');
        return false;
      }

      khLog(
        '✅ Knowledge document approved successfully with status: $newStatus',
      );
      khSystemLog(KhLogAction.approveDocument); // System Logs §3
      if (KhLogAction.isPublished(newStatus)) {
        khSystemLog(KhLogAction.publishDocument);
      }
      return true;
    } catch (e) {
      khLog('❌ Error approving knowledge: $e');
      rethrow;
    }
  }

  Future<bool> _applyPendingEdit(
    DocumentReference ref,
    Map<String, dynamic> data,
  ) async {
    try {
      final Map<String, dynamic> edit = Map<String, dynamic>.from(
        data[CreateKnowledgeKeys.pendingEdit] as Map,
      );
      final List<dynamic> liveStatuses = List<dynamic>.from(
        data[CreateKnowledgeKeys.status] ?? const [],
      );
      final String keep = liveStatuses.isEmpty
          ? 'published'
          : liveStatuses.last.toString().trim().toLowerCase();

      final List<dynamic> statuses = List<dynamic>.from(
        edit[CreateKnowledgeKeys.status] ?? const [],
      );
      if (statuses.isEmpty) {
        statuses.add(keep);
      } else {
        statuses[statuses.length - 1] = keep;
      }
      edit[CreateKnowledgeKeys.status] = statuses;
      edit[CreateKnowledgeKeys.currentStatus] = keep;
      edit[CreateKnowledgeKeys.pendingEdit] = FieldValue.delete();
      edit[CreateKnowledgeKeys.pendingEditAt] = FieldValue.delete();
      edit[CreateKnowledgeKeys.pendingEditBy] = FieldValue.delete();
      edit[CreateKnowledgeKeys.updatedAt] = FieldValue.serverTimestamp();
      await ref.update(edit);
      return true;
    } catch (e) {
      khLog('❌ Applying the pending edit failed: $e');
      rethrow;
    }
  }
}
