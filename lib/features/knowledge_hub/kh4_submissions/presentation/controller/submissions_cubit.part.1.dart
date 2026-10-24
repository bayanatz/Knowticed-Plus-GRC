/// Module: knowledge_hub/kh4_submissions/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_cubit.part.1.dart
/// Description: Mixin methods of `SubmissionsCubit` — split out of `submissions_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'submissions_cubit.dart';

mixin SubmissionsCubitPart1 on SubmissionsCubitBase {
  /// Set current user email
  void setCurrentUserEmail(String email) {
    _currentUserEmail = email.toLowerCase().trim();
    khLog('👤 [SUBMISSIONS] Current user set: $_currentUserEmail');
  }

  /// Tells the author their document was archived, through the module's
  /// bilingual "document archived" template (title, body and both languages
  /// come from the template, not from this code).
  @override
  Future<bool> _sendArchiveNotification({
    required String knowledgeId,
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required DateTime archivedDate,
  }) async {
    if (recipientEmail.isEmpty) return false;
    try {
      return await _repository.notifyOwnerOfArchival(
        documentId: knowledgeId,
        senderEmail: AppConstants.systemSenderEmail,
        ownerEmail: recipientEmail,
        documentNameEn: documentNameEnglish,
        documentNameAr: documentNameArabic,
        isArabic: KhLocale.isArabicNow,
      );
    } catch (e) {
      khLog('Archive notification failed: $e', name: 'ArchiveNotification');
      return false;
    }
  }

  /// Get current user email from various sources
  @override
  String? _getCurrentUserEmail() {
    // If already set, return it
    if (_currentUserEmail != null && _currentUserEmail!.isNotEmpty) {
      return _currentUserEmail;
    }

    // Try to get from GetX controller
    try {
      final employeeController = people.employeesOrNull;
      if (employeeController != null) {
        if (employeeController.employeeEntity?.email != null) {
          _currentUserEmail =
              employeeController.employeeEntity!.email!.toLowerCase().trim();
          khLog(
            '✅ [SUBMISSIONS] Email from MainCoreEmployeeController: $_currentUserEmail',
          );
          return _currentUserEmail;
        }
      }
    } catch (e) {
      khLog('⚠️ [SUBMISSIONS] Error accessing MainCoreEmployeeController: $e');
    }

    // KH-CREATE-07: no ConstantVar fallback (stale after an account switch).

    khLog('❌ [SUBMISSIONS] No user email found!');
    return null;
  }

  /// Filter documents to only show current user's documents
  List<CreateKnowledgeModel> _filterByCurrentUser(
    List<CreateKnowledgeModel> knowledgeList,
  ) {
    final userEmail = _getCurrentUserEmail();

    if (userEmail == null) {
      khLog('⚠️ [FILTER] No user email - showing ALL documents (insecure!)');
      return knowledgeList;
    }

    khLog('🔐 [FILTER] Filtering documents for user: $userEmail');
    khLog(
      '📊 [FILTER] Total documents before filtering: ${knowledgeList.length}',
    );

    final userDocuments = knowledgeList.where((knowledge) {
      if (knowledge.createdByEmail.isEmpty) {
        khLog(
          '   ⚠️ No creator email for document: ${knowledge.currentKnowledgeId}',
        );
        return false;
      }

      final creatorEmail = knowledge.currentCreatedByEmail.toLowerCase().trim();
      final isUserDocument = creatorEmail == userEmail;

      if (!isUserDocument) {
        khLog(
          '   ❌ Filtered out: ${knowledge.currentKnowledgeId} - Creator: $creatorEmail, Current User: $userEmail',
        );
      } else {
        khLog(
          '   ✅ Keeping: ${knowledge.currentKnowledgeId} - Creator: $creatorEmail',
        );
      }

      return isUserDocument;
    }).toList();

    khLog(
      '📊 [FILTER] Total documents after filtering: ${userDocuments.length}',
    );
    return userDocuments;
  }

  // ADD THESE METHODS TO YOUR submissions_cubit.dart

  /// Update a comment's text
  Future<void> updateComment({
    required String knowledgeId,
    required String commentId,
    required String newText,
  }) async {
    try {
      emit(UpdatingCommentLoadingState());

      // Fetch the current comment
      final comment = currentComments.firstWhere(
        (c) => c.currentCommentId == commentId,
        orElse: () => CreateNewCommentModel(
          timestamps: [],
          commentId: [],
          commentText: [],
          createdById: [],
          createdByEmail: [],
          attachmentExtension: [],
          attachmentSize: [],
        ),
      );

      if (comment.commentId.isEmpty) {
        emit(UpdatingCommentErrorState('Comment not found'));
        return;
      }

      // Create updated comment using copyWith
      final updatedComment = comment.copyWith(commentText: newText);

      // Update in Firebase
      bool success = await _repository.updateComment(
        knowledgeId: knowledgeId,
        commentId: commentId,
        updatedComment: updatedComment,
      );

      if (success) {
        emit(UpdatingCommentSuccessState());
        // Refresh comments
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(UpdatingCommentErrorState('Failed to update comment'));
      }
    } catch (e) {
      khLog('Error in updateComment: $e');
      emit(UpdatingCommentErrorState(e.toString()));
    }
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String knowledgeId,
    required String commentId,
  }) async {
    try {
      emit(DeletingCommentLoadingState());

      bool success = await _repository.deleteComment(
        knowledgeId: knowledgeId,
        commentId: commentId,
      );

      if (success) {
        emit(DeletingCommentSuccessState());
        // Refresh comments
        await fetchCommentsByKnowledgeId(knowledgeId);
      } else {
        emit(DeletingCommentErrorState('Failed to delete comment'));
      }
    } catch (e) {
      khLog('Error in deleteComment: $e');
      emit(DeletingCommentErrorState(e.toString()));
    }
  }

  /// Extract available departments from current user's documents only
  void _extractAvailableDepartments() {
    Set<String> departments = {};

    for (var knowledge in allKnowledge) {
      String dept = knowledge.owningDepartment.first;
      if (dept.isNotEmpty) {
        departments.add(dept);
      }
    }

    availableDepartments = departments.toList()..sort();
    khLog('Available departments for current user: $availableDepartments');
  }

  /// Fetch all knowledge documents with user filtering
  @override
  Future<void> fetchMySubmissions() async {
    try {
      emit(FetchingSubmissionsLoadingState());

      // Get current user email first
      final userEmail = _getCurrentUserEmail();
      if (userEmail == null) {
        khLog('❌ [FETCH] Cannot fetch submissions - no user email available');
        emit(FetchingSubmissionsErrorState('User not authenticated'));
        return;
      }

      khLog('👤 [FETCH] Fetching submissions for user: $userEmail');

      // KH-CREATE-06: fetch only this user's own documents.
      List<CreateKnowledgeModel> allDocuments =
          await _repository.fetchSubmissionsByCreator(userEmail);
      khLog(
        '📥 [FETCH] Firebase returned ${allDocuments.length} total documents',
      );

      // FILTER: Only show current user's documents
      allKnowledge = _filterByCurrentUser(allDocuments);
      khLog('✅ [FETCH] After user filtering: ${allKnowledge.length} documents');

      // Run complete status flow checks only on user's documents
      final bool published = await _autoPublishScheduledDocuments();
      final bool archived = await _autoArchiveExpiredDocuments();

      // KH-SUBMIT-10: read again only when a status really changed.
      if (published || archived) {
        allDocuments = await _repository.fetchSubmissionsByCreator(userEmail);
        allKnowledge = _filterByCurrentUser(allDocuments);
        khLog(
          '🔄 [FETCH] After re-fetch and filtering: ${allKnowledge.length} documents',
        );
      }
      if (isClosed) return;

      filteredKnowledge = List.from(allKnowledge);
      upperCategoryFiltered = List.from(allKnowledge);

      _extractAvailableDepartments();
      _calculateStatusCounts();

      if (filteredKnowledge.isEmpty) {
        khLog('📭 [FETCH] No submissions found for user: $userEmail');
        emit(FetchingSubmissionsEmptyState());
      } else {
        khLog(
          '✅ [FETCH] Successfully loaded ${filteredKnowledge.length} submissions for user: $userEmail',
        );
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
      _watchSubmissions();
    } catch (e) {
      khLog('Error in fetchAllSubmissions: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Keeps the submissions grid, tab counts and departments live.
  void _watchSubmissions() => _live.watchPaths([
        getBaseUrl(FirebaseCollections.createKnowledge),
      ], _reloadSubmissionsSilently);

  /// Re-reads the user's documents and re-applies the tab / inner tab /
  /// department / search / date filters that are currently selected, with
  /// no loading state and without the auto-publish / auto-archive writes.
  Future<void> _reloadSubmissionsSilently() async {
    final userEmail = _getCurrentUserEmail();
    if (userEmail == null) return;
    try {
      final documents = await _repository.fetchSubmissionsByCreator(userEmail);
      if (isClosed) return;
      allKnowledge = _filterByCurrentUser(documents);
      _extractAvailableDepartments();
      _calculateStatusCounts();

      final status = selectedStatus ?? 'All';
      final index = selectedStatusIndex;
      final inner = selectedInnerStatus;
      final innerIndex = selectedInnerStatusIndex;
      _silentRefresh = true;
      try {
        await filterByStatus(status, index);
        if (inner != null) await filterByInnerStatus(inner, innerIndex);
      } finally {
        _silentRefresh = false;
      }
    } catch (e) {
      khLog('Silent submissions refresh failed: $e');
    }
  }

  /// COMPLETE STATUS FLOW: Auto-publish approved documents based on start date.
  ///
  /// Returns true when at least one document was published.
  Future<bool> _autoPublishScheduledDocuments() async {
    khLog('🔄 [AUTO-PUBLISH] Starting auto-publish check...');

    try {
      DateTime now = DateTime.now();
      khLog('⏰ [AUTO-PUBLISH] Current time: $now');

      List<String> documentsToUpdate = [];
      int approvedCount = 0;
      int withStartDateCount = 0;
      int noStartDateCount = 0;
      int eligibleCount = 0;

      for (var knowledge in allKnowledge) {
        if (knowledge.currentStatus == 'approved') {
          approvedCount++;

          khLog(
            '📄 [AUTO-PUBLISH] Checking approved doc: ${knowledge.currentKnowledgeId}',
          );
          khLog(
            '   📅 schedulePublishing: ${knowledge.currentSchedulePublishing}',
          );

          // SCENARIO 1: No start date - publish immediately
          if (knowledge.currentStartDateTime == null) {
            noStartDateCount++;
            eligibleCount++;
            documentsToUpdate.add(knowledge.currentKnowledgeId);
            khLog('   ✅ ELIGIBLE for immediate publish! (No start date)');
          }
          // SCENARIO 2: Has start date - check if time has come
          else {
            try {
              DateTime startDate = knowledge.currentStartDateTime!.toDate();
              withStartDateCount++;

              khLog('   🕐 Start date: $startDate');
              khLog(
                '   ⏱️  Time difference: ${now.difference(startDate).inHours} hours',
              );

              // Remove timezone by comparing dates only
              DateTime nowDate = DateTime(
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute,
              );
              DateTime startDateOnly = DateTime(
                startDate.year,
                startDate.month,
                startDate.day,
                startDate.hour,
                startDate.minute,
              );

              khLog('   📆 Now: $nowDate');
              khLog('   📆 Start: $startDateOnly');

              // If start date has passed or is now, auto-publish
              if (nowDate.isAfter(startDateOnly) ||
                  nowDate.isAtSameMomentAs(startDateOnly)) {
                eligibleCount++;
                documentsToUpdate.add(knowledge.currentKnowledgeId);
                khLog(
                  '   ✅ ELIGIBLE for auto-publish! (Start date has passed)',
                );
              } else {
                khLog(
                  '   ⏭️  Start date is in the future (${startDateOnly.difference(nowDate).inDays} days from now)',
                );
              }
            } catch (e) {
              khLog('   ⚠️  Error parsing start date: $e');
            }
          }
        }
      }

      khLog('📊 [AUTO-PUBLISH] Summary:');
      khLog('   • Total approved documents: $approvedCount');
      khLog('   • With start dates: $withStartDateCount');
      khLog('   • Without start dates: $noStartDateCount');
      khLog('   • Eligible for auto-publish: $eligibleCount');
      khLog('   • Will update: ${documentsToUpdate.length}');

      // Update all documents that need to be published
      if (documentsToUpdate.isNotEmpty) {
        khLog(
          '🚀 [AUTO-PUBLISH] Publishing ${documentsToUpdate.length} documents...',
        );

        for (String knowledgeId in documentsToUpdate) {
          khLog('   📤 Publishing: $knowledgeId');
          await _repository.updateSubmissionStatus(
            knowledgeId: knowledgeId,
            newStatus: 'published',
          );
        }

        khLog(
          '✅ [AUTO-PUBLISH] Successfully auto-published ${documentsToUpdate.length} documents',
        );
        return true;
      }
      khLog('ℹ️ [AUTO-PUBLISH] No documents need auto-publishing');
      return false;
    } catch (e) {
      khLog('❌ [AUTO-PUBLISH] Error in _autoPublishScheduledDocuments: $e');
      // Something may have been written before the failure: read again.
      return true;
    }
  }
}
