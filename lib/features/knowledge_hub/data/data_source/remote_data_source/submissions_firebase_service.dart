/// Module: knowledge_hub/data/data_source/remote_data_source
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_firebase_service.dart
/// Description: Firebase services specifically for Submissions screen
/// Author: Amr Mesbah
/// Created at: 18/10/2025
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/kh_firestore_keys.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data_json.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_knowledge_new_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/data_source/remote_data_source/create_comment_firebase_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';

class SubmissionsFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The documents created by [creatorEmail] only — asked of Firestore.
  ///
  /// KH-CREATE-06. Submissions used to download EVERY
  /// document in the company (other people's pending, rejected and restricted
  /// ones included) and keep the user's own on the device.
  Future<List<CreateKnowledgeModel>> fetchSubmissionsByCreator(
    String creatorEmail,
  ) async {
    final snap = await _firestore
        .collection(getBaseUrl(FirebaseCollections.createKnowledge))
        .where(CreateKnowledgeKeys.createdByEmail, arrayContains: creatorEmail)
        .get();
    final list = <CreateKnowledgeModel>[];
    for (final doc in snap.docs) {
      try {
        list.add(CreateKnowledgeModel.fromJson(doc.data(), doc.id));
      } catch (e) {
        khLog('Error parsing document ${doc.id}: $e');
      }
    }
    return list;
  }

  /// System Logs §3 for the status changes made here: the scheduled
  /// auto-publish and the end-date auto-archive.
  void _logStatusChange(String newStatus) {
    final String status = newStatus.trim().toLowerCase();
    if (status == 'published') {
      khSystemLog(KhLogAction.publishDocument);
    } else if (status == 'archived') {
      khSystemLog(KhLogAction.archiveDocument);
    }
  }

  /// Update submission status (for admin actions)
  Future<bool> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      khLog(
        '📝 Updating submission status for knowledgeId: $knowledgeId to $newStatus',
      );

      // Query by Firestore document ID directly if it looks like a doc ID
      // Check if knowledgeId is a Firestore-style doc ID (alphanumeric, 20+ chars)
      if (knowledgeId.length >= 20 &&
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        khLog('   Attempting direct document access with ID: $knowledgeId');

        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          khLog('   ✅ Found document directly by Firestore ID');

          Map<String, dynamic> existingData =
              docSnapshot.data() as Map<String, dynamic>;
          CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
            existingData,
            docSnapshot.id,
          );

          // Add new status to the array
          List<String> updatedStatus = List<String>.from(existingModel.status)
            ..add(newStatus);
          List<int> updatedTimestamps = List<int>.from(existingModel.timestamps)
            ..add(DateTime.now().millisecondsSinceEpoch);

          await docSnapshot.reference.update({
            CreateKnowledgeKeys.status: updatedStatus,
            CreateKnowledgeKeys.currentStatus: updatedStatus.isEmpty
                ? ''
                : updatedStatus.last.toString(), // KH-CREATE-06
            CreateKnowledgeKeys.timestamps: updatedTimestamps,
            CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
          });

          khLog('✅ Submission status updated successfully via direct access');
          _logStatusChange(newStatus);
          return true;
        } else {
          khLog(
            '   ⚠️ Document not found via direct access, falling back to query...',
          );
        }
      }

      // Fallback: Search by knowledgeId field (for backward compatibility)
      khLog('   Searching by knowledgeId field...');
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        khLog('❌ No document found with knowledgeId: $knowledgeId');
        return false;
      }

      var targetDoc = querySnapshot.docs.first;
      khLog('   ✅ Found document via query: ${targetDoc.id}');

      // Get existing model
      Map<String, dynamic> existingData =
          targetDoc.data() as Map<String, dynamic>;
      CreateKnowledgeModel existingModel = CreateKnowledgeModel.fromJson(
        existingData,
        targetDoc.id,
      );

      // Add new status to the array
      List<String> updatedStatus = List<String>.from(existingModel.status)
        ..add(newStatus);
      List<int> updatedTimestamps = List<int>.from(existingModel.timestamps)
        ..add(DateTime.now().millisecondsSinceEpoch);

      await targetDoc.reference.update({
        CreateKnowledgeKeys.status: updatedStatus,
        CreateKnowledgeKeys.currentStatus: updatedStatus.isEmpty
            ? ''
            : updatedStatus.last.toString(), // KH-CREATE-06
        CreateKnowledgeKeys.timestamps: updatedTimestamps,
        CreateKnowledgeKeys.updatedAt: FieldValue.serverTimestamp(),
      });

      khLog('✅ Submission status updated successfully via query');
      _logStatusChange(newStatus);
      return true;
    } catch (e) {
      khLog('❌ Error updating submission status: $e');
      rethrow;
    }
  }

  /// Fetch single submission by knowledgeId or Firestore document ID
  Future<CreateKnowledgeModel?> fetchSubmissionByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      khLog('🔍 Searching for knowledgeId: $knowledgeId');

      // Try direct document access first (if it's a Firestore doc ID)
      if (knowledgeId.length >= 20 &&
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(knowledgeId)) {
        khLog('   Attempting direct document access...');

        DocumentSnapshot docSnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.createKnowledge))
            .doc(knowledgeId)
            .get();

        if (docSnapshot.exists) {
          khLog('✅ Found document directly: ${docSnapshot.id}');
          Map<String, dynamic> data =
              docSnapshot.data() as Map<String, dynamic>;
          return CreateKnowledgeModel.fromJson(data, docSnapshot.id);
        }

        khLog('   ⚠️ Not found via direct access, trying query...');
      }

      // Fallback: Query by knowledgeId field
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .where(CreateKnowledgeKeys.knowledgeId, arrayContains: knowledgeId)
          .limit(1)
          .get();

      khLog('   Query returned ${querySnapshot.docs.length} documents');

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        khLog('✅ Submission fetched by query - Doc ID: ${doc.id}');
        return CreateKnowledgeModel.fromJson(data, doc.id);
      }

      khLog('❌ No submission found with knowledgeId: $knowledgeId');
      return null;
    } catch (e) {
      khLog('❌ Error fetching submission by knowledgeId: $e');
      rethrow;
    }
  }

  // ==================== COMMENTS (KH-SUBMIT-02) ====================
  //
  // These read and wrote a `Comments` SUBCOLLECTION under
  // each document, a different store from the one the hub, analytics and
  // approvals use. They now all use the single top-level comments
  // collection through CommentsFirebaseServices, so the author sees questions
  // asked on the hub and the hub sees the author's replies.

  final CommentsFirebaseServices _comments = CommentsFirebaseServices();

  CollectionReference<Map<String, dynamic>> get _commentsCol =>
      _firestore.collection(getBaseUrl(FirebaseCollections.knowledgeComments));

  /// Every comment on [knowledgeId], whichever screen wrote it.
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) => _comments.fetchCommentsByKnowledgeId(knowledgeId);

  /// Live comments on [knowledgeId].
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
    String knowledgeId,
  ) => _comments.streamCommentsByKnowledgeId(knowledgeId);

  /// Adds a comment to the single store, in both field formats.
  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  }) async {
    try {
      final ref = _commentsCol.doc();
      await ref.set({
        ...comment.toJson(),
        KhCommentKeys.commentId: [ref.id],
        KhCommentKeys.knowledgeId: knowledgeId,
        ...CommentsFirebaseServices.sharedCommentFields(
          knowledgeId: knowledgeId,
          commentId: ref.id,
          text: comment.currentCommentText,
          authorEmail: comment.currentCreatedByEmail,
          fileUrl: comment.currentAttachmentUrl.isEmpty
              ? null
              : comment.currentAttachmentUrl,
          fileName: comment.currentAttachmentName.isEmpty
              ? null
              : comment.currentAttachmentName,
          fileSize: comment.currentAttachmentSize,
        ),
      });
      khSystemLog(KhLogAction.submitInquiryComment); // System Logs §3
      return true;
    } catch (e) {
      khLog('❌ [FIREBASE] Error adding comment: $e');
      rethrow;
    }
  }

  /// Updates a comment's text in the single store (both field formats).
  Future<bool> updateComment({
    required String knowledgeId,
    required String commentId,
    required CreateNewCommentModel updatedComment,
  }) async {
    try {
      await _commentsCol.doc(commentId).update({
        ...updatedComment.toJson(),
        KhSharedCommentKeys.commentText: updatedComment.currentCommentText,
      });
      return true;
    } catch (e) {
      khLog('❌ [FIREBASE] Error updating comment: $e');
      rethrow;
    }
  }

  /// Deletes a comment from the single store.
  Future<bool> deleteComment({
    required String knowledgeId,
    required String commentId,
  }) async {
    try {
      await _commentsCol.doc(commentId).delete();
      return true;
    } catch (e) {
      khLog('❌ [FIREBASE] Error deleting comment: $e');
      rethrow;
    }
  }

  /// Fetch user data by userId - returns single employee or null
  Future<EmployeeData?> fetchUserDataByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.employeeDirectory))
          // KH-SUBMIT-07: rows saved before the fix may hold an e-mail.
          .where(
            userId.contains('@') ? EmployeeKeys.email : EmployeeKeys.id,
            isEqualTo: userId,
          )
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        khLog('No employee found with userId: $userId');
        return null;
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      EmployeeData employee = EmployeeData.fromJson(data);

      khLog('Successfully fetched employee data for userId: $userId');
      return employee;
    } catch (e) {
      khLog('Error fetching user data: $e');
      rethrow;
    }
  }

  /// Batch fetch user data for multiple comments
  /// Batch fetch user data for multiple user IDs or emails
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) return {};

      khLog(
        '👥 [Firebase] Fetching data for ${userIds.length} users: $userIds',
        name: 'SubmissionsFirebase',
      );

      final uniqueUserIds = userIds.toSet().toList();
      Map<String, EmployeeData> usersMap = {};

      // KH-SUBMIT-07: new rows hold employee IDs, older rows may still hold
      // e-mails — each group is queried by its own field.
      for (final bool areEmails in const [false, true]) {
        final List<String> group = uniqueUserIds
            .where((k) => k.contains('@') == areEmails)
            .toList();
        if (group.isEmpty) continue;
        final String queryField = areEmails
            ? EmployeeKeys.email
            : EmployeeKeys.id;

        // Firestore 'in' queries are limited to 10 items
        for (int i = 0; i < group.length; i += 10) {
          final batch = group.skip(i).take(10).toList();

          khLog(
            '📦 [Firebase] Fetching batch ${(i ~/ 10) + 1}: $batch',
            name: 'SubmissionsFirebase',
          );

          QuerySnapshot querySnapshot = await _firestore
              .collection(getBaseUrl(FirebaseCollections.employeeDirectory))
              .where(queryField, whereIn: batch) // Use detected field
              .get();

          khLog(
            '📥 [Firebase] Batch query returned ${querySnapshot.docs.length} documents',
            name: 'SubmissionsFirebase',
          );

          for (var doc in querySnapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // DEBUG: Log what we're getting
              khLog(
                '📄 [Firebase] Document data keys: ${data.keys.toList()}',
                name: 'SubmissionsFirebase',
              );

              EmployeeData employee = EmployeeData.fromJson(data);

              // Store by the ID/email that was used to query
              String key = areEmails
                  ? employee.currentemployeeEmail
                  : employee.currentemployeeId;
              usersMap[key] = employee;

              khLog(
                '✅ [Firebase] Cached employee: $key - ${employee.currentemployeeName}',
                name: 'SubmissionsFirebase',
              );
            } catch (e) {
              khLog(
                '❌ [Firebase] Error parsing employee data from doc ${doc.id}: $e',
                name: 'SubmissionsFirebase',
              );
            }
          }
        }
      }

      khLog(
        '✅ [Firebase] Successfully fetched ${usersMap.length} user records',
        name: 'SubmissionsFirebase',
      );
      khLog(
        '🗂️ [Firebase] User IDs in result: ${usersMap.keys.toList()}',
        name: 'SubmissionsFirebase',
      );

      return usersMap;
    } catch (e, stackTrace) {
      khLog(
        '❌ [Firebase] Error fetching multiple user data: $e',
        name: 'SubmissionsFirebase',
      );
      khLog(
        '📚 [Firebase] Stack trace: $stackTrace',
        name: 'SubmissionsFirebase',
      );
      rethrow;
    }
  }

  /// Record file action (download or view)
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) async {
    try {
      DocumentReference actionRef = _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .doc();

      // KH-SUBMIT-06: always 'en' digits. Formatted in the device language,
      // an Arabic phone stored Arabic digits that could not be read back.
      final String formattedTimeStamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
        'en',
      ).format(DateTime.now());

      final DocumentUtilizationModel actionModel =
          DocumentUtilizationModel.createNew(
            timestamp: formattedTimeStamp,
            fileId: knowledgeId,
            typeOfAction: typeOfAction,
            employeeId: employeeId,
          );

      Map<String, dynamic> actionData = actionModel.toJson();
      actionData[KhFileActionKeys.actionTimestamp] =
          FieldValue.serverTimestamp();

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
}
