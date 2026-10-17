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
  Future<void> _submitChanges(BuildContext context) async {
    showConfirmationDialog(
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      title: S.of(context).requesting_a_change,
      message: S.of(context).are_you_sure_submit_request,
      onConfirm: () async {
        final NavigatorState navigator = Navigator.of(context);

        // Read before the first await — `context` must not be touched
        // afterwards. Carries the language the reviewers' notification is
        // sent in.
        final bool isArabic =
            Localizations.localeOf(context).languageCode == 'ar';

        // ADDED 21/9/2026 — Settings bug report p.1/p.7: the confirm dialog
        // closed and nothing showed until the success dialog, so the page
        // looked frozen while the request was written. Same overlay the rest
        // of the app uses; always taken down before any dialog that follows.
        showLoadingIndicator();

        // `widget.changes` is a Map<String, dynamic>, so `entries` yields
        // MapEntry<String, dynamic> — annotating the parameter as
        // MapEntry<String, Map<String, dynamic>> made the closure unassignable
        // and collapsed the result to List<dynamic>. Narrow the *value*
        // instead, which is where the real shape lives.
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
            .where((FieldChange c) => _PreviewHealthInsuranceChangesPageState
                ._isEmergencyContactField(c.fieldName))
            .toList();
        final List<FieldChange> insuranceChanges = changes
            .where((FieldChange c) => !_PreviewHealthInsuranceChangesPageState
                ._isEmergencyContactField(c.fieldName))
            .toList();

        final String employeeId = employee?.id ?? '';
        final String employeeName =
            '${employee?.firstName.lastOrNull ?? ''} ${employee?.lastName.lastOrNull ?? ''}'
                .trim();
        final String employeeEmail = employee?.email.lastOrNull ?? '';
        final String requestNote = requestNoteController.text.trim();

        // Both sections are submitted when both were edited. A section with no
        // edits raises nothing — filing an empty request would put a card in
        // the reviewer's queue with no changes to decide on, and
        // `RequestsRepository.submitRequest` rejects it anyway.
        bool ok = true;

        if (insuranceChanges.isNotEmpty) {
          ok = await _requestsCubit.submit(
            section: SettingsRequestKind.healthInsurance.sectionName,
            employeeId: employeeId,
            employeeName: employeeName,
            employeeEmail: employeeEmail,
            requestNote: requestNote,
            changes: insuranceChanges,
            isArabic: isArabic,
          );
        }

        if (ok && emergencyChanges.isNotEmpty) {
          ok = await _requestsCubit.submit(
            section: SettingsRequestKind.emergencyContact.sectionName,
            employeeId: employeeId,
            employeeName: employeeName,
            employeeEmail: employeeEmail,
            requestNote: requestNote,
            changes: emergencyChanges,
            isArabic: isArabic,
          );
        }

        // Nothing was edited at all — treat it as a failed submission so the
        // success dialog does not claim a request was raised.
        if (insuranceChanges.isEmpty && emergencyChanges.isEmpty) ok = false;

        hideLoadingIndicator();

        if (!context.mounted) return;

        if (!ok) {
          _requestsCubit.clearMessages();
          if (!context.mounted) return;
          await RequestErrorDialog.show(context);
          return;
        }

        _requestsCubit.clearMessages();

        // Uses the shared dialog from core/custom/dialogs rather than the
        // page-local copy that se6's preview_changes_page still carries; the
        // local one was lost in the CR-SKEL-SE4-N11 refactor.
        await showSuccessDialog(
          context: context,
          lottieAsset:
              'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
          title: S.of(context).request_submitted,
          subtitle: S.of(context).successfully_submitted_request,
        );

        // Close the success dialog, then the preview and edit pages. Was three
        // `Get.back()` calls interleaved with `Navigator.pop`, which popped
        // whatever route happened to be on top.
        await Future<void>.delayed(const Duration(seconds: 2));
        for (int i = 0; i < 3; i++) {
          if (navigator.canPop()) navigator.pop();
        }
      },
    );
  }
}
