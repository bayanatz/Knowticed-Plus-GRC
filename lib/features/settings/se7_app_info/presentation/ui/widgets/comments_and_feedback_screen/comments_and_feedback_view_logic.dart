/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: comments_and_feedback_view_logic.dart
/// Description: Logic and event handlers of `_CommentsAndFeedbackViewState` — split out of `comments_and_feedback_screen.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/comments_and_feedback_screen.dart';

// Split from comments_and_feedback_screen.dart to keep every file under 700 lines.

extension _CommentsAndFeedbackViewStateLogic on _CommentsAndFeedbackViewState {
  // ── Submit ────────────────────────────────────────────────────────────────

  /// Function Name: [_submit]
  ///
  /// Purpose: Persist whatever the user filled in, then confirm.
  ///
  /// Parameters:
  /// - [cubit]: does the write and refreshes the list behind the dialog.
  /// - [popOnSuccess]: true on the phone layout only. See the FILE INFO note.
  Future<void> _submit({
    required CommentsFeedbackCubit cubit,
    required bool isSubmitting,
    required bool popOnSuccess,
  }) async {
    if (isSubmitting || !hasAnyData) return;

    // ADDED 21/9/2026 — Settings bug report p.6: "where is the confirmation
    // dialog after press submit?". Every other request in Settings asks first;
    // this one wrote straight away.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: S.of(context).commentsAndFeedbacks,
      subtitle: S.of(context).are_you_sure_submit_request,
      confirmLabel: S.of(context).yes,
      cancelLabel: S.of(context).no,
      lottieAsset:
          'assets/lottie_assets/main_lottie_assets/lot_action_edit_document.json',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    AppControllers.haptic.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    // Guarded rather than a bare `Get.find`: this screen is also reachable
    // through `Routes.settingsCommentsAndFeedback`, where the settings shell
    // may never have been built. Same pattern `settings_screen.dart` uses.
    final employee = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().employee
        : null;

    final AppFeedback feedback = AppFeedback(
      employeeId: employee?.id ?? '',
      employeeName:
          '${employee?.firstName.lastOrNull ?? ''} ${employee?.lastName.lastOrNull ?? ''}'
              .trim(),
      employeeEmail: employee?.email.lastOrNull ?? '',
      bug: _bodyFor(FeedbackKind.bug),
      comment: _bodyFor(FeedbackKind.comment),
      featureRequest: _bodyFor(FeedbackKind.featureRequest),
      // AppFeedback drops anything belonging to a box that was left empty or
      // unticked, so these can be passed whole.
      attachments: _attachments,
      priorities: _priorities,
      details: _detailsForSubmit(),
    );

    final Failure? failure = await cubit.submit(feedback);

    if (!mounted) return;

    if (failure != null) {
      // The raw Firestore message is not shown — it is not something a user
      // can act on. showMessage (not showSuccess) because a failure must stay
      // on screen until dismissed.
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).anErrorOccurred,
      );
      return;
    }

    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lot_status_success.json',
      title: S.of(context).thanksForSharingYourFeedback,
      subtitle: S.of(context).weValueOurCustomersAndStriveToExceedTheirExpecta,
    );

    if (!mounted) return;

    // Clear the form so a second submission does not resend the first.
    for (final TextEditingController controller in _controllers.values) {
      controller.clear();
    }
    for (final TextEditingController controller in _stepsControllers.values) {
      controller.clear();
    }
    rebuild(() {
      _selectedKinds.clear();
      _expandedKinds.clear();
      _moreOptionsKinds.clear();
      _attachments.clear();
      _priorities.clear();
      _details.clear();
    });

    if (popOnSuccess) Get.back();
  }

  // ── Attachments ───────────────────────────────────────────────────────────

  /// Function Name: [_pickAndUpload]
  ///
  /// Purpose: Pick ONE file for [kind] and put it in Storage straight away,
  ///          APPENDING it to that box's list.
  ///
  /// The upload runs on tap, not on submit. That leaves an orphan in the
  /// bucket if the user picks a file and then walks away — accepted, because
  /// the alternative is a Submit that silently stalls for the length of an
  /// upload with no way to tell whether the file was accepted.
  ///
  /// CHANGED 20/10/2026 (CR-KNP-SET-APP-04): was `withData: true`, which read
  /// the WHOLE file into memory before the 10 MB check in the data source
  /// could run — a 2 GB pick froze the app. The picker now hands back a
  /// stream, `file.size` is checked first, and only a file under the limit is
  /// read. Bytes are still what goes to the repository so web (no path) keeps
  /// working.
  Future<void> _pickAndUpload(
    CommentsFeedbackCubit cubit,
    FeedbackKind kind,
  ) async {
    if (_uploadingKind != null) return;

    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withReadStream: true,
    );
    if (picked == null || picked.files.isEmpty) return; // cancelled

    final PlatformFile file = picked.files.first;

    if (!mounted) return;

    const int limit = FeedbackAttachmentRemoteDataSource.maxSizeInBytes;
    if (file.size > limit) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
        title: S.of(context).unsuccessful,
        subtitle: _tooLargeMessage(context, limit ~/ (1024 * 1024)),
      );
      return;
    }

    final Uint8List? bytes = await _readPickedFile(file);
    if (!mounted) return;

    if (bytes == null) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath:
            'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).anErrorOccurred,
      );
      return;
    }

    rebuild(() => _uploadingKind = kind);

    final result = await cubit.uploadAttachment(
      kind: kind,
      fileName: file.name,
      bytes: bytes,
      contentType: _contentTypeOf(file.extension),
    );

    if (!mounted) return;

    rebuild(() => _uploadingKind = null);

    await result.fold(
      (Failure failure) async {
        await CustomDialogManager.showMessage(
          context: context,
          lottiePath:
              'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
          title: S.of(context).unsuccessful,
          // The failure message is shown here, unlike on submit: the size
          // ceiling is the common case and it IS something the user can act on.
          subtitle: failure.errMessage,
        );
      },
      (FeedbackAttachment attachment) async {
        rebuild(() {
          (_attachments[kind] ??= <FeedbackAttachment>[]).add(attachment);
        });
      },
    );
  }

  static String _tooLargeMessage(BuildContext context, int megabytes) =>
      Localizations.localeOf(context).languageCode == 'ar'
          ? 'الملف أكبر من $megabytes ميجابايت.'
          : 'The file is larger than $megabytes MB.';

  /// Reads a size-checked pick into memory: the read stream when the picker
  /// gave one, else the bytes it may already hold (web), else the path.
  static Future<Uint8List?> _readPickedFile(PlatformFile file) async {
    try {
      if (file.readStream != null) {
        final BytesBuilder builder = BytesBuilder(copy: false);
        await for (final List<int> chunk in file.readStream!) {
          builder.add(chunk);
        }
        return builder.takeBytes();
      }
      if (file.bytes != null) return file.bytes;
      if (file.path != null) return await File(file.path!).readAsBytes();
    } catch (e) {
      debugPrint('Feedback attachment read failed: $e');
    }
    return null;
  }
}
