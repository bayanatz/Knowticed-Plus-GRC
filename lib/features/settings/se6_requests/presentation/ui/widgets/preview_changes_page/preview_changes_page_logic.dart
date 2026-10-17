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
  Future<void> _submitChanges(BuildContext context) async {
    showConfirmationDialog(
      // 21/9/2026 — report p.22: this animation rendered as a small dot in the
      // confirm dialog. Same icon as the Health Insurance confirm (p.14).
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      title: S.of(context).requesting_a_change,
      message: S.of(context).are_you_sure_submit_request,
      onConfirm: () async {
        final NavigatorState navigator = Navigator.of(context);

        // Read before the first await — `context` must not be touched
        // afterwards. Carries the language the reviewers' notification is
        // sent in (ADDED 24/8/2026).
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

        hideLoadingIndicator();

        if (!mounted) return;

        if (!ok) {
          _requestsCubit.clearMessages();
          if (!context.mounted) return;
          await RequestErrorDialog.show(context);
          return;
        }

        _requestsCubit.clearMessages();

        if (!context.mounted) return;
        await showSuccessDialog(
          lottiePath:
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

  Future<void> showConfirmationDialog({
    required String lottiePath,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    var isPhone = ContextExtension(context).isPhone;
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: 405.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  lottiePath,
                  width: 70.sp,
                  height: 70.sp,
                  fit: BoxFit.scaleDown,
                  repeat: true,
                  animate: true,
                ),
                SizedBox(height: 20.sp),
                Text(
                  title,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.sp),
                  child: Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customButton(
                        title: S.of(context).no,
                        function: () => Navigator.pop(context),
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.text,
                        ),
                        width: isPhone ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        // 21/9/2026 — report p.14/p.22: same grey + white as Discard Changes.
                        color: AppColors.darkGrey,
                      ),
                      SizedBox(width: 20.sp),
                      customButton(
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isPhone ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
