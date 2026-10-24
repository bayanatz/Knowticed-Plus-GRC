/// Module: knowledge_hub_module / core/create_comment_firebase_service.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_comment_firebase_service.dart
/// Description: Handles all Firebase operations for comments
/// Author: Amr Mesbah
/// Created at: 12/10/2025
/// Updated: Refactored to match simplified comment model
library;

import 'package:knowticed_plus/features/knowledge_hub/data/models/kh_firestore_keys.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data_json.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_system_log.dart';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/document_utilization_model.dart';
import 'package:knowticed_plus/features/knowledge_hub/data/models/employee_data.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';

class CommentsFirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload comment attachment to Firebase Storage
  /// Returns a map with attachment details
  /// The url, name, extension and size are all stored with the comment
  /// (KH-CREATE-05).
  Future<Map<String, dynamic>?> uploadCommentAttachment(File file) async {
    try {
      String fileName = file.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      int fileSize = await file.length();

      String filePath =
          '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/comment_attachments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Determine icon based on file extension
      String icon = _getFileIcon(fileExtension);

      khLog('Comment attachment uploaded successfully');

      // ✅ Return all details for reference
      // Only extension and size will be stored in comment model
      return {
        KhAttachmentKeys.url: downloadUrl,
        KhAttachmentKeys.name: fileName,
        KhAttachmentKeys.extension: fileExtension,
        KhAttachmentKeys.size: fileSize,
        KhAttachmentKeys.icon: icon,
      };
    } catch (e) {
      khLog('Error uploading comment attachment: $e');
      rethrow;
    }
  }

  /// Helper method to get file icon based on extension
  String _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
      case 'xls':
      case 'xlsx':
        return 'assets/icons_assets/main_icons_assets/ic_file_excel.svg';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg';
      default:
        return 'assets/icons_assets/knowledge_hub_assets/ic_file_word.svg';
    }
  }

  /// Create a new comment for a knowledge document
  /// Note: Only stores essential fields. User details fetched via createdById when needed in UI
  Future<bool> createComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    try {
      // Generate new comment document reference
      DocumentReference commentRef = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .doc();

      //Comments

      // Create comment model
      CreateNewCommentModel commentModel = CreateNewCommentModel.createNew(
        commentId: commentRef.id,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: attachmentExtension,
        attachmentSize: attachmentSize,
        // KH-CREATE-05: keep the link and name, so the attachment can be opened.
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
      );

      // Convert to JSON and add knowledgeId reference
      Map<String, dynamic> commentData = commentModel.toJson();
      commentData[KhCommentKeys.knowledgeId] = knowledgeId;
      // KH-SUBMIT-02: also write the shared comment-box fields, so the same
      // comment shows in Submission details (UniversalCommentSection reads
      // `Request_Id` / `Comment_*` from this same collection).
      commentData.addAll(
        sharedCommentFields(
          knowledgeId: knowledgeId,
          commentId: commentRef.id,
          text: commentText,
          authorEmail: createdByEmail,
          fileUrl: attachmentUrl,
          fileName: attachmentName,
          fileSize: attachmentSize,
        ),
      );

      // Save to Firestore
      await commentRef.set(commentData);

      khLog('Comment created successfully for knowledge: $knowledgeId');
      khSystemLog(KhLogAction.submitInquiryComment); // System Logs §3
      return true;
    } catch (e) {
      khLog('Error creating comment: $e');
      rethrow;
    }
  }

  // ==================== ONE COMMENT STORE (KH-SUBMIT-02) ====================
  //
  // KH-SUBMIT-02 (critical). The hub saved comments here
  // with `knowledgeId`; Submission details read the same collection but by
  // `Request_Id` (the shared comment box), and Submissions' own list read a
  // `Comments` SUBCOLLECTION under each document. Questions asked on the hub
  // never reached the author, and the author's replies never reached the hub.
  //
  // Everything now lives in THIS collection: new hub comments carry both
  // field sets, and every reader accepts both formats.

  /// The fields the shared comment box (UniversalCommentSection) reads.
  static Map<String, dynamic> sharedCommentFields({
    required String knowledgeId,
    required String commentId,
    required String text,
    required String authorEmail,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) => {
    KhSharedCommentKeys.requestId: knowledgeId,
    KhSharedCommentKeys.commentId: commentId,
    KhSharedCommentKeys.commentText: text.isEmpty ? null : text,
    KhSharedCommentKeys.commenterId: authorEmail,
    KhSharedCommentKeys.commentDate: Timestamp.now(),
    KhSharedCommentKeys.commentLink: fileUrl,
    KhSharedCommentKeys.fileName: fileName,
    KhSharedCommentKeys.fileSize: fileSize,
  };

  /// Reads a comment written by EITHER the hub or the shared comment box.
  static CreateNewCommentModel commentFromAnyFormat(
    Map<String, dynamic> data,
    String docId,
  ) {
    if (data.containsKey(KhCommentKeys.commentText)) {
      var model = CreateNewCommentModel.fromJson(data);
      // Edited in the shared box → its Comment_Text is the newest text.
      final shared = data[KhSharedCommentKeys.commentText];
      if (shared is String && shared != model.currentCommentText) {
        model = model.copyWith(commentText: shared);
      }
      return model;
    }
    final date = data[KhSharedCommentKeys.commentDate];
    final int millis = date is Timestamp
        ? date.millisecondsSinceEpoch
        : DateTime.now().millisecondsSinceEpoch;
    final String fileName =
        (data[KhSharedCommentKeys.fileName] as String?) ?? '';
    final String email =
        (data[KhSharedCommentKeys.commenterId] as String?) ?? '';
    final sizeRaw = data[KhSharedCommentKeys.fileSize];
    return CreateNewCommentModel(
      timestamps: [millis.toString()],
      commentId: [docId],
      commentText: [(data[KhSharedCommentKeys.commentText] as String?) ?? ''],
      createdById: [email],
      createdByEmail: [email],
      attachmentExtension: [
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '',
      ],
      attachmentSize: [sizeRaw is int ? sizeRaw : 0],
      attachmentUrl: [(data[KhSharedCommentKeys.commentLink] as String?) ?? ''],
      attachmentName: [fileName],
    );
  }

  /// Every comment on [knowledgeId], whichever screen wrote it.
  Query<Map<String, dynamic>> commentsQuery(String knowledgeId) => _firestore
      .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
      .where(
        Filter.or(
          Filter(KhCommentKeys.knowledgeId, isEqualTo: knowledgeId),
          Filter(KhSharedCommentKeys.requestId, isEqualTo: knowledgeId),
        ),
      );

  List<CreateNewCommentModel> _commentsFrom(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final list = <CreateNewCommentModel>[];
    for (final doc in snap.docs) {
      try {
        list.add(commentFromAnyFormat(doc.data(), doc.id));
      } catch (e) {
        khLog('Error parsing comment ${doc.id}: $e');
      }
    }
    list.sort(
      (a, b) => (int.tryParse(a.timestamps.first) ?? 0).compareTo(
        int.tryParse(b.timestamps.first) ?? 0,
      ),
    );
    return list;
  }

  /// Fetch all comments for a specific knowledge document
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) async {
    // KH-CREATE-21: a failed read is passed UP (the cubit emits its error
    // state with retry) instead of returning [] that looks like "no comments".
    return _commentsFrom(await commentsQuery(knowledgeId).get());
  }

  /// Stream comments for real-time updates
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
    String knowledgeId,
  ) {
    // KH-SUBMIT-02: both formats, one store.
    return commentsQuery(knowledgeId).snapshots().map(_commentsFrom);
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId) async {
    try {
      await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .doc(commentId)
          .delete();
      //Comments
      khLog('Comment deleted successfully: $commentId');
      return true;
    } catch (e) {
      khLog('Error deleting comment: $e');
      rethrow;
    }
  }

  /// Get comment count for a knowledge document
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeComments))
          .where(KhCommentKeys.knowledgeId, isEqualTo: knowledgeId)
          .get();
      //Comments
      return querySnapshot.size;
    } catch (e) {
      khLog('Error getting comment count: $e');
      rethrow;
    }
  }

  /// Record file action (download or view) using DocumentUtilizationModel
  /// ✅ Simplified to store only essential tracking data
  /// User details should be fetched via userId using fetchUserDataByUserId() in UI
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction, // 'download' or 'view'
    required String employeeId,
  }) async {
    try {
      // Generate new action document reference
      DocumentReference actionRef = _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .doc();
      // ✅ Create formatted timestamp
      // KH-SUBMIT-06: always 'en' digits. Formatted in the device language,
      // an Arabic phone stored Arabic digits that could not be read back.
      final String formattedTimeStamp = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
        'en',
      ).format(DateTime.now());

      // ✅ Create DocumentUtilizationModel instance
      final DocumentUtilizationModel actionModel =
          DocumentUtilizationModel.createNew(
            timestamp: formattedTimeStamp,
            fileId: knowledgeId,
            typeOfAction: typeOfAction,
            employeeId: employeeId,
          );

      // ✅ Convert model to JSON
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

  /// Fetch file actions by knowledge/file ID
  /// ✅ Returns DocumentUtilizationModel with userId - use fetchUserDataByUserId() to get user details in UI
  Future<List<DocumentUtilizationModel>> fetchFileActionsByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      khLog('Searching for fileId: $knowledgeId');

      // Use array-contains since fileId is stored as an array
      QuerySnapshot querySnapshot = await _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .where(KhFileActionKeys.fileId, arrayContains: knowledgeId)
          .get();
      //Document_Utilization
      khLog('Filtered query returned: ${querySnapshot.docs.length} documents');

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
  /// ✅ Returns DocumentUtilizationModel with userId - use fetchUserDataByUserId() to get user details in UI
  Stream<List<DocumentUtilizationModel>> streamFileActionsByKnowledgeId(
    String knowledgeId,
  ) {
    try {
      return _firestore
          .collection(
            getBaseUrl(FirebaseCollections.knowledgeDocumentUtilization),
          )
          .where(KhFileActionKeys.fileId, arrayContains: knowledgeId)
          .orderBy(KhFileActionKeys.actionTimestamp, descending: true)
          .snapshots()
          //Document_Utilization
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

  /// Fetch user data by userId - returns single employee or null
  /// ✅ Use this to get user details (name, photo, department, role) for display
  Future<EmployeeData?> fetchUserDataByUserId(String userId) async {
    try {
      // KH-CREATE-14: rows saved before the fix may hold an e-mail.
      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.employeeDirectory))
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

      // Get the first (and only) document
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

  /// ✅ Batch fetch user data for multiple comments
  /// This is more efficient than fetching individually for each comment
  /// ✅ Batch fetch user data for multiple comments
  /// This is more efficient than fetching individually for each comment
  Future<Map<String, EmployeeData>> fetchMultipleUserData(
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) {
        khLog(
          '⚠️ [Firebase] fetchMultipleUserData called with empty userIds list',
        );
        return {};
      }

      khLog(
        '👥 [Firebase] Fetching data for ${userIds.length} users: $userIds',
      );

      // Remove duplicates
      final uniqueUserIds = userIds.toSet().toList();
      khLog('👥 [Firebase] Unique user IDs: ${uniqueUserIds.length}');

      // Firestore 'in' queries are limited to 10 items, so we batch them
      Map<String, EmployeeData> usersMap = {};

      // KH-CREATE-14: new rows hold employee IDs, older rows may still hold
      // e-mails — each group is queried by its own field.
      for (final bool areEmails in const [false, true]) {
        final List<String> group = uniqueUserIds
            .where((k) => k.contains('@') == areEmails)
            .toList();
        if (group.isEmpty) continue;
        for (int i = 0; i < group.length; i += 10) {
          final batch = group.skip(i).take(10).toList();
          khLog('📦 [Firebase] Fetching batch ${(i ~/ 10) + 1}: $batch');

          QuerySnapshot querySnapshot = await _firestore
              .collection(getBaseUrl(FirebaseCollections.employeeDirectory))
              .where(
                areEmails ? EmployeeKeys.email : EmployeeKeys.id,
                whereIn: batch,
              )
              .get();
          khLog(
            '📥 [Firebase] Batch query returned ${querySnapshot.docs.length} documents',
          );

          for (var doc in querySnapshot.docs) {
            try {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              khLog('📄 [Firebase] Parsing employee doc: ${doc.id}');
              khLog('📄 [Firebase] Data keys: ${data.keys.toList()}');

              EmployeeData employee = EmployeeData.fromJson(data);
              usersMap[areEmails
                      ? employee.currentemployeeEmail
                      : employee.currentemployeeId] =
                  employee;

              khLog(
                '✅ [Firebase] Parsed employee: id="${employee.currentemployeeId}", name="${employee.currentemployeeName}", dept="${employee.currentemployeeDepartment}"',
              );
            } catch (e, stack) {
              khLog(
                '❌ [Firebase] Error parsing employee data from doc ${doc.id}: $e',
              );
              khLog('📄 [Firebase] Raw data: ${doc.data()}');
              khLog('🧱 Stack: $stack');
            }
          }
        }
      }

      khLog(
        '✅ [Firebase] Successfully fetched ${usersMap.length} user records',
      );
      khLog('🗂️ [Firebase] User IDs in result: ${usersMap.keys.toList()}');

      return usersMap;
    } catch (e) {
      khLog('❌ [Firebase] Error fetching multiple user data: $e');
      rethrow;
    }
  }

  /// Fetch department name by department ID
  Future<String> fetchDepartmentNameById(String departmentId) async {
    try {
      if (departmentId.isEmpty) {
        khLog('⚠️ Empty department ID provided');
        return 'Unknown Department';
      }

      khLog('🔍 [Firebase] Fetching department for ID: $departmentId');

      QuerySnapshot querySnapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.departmentDirectory))
          .where(KhDepartmentKeys.departmentId, isEqualTo: departmentId)
          .limit(1)
          .get();

      //Departments
      if (querySnapshot.docs.isEmpty) {
        khLog('⚠️ No department found with ID: $departmentId');
        return 'Unknown Department';
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String departmentName =
          data[KhDepartmentKeys.departmentName] as String? ??
          'Unknown Department';

      khLog('✅ Found department: $departmentName for ID: $departmentId');
      return departmentName;
    } catch (e) {
      khLog('❌ Error fetching department by ID: $e');
      rethrow;
    }
  }

  /// Batch fetch department names for multiple department IDs
  /// More efficient than fetching individually
  Future<Map<String, String>> fetchMultipleDepartmentNames(
    List<String> departmentIds,
  ) async {
    try {
      if (departmentIds.isEmpty) {
        khLog(
          '⚠️ [Firebase] fetchMultipleDepartmentNames called with empty list',
        );
        return {};
      }

      khLog(
        '🏢 [Firebase] Fetching ${departmentIds.length} departments: $departmentIds',
      );

      // Remove duplicates
      final uniqueIds = departmentIds.toSet().toList();
      khLog('🏢 [Firebase] Unique department IDs: ${uniqueIds.length}');

      Map<String, String> departmentMap = {};

      // Firestore 'in' queries are limited to 10 items
      for (int i = 0; i < uniqueIds.length; i += 10) {
        final batch = uniqueIds.skip(i).take(10).toList();
        khLog(
          '📦 [Firebase] Fetching department batch ${(i ~/ 10) + 1}: $batch',
        );

        QuerySnapshot querySnapshot = await _firestore
            .collection(getBaseUrl(FirebaseCollections.departmentDirectory))
            .where(KhDepartmentKeys.departmentId, whereIn: batch)
            .get();
        khLog(
          '📥 [Firebase] Department batch query returned ${querySnapshot.docs.length} documents',
        );

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            String? deptId = data[KhDepartmentKeys.departmentId] as String?;
            String? deptName = data[KhDepartmentKeys.departmentName] as String?;

            if (deptId != null && deptId.isNotEmpty && deptName != null) {
              departmentMap[deptId] = deptName;
              khLog(
                '✅ [Firebase] Mapped department: ID="$deptId" → Name="$deptName"',
              );
            }
          } catch (e) {
            khLog('❌ [Firebase] Error parsing department doc ${doc.id}: $e');
          }
        }
      }

      khLog(
        '✅ [Firebase] Successfully fetched ${departmentMap.length} department names',
      );
      khLog(
        '🗂️ [Firebase] Department IDs in result: ${departmentMap.keys.toList()}',
      );

      return departmentMap;
    } catch (e) {
      khLog('❌ [Firebase] Error fetching multiple department names: $e');
      rethrow;
    }
  }
}
