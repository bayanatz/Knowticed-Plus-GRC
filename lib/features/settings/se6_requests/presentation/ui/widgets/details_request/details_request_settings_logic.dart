/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: details_request_settings_logic.dart
/// Description: Logic and event handlers of `_DetailsRequestSettingsState` — split out of `details_request.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/details_request.dart';

// Split from details_request.dart to keep every file under 700 lines.

extension _DetailsRequestSettingsStateLogic on _DetailsRequestSettingsState {
  /// Function Name: [_loadRequest]
  ///
  /// Purpose: Load the request through the cubit and mirror it into the local
  ///          fields this page renders.
  ///
  /// The Firestore read, the two document shapes and the three `try` blocks
  /// moved into `RequestsRepository` / `ChangeRequestMapper`
  /// (CR-SKEL-SE6-N01, N02). The legacy single-field fallback lives there now.
  Future<void> _loadRequest() async {
    final String requestId = widget.requestId ?? '';
    if (requestId.isEmpty) {
      rebuild(() => isLoading = false);
      return;
    }

    await _requestsCubit.loadRequest(requestId);
    if (!mounted) return;

    final ChangeRequest? loaded = _requestsCubit.state.selected;
    if (loaded == null) {
      _requestsCubit.clearMessages();
      rebuild(() => isLoading = false);
      return;
    }

    rebuild(() {
      _request = loaded;
      createdByEmail = loaded.employeeEmail;
      createdByID = loaded.employeeId;
      status = loaded.status.wireValue;
      section = loaded.section;
      requestTime = loaded.requestDate?.millisecondsSinceEpoch ?? 0;
      requestNoteController.text = loaded.requestNote;
      changes = _DetailsRequestSettingsState._mergeCountryCodeIntoPhone(
        loaded.changes
            .map(
              (FieldChange c) => <String, String>{
                'fieldName': c.fieldName,
                'oldValue': c.oldValue,
                'newValue': c.newValue,
              },
            )
            .toList(),
      );
      isLoading = false;
    });
  }

  /// Function Name: [_decide]
  ///
  /// Purpose: Approve or reject the open request.
  ///
  /// The employee-profile write, the field-name table and the Firestore status
  /// update moved into `RequestsRepository` / `RequestFieldMapping`
  /// (CR-SKEL-SE6-N01, N02). Approving still writes the profile first and the
  /// status second, so a failed profile write leaves the request pending
  /// instead of reading as approved with nothing applied.
  Future<void> _decide(RequestStatus decision) async {
    final ChangeRequest? request = _request;
    if (request == null) return;

    rebuild(() => isProcessing = true);

    // Read before the first await — `context` must not be touched afterwards.
    final bool isArabic = _isArabic;
    final MainCoreEmployeeController employeeController =
        Get.find<MainCoreEmployeeController>();

    // Who is acting. The cubit needs it as the notification's sender; with no
    // email it skips the notification rather than sending from nobody.
    final String approverEmail = employeeController.employeeEntity?.email ?? '';
    // 9/10/2026 — also checked by the repository's self-approval rule for an
    // approve / reject (cancel is the requester's own action, not checked).
    final String approverEmployeeId =
        employeeController.employeeEntity?.id ?? '';

    final bool ok;
    if (decision == RequestStatus.approved) {
      final String employeeId =
          employeeController.getLocaleEmployee(createdByEmail)?.id ?? '';
      ok = await _requestsCubit.approve(
        request: request,
        employeeId: employeeId,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
      );
    } else {
      // Reject and cancel are the same operation on the document: a status
      // change with the employee profile left untouched. Only reject notifies
      // — a cancel is the employee's own doing.
      ok = await _requestsCubit.setStatus(
        request,
        decision,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
        // No rejection-reason field exists on this screen yet; the template's
        // {{rejectionReason}} renders as this until one is added.
        rejectionReason: '-',
      );
    }

    if (ok && decision == RequestStatus.approved) {
      // The approval wrote the employee document, but the profile screens read
      // MainCoreEmployeeController's in-memory cache — without this refresh
      // they keep showing the old values until the app restarts.
      await employeeController.getAllNewEmployees();
      employeeController.update(<String>['employee_profile']);
    }

    if (!mounted) return;

    rebuild(() {
      isProcessing = false;
      if (ok) status = decision.wireValue;
    });

    if (!ok) {
      // 9/10/2026 — a blocked self-approval shows its own EN/AR reason.
      final String? blockedMessage = _requestsCubit.state.userMessage;
      _requestsCubit.clearMessages();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(blockedMessage ?? S.of(context).errorOccurred),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    _requestsCubit.clearMessages();
  }
}
