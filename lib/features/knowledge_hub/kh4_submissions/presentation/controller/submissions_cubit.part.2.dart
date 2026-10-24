/// Module: knowledge_hub/kh4_submissions/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: submissions_cubit.part.2.dart
/// Description: Mixin methods of `SubmissionsCubit` — split out of `submissions_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'submissions_cubit.dart';

mixin SubmissionsCubitPart2 on SubmissionsCubitBase {
  /// Reminds the signed-in author's SUPERVISOR that a document is waiting.
  ///
  /// KH-SUBMIT-04: the "Send reminder" button on a pending
  /// submission had an empty handler. Returns whether the reminder was sent.
  Future<bool> sendReviewReminder({
    required String knowledgeId,
    required String documentNameEn,
    required String documentNameAr,
  }) async {
    final String? authorEmail = people.signedInEmployee?.email;
    if (authorEmail == null || authorEmail.isEmpty) return false;
    try {
      final author = await _repository.fetchUserDataByEmail(authorEmail);
      final String supervisor = author?.currentemployeeSupervisor ?? '';
      if (supervisor.isEmpty) return false;
      return await _repository.remindOfPendingReview(
        documentId: knowledgeId,
        senderEmail: authorEmail,
        receiverEmail: supervisor,
        isArabic: KhLocale.isArabicNow,
        documentNameEn: documentNameEn,
        documentNameAr: documentNameAr,
      );
    } catch (e) {
      khLog('sendReviewReminder failed: $e');
      return false;
    }
  }

  /// COMPLETE STATUS FLOW: Auto-archive published documents when end date has
  /// passed. Returns true when at least one document was archived.
  @override
  Future<bool> _autoArchiveExpiredDocuments() async {
    khLog('🗄️ [AUTO-ARCHIVE] Starting auto-archive check...');

    try {
      DateTime now = DateTime.now();
      khLog('⏰ [AUTO-ARCHIVE] Current time: $now');

      List<Map<String, dynamic>> documentsToArchive =
          []; // Changed to store document data
      int publishedCount = 0;
      int withEndDateCount = 0;
      int eligibleCount = 0;

      for (var knowledge in allKnowledge) {
        if (knowledge.currentStatus == 'published') {
          publishedCount++;

          khLog(
            '📄 [AUTO-ARCHIVE] Checking published doc: ${knowledge.currentKnowledgeId}',
          );

          // Only check documents that have end dates
          if (knowledge.currentEndDateTime != null) {
            try {
              DateTime endDate = knowledge.currentEndDateTime!.toDate();
              withEndDateCount++;

              khLog('   🕐 End date: $endDate');
              khLog(
                '   ⏱️  Time difference: ${now.difference(endDate).inHours} hours',
              );

              // Remove timezone by comparing dates only
              DateTime nowDate = DateTime(
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute,
              );
              DateTime endDateOnly = DateTime(
                endDate.year,
                endDate.month,
                endDate.day,
                endDate.hour,
                endDate.minute,
              );

              khLog('   📆 Now: $nowDate');
              khLog('   📆 End: $endDateOnly');

              // SCENARIO 3: If end date has passed, auto-archive
              if (nowDate.isAfter(endDateOnly)) {
                eligibleCount++;

                // Store document data for notification
                documentsToArchive.add({
                  'knowledgeId': knowledge.currentKnowledgeId,
                  'creatorEmail': knowledge.currentCreatedByEmail,
                  'nameEnglish': knowledge.currentNameEnglish,
                  'nameArabic': knowledge.currentNameArabic,
                  'endDate': endDate,
                });

                khLog('   ✅ ELIGIBLE for auto-archive! (End date has passed)');
              } else {
                khLog(
                  '   ⏭️  End date is in the future (${endDateOnly.difference(nowDate).inDays} days from now)',
                );
              }
            } catch (e) {
              khLog('   ⚠️  Error parsing end date: $e');
            }
          } else {
            khLog(
              '   ⏭️  No end date set - will remain published indefinitely',
            );
          }
        }
      }

      khLog('📊 [AUTO-ARCHIVE] Summary:');
      khLog('   • Total published documents: $publishedCount');
      khLog('   • With end dates: $withEndDateCount');
      khLog('   • Eligible for auto-archive: $eligibleCount');
      khLog('   • Will update: ${documentsToArchive.length}');

      // Update all documents that need to be archived
      if (documentsToArchive.isNotEmpty) {
        khLog(
          '🗄️ [AUTO-ARCHIVE] Archiving ${documentsToArchive.length} documents...',
        );

        for (var docData in documentsToArchive) {
          String knowledgeId = docData['knowledgeId'];
          String creatorEmail = docData['creatorEmail'];
          String nameEnglish = docData['nameEnglish'];
          String nameArabic = docData['nameArabic'];

          khLog('   📦 Archiving: $knowledgeId', name: 'AUTO-ARCHIVE');

          // Update status to archived
          await _repository.updateSubmissionStatus(
            knowledgeId: knowledgeId,
            newStatus: 'archived',
          );

          // Send notification to document creator
          if (creatorEmail.isNotEmpty) {
            khLog(
              '   📧 Sending archive notification to: $creatorEmail',
              name: 'AUTO-ARCHIVE',
            );
            await _sendArchiveNotification(
              knowledgeId: knowledgeId,
              recipientEmail: creatorEmail,
              documentNameEnglish: nameEnglish,
              documentNameArabic: nameArabic,
              archivedDate: now,
            );
          } else {
            khLog(
              '   ⚠️ No creator email found, skipping notification',
              name: 'AUTO-ARCHIVE',
            );
          }
        }

        khLog(
          '✅ [AUTO-ARCHIVE] Successfully auto-archived ${documentsToArchive.length} documents',
        );
        return true;
      }
      khLog('ℹ️ [AUTO-ARCHIVE] No documents need auto-archiving');
      return false;
    } catch (e) {
      khLog('❌ [AUTO-ARCHIVE] Error in _autoArchiveExpiredDocuments: $e');
      // Something may have been written before the failure: read again.
      return true;
    }
  }

  /// Update submission status with user validation
  @override
  Future<void> updateSubmissionStatus({
    required String knowledgeId,
    required String newStatus,
  }) async {
    try {
      emit(FetchingSubmissionsLoadingState());

      // SECURITY: Verify the document belongs to current user
      final userEmail = _getCurrentUserEmail();
      final knowledge = allKnowledge.firstWhere(
        (k) => k.currentKnowledgeId == knowledgeId,
        orElse: () => CreateKnowledgeModel(
          timestamps: [],
          knowledgeId: [],
          nameEnglish: [],
          nameArabic: [],
          startTime: [],
          endTime: [],
          descriptionEnglish: [],
          descriptionArabic: [],
          knowledgeDocumentType: [],
          owningDepartment: [],
          limitedDepartments: [],
          schedulePublishing: [],
          startDateTime: [],
          endDateTime: [],
          documentUrl: [],
          documentFileName: [],
          timeStamp: [],
          documentExtension: [],
          documentSize: [],
          status: [],
          createdByEmail: [],
        ),
      );

      // Check if document belongs to current user
      if (userEmail != null &&
          knowledge.createdByEmail.isNotEmpty &&
          knowledge.currentCreatedByEmail.toLowerCase().trim() != userEmail) {
        khLog(
          '❌ [SECURITY] User $userEmail attempted to update document owned by ${knowledge.currentCreatedByEmail}',
        );
        emit(
          FetchingSubmissionsErrorState(
            'Unauthorized: You can only update your own documents',
          ),
        );
        return;
      }

      String finalStatus = newStatus;

      // COMPLETE STATUS FLOW LOGIC
      if (newStatus == 'approved') {
        // Check if we should auto-publish immediately (no start date)
        if (knowledge.currentStartDateTime == null) {
          khLog(
            '🚀 [STATUS FLOW] Approved with no start date - auto-publishing immediately',
          );
          finalStatus = 'published';
        } else {
          // Has start date - remain approved until auto-publish triggers
          khLog(
            '⏳ [STATUS FLOW] Approved with start date - will auto-publish later',
          );
          finalStatus = 'approved';
        }
      }

      khLog(
        '🔄 [STATUS UPDATE] Changing $knowledgeId from ${knowledge.currentStatus} to $finalStatus',
      );

      bool success = await _repository.updateSubmissionStatus(
        knowledgeId: knowledgeId,
        newStatus: finalStatus,
      );

      if (success) {
        // If we published a document, check if it needs immediate archiving
        if (finalStatus == 'published') {
          await _checkImmediateArchiving(knowledgeId, knowledge);
        }

        // Refresh the list to get updated statuses
        await fetchMySubmissions();

        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      } else {
        emit(FetchingSubmissionsErrorState('Failed to update status'));
      }
    } catch (e) {
      khLog('Error in updateSubmissionStatus: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Check if a published document needs immediate archiving
  /// Check if a published document needs immediate archiving
  Future<void> _checkImmediateArchiving(
    String knowledgeId,
    CreateKnowledgeModel knowledge,
  ) async {
    try {
      if (knowledge.currentEndDateTime != null) {
        DateTime endDate = knowledge.currentEndDateTime!.toDate();
        DateTime now = DateTime.now();

        if (now.isAfter(endDate)) {
          khLog(
            '📦 [IMMEDIATE ARCHIVE] Document $knowledgeId has passed end date - archiving now',
          );

          // Update to archived status
          await _repository.updateSubmissionStatus(
            knowledgeId: knowledgeId,
            newStatus: 'archived',
          );

          // Send notification to creator
          String creatorEmail = knowledge.currentCreatedByEmail;

          if (creatorEmail.isNotEmpty) {
            await _sendArchiveNotification(
              knowledgeId: knowledgeId,
              recipientEmail: creatorEmail,
              documentNameEnglish: knowledge.currentNameEnglish,
              documentNameArabic: knowledge.currentNameArabic,
              archivedDate: now,
            );
          }
        }
      }
    } catch (e) {
      khLog('Error in _checkImmediateArchiving: $e');
    }
  }

  /// Calculate status counts from allKnowledge list
  @override
  void _calculateStatusCounts() {
    statusCounts = {
      'All': allKnowledge.length,
      'Published': 0,
      'Approved': 0,
      'Pending': 0,
      'Rejected': 0,
      'Removed': 0,
      'Archive': 0,
    };

    for (var knowledge in allKnowledge) {
      String currentStatus = knowledge.currentStatus;

      if (currentStatus == 'published') {
        statusCounts['Published'] = (statusCounts['Published'] ?? 0) + 1;
      } else if (currentStatus == 'approved') {
        statusCounts['Approved'] = (statusCounts['Approved'] ?? 0) + 1;
      } else if (currentStatus == 'pending_approval' ||
          currentStatus == 'scheduled') {
        statusCounts['Pending'] = (statusCounts['Pending'] ?? 0) + 1;
      } else if (currentStatus == 'rejected') {
        statusCounts['Rejected'] = (statusCounts['Rejected'] ?? 0) + 1;
      } else if (currentStatus == 'removed') {
        statusCounts['Removed'] = (statusCounts['Removed'] ?? 0) + 1;
      } else if (currentStatus == 'archived') {
        statusCounts['Archive'] = (statusCounts['Archive'] ?? 0) + 1;
      }
    }

    khLog('Status counts calculated: $statusCounts');
  }

  /// Get count for specific status
  int getStatusCount(String status) {
    return statusCounts[status] ?? 0;
  }

  /// Change selected index (for UI highlighting)
  void chooseIndex(int index) {
    selectedStatusIndex = index;
    emit(ChangeIndexSuccessState(index));
  }

  /// Change inner index (for UI highlighting)
  void chooseInnerIndex(int index) {
    selectedInnerStatusIndex = index;
    emit(ChangeInnerIndexSuccessState(index));
  }

  /// Filter by status with department consideration
  @override
  Future<void> filterByStatus(String status, int index) async {
    try {
      selectedStatusIndex = index;
      selectedStatus = status;
      selectedInnerStatus = null;
      selectedInnerStatusIndex = 0;

      emit(ChangeIndexSuccessState(index));
      emit(ChangeInnerIndexSuccessState(0));
      emit(FetchingSubmissionsLoadingState());

      // Filter locally based on upper category
      if (status == 'All') {
        upperCategoryFiltered = List.from(allKnowledge);
      } else if (status == 'Pending') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'pending_approval' ||
              knowledge.currentStatus == 'scheduled';
        }).toList();
      } else if (status == 'Approved') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'approved';
        }).toList();
      } else if (status == 'Published') {
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == 'published';
        }).toList();
      } else {
        String actualStatus = _mapDisplayStatusToActual(status);
        upperCategoryFiltered = allKnowledge.where((knowledge) {
          return knowledge.currentStatus == actualStatus;
        }).toList();
      }

      // Start with upper category results
      filteredKnowledge = List.from(upperCategoryFiltered);

      // Apply department filter if selected
      if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('Error in filterByStatus: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Filter by department
  Future<void> filterByDepartment(String? department) async {
    try {
      selectedDepartment = department;
      emit(FetchingSubmissionsLoadingState());

      // Start from current filtered results (respects status filter)
      filteredKnowledge = List.from(upperCategoryFiltered);

      // Apply department filter
      if (department != null && department.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('Error in filterByDepartment: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Apply department filter to current filtered list
  void _applyDepartmentFilter() {
    if (selectedDepartment == null || selectedDepartment!.isEmpty) {
      return;
    }

    filteredKnowledge = filteredKnowledge.where((knowledge) {
      String dept = knowledge.owningDepartment.first;
      return dept == selectedDepartment;
    }).toList();

    khLog(
      'Applied department filter: $selectedDepartment, results: ${filteredKnowledge.length}',
    );
  }

  /// Filter by inner status (works within upper category results)
  @override
  Future<void> filterByInnerStatus(String innerStatus, int index) async {
    try {
      selectedInnerStatusIndex = index;
      selectedInnerStatus = innerStatus;

      emit(ChangeInnerIndexSuccessState(index));
      emit(FetchingSubmissionsLoadingState());

      // Start from upper category filtered results
      List<CreateKnowledgeModel> baseList = List.from(upperCategoryFiltered);

      // Apply inner filter
      if (innerStatus == 'All') {
        filteredKnowledge = baseList;
      } else if (innerStatus == 'Published') {
        filteredKnowledge = baseList.where((knowledge) {
          return knowledge.currentStatus == 'published';
        }).toList();
      } else if (innerStatus == 'Scheduled') {
        // Documents with schedulePublishing = true AND start date in the future
        filteredKnowledge = baseList.where((knowledge) {
          if (!knowledge.currentSchedulePublishing) return false;

          DateTime startDate = knowledge.currentStartDateTime!.toDate();
          DateTime now = DateTime.now();

          // Start date hasn't come yet
          return startDate.isAfter(now);
        }).toList();
      } else if (innerStatus == 'ExpiringSoon') {
        // Documents with end date within the next 2 weeks
        filteredKnowledge = baseList.where((knowledge) {
          // A document with no end date never expires, so it is not "expiring
          // soon" (the old `!` threw for it and emptied the whole tab).
          final endTimestamp = knowledge.currentEndDateTime;
          if (endTimestamp == null) return false;
          DateTime endDate = endTimestamp.toDate();
          DateTime now = DateTime.now();
          DateTime twoWeeksFromNow = now.add(const Duration(days: 14));

          // End date is in the future but within 2 weeks
          return endDate.isAfter(now) && endDate.isBefore(twoWeeksFromNow);
        }).toList();
      } else if (innerStatus == 'Archive') {
        filteredKnowledge = baseList.where((knowledge) {
          return knowledge.currentStatus == 'archived';
        }).toList();
      }

      // Apply department filter if selected
      if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply search if there's a query
      if (searchQuery.isNotEmpty) {
        _applySearch();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('Error in filterByInnerStatus: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Search knowledge
  Future<void> searchKnowledge(String query) async {
    try {
      searchQuery = query;
      emit(FetchingSubmissionsLoadingState());

      if (query.isEmpty) {
        // Reset to filtered by status only
        if (selectedStatus == null || selectedStatus == 'All') {
          filteredKnowledge = List.from(allKnowledge);
        } else {
          // Reapply status filter
          await filterByStatus(selectedStatus!, selectedStatusIndex);
          return;
        }
      } else {
        _applySearch();
      }

      // Apply department filter if selected
      if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
        _applyDepartmentFilter();
      }

      // Apply date filters if set
      _applyDateFilters();

      if (filteredKnowledge.isEmpty) {
        emit(FetchingSubmissionsEmptyState());
      } else {
        emit(FetchingSubmissionsSuccessState(filteredKnowledge));
      }
    } catch (e) {
      khLog('Error in searchKnowledge: $e');
      emit(FetchingSubmissionsErrorState(e.toString()));
    }
  }

  /// Apply search on current filtered list
  @override
  void _applySearch() {
    String lowerQuery = searchQuery.toLowerCase();

    // Search within the current filteredKnowledge
    List<CreateKnowledgeModel> searchBase = List.from(filteredKnowledge);

    filteredKnowledge = searchBase.where((knowledge) {
      String nameEn = knowledge.nameEnglish.first.toLowerCase();
      String nameAr = knowledge.nameArabic.first.toLowerCase();
      String descEn = knowledge.descriptionEnglish.first.toLowerCase();
      String descAr = knowledge.descriptionArabic.first.toLowerCase();

      return nameEn.contains(lowerQuery) ||
          nameAr.contains(lowerQuery) ||
          descEn.contains(lowerQuery) ||
          descAr.contains(lowerQuery);
    }).toList();
  }
}
