/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: preview_changes_page_logic.dart
/// Description: Logic and event handlers of `_PreviewChangesPageState` — split out of `preview_changes_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/preview_changes_page.dart';

// Split from preview_changes_page.dart to keep every file under 700 lines.

extension _PreviewChangesPageStateLogic on _PreviewChangesPageState {
  /// Function Name: [_submitChanges]
  ///
  /// Purpose: Raise a change request for everything edited in this session.
  ///
  /// The Firestore write, the employee-existence check and the error handling
  /// moved into `RequestsCubit` / `RequestsRepository` — this method only
  /// gathers values, dispatches, and drives the dialogs (CR-SKEL-SE6-N01/N02,
  /// CR-SKEL-SE4-N11).
  /// Function Name: [_submitChanges]
  ///
  /// Purpose: Are You Sure → write → Success → back to Settings.
  ///
  /// CHANGED 20/10/2026 (X-126 / X-128): the page-local confirm and success
  /// dialogs are gone — this is the shared `CustomDialogManager.showDialogFlow`
  /// (the reference dialog, 5 s success). After the success dialog the app
  /// returns to Settings › Personal Information (pops the preview and the
  /// edit page) instead of leaving the user on the form.
  Future<void> _submitChanges(BuildContext context) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    _submitFailed = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      // 21/9/2026 — report p.22: this animation rendered as a small dot in the
      // confirm dialog. Same icon as the Health Insurance confirm (p.14).
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
        // CR-KNP-SET-HR-07: the request is filed; if only the reviewers'
        // notification failed, say so without blocking.
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
        // X-128: back to Settings › Personal Information.
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

  /// The write behind "Yes": uploads the photo (CR-KNP-SET-HR-01), builds
  /// the field changes and files the request. Returns whether it succeeded,
  /// so the flow only shows Success on a real success.
  Future<bool> _performSubmit(bool isArabic) async {
    String? photoUrl;
    if (widget.selectedImage != null) {
      final Either<FirebaseFailure, String> uploaded =
          await FirebaseRepository.uploadFile(
        collectionName:
            '${ApiConstants.baseUri}/employee_photos/${employee?.id ?? 'unknown'}',
        documentName: 'photo',
        filePath: widget.selectedImage!.path,
      );
      photoUrl = uploaded.fold((_) => null, (String url) => url);
      if (photoUrl == null) {
        _submitFailed = true;
        return false;
      }
    }

    final List<FieldChange> changes = widget.changes.entries
        .map<FieldChange>((MapEntry<String, dynamic> entry) {
      final Map<String, dynamic> value =
          (entry.value as Map).cast<String, dynamic>();
      final bool isPhoto = entry.key == 'photo' && photoUrl != null;
      return FieldChange(
        fieldName: entry.key,
        oldValue: value['oldValue']?.toString() ?? '',
        newValue: isPhoto ? photoUrl : value['newValue']?.toString() ?? '',
      );
    }).toList();

    final bool ok = await _requestsCubit.submit(
      section: ChangeRequest.defaultSection,
      employeeId: employee?.id ?? '',
      employeeName:
          '${employee?.firstName.lastOrNull ?? ''} ${employee?.lastName.lastOrNull ?? ''}'
              .trim(),
      employeeEmail: employee?.email.lastOrNull ?? '',
      requestNote: requestNoteController.text.trim(),
      changes: changes,
      isArabic: isArabic,
    );
    if (!ok) _submitFailed = true;
    return ok;
  }
}
