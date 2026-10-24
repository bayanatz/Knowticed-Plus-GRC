/// Module: knowledge_hub/data/data_source/remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_firebase_services.part.2.dart
/// Description: Mixin methods of `ApprovalsFirebaseServices` — split out of `approvals_firebase_services.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_firebase_services.dart';

mixin ApprovalsServicesPart2
    on ApprovalsFirebaseServicesBase, ApprovalsServicesPart1 {
  Future<bool> requestRevision({
    required String knowledgeId,
    required String notes,
  }) async {
    try {
      final snap = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return false;
      final doc = snap.docs.first;
      final data = doc.data();
      if (!_latestStatusIsPending(data)) return false;

      final statuses = List<dynamic>.from(
        data[CreateKnowledgeKeys.status] ?? const [],
      );
      final reasons = List<dynamic>.from(
        data[CreateKnowledgeKeys.statusReason] ?? const [],
      );
      while (reasons.length < statuses.length) {
        reasons.add('');
      }
      final timestamps = List<dynamic>.from(
        data[CreateKnowledgeKeys.timestamps] ?? const [],
      );
      statuses.add('revision_requested');
      reasons.add(notes);
      timestamps.add(DateTime.now().millisecondsSinceEpoch);

      await doc.reference.update({
        CreateKnowledgeKeys.status: statuses,
        CreateKnowledgeKeys.statusReason: reasons,
        CreateKnowledgeKeys.timestamps: timestamps,
        CreateKnowledgeKeys.currentStatus: 'revision_requested',
        CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
      });
      khSystemLog(KhLogAction.requestDocumentRevision); // System Logs §3
      return true;
    } catch (e) {
      khLog('requestRevision failed: $e');
      rethrow;
    }
  }

  /// True when the document's LATEST status is pending approval.
  /// Throws a parked edit away; the live version is untouched (KH p.13).
  Future<bool> _discardPendingEdit(DocumentReference ref) async {
    try {
      await ref.update({
        CreateKnowledgeKeys.pendingEdit: FieldValue.delete(),
        CreateKnowledgeKeys.pendingEditAt: FieldValue.delete(),
        CreateKnowledgeKeys.pendingEditBy: FieldValue.delete(),
        CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      khLog('❌ Discarding the pending edit failed: $e');
      rethrow;
    }
  }

  bool _latestStatusIsPending(Map<String, dynamic> data) {
    final statuses = List<dynamic>.from(
      data[CreateKnowledgeKeys.status] ?? const [],
    );
    if (statuses.isEmpty) return false;
    final latest = statuses.last.toString().trim().toLowerCase();
    return latest == 'pending_approval' ||
        latest == 'pending' ||
        latest == 'scheduled';
  }

  /// Update submission status (for admin actions)
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      _debugPaths('updateSubmissionStatus');

      khLog(
        'Updating submission status for knowledgeId: $knowledgeId to $newStatus',
      );

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        khLog('No document found with knowledgeId: $knowledgeId');
        return false;
      }

      var doc = querySnapshot.docs.first;

      // Get existing model
      Map<String, dynamic> existingData = doc.data() as Map<String, dynamic>;
      CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
        existingData,
        doc.id,
      );

      // Add new status to the array
      List<String> updatedStatus = List<String>.from(existingModel.status)
        ..add(newStatus);
      List<int> updatedTimestamps = List<int>.from(existingModel.timestamps)
        ..add(DateTime.now().millisecondsSinceEpoch);

      await doc.reference.update({
        CreateKnowledgeKeys.status: updatedStatus,
        CreateKnowledgeKeys.currentStatus: updatedStatus.isEmpty
            ? ''
            : updatedStatus.last.toString(), // KH-CREATE-06
        CreateKnowledgeKeys.timestamps: updatedTimestamps,
        CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
      });

      khLog('Submission status updated successfully');
      return true;
    } catch (e) {
      khLog('Error updating submission status: $e');
      rethrow;
    }
  }

  // ==================== APPROVALS MANAGEMENT ====================

  /// Create or update approval document in Approvals collection
  Future<bool> createOrUpdateApproval({
    required String knowledgeId,
    required String status,
    String? rejectionReason,
    String? approvalJustification,
  }) async {
    try {
      _debugPaths('createOrUpdateApproval');

      khLog(
        'Creating/Updating approval for knowledgeId: $knowledgeId with status: $status',
      );

      // ✅ Use dynamic path
      // Reference to the approval document (using knowledgeId as document ID)
      DocumentReference approvalRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeApprovals))
          .doc(knowledgeId);

      // Check if approval document already exists
      DocumentSnapshot approvalSnapshot = await approvalRef.get();

      if (approvalSnapshot.exists) {
        // Document exists - update it by adding new values to arrays
        khLog('Approval document exists, updating...');

        Map<String, dynamic> existingData =
            approvalSnapshot.data() as Map<String, dynamic>;
        ApprovalModel existingApproval = ApprovalModel.fromJson(existingData);

        // Create updated model using copyWith
        ApprovalModel updatedApproval = existingApproval.copyWith(
          status: status,
          rejectionReason: rejectionReason ?? '',
          approvalJustification: approvalJustification ?? '',
        );

        // Save updated data
        await approvalRef.update(updatedApproval.toJson());
        khLog('Approval document updated successfully');
      } else {
        // Document doesn't exist - create new one
        khLog('Creating new approval document...');

        ApprovalModel newApproval = ApprovalModel.createNew(
          knowledgeId: knowledgeId,
          status: status,
          rejectionReason: rejectionReason,
          approvalJustification: approvalJustification,
        );

        await approvalRef.set(newApproval.toJson());
        khLog('Approval document created successfully');
      }

      return true;
    } catch (e) {
      khLog('Error creating/updating approval: $e');
      rethrow;
    }
  }

  /// Reject knowledge document - updates both Create_Knowledge and Approvals collections
  Future<bool> rejectKnowledge({
    required String knowledgeId,
    required String rejectionReason,
  }) async {
    try {
      _debugPaths('rejectKnowledge');

      khLog('🔴 Rejecting knowledge document: $knowledgeId');

      final pendingCheck = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();
      if (pendingCheck.docs.isNotEmpty &&
          pendingCheck.docs.first.data()[CreateKnowledgeKeys.pendingEdit]
              is Map) {
        final bool discarded = await _discardPendingEdit(
          pendingCheck.docs.first.reference,
        );
        if (!discarded) return false;
        khSystemLog(KhLogAction.rejectDocument); // System Logs §3
        return await createOrUpdateApproval(
          knowledgeId: knowledgeId,
          status: 'rejected',
          rejectionReason: rejectionReason,
          approvalJustification: '',
        );
      }

      if (pendingCheck.docs.isEmpty ||
          !_latestStatusIsPending(pendingCheck.docs.first.data())) {
        khLog('⛔ rejectKnowledge refused: $knowledgeId is not pending');
        return false;
      }

      // 1. Update status in Create_Knowledge collection
      bool statusUpdated = await updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: 'rejected',
      );

      if (!statusUpdated) {
        khLog('❌ Failed to update status in Create_Knowledge');
        return false;
      }

      // 2. Create/Update approval record in Approvals collection
      bool approvalCreated = await createOrUpdateApproval(
        knowledgeId: knowledgeId,
        status: 'rejected',
        rejectionReason: rejectionReason,
        approvalJustification: '',
      );

      if (!approvalCreated) {
        khLog('❌ Failed to create approval record');
        return false;
      }

      khLog('✅ Knowledge document rejected successfully');
      khSystemLog(KhLogAction.rejectDocument); // System Logs §3
      return true;
    } catch (e) {
      khLog('❌ Error rejecting knowledge: $e');
      rethrow;
    }
  }

  /// Fetch approval details for a specific knowledge document
  Future<ApprovalModel?> fetchApprovalByKnowledgeId(String knowledgeId) async {
    try {
      _debugPaths('fetchApprovalByKnowledgeId');

      khLog('Fetching approval for knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      DocumentSnapshot approvalSnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeApprovals))
          .doc(knowledgeId)
          .get();

      if (!approvalSnapshot.exists) {
        khLog('No approval found for knowledgeId: $knowledgeId');
        return null;
      }

      Map<String, dynamic> data =
          approvalSnapshot.data() as Map<String, dynamic>;
      ApprovalModel approval = ApprovalModel.fromJson(data);

      khLog('Approval fetched successfully');
      return approval;
    } catch (e) {
      khLog('Error fetching approval: $e');
      rethrow;
    }
  }

  // ==================== FILE ACTIONS/UTILIZATION ====================

  /// 13. Record file action (download, view, or export)
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction, // 'download', 'view', or 'export'
    required String employeeId,
  }) async {
    try {
      _debugPaths('recordFileAction');

      // ✅ Use dynamic path
      // Generate new action document reference
      DocumentReference actionRef = _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .doc();

      // Create formatted timestamp
      final String formattedTimeStamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
        'en',
      ).format(DateTime.now());

      // Create DocumentUtilizationModel instance
      final DocumentUtilizationModel actionModel =
          DocumentUtilizationModel.createNew(
            timestamp: formattedTimeStamp,
            fileId: knowledgeId,
            typeOfAction: typeOfAction,
            employeeId: employeeId,
          );

      // Convert model to JSON
      Map<String, dynamic> actionData = actionModel.toJson();

      // Add server timestamp for querying purposes
      actionData[KhFileActionKeys.actionTimestamp] =
          FieldValue.serverTimestamp();

      // Save to Firestore
      await actionRef.set(actionData);

      khLog(
        'File action recorded successfully: $typeOfAction by employee: $employeeId',
      );
      return true;
    } catch (e) {
      khLog('Error recording file action: $e');
      rethrow;
    }
  }

  /// 14. Fetch file actions by knowledge/file ID
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      _debugPaths('fetchFileActionsByKnowledgeId');

      khLog('Fetching file actions for knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .where(KhFileActionKeys.fileId, arrayContains: knowledgeId)
          .get();

      khLog('Query returned ${querySnapshot.docs.length} file actions');

      List<DocumentUtilizationModel> actionsList = [];

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DocumentUtilizationModel model = DocumentUtilizationModel.fromJson(
            data,
          );
          actionsList.add(model);
        } catch (e) {
          khLog('Error parsing action ${doc.id}: $e');
        }
      }

      return actionsList;
    } catch (e) {
      khLog('Error fetching file actions: $e');
      rethrow;
    }
  }

  /// Stream file actions for real-time updates
  Stream<List<DocumentUtilizationModel>> streamFileActionsByKnowledgeId(
    String knowledgeId,
  ) {
    try {
      _debugPaths('streamFileActionsByKnowledgeId');

      // ✅ Use dynamic path
      return _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .where(KhFileActionKeys.fileId, arrayContains: knowledgeId)
          .orderBy(KhFileActionKeys.actionTimestamp, descending: true)
          .snapshots()
          .map((snapshot) {
            List<DocumentUtilizationModel> actionsList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                DocumentUtilizationModel model =
                    DocumentUtilizationModel.fromJson(data);
                actionsList.add(model);
              } catch (e) {
                khLog('Error parsing action ${doc.id}: $e');
              }
            }

            return actionsList;
          });
    } catch (e) {
      khLog('Error streaming file actions: $e');
      rethrow;
    }
  }

  // ==================== ADDITIONAL HELPER METHODS ====================

  /// Get comment count for a knowledge document
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      _debugPaths('getCommentCount');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .where(KhCommentKeys.knowledgeId, isEqualTo: knowledgeId)
          .get();

      return querySnapshot.size;
    } catch (e) {
      khLog('Error getting comment count: $e');
      rethrow;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      _debugPaths('deleteComment');

      // ✅ Use dynamic path
      await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .doc(commentId)
          .delete();

      khLog('Comment deleted successfully: $commentId');
      return true;
    } catch (e) {
      khLog('Error deleting comment: $e');
      rethrow;
    }
  }

  /// Get file action statistics by type
  Future<Map<String, int>> getFileActionStats(String knowledgeId) async {
    try {
      _debugPaths('getFileActionStats');

      // ✅ Use dynamic path
      QuerySnapshot querySnapshot = await _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .where(KhFileActionKeys.fileId, arrayContains: knowledgeId)
          .get();

      Map<String, int> stats = {'view': 0, 'download': 0, 'export': 0};

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DocumentUtilizationModel model = DocumentUtilizationModel.fromJson(
            data,
          );
          String actionType = model.currentTypeOfAction.toLowerCase();

          if (stats.containsKey(actionType)) {
            stats[actionType] = stats[actionType]! + 1;
          }
        } catch (e) {
          khLog('Error parsing action stats: $e');
        }
      }

      khLog('File action stats for $knowledgeId: $stats');
      return stats;
    } catch (e) {
      khLog('Error getting file action stats: $e');
      rethrow;
    }
  }
}
