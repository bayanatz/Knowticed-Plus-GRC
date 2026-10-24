/// Module: knowledge_hub/kh6_approvals/presentation/controller
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_cubit.part.1.dart
/// Description: Mixin methods of `ApprovalsCubit` — split out of `approvals_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'approvals_cubit.dart';

mixin ApprovalsCubitPart1 on ApprovalsCubitBase {
  /// Loads the approver's queue for the signed-in user.
  ///
  /// [resolveUserEmail] returns the signed-in employee's e-mail (loading the
  /// employee first if needed) — never a fallback identity (KH-APPROVE-01).
  /// Any failure ends in the error state, which the screen shows with Retry.
  Future<bool> initializeQueue({
    required Future<String?> Function() resolveUserEmail,
  }) async {
    try {
      final String? email = await resolveUserEmail();
      if (email == null || email.isEmpty) {
        emit(
          FetchingApprovalsErrorState(
            '',
            key: ApprovalsErrorKey.accountNotLoaded,
          ),
        );
        return false;
      }
      setCurrentUserEmail(email);
      await fetchAllSubmissions();
      await filterByStatusKey('all', 0);
      return true;
    } catch (e) {
      showLoadError(e.toString());
      return false;
    }
  }

  /// Department name + creator for one queue card. Never throws.
  Future<Map<String, dynamic>> fetchCardData(
    CreateKnowledgeModel approvals,
  ) async {
    final Map<String, dynamic> result = {};
    try {
      result['departmentName'] = await getDepartmentName(
        approvals.currentOwningDepartment,
      );
      final creatorEmail = approvals.currentCreatedByEmail;
      if (creatorEmail.isNotEmpty) {
        result['creatorData'] = await getUserDataByEmail(creatorEmail);
      }
    } catch (e) {
      khLog('fetchCardData failed: $e');
    }
    return result;
  }

  /// Creator + department name for the details screen. Never throws.
  Future<({EmployeeData? creator, String? departmentName})>
  loadCreatorAndDepartment({
    required String creatorEmail,
    required String department,
  }) async {
    EmployeeData? creator;
    String? departmentName;
    try {
      if (creatorEmail.isNotEmpty) {
        creator = await getUserDataByEmail(creatorEmail);
      }
      if (department.isNotEmpty) {
        departmentName = await getDepartmentName(department);
      }
    } catch (e) {
      khLog('loadCreatorAndDepartment failed: $e');
    }
    return (creator: creator, departmentName: departmentName);
  }

  /// Shows the queue's error state (with Retry) — e.g. when the signed-in
  /// employee could not be resolved (KH-APPROVE-01).
  void showLoadError(String message) =>
      emit(FetchingApprovalsErrorState(message));

  /// ✅ SET CURRENT USER EMAIL (Call this when user logs in)
  void setCurrentUserEmail(String email) {
    currentUserEmail = email;
    khLog('🔐 Current user email set: $currentUserEmail');
  }

  int getStatusCountByKey(String statusKey) {
    switch (statusKey) {
      case 'all':
        return allKnowledge.length;
      case 'approved':
        return allKnowledge
            .where(
              (k) =>
                  k.currentStatus == 'approved' ||
                  k.currentStatus == 'published',
            )
            .length;
      case 'pending':
        return allKnowledge
            .where(
              (k) =>
                  k.currentStatus == 'pending_approval' ||
                  k.currentStatus == 'scheduled',
            )
            .length;
      case 'rejected':
        return allKnowledge.where((k) => k.currentStatus == 'rejected').length;
      case 'removed':
        return allKnowledge.where((k) => k.currentStatus == 'removed').length;
      default:
        return 0;
    }
  }

  Future<bool> _sendApprovalNotification({
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required bool isApproved,
    required String knowledgeId,
  }) async {
    if (recipientEmail.isEmpty) {
      khLog('⚠️ [KH-NOTIFY] decision on $knowledgeId — no recipient, skipped');
      return false;
    }

    final bool sent =
        await KnowledgeHubNotificationService.notifyAuthorOfDecision(
          documentId: knowledgeId,
          approved: isApproved,
          approverEmail: currentUserEmail ?? '',
          authorEmail: recipientEmail,
          documentNameEn: documentNameEnglish,
          documentNameAr: documentNameArabic,
          isArabic: KhLocale.isArabicNow,
        );

    khLog(
      '${sent ? '✅' : '⚠️'} [KH-NOTIFY] '
      '${isApproved ? 'approved' : 'rejected'} → $recipientEmail '
      '($knowledgeId)',
    );
    return sent;
  }

  /// Function Name: [_announcePublication]
  ///
  /// Purpose: Raise §1.1 "Document Published and Effective".
  ///
  Future<bool> _announcePublication({
    required String recipientEmail,
    required String documentNameEnglish,
    required String documentNameArabic,
    required String knowledgeId,
  }) async {
    if (recipientEmail.isEmpty) return false;

    final bool sent = await KnowledgeHubNotificationService.notifyOfPublication(
      documentId: knowledgeId,
      senderEmail: currentUserEmail ?? '',
      receiverEmail: recipientEmail,
      documentNameEn: documentNameEnglish,
      documentNameAr: documentNameArabic,
      isArabic: KhLocale.isArabicNow,
    );

    khLog(
      '${sent ? '✅' : '⚠️'} [KH-NOTIFY] published → $recipientEmail '
      '($knowledgeId)',
    );
    return sent;
  }

  /// Function Name: [returnForRevision]
  ///
  /// Purpose: Raise §1.1 "Document Returned for Revision" — the reviewer wants
  /// changes and expects the SAME document back, which is a different outcome
  /// from a rejection (that one ends the request).
  ///
  Future<bool> returnForRevision({
    required String knowledgeId,
    required String revisionNotes,
  }) async {
    try {
      CreateKnowledgeModel? knowledgeDoc;
      try {
        knowledgeDoc = allKnowledge.firstWhere(
          (CreateKnowledgeModel doc) =>
              doc.currentKnowledgeId == knowledgeId ||
              doc.knowledgeId.contains(knowledgeId),
        );
      } catch (_) {
        khLog('❌ [KH-NOTIFY] returnForRevision: $knowledgeId not found');
        return false;
      }

      final String status = knowledgeDoc.currentStatus.trim().toLowerCase();
      if (status != 'pending_approval' && status != 'pending') return false;

      final bool returned = await _repository.requestRevision(
        knowledgeId: knowledgeId,
        notes: revisionNotes,
      );
      if (!returned) return false;

      await _repository.createOrUpdateApproval(
        knowledgeId: knowledgeId,
        status: 'revision_requested',
        rejectionReason: revisionNotes,
        approvalJustification: '',
      );
      await fetchAllSubmissions();

      final String authorEmail = knowledgeDoc.authorEmail; // KH-APPROVE-08

      return await KnowledgeHubNotificationService.notifyAuthorOfRevisionRequest(
        documentId: knowledgeId,
        senderEmail: currentUserEmail ?? '',
        authorEmail: authorEmail,
        documentNameEn: knowledgeDoc.currentNameEnglish,
        documentNameAr: knowledgeDoc.currentNameArabic,
        isArabic: KhLocale.isArabicNow,
      );
    } catch (e) {
      khLog('❌ [KH-NOTIFY] returnForRevision failed: $e');
      return false;
    }
  }

  void applyAllFilters() {
    List<CreateKnowledgeModel> list = List.from(allKnowledge);

    // Status (tab or dialog).
    final String? status = selectedStatus;
    if (status != null &&
        status.isNotEmpty &&
        status != 'All' &&
        status != 'Status') {
      if (status == 'Approved') {
        list = list
            .where(
              (k) =>
                  k.currentStatus == 'published' ||
                  k.currentStatus == 'approved',
            )
            .toList();
      } else if (status == 'Pending') {
        list = list
            .where(
              (k) =>
                  k.currentStatus == 'pending_approval' ||
                  k.currentStatus == 'scheduled',
            )
            .toList();
      } else {
        final String actual = _mapDisplayStatusToActual(status);
        list = list.where((k) => k.currentStatus == actual).toList();
      }
    }
    upperCategoryFiltered = List.from(list);

    // Department.
    final String? deptId = selectedDepartmentId;
    if (deptId != null && deptId.isNotEmpty && deptId != 'all') {
      String? deptName;
      try {
        deptName = people.departments.getEnglishDepartmentNameFromDepartmentId(
          departmentId: deptId,
        );
      } catch (_) {
        deptName = null;
      }
      final String wanted = (deptName ?? '').toLowerCase();
      list = wanted.isEmpty
          ? <CreateKnowledgeModel>[]
          : list
                .where((k) => k.currentOwningDepartment.toLowerCase() == wanted)
                .toList();
    }

    // Document type (filter dialog).
    final String? docType = selectedDocumentType;
    if (docType != null && docType.isNotEmpty && docType != 'Document Type') {
      list = list
          .where(
            (k) =>
                k.knowledgeDocumentType.isNotEmpty &&
                k.knowledgeDocumentType.first == docType,
          )
          .toList();
    }

    filteredKnowledge = list;
    if (searchQuery.isNotEmpty) _applySearch();
    if (selectedStartDate != null || selectedEndDate != null) {
      _applyDateFilters();
    }

    // Newest request first.
    filteredKnowledge.sort(
      (a, b) => (b.currentTimestamp ?? 0).compareTo(a.currentTimestamp ?? 0),
    );

    if (filteredKnowledge.isEmpty) {
      emit(FetchingApprovalsEmptyState());
    } else {
      emit(FetchingApprovalsSuccessState(filteredKnowledge));
    }
  }

  /// Filter by status using language-independent key
  Future<void> filterByStatusKey(String statusKey, int index) async {
    try {
      selectedStatusIndex = index;
      selectedInnerStatus = null;
      selectedInnerStatusIndex = 0;
      selectedStatus = switch (statusKey) {
        'approved' => 'Approved',
        'pending' => 'Pending',
        'rejected' => 'Rejected',
        'removed' => 'Removed',
        _ => 'All',
      };
      emit(ChangeIndexSuccessState(index));
      applyAllFilters();
    } catch (e) {
      khLog('❌ Error in filterByStatusKey: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  /// Filter by department
  Future<void> filterByDepartment(String? departmentId) async {
    try {
      selectedDepartmentId = departmentId;
      applyAllFilters();
    } catch (e) {
      khLog('❌ Error in filterByDepartment: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  /// Calculate status counts from allKnowledge list
  void _calculateStatusCounts() {
    statusCounts = {
      'All': allKnowledge.length,
      'Approved': 0,
      'Pending': 0,
      'Rejected': 0,
      'Removed': 0,
      'Archive': 0,
    };

    // ✅ Add this to see what statuses actually exist
    Set<String> uniqueStatuses = {};

    for (var knowledge in allKnowledge) {
      String currentStatus = knowledge.currentStatus;

      // ✅ Track unique statuses for debugging
      uniqueStatuses.add(currentStatus);

      if (currentStatus == 'approved' || currentStatus == 'published') {
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

    khLog('📊 Status counts calculated: $statusCounts');
    khLog('🔍 Unique statuses found in data: $uniqueStatuses');
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

  /// Filter by status (upper category)
  Future<void> filterByStatus(String status, int index) async {
    try {
      selectedStatusIndex = index;
      selectedStatus = status;
      selectedInnerStatus = null;
      selectedInnerStatusIndex = 0;
      emit(ChangeIndexSuccessState(index));
      applyAllFilters();
    } catch (e) {
      khLog('❌ Error in filterByStatus: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  /// Search knowledge
  Future<void> searchKnowledge(String query) async {
    try {
      searchQuery = query;
      applyAllFilters();
    } catch (e) {
      khLog('❌ Error in searchKnowledge: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  /// Apply search on current filtered list
  void _applySearch() {
    String lowerQuery = searchQuery.toLowerCase();

    List<CreateKnowledgeModel> searchBase = List.from(filteredKnowledge);

    filteredKnowledge = searchBase.where((knowledge) {
      // ✅ Search in both languages
      String nameEn = knowledge.currentNameEnglish.toLowerCase();
      String nameAr = knowledge.currentNameArabic.toLowerCase();
      String descEn = knowledge.currentDescriptionEnglish.toLowerCase();
      String descAr = knowledge.currentDescriptionArabic.toLowerCase();

      return nameEn.contains(lowerQuery) ||
          nameAr.contains(lowerQuery) ||
          descEn.contains(lowerQuery) ||
          descAr.contains(lowerQuery);
    }).toList();

    khLog('🔍 Search results: ${filteredKnowledge.length} documents found');
  }

  /// Apply date filters to the current filtered list
  void _applyDateFilters() {
    // ✅ ONLY apply if dates are actually set
    if (selectedStartDate == null && selectedEndDate == null) {
      return; // No date filters to apply
    }

    filteredKnowledge = filteredKnowledge.where((knowledge) {
      // Don't filter out documents with empty timestamps
      if (knowledge.timestamps.isEmpty) {
        // If no timestamps, use current time as fallback
        // This ensures newly created/approved documents still appear
        DateTime docDate = DateTime.now();

        bool matchesStartDate =
            selectedStartDate == null ||
            docDate.isAfter(selectedStartDate!) ||
            docDate.isAtSameMomentAs(selectedStartDate!);

        bool matchesEndDate =
            selectedEndDate == null ||
            docDate.isBefore(selectedEndDate!.add(const Duration(days: 1))) ||
            docDate.isAtSameMomentAs(selectedEndDate!);

        return matchesStartDate && matchesEndDate;
      }

      // Get the latest timestamp (most recent status update)
      int latestTimestamp = knowledge.timestamps.last;
      DateTime docDate = DateTime.fromMillisecondsSinceEpoch(latestTimestamp);

      bool matchesStartDate =
          selectedStartDate == null ||
          docDate.isAfter(selectedStartDate!) ||
          docDate.isAtSameMomentAs(selectedStartDate!);

      bool matchesEndDate =
          selectedEndDate == null ||
          docDate.isBefore(selectedEndDate!.add(const Duration(days: 1))) ||
          docDate.isAtSameMomentAs(selectedEndDate!);

      return matchesStartDate && matchesEndDate;
    }).toList();

    khLog('📅 After date filtering: ${filteredKnowledge.length} documents');
  }
}
