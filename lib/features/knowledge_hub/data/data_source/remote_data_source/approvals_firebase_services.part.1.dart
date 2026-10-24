/// Module: knowledge_hub/data/data_source/remote_data_source
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_firebase_services.part.1.dart
/// Description: Mixin methods of `ApprovalsFirebaseServices` — split out of `approvals_firebase_services.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_firebase_services.dart';

mixin ApprovalsServicesPart1 on ApprovalsFirebaseServicesBase {
  /// ✅ HELPER: Get dynamic company ID from ApiConstants
  String _getCompanyId() {
    final String companyId = ApiConstants.baseUri.split("/").last;
    if (companyId.isEmpty) khLog('⚠️ Company ID is not set');
    return companyId;
  }

  /// ✅ DEBUG: Log current company ID and paths
  void _debugPaths(String methodName) {
    String companyId = _getCompanyId();
    khLog('📂 [$methodName] Company ID: $companyId');
    khLog('📂 [$methodName] Base URI: ${ApiConstants.baseUri}');
  }

  // ==================== KNOWLEDGE DOCUMENTS ====================

  /// All knowledge documents, or the FAILURE — never an empty list standing in
  /// for an error.
  ///
  Future<Either<Failure, KnowledgeFetchResult>>
  fetchAllKnowledgeResult() async {
    final QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .get();
    } catch (e) {
      khLog('fetchAllKnowledgeResult failed: $e');
      return Left(FirebaseFailure(e.toString()));
    }
    final docs = <CreateKnowledgeModel>[];
    int unreadable = 0;
    for (final doc in snap.docs) {
      try {
        docs.add(CreateKnowledgeModel.fromJson(doc.data(), doc.id));
      } catch (e) {
        unreadable++;
        khLog('Unreadable document ${doc.id}: $e');
      }
    }
    return Right(KnowledgeFetchResult(docs, unreadable));
  }

  // ==================== DEPARTMENTS ====================

  /// 2. Fetch department name by department ID
  Future<String> fetchDepartmentNameById(String departmentId) async {
    try {
      _debugPaths('fetchDepartmentNameById');

      if (departmentId.isEmpty) {
        khLog('⚠️ Empty department ID provided');
        return ''; // the UI shows the translated 'unknown' label
      }

      khLog('🔍 [Firebase] Fetching department for ID: $departmentId');

      // ✅ Use dynamic path
      String departmentsPath = getBaseUrl(
        FirebaseCollections.departmentDirectory,
      );
      khLog('📂 Using path: $departmentsPath');

      // First, try matching by Department_ID
      QuerySnapshot querySnapshot = await _firestore
          .collection(departmentsPath)
          .where(KhDepartmentKeys.departmentId, isEqualTo: departmentId)
          .limit(1)
          .get();

      // 🔥 FALLBACK: If not found, try matching by Department_Name (case-insensitive)
      if (querySnapshot.docs.isEmpty) {
        khLog('⚠️ No department found by ID, trying by name: $departmentId');

        // Try lowercase match
        querySnapshot = await _firestore
            .collection(departmentsPath)
            .where(
              KhDepartmentKeys.departmentName,
              isEqualTo: departmentId.toLowerCase(),
            )
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isEmpty) {
        khLog('⚠️ No department found with ID or Name: $departmentId');
        return departmentId; // ← Return the original value as fallback
      }

      var doc = querySnapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      String departmentName =
          data[KhDepartmentKeys.departmentName] as String? ?? '';

      khLog('✅ Found department: $departmentName for ID/Name: $departmentId');
      return departmentName;
    } catch (e) {
      khLog('❌ Error fetching department by ID: $e');
      rethrow;
    }
  }

  // ==================== USERS/EMPLOYEES ====================

  /// 4. Fetch user data by userId - returns single employee or null
  Future<EmployeeData?> fetchUserDataByUserId(String userId) async {
    try {
      _debugPaths('fetchUserDataByUserId');

      // ✅ Use dynamic path
      String employeesPath = getBaseUrl(FirebaseCollections.employeesInfo);
      khLog('📂 Using path: $employeesPath');

      QuerySnapshot querySnapshot = await _firestore
          .collection(employeesPath)
          .where(EmployeeKeys.id, isEqualTo: userId)
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

  /// Fetch all employees using dynamic path
  Future<List<EmployeeData>> fetchAllEmployees() async {
    try {
      String companyId = _getCompanyId();
      String employeesPath = getBaseUrl(FirebaseCollections.employeesInfo);

      khLog('📥 Fetching all employees from: $employeesPath');
      khLog('🏢 Company ID: $companyId');

      final snapshot = await _firestore.collection(employeesPath).get();

      List<EmployeeData> employees = [];

      for (var doc in snapshot.docs) {
        try {
          final employee = EmployeeData.fromJson(doc.data());
          employees.add(employee);
          khLog(
            '✅ Added employee: ${employee.currentemployeeName} - ${employee.currentemployeeEmail}',
          );
        } catch (e) {
          khLog('❌ Error parsing employee ${doc.id}: $e');
        }
      }

      khLog('✅ Successfully fetched ${employees.length} employees');
      return employees;
    } catch (e) {
      khLog('❌ Error fetching all employees: $e');
      rethrow;
    }
  }

  // ==================== COMMENTS ====================

  /// 5. Fetch comments for a specific knowledge document
  Future<List<CreateNewCommentModel>> fetchCommentsByKnowledgeId(
    String knowledgeId,
  ) async {
    try {
      _debugPaths('fetchCommentsByKnowledgeId');

      khLog('Fetching comments for knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      String commentsPath = getBaseUrl(FirebaseCollections.knowledgeComments);
      khLog('📂 Using path: $commentsPath');

      // Query the Comments collection directly using knowledgeId field
      QuerySnapshot commentsSnapshot = await _firestore
          .collection(commentsPath)
          .where(KhCommentKeys.knowledgeId, isEqualTo: knowledgeId)
          .get();

      List<CreateNewCommentModel> commentsList = [];

      for (var doc in commentsSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CreateNewCommentModel model = CreateNewCommentModel.fromJson(data);
          commentsList.add(model);
        } catch (e) {
          khLog('Error parsing comment ${doc.id}: $e');
        }
      }

      // Sort by timestamp
      commentsList.sort((a, b) {
        try {
          int timestampA = int.parse(a.timestamps.first);
          int timestampB = int.parse(b.timestamps.first);
          return timestampA.compareTo(timestampB);
        } catch (e) {
          khLog('Error parsing timestamps for sorting: $e');
          return 0;
        }
      });

      khLog(
        'Fetched ${commentsList.length} comments for knowledgeId: $knowledgeId',
      );
      return commentsList;
    } catch (e) {
      khLog('Error fetching comments: $e');
      rethrow;
    }
  }

  /// Stream comments for real-time updates
  Stream<List<CreateNewCommentModel>> streamCommentsByKnowledgeId(
    String knowledgeId,
  ) {
    try {
      _debugPaths('streamCommentsByKnowledgeId');

      // ✅ Use dynamic path
      String commentsPath = getBaseUrl(FirebaseCollections.knowledgeComments);

      return _firestore
          .collection(commentsPath)
          .where(KhCommentKeys.knowledgeId, isEqualTo: knowledgeId)
          .snapshots()
          .map((snapshot) {
            List<CreateNewCommentModel> commentsList = [];

            for (var doc in snapshot.docs) {
              try {
                Map<String, dynamic> data = doc.data();
                CreateNewCommentModel model = CreateNewCommentModel.fromJson(
                  data,
                );
                commentsList.add(model);
              } catch (e) {
                khLog('Error parsing comment ${doc.id}: $e');
              }
            }

            // Sort by timestamp
            commentsList.sort((a, b) {
              try {
                int timestampA = int.parse(a.timestamps.first);
                int timestampB = int.parse(b.timestamps.first);
                return timestampA.compareTo(timestampB);
              } catch (e) {
                return 0;
              }
            });

            return commentsList;
          });
    } catch (e) {
      khLog('Error streaming comments: $e');
      rethrow;
    }
  }

  /// 6. Add a new comment to a knowledge document
  Future<bool> addCommentToKnowledge({
    required String knowledgeId,
    required CreateNewCommentModel comment,
  }) async {
    try {
      _debugPaths('addCommentToKnowledge');

      khLog('Adding comment to knowledgeId: $knowledgeId');

      // ✅ Use dynamic path
      String commentsPath = getBaseUrl(FirebaseCollections.knowledgeComments);
      khLog('📂 Using path: $commentsPath');

      // Generate new comment document reference
      DocumentReference commentRef = _firestore.collection(commentsPath).doc();

      // Convert comment to JSON and add knowledgeId reference
      Map<String, dynamic> commentData = comment.toJson();
      commentData[KhCommentKeys.knowledgeId] = knowledgeId;

      // Save to Firestore
      await commentRef.set(commentData);

      khLog('Comment added successfully');
      khSystemLog(KhLogAction.submitInquiryComment); // System Logs §3
      return true;
    } catch (e) {
      khLog('Error adding comment: $e');
      rethrow;
    }
  }

  /// 12. Upload comment attachment to Firebase Storage
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

      khLog('Comment attachment uploaded successfully');

      return {
        KhAttachmentKeys.url: downloadUrl,
        KhAttachmentKeys.name: fileName,
        KhAttachmentKeys.extension: fileExtension,
        KhAttachmentKeys.size: fileSize,
      };
    } catch (e) {
      khLog('Error uploading comment attachment: $e');
      rethrow;
    }
  }

  // ==================== MEDIA UPLOADS ====================

  /// 7. Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      String fileName =
          '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      khLog('Image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      khLog('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload document to Firebase Storage
  Future<String?> uploadDocument(File documentFile, String fileName) async {
    try {
      String filePath =
          '${getBaseUrl(FirebaseCollections.knowledgeHubRoot)}/knowledge_documents/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      Reference storageRef = _storage.ref().child(filePath);
      UploadTask uploadTask = storageRef.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      khLog('Document uploaded successfully');
      return downloadUrl;
    } catch (e) {
      khLog('Error uploading document: $e');
      rethrow;
    }
  }
}
