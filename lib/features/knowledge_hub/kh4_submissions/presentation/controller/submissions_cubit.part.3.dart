/// Module: knowledge_hub/kh4_submissions/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_cubit.part.3.dart
/// Description: Mixin methods of `SubmissionsCubit` — split out of `submissions_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'submissions_cubit.dart';

mixin SubmissionsCubitPart3 on SubmissionsCubitBase {
  /// Apply filters from dialog with department support
  /*Future<void> applyFilters({
    String? documentType,
    String? status,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(FetchingSubmissionsLoadingState());

      selectedDocumentType = documentType;
      selectedStatus = status;
      selectedDepartment = department;
      selectedStartDate = startDate;
      selectedEndDate = endDate;

      // Start with all knowledge
      filteredKnowledge = List.from(allKnowledge);

      // Filter by status
      if (status != null && status.isNotEmpty && status != 'Status') {
        if (status == 'All') {
          filteredKnowledge = List.from(allKnowledge);
        } else if (status == 'Pending') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'pending_approval' ||
                knowledge.currentStatus == 'scheduled';
          }).toList();
        } else if (status == 'Approved') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'approved';
          }).toList();
        } else if (status == 'Published') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'published';
          }).toList();
        } else {
          String actualStatus = _mapDisplayStatusToActual(status);
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == actualStatus;
          }).toList();
        }
      }

      // Filter by department
      if (department != null && department.isNotEmpty && department != 'Department') {
        filteredKnowledge = filteredKnowledge.where((knowledge) {
          String dept = knowledge.owningDepartment.first;
          return dept == department;
        }).toList();
      }

      // Filter by document type
      if (documentType != null &&
          documentType.isNotEmpty &&
          documentType != 'Document Type') {
        filteredKnowledge = filteredKnowledge.where((knowledge) {
          String currentType = knowledge.knowledgeDocumentType.first;
          return currentType == documentType;
        }).toList();
      }

      // Apply search if exists
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('Error in applyFilters: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }*/

  Future<void> applyFilters({
    String? documentType,
    String? status,
    String? department,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(FetchingSubmissionsLoadingState());

      selectedDocumentType = documentType;
      selectedStatus = status;
      selectedDepartment = department;
      selectedStartDate = startDate;
      selectedEndDate = endDate;

      // Start with all knowledge
      filteredKnowledge = List.from(allKnowledge);

      khLog('=== FILTER DEBUG ===');
      khLog('Document Type Filter: $documentType');
      khLog('Status Filter: $status');
      khLog('Department Filter: $department');
      khLog('Total knowledge before filter: ${filteredKnowledge.length}');

      // Filter by status
      if (status != null && status.isNotEmpty) {
        if (status == 'Pending') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'pending_approval' ||
                knowledge.currentStatus == 'scheduled';
          }).toList();
        } else if (status == 'Approved') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'approved';
          }).toList();
        } else if (status == 'Published') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'published';
          }).toList();
        } else if (status == 'Rejected') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'rejected';
          }).toList();
        } else if (status == 'Removed') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'removed';
          }).toList();
        } else if (status == 'Archive') {
          filteredKnowledge = filteredKnowledge.where((knowledge) {
            return knowledge.currentStatus == 'archived';
          }).toList();
        }

        khLog('After status filter ($status): ${filteredKnowledge.length}');
      }

      // Filter by department
      if (department != null && department.isNotEmpty) {
        filteredKnowledge = filteredKnowledge.where((knowledge) {
          String dept = knowledge.owningDepartment.first;
          return dept == department;
        }).toList();

        khLog(
          'After department filter ($department): ${filteredKnowledge.length}',
        );
      }

      // COMPLETE FIX: Document type filter - match exact categories
      if (documentType != null && documentType.isNotEmpty) {
        khLog('📄 Filtering by document type: $documentType');

        // First, let's see what we have in the data
        khLog('📋 Sample document types in data:');
        for (var knowledge in filteredKnowledge.take(5)) {
          khLog(
            '   - ${knowledge.nameEnglish.first}: "${knowledge.knowledgeDocumentType.first}"',
          );
        }

        filteredKnowledge = filteredKnowledge.where((knowledge) {
          if (knowledge.knowledgeDocumentType.isEmpty) {
            khLog(
              '   ⚠️ Empty document type for: ${knowledge.nameEnglish.first}',
            );
            return false;
          }

          String storedType = knowledge.knowledgeDocumentType.first.trim();
          String filterType = documentType.trim();

          khLog('   Checking: ${knowledge.nameEnglish.first}');
          khLog('   Stored: "$storedType", Filter: "$filterType"');

          // Direct exact match (case-insensitive)
          bool matches = storedType.toLowerCase() == filterType.toLowerCase();

          if (matches) {
            khLog('   ✅ MATCH');
          } else {
            khLog('   ❌ NO MATCH');
          }

          return matches;
        }).toList();

        khLog(
          'After document type filter ($documentType): ${filteredKnowledge.length}',
        );

        // If no results, show what document types exist
        if (filteredKnowledge.isEmpty) {
          khLog('⚠️ NO RESULTS - Available document types in all data:');
          Set<String> availableTypes = {};
          for (var knowledge in allKnowledge) {
            if (knowledge.knowledgeDocumentType.isNotEmpty) {
              availableTypes.add(knowledge.knowledgeDocumentType.first);
            }
          }
          khLog('   Available: ${availableTypes.join(', ')}');
        }
      }

      // Apply search if exists
      if (searchQuery.isNotEmpty) {
        _applySearch();
        khLog('After search filter: ${filteredKnowledge.length}');
      }

      // Apply date filters
      _applyDateFilters();
      khLog('After date filters: ${filteredKnowledge.length}');

      khLog(
        '=== FILTER COMPLETE - Final Count: ${filteredKnowledge.length} ===',
      );

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('❌ Error in applyFilters: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Reset all filters including department
  Future<void> resetFilters() async {
    try {
      selectedDocumentType = null;
      selectedStatus = null;
      selectedInnerStatus = null;
      selectedDepartment = null;
      selectedStartDate = null;
      selectedEndDate = null;
      searchQuery = '';
      selectedStatusIndex = 0;
      selectedInnerStatusIndex = 0;

      filteredKnowledge = List.from(allKnowledge);
      upperCategoryFiltered = List.from(allKnowledge);

      emit(ChangeIndexSuccessState(0));
      emit(ChangeInnerIndexSuccessState(0));

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('Error in resetFilters: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Map display status names to actual database status values
  @override
  String _mapDisplayStatusToActual(String displayStatus) {
    switch (displayStatus) {
      case 'Published':
        return 'published';
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

  /// Helper: Fetch user data for all comments
  Future<void> _fetchUsersForComments(
    List<CreateNewCommentModel> comments,
  ) async {
    try {
      final userIds = comments
          .map((c) => c.currentCreatedById)
          .where((id) => id.isNotEmpty && !_usersCache.containsKey(id))
          .toSet()
          .toList();

      if (userIds.isEmpty) return;

      final newUsers = await _repository.fetchMultipleUserData(userIds);
      _usersCache.addAll(newUsers);

      khLog('Cached ${newUsers.length} user records for comments');
    } catch (e) {
      khLog('Error fetching users for comments: $e');
    }
  }

  /// Fetch comments for a specific knowledge document
  @override
  Future<void> fetchCommentsByKnowledgeId(String knowledgeId) async {
    try {
      currentKnowledgeId = knowledgeId;
      emit(FetchingCommentsLoadingState());

      currentComments = await _repository.fetchCommentsByKnowledgeId(
        knowledgeId,
      );

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
      khLog('Error in fetchCommentsByKnowledgeId: $e');
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
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    try {
      emit(AddingCommentLoadingState());

      String commentId = DateTime.now().millisecondsSinceEpoch.toString();

      CreateNewCommentModel comment = CreateNewCommentModel.createNew(
        commentId: commentId,
        commentText: commentText,
        createdById: createdById,
        createdByEmail: createdByEmail,
        attachmentExtension: attachmentExtension,
        attachmentSize: attachmentSize,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
      );

      bool success = await _repository.addCommentToKnowledge(
        knowledgeId: knowledgeId,
        comment: comment,
      );

      if (success) {
        emit(AddingCommentSuccessState());
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(AddingCommentErrorState('add_failed'));
      }
    } catch (e) {
      khLog('Error in addComment: $e');
      emit(AddingCommentErrorState(e.toString()));
    }
  }

  /// Uploads [file] and adds a comment that links to it. Returns whether
  /// both steps worked; never throws.
  Future<bool> addAttachmentComment({
    required String knowledgeId,
    required File file,
    required String fileName,
    required String createdById,
    required String createdByEmail,
    String? attachmentExtension,
    int? attachmentSize,
  }) async {
    String? url;
    try {
      url = await _repository.uploadCommentAttachment(
        file: file,
        knowledgeId: knowledgeId,
        fileName: fileName,
      );
    } catch (e) {
      khLog('uploadCommentAttachment failed: $e', name: 'SubmissionsCubit');
    }
    if (url == null || url.isEmpty) {
      emit(AddingCommentErrorState('upload_failed'));
      return false;
    }
    await addComment(
      knowledgeId: knowledgeId,
      commentText: fileName,
      createdById: createdById,
      createdByEmail: createdByEmail,
      attachmentExtension: attachmentExtension,
      attachmentSize: attachmentSize,
      attachmentUrl: url,
      attachmentName: fileName,
    );
    return state is! AddingCommentErrorState;
  }

  /// Saves one view or download of [knowledgeId] by [employeeId] (the
  /// viewer's employee ID — the one meaning every screen and analytics use,
  /// KH-CREATE-14 / KH-SUBMIT-07).
  Future<bool> recordFileAction({
    required String knowledgeId,
    required String typeOfAction,
    required String employeeId,
  }) async {
    if (employeeId.isEmpty) return false;
    try {
      return await _repository.recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: typeOfAction,
        employeeId: employeeId,
      );
    } catch (e) {
      khLog('Error recording file action: $e', name: 'SubmissionsCubit');
      return false;
    }
  }

  /// Why [knowledgeId] was last removed / approved, or null when there is
  /// no reason or it cannot be read.
  Future<String?> getRemovalReason(String knowledgeId) async {
    try {
      return await _repository.getRemovalReason(knowledgeId);
    } catch (e) {
      khLog('getRemovalReason failed: $e', name: 'SubmissionsCubit');
      return null;
    }
  }

  Future<String?> getApprovalReason(String knowledgeId) async {
    try {
      return await _repository.getApprovalReason(knowledgeId);
    } catch (e) {
      khLog('getApprovalReason failed: $e', name: 'SubmissionsCubit');
      return null;
    }
  }
}
