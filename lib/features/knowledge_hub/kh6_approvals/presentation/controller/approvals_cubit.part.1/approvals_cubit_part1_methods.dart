/// Module: knowledge_hub/kh6_approvals/presentation/controller/approvals_cubit.part.1
///
///*************************** FILE INFO ****************************///
/// File Name: approvals_cubit_part1_methods.dart
/// Description: Methods of `ApprovalsCubit` — split out of `approvals_cubit.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../approvals_cubit.dart';

// Split from approvals_cubit.part.1.dart to keep every file under 700 lines.

mixin ApprovalsCubitPart1Methods2 on ApprovalsCubitBase, ApprovalsCubitPart1 {
  /// ✅ Fetch all knowledge documents that current user supervises (ALL STATUSES)
  @override
  Future<void> fetchAllSubmissions({bool silent = false}) async {
    try {
      if (!silent) emit(FetchingApprovalsLoadingState());

      // ✅ Check if current user email is set
      if (currentUserEmail == null || currentUserEmail!.isEmpty) {
        khLog('❌ Current user email not set!');
        if (silent) return;
        emit(
          FetchingApprovalsErrorState(
            '',
            key: ApprovalsErrorKey.sessionExpired,
          ),
        );
        return;
      }

      khLog('📥 Fetching all knowledge documents...');
      khLog('👤 Current logged-in user (Supervisor): $currentUserEmail');

      // Fetch ALL knowledge documents from Firebase
      final result = await _repository.fetchAllKnowledgeResult();
      if (result.isLeft()) {
        if (silent) return;
        final String detail = result.fold((f) => f.message, (_) => '');
        emit(
          FetchingApprovalsErrorState(
            detail,
            key: ApprovalsErrorKey.loadFailed,
          ),
        );
        return;
      }
      final fetched = result.getOrElse(() => const KnowledgeFetchResult([], 0));
      unreadableDocuments = fetched.unreadable;
      List<CreateKnowledgeModel> allDocs = fetched.documents;
      khLog('📊 Total documents fetched: ${allDocs.length}');

      // Show ALL documents where current user is the approver
      List<CreateKnowledgeModel> approvalDocs = [];

      for (var doc in allDocs) {
        try {
          // Get the email of the person who created this document
          String createdByEmail = doc.authorEmail; // KH-APPROVE-08

          if (createdByEmail.isEmpty) {
            khLog(
              '⚠️ Document ${doc.knowledgeId.first} has no creator email, skipping',
            );
            continue;
          }

          khLog('🔍 Checking document: ${doc.nameEnglish.first}');
          khLog('   Created by: $createdByEmail');
          khLog('   Current status: ${doc.currentStatus}');

          // ✅ Fetch the creator's employee data to get their supervisor.
          // KH-APPROVE-10: a FAILED read throws and is counted below; only
          // an author who really has no employee record is skipped here.
          EmployeeData? creatorData = await _findCreatorOrThrow(createdByEmail);

          if (creatorData == null) {
            khLog(
              '⚠️ Could not find employee data for creator: $createdByEmail',
            );
            continue;
          }

          String creatorSupervisor = creatorData.currentemployeeSupervisor;
          khLog('   Creator supervisor from DB: $creatorSupervisor');
          khLog('   Current user (Potential approver): $currentUserEmail');

          // ✅ Check if current user is the supervisor (regardless of status)
          if (creatorSupervisor.isNotEmpty &&
              creatorSupervisor.toLowerCase() ==
                  currentUserEmail!.toLowerCase()) {
            approvalDocs.add(doc.pendingEditModel ?? doc);
            khLog(
              '✅ ADDED - Current user is the supervisor (Status: ${doc.currentStatus})',
            );
          } else {
            khLog('❌ EXCLUDED - Current user is NOT the supervisor');
          }
        } catch (e) {
          // KH-APPROVE-10: counted and shown, never skipped silently.
          unreadableDocuments++;
          khLog('❌ Error processing document ${doc.knowledgeId.first}: $e');
          continue;
        }
      }

      khLog(
        '📋 Final documents supervised by current user: ${approvalDocs.length}',
      );

      allKnowledge = approvalDocs;

      // Calculate status counts locally
      _calculateStatusCounts();

      applyAllFilters();
      _watchApprovals();
    } catch (e) {
      khLog('❌ Error in fetchAllSubmissions: $e');
      if (!silent) emit(FetchingApprovalsErrorState(e.toString()));
    }
  }

  /// Keeps the approvals queue, tab counts and cards live. Filters stay as
  /// the user left them (applyAllFilters re-applies them).
  void _watchApprovals() => _live.watchPaths([
        getBaseUrl(FirebaseCollections.createKnowledge),
        getBaseUrl(FirebaseCollections.knowledgeApprovals),
      ], () => fetchAllSubmissions(silent: true));

  /// The author's employee record for the approvals queue.
  ///
  /// KH-APPROVE-10: unlike [getUserDataByEmail], a failed read is NOT turned
  /// into "not found" — it throws, so [fetchAllSubmissions] counts the
  /// document as unreadable instead of dropping it from the queue. Returns
  /// null only when the employee does not exist.
  Future<EmployeeData?> _findCreatorOrThrow(String email) async {
    final String key = email.toLowerCase().trim();
    for (final EmployeeData user in _usersCache.values) {
      if (user.currentemployeeEmail.toLowerCase().trim() == key) return user;
    }
    EmployeeData? found = await _repository.fetchUserDataByEmail(email);
    if (found == null) {
      final List<EmployeeData> all = await _repository.fetchAllEmployees();
      for (final EmployeeData employee in all) {
        if (employee.currentemployeeEmail.toLowerCase().trim() == key) {
          found = employee;
          break;
        }
      }
    }
    if (found != null) _usersCache[found.currentemployeeId] = found;
    return found;
  }

  /// Apply filters from dialog
  Future<void> applyFilters({
    String? documentType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      emit(FetchingApprovalsLoadingState());

      selectedDocumentType = documentType;
      selectedStatus = status;
      selectedStartDate = startDate;
      selectedEndDate = endDate;

      // See [ApprovalsCubit.dialogFilterActive]. 'All' is the status dropdown's
      // show-everything option and the two placeholder strings are what an
      // untouched dropdown reports, so none of them count as a filter — applying
      // the dialog with nothing chosen leaves the button plain.
      dialogFilterActive = (documentType != null &&
              documentType.isNotEmpty &&
              documentType != 'Document Type') ||
          (status != null &&
              status.isNotEmpty &&
              status != 'Status' &&
              status != 'All') ||
          startDate != null ||
          endDate != null;

      applyAllFilters();
    } catch (e) {
      khLog('❌ Error in applyFilters: $e');
      emit(FetchingApprovalsErrorState(e.toString()));
    }
  }
}
