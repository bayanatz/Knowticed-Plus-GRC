/// Module: knowledge_hub/kh6_approvals/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_cubit.part.2.dart
/// Description: Mixin methods of `ApprovalsCubit` — split out of `approvals_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_cubit.dart';

mixin ApprovalsCubitPart2
    on ApprovalsCubitBase, ApprovalsCubitPart1, ApprovalsCubitPart1Methods2 {
  /// Reset all filters
  Future<void> resetFilters() async {
    try {
      selectedDocumentType = null;
      selectedStatus = null;
      selectedInnerStatus = null;
      dialogFilterActive = false;
      selectedStartDate = null;
      selectedEndDate = null;
      searchQuery = '';
      selectedStatusIndex = 0;
      selectedInnerStatusIndex = 0;

      emit(ChangeIndexSuccessState(0));
      applyAllFilters(); // keeps the department, sorts newest first
    } catch (e) {
      khLog('❌ Error in resetFilters: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  /// Update submission status (admin action)
  Future<void> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      emit(FetchingApprovalsLoadingState());

      bool success = await _repository.updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: newStatus,
      );

      if (success) {
        // Refresh the list
        await fetchAllSubmissions();
      } else {
        emit(
          FetchingApprovalsErrorState(
            '',
            key: ApprovalsErrorKey.statusUpdateFailed,
          ),
        );
      }
    } catch (e) {
      khLog('❌ Error in updateSubmissionStatus: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  // ==================== APPROVE/REJECT METHODS ====================

  /// Approve a knowledge document
  /// Approve a knowledge document
  /// Approve a knowledge document
  Future<void> approveKnowledge({
    required String knowledgeId,
    required String approvalJustification,
  }) async {
    if (!KnowledgeHubAccess.approvalAccess.canApprove) {
      khLog('⛔ approveKnowledge denied: role lacks approval permission');
      emit(
        ApprovingKnowledgeErrorState(
          '',
          key: ApprovalsErrorKey.noApprovePermission,
        ),
      );
      return;
    }

    try {
      khLog('🟢 Approving knowledge document: $knowledgeId');
      emit(ApprovingKnowledgeLoadingState());

      final CreateKnowledgeModel? knowledgeDoc =
          await _findPendingInOwnQueueFresh(knowledgeId);
      if (knowledgeDoc == null) {
        khLog(
          '⛔ approving denied: $knowledgeId is not a pending document in this queue',
        );
        emit(
          ApprovingKnowledgeErrorState(
            '',
            key: ApprovalsErrorKey.notPendingInQueue,
          ),
        );
        return;
      }

      final creatorEmail = knowledgeDoc.currentCreatedByEmail;
      final documentNameEnglish = knowledgeDoc.currentNameEnglish;
      final documentNameArabic = knowledgeDoc.currentNameArabic;

      khLog('📄 Document found:');
      khLog('   Name (EN): $documentNameEnglish');
      khLog('   Name (AR): $documentNameArabic');
      khLog('   Creator: $creatorEmail');

      // STEP 2: Perform the approval in Firebase
      bool success = await _repository.approveKnowledge(
        knowledgeId: knowledgeId,
        approvalJustification: approvalJustification,
      );

      if (success) {
        khLog('✅ Knowledge approved successfully in Firebase');

        // STEP 3: Send notification
        if (creatorEmail.isNotEmpty) {
          await _sendApprovalNotification(
            recipientEmail: creatorEmail,
            documentNameEnglish: documentNameEnglish,
            documentNameArabic: documentNameArabic,
            isApproved: true,
            knowledgeId: knowledgeId,
          );
          khLog('✅ Approval notification sent to: $creatorEmail');

          if (!knowledgeDoc.currentSchedulePublishing) {
            await _announcePublication(
              recipientEmail: creatorEmail,
              documentNameEnglish: documentNameEnglish,
              documentNameArabic: documentNameArabic,
              knowledgeId: knowledgeId,
            );
          }
        }

        // STEP 4: Refresh and emit success
        emit(ApprovingKnowledgeSuccessState());
        await fetchAllSubmissions();
      } else {
        emit(
          ApprovingKnowledgeErrorState(
            '',
            key: ApprovalsErrorKey.approveFailed,
          ),
        );
      }
    } catch (e, stackTrace) {
      khLog('❌ Error approving knowledge: $e');
      khLog('❌ Stack trace: $stackTrace');
      emit(ApprovingKnowledgeErrorState(e.toString()));
    }
  }

  /// Reject a knowledge document
  Future<void> rejectKnowledge({
    required String knowledgeId,
    required String rejectionReason,
  }) async {
    if (!KnowledgeHubAccess.approvalAccess.canReject) {
      khLog('⛔ rejectKnowledge denied: role lacks reject permission');
      emit(
        RejectingKnowledgeErrorState(
          '',
          key: ApprovalsErrorKey.noRejectPermission,
        ),
      );
      return;
    }

    try {
      khLog('🔴 Rejecting knowledge document: $knowledgeId');
      emit(RejectingKnowledgeLoadingState());

      final CreateKnowledgeModel? knowledgeDoc =
          await _findPendingInOwnQueueFresh(knowledgeId);
      if (knowledgeDoc == null) {
        khLog(
          '⛔ rejecting denied: $knowledgeId is not a pending document in this queue',
        );
        emit(
          RejectingKnowledgeErrorState(
            '',
            key: ApprovalsErrorKey.notPendingInQueue,
          ),
        );
        return;
      }

      final creatorEmail = knowledgeDoc.currentCreatedByEmail;
      final documentNameEnglish = knowledgeDoc.currentNameEnglish;
      final documentNameArabic = knowledgeDoc.currentNameArabic;

      khLog('📄 Document found:');
      khLog('   Name (EN): $documentNameEnglish');
      khLog('   Name (AR): $documentNameArabic');
      khLog('   Creator: $creatorEmail');

      // STEP 2: Perform the rejection in Firebase
      bool success = await _repository.rejectKnowledge(
        knowledgeId: knowledgeId,
        rejectionReason: rejectionReason,
      );

      if (success) {
        khLog('✅ Knowledge rejected successfully in Firebase');

        // STEP 3: Send notification
        if (creatorEmail.isNotEmpty) {
          await _sendApprovalNotification(
            recipientEmail: creatorEmail,
            documentNameEnglish: documentNameEnglish,
            documentNameArabic: documentNameArabic,
            isApproved: false,
            knowledgeId: knowledgeId,
          );
          khLog('✅ Rejection notification sent to: $creatorEmail');
        }

        // STEP 4: Refresh and emit success
        emit(RejectingKnowledgeSuccessState());
        await fetchAllSubmissions();
      } else {
        emit(
          RejectingKnowledgeErrorState('', key: ApprovalsErrorKey.rejectFailed),
        );
      }
    } catch (e, stackTrace) {
      khLog('❌ Error rejecting knowledge: $e');
      khLog('❌ Stack trace: $stackTrace');
      emit(RejectingKnowledgeErrorState(e.toString()));
    }
  }

  /// The document with [knowledgeId] ONLY if it is in this approver's own
  /// queue ([allKnowledge], built from their team's submissions) and its
  /// current status is still pending. Null otherwise — no company-wide
  /// fallback (KH-APPROVE-02).
  CreateKnowledgeModel? _findPendingInOwnQueue(String knowledgeId) {
    for (final doc in allKnowledge) {
      final bool sameDoc =
          doc.currentKnowledgeId == knowledgeId ||
          doc.knowledgeId.contains(knowledgeId);
      if (!sameDoc) continue;
      final status = doc.currentStatus.trim().toLowerCase();
      if (status == 'pending_approval' ||
          status == 'pending' ||
          status == 'scheduled') {
        return doc;
      }
    }
    return null;
  }

  /// The pending document, reloading this approver's queue ONCE when it is
  /// not in the copy held in memory (the details page can be open on a queue
  /// that has since been refreshed or was loaded before the request arrived).
  /// Still only ever this approver's own queue (KH-APPROVE-02).
  Future<CreateKnowledgeModel?> _findPendingInOwnQueueFresh(
    String knowledgeId,
  ) async {
    final CreateKnowledgeModel? cached = _findPendingInOwnQueue(knowledgeId);
    if (cached != null) return cached;
    await fetchAllSubmissions();
    return _findPendingInOwnQueue(knowledgeId);
  }

  /// Map display status names to actual database status values
  @override
  String _mapDisplayStatusToActual(String displayStatus) {
    switch (displayStatus) {
      case 'Approved':
        return 'approved';
      case 'Pending':
        return 'pending_approval';
      case 'Rejected':
        return 'rejected';
      case 'Removed':
        return 'removed';
      case 'Archive':
        return 'archived';
      default:
        return displayStatus.toLowerCase();
    }
  }

  /// ✅ Helper: Fetch user data for all comments
  Future<void> _fetchUsersForComments(
    List<CreateNewCommentModel> comments,
  ) async {
    try {
      // Extract unique user IDs that aren't already cached
      final userIds = comments
          .map((c) => c.currentCreatedById)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userIds.isEmpty) return;

      // Batch fetch user data
      final newUsers = await _repository.fetchMultipleUserData(userIds);

      // Add to cache
      _usersCache.addAll(newUsers);

      khLog('✅ Cached ${newUsers.length} user records for comments');
    } catch (e) {
      khLog('❌ Error fetching users for comments: $e');
    }
  }

  /// ✅ Get department name for a specific departmentId (from cache or fetch)
  @override
  Future<String> getDepartmentName(String departmentId) async {
    // Check cache first
    if (_departmentsCache.containsKey(departmentId)) {
      return _departmentsCache[departmentId]!;
    }

    // Fetch if not in cache
    try {
      final departmentName = await _repository.fetchDepartmentNameById(
        departmentId,
      );
      _departmentsCache[departmentId] = departmentName;
      return departmentName;
    } catch (e) {
      khLog('❌ Error fetching department name for $departmentId: $e');
      return ''; // the UI shows S.khUnknownDepartment
    }
  }

  /// ✅ Batch fetch department names for multiple knowledge documents
  Future<void> fetchDepartmentsForKnowledge(
    List<CreateKnowledgeModel> knowledgeList,
  ) async {
    try {
      // Extract unique department IDs that aren't already cached
      final departmentIds = knowledgeList
          .map((k) => k.currentOwningDepartment)
          .where((id) => id.isNotEmpty && !_departmentsCache.containsKey(id))
          .toSet()
          .toList();

      if (departmentIds.isEmpty) return;

      // Batch fetch department names
      final newDepartments = await _repository.fetchMultipleDepartmentNames(
        departmentIds,
      );

      // Add to cache
      _departmentsCache.addAll(newDepartments);

      khLog('✅ Cached ${newDepartments.length} department names');
    } catch (e) {
      khLog('❌ Error fetching departments for knowledge: $e');
    }
  }

  /// Fetch comments for a specific knowledge document
  Future<void> fetchCommentsByKnowledgeId(String knowledgeId) async {
    try {
      currentKnowledgeId = knowledgeId;
      emit(FetchingCommentsLoadingState());

      currentComments = await _repository.fetchCommentsByKnowledgeId(
        knowledgeId,
      );

      // ✅ Fetch user data for all comment creators
      await _fetchUsersForComments(currentComments);

      if (currentComments.isEmpty) {
        emit(FetchingCommentsEmptyState());
      } else {
        emit(FetchingCommentsSuccessState(currentComments));
      }
      _live.watchPaths([
        getBaseUrl(FirebaseCollections.knowledgeComments),
      ], _reloadCommentsSilently);
    } catch (e) {
      khLog('❌ Error in fetchCommentsByKnowledgeId: $e');
      emit(FetchingCommentsErrorState(e.toString()));
    }
  }

  /// Live refresh of the open document's comments (no loader).
  Future<void> _reloadCommentsSilently() async {
    final String? knowledgeId = currentKnowledgeId;
    if (knowledgeId == null) return;
    try {
      final comments = await _repository.fetchCommentsByKnowledgeId(
        knowledgeId,
      );
      if (isClosed || currentKnowledgeId != knowledgeId) return;
      currentComments = comments;
      await _fetchUsersForComments(currentComments);
      if (currentComments.isEmpty) {
        emit(FetchingCommentsEmptyState());
      } else {
        emit(FetchingCommentsSuccessState(currentComments));
      }
    } catch (e) {
      khLog('Silent comments refresh failed: $e');
    }
  }

  /// Add a new comment
  Future<void> addComment({
    required String knowledgeId,
    required String commentText,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
  }) async {
    try {
      emit(AddingCommentLoadingState());

      // Generate unique comment ID
      String commentId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create comment model with simplified fields
      CreateNewCommentModel comment = CreateNewCommentModel.createNew(
        commentId: commentId,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: attachmentExtension,
        attachmentSize: attachmentSize,
      );

      bool success = await _repository.addCommentToKnowledge(
        knowledgeId: knowledgeId,
        comment: comment,
      );

      if (success) {
        emit(AddingCommentSuccessState());
        // Refresh comments
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(
          AddingCommentErrorState('', key: ApprovalsErrorKey.addCommentFailed),
        );
      }
    } catch (e) {
      khLog('❌ Error in addComment: $e');
      emit(AddingCommentErrorState(e.toString()));
    }
  }

  /// ✅ Get comment count for a knowledge document
  Future<int> getCommentCount(String knowledgeId) async {
    try {
      final comments = await _repository.fetchCommentsByKnowledgeId(
        knowledgeId,
      );
      return comments.length;
    } catch (e) {
      khLog('❌ Error getting comment count: $e');
      return 0;
    }
  }

  /// ✅ Get file action statistics
  Future<Map<String, int>> getFileActionStats(String knowledgeId) async {
    try {
      return await _repository.getFileActionStats(knowledgeId);
    } catch (e) {
      khLog('❌ Error getting file action stats: $e');
      return {'view': 0, 'download': 0, 'export': 0};
    }
  }

  /// Get user data by email (from cache or fetch)
  @override
  Future<EmployeeData?> getUserDataByEmail(String email) async {
    if (email.isEmpty) return null;

    // Check cache first - search through cached users by email
    for (var user in _usersCache.values) {
      if (user.currentemployeeEmail.toLowerCase() == email.toLowerCase()) {
        khLog('✅ Found user in cache by email: $email');
        return user;
      }
    }

    // Fetch if not in cache
    try {
      khLog('🔍 Fetching user from Firebase by email: $email');
      final userData = await _repository.fetchUserDataByEmail(email);

      if (userData != null) {
        // Cache the user data using their ID as key
        _usersCache[userData.currentemployeeId] = userData;
        khLog('✅ Cached user data for: ${userData.currentemployeeName}');
      } else {
        khLog('❌ No user found for email: $email');
        // Try alternative approach - fetch all employees and search locally
        return await _fetchAllEmployeesAndFindByEmail(email);
      }

      return userData;
    } catch (e) {
      khLog('❌ Error fetching user data by email $email: $e');
      // Fallback: try to fetch all employees and search
      return await _fetchAllEmployeesAndFindByEmail(email);
    }
  }

  /// Fallback method: Fetch all employees and search by email
  Future<EmployeeData?> _fetchAllEmployeesAndFindByEmail(String email) async {
    try {
      khLog('🔄 Using fallback: fetching all employees to find: $email');

      // Fetch all employees from the main path
      final allEmployees = await _repository.fetchAllEmployees();

      // Search for the employee by email
      for (var employee in allEmployees) {
        if (employee.currentemployeeEmail.toLowerCase() ==
            email.toLowerCase()) {
          khLog(
            '✅ Found employee in fallback search: ${employee.currentemployeeName}',
          );
          // Cache the found employee
          _usersCache[employee.currentemployeeId] = employee;
          return employee;
        }
      }

      khLog('❌ Employee not found even in fallback search: $email');
      return null;
    } catch (e) {
      khLog('❌ Error in fallback employee search: $e');
      return null;
    }
  }

  /// Record file action (view/download)
  Future<void> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) async {
    emit(RecordFileActionLoading());
    try {
      final success = await _repository.recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: typeOfAction,
        employeeId: employeeId,
      );

      if (success) {
        emit(RecordFileActionSuccess(typeOfAction: typeOfAction));
      } else {
        emit(
          RecordFileActionFailure(
            typeOfAction,
            key: ApprovalsErrorKey.recordActionFailed,
          ),
        );
      }
    } catch (e) {
      khLog('❌ Error in recordFileAction: $e');
      emit(RecordFileActionFailure(e.toString()));
    }
  }
}
