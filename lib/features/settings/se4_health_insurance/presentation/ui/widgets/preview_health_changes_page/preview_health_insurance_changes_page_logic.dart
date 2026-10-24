/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: preview_health_insurance_changes_page_logic.dart
/// Description: Logic and event handlers of `_PreviewHealthInsuranceChangesPageState` — split out of `preview_health_changes_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/preview_health_changes_page.dart';

// Split from preview_health_changes_page.dart to keep every file under 700 lines.

extension _PreviewHealthInsuranceChangesPageStateLogic
    on _PreviewHealthInsuranceChangesPageState {
  /// Function Name: [_submitChanges]
  ///
  /// Purpose: Raise a change request for everything edited in this session.
  ///
  /// The Firestore write, the employee-existence check and the error handling
  /// moved into `RequestsCubit` / `RequestsRepository` — this method only
  /// gathers values, dispatches, and drives the dialogs (CR-SKEL-SE6-N01/N02,
  /// CR-SKEL-SE4-N11).
  ///
  /// UPDATED 24/8/2026: this screen edits two settings sections at once — the
  /// insurance fields and the two emergency contacts — and used to file both as
  /// one `Health Insurance` request. `se5_emergency_contact` is its own
  /// section, so the edits are now split by field name and filed as up to two
  /// requests. An employee who touched only a next-of-kin phone number no
  /// longer receives a notification about their health insurance, and a
  /// reviewer sees the two kinds of change as separate items.
  /// Function Name: [_submitChanges]
  ///
  /// Purpose: Are You Sure → write → Success → back to Settings.
  ///
  /// CHANGED 20/10/2026 (X-126 / X-128, same as the Personal Information
  /// preview): the page-local confirm dialog is gone — this is the shared
  /// `CustomDialogManager.showDialogFlow` (the reference dialog, 5 s
  /// success), and after the success dialog the app returns to Settings ›
  /// Health Insurance (pops the preview and the edit page).
  Future<void> _submitChanges(BuildContext context) async {
    // 23/10/2026 (Moataz): removing the OPTIONAL second emergency contact is
    // saved straight away — no "Are you sure", no request to approve. It only
    // applies when that removal is the ONLY thing edited.
    if (_isOnlySecondContactRemoval()) {
      await _removeSecondContactDirectly(context);
      return;
    }

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    _submitFailed = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      confirmTitle: S.of(context).requesting_a_change,
      confirmSubtitle: S.of(context).are_you_sure_submit_request,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      confirmWidth: 411,
      successWidth: 411,
      onConfirm: () => _performSubmit(isArabic),
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      successTitle: S.of(context).request_submitted,
      successSubtitle: S.of(context).successfully_submitted_request,
      onSuccessComplete: () {
        // CR-KNP-SET-HR-07: filed; a failed notification is a warning only.
        final String? warning = _requestsCubit.state.warning;
        _requestsCubit.clearMessages();
        if (warning != null) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(warning),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ));
        }
        // X-128: back to Settings › Health Insurance.
        for (int i = 0; i < 2; i++) {
          if (navigator.canPop()) navigator.pop();
        }
      },
    );

    if (!_submitFailed || !mounted) return;
    _requestsCubit.clearMessages();
    if (!context.mounted) return;
    await RequestErrorDialog.show(context);
  }

  /// The write behind "Yes": both sections in ONE write (CR-KNP-SET-HR-05).
  /// Returns whether it succeeded, so the flow only shows Success on a real
  /// success.
  Future<bool> _performSubmit(bool isArabic) async {
    final List<FieldChange> changes = widget.changes.entries
        .map<FieldChange>((MapEntry<String, dynamic> entry) {
      final Map<String, dynamic> value =
          (entry.value as Map).cast<String, dynamic>();
      return FieldChange(
        fieldName: entry.key,
        oldValue: value['oldValue']?.toString() ?? '',
        newValue: value['newValue']?.toString() ?? '',
      );
    }).toList();

    final List<FieldChange> emergencyChanges = changes
        .where((FieldChange c) =>
            _PreviewHealthInsuranceChangesPageState._isEmergencyContactField(
                c.fieldName))
        .toList();
    final List<FieldChange> insuranceChanges = changes
        .where((FieldChange c) =>
            !_PreviewHealthInsuranceChangesPageState._isEmergencyContactField(
                c.fieldName))
        .toList();

    final bool ok = await _requestsCubit.submitMany(
      parts: <({String section, List<FieldChange> changes})>[
        (
          section: SettingsRequestKind.healthInsurance.sectionName,
          changes: insuranceChanges,
        ),
        (
          section: SettingsRequestKind.emergencyContact.sectionName,
          changes: emergencyChanges,
        ),
      ],
      employeeId: employee?.id ?? '',
      employeeName:
          '${employee?.firstName.lastOrNull ?? ''} ${employee?.lastName.lastOrNull ?? ''}'
              .trim(),
      employeeEmail: employee?.email.lastOrNull ?? '',
      requestNote: requestNoteController.text.trim(),
      isArabic: isArabic,
    );
    if (!ok) _submitFailed = true;
    return ok;
  }

  /// Whether every edited field is a second-contact field that was emptied.
  bool _isOnlySecondContactRemoval() {
    if (widget.changes.isEmpty) return false;
    return widget.changes.entries.every((MapEntry<String, dynamic> entry) {
      if (!entry.key.toLowerCase().startsWith('secondcontact')) return false;
      final Map<String, dynamic> value =
          (entry.value as Map).cast<String, dynamic>();
      return (value['newValue']?.toString() ?? '').trim().isEmpty;
    });
  }

  /// Applies the removal to the employee's own record — the very write an
  /// approved request performs (`applyChangesToEmployee`) — then shows the
  /// success dialog and returns to Settings › Health Insurance.
  Future<void> _removeSecondContactDirectly(BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final List<FieldChange> changes = widget.changes.entries
        .map<FieldChange>((MapEntry<String, dynamic> entry) {
      final Map<String, dynamic> value =
          (entry.value as Map).cast<String, dynamic>();
      return FieldChange(
        fieldName: entry.key,
        oldValue: value['oldValue']?.toString() ?? '',
        newValue: value['newValue']?.toString() ?? '',
      );
    }).toList();

    bool ok = false;
    try {
      final RequestsRemoteDataSource source = RequestsRemoteDataSource();
      final List<String> skipped = await source.applyChangesToEmployee(
          employeeId: employee?.id ?? '', changes: changes);
      ok = skipped.isEmpty;
    } catch (_) {
      ok = false;
    }

    if (!context.mounted) return;
    if (!ok) {
      await RequestErrorDialog.show(context);
      return;
    }
    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      title: S.of(context).dataHasBeenSavedSuccessfully,
    );
    for (int i = 0; i < 2; i++) {
      if (navigator.canPop()) navigator.pop();
    }
  }
}
