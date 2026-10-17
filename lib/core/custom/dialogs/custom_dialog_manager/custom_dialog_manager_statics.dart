/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dialog_manager_statics.dart
/// Description: `_CustomDialogManagerStatics` — split out of `57-custom_dialog_manager.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_dialog_manager.dart';

// Split from 57-custom_dialog_manager.dart to keep every file under 700 lines.

abstract final class _CustomDialogManagerStatics {
  static Future<void> showDialogFlow({
    required BuildContext context,
    required String confirmLottie,
    required String confirmTitle,
    required String confirmSubtitle,
    required String confirmYesText,
    required String confirmNoText,
    // B2 FIX: must return whether the confirm action actually succeeded so the
    // success dialog is only shown on a real success (was VoidCallback, called
    // fire-and-forget with success shown unconditionally).
    required Future<bool> Function() onConfirm,
    VoidCallback? onNoPressed,
    bool commentRequired = false,
    required String successLottie,
    required String successTitle,
    required String successSubtitle,
    bool comment = false,
    TextEditingController? commentController,
    String commentSubmitText = '',
    String commentDiscardText = '',
    String customReasonTitle = '',

    /// SVG for the reason dialog's header icon. Null keeps the title-based
    /// default; see [_showCommentDialog].
    String? customReasonIconAsset,
    // B2 FIX: returns whether the submit action succeeded (was Future<void>).
    Future<bool> Function()? onCommentSubmit,
    VoidCallback? onCommentDiscard,
    VoidCallback? onSuccessDismissed,
    VoidCallback? onSuccessComplete, // ✅ ADD THIS PARAMETER
    /// Skip the success step entirely. The confirm dialog closes and
    /// [onSuccessComplete] runs straight away — no second dialog, no
    /// [onSuccessDismissed]. For flows where the outcome is self-evident
    /// (logout lands the user on the sign-in screen), an extra "it worked"
    /// dialog is one more tap between the user and where they asked to go.
    /// Defaults to true so every existing caller is unchanged.
    bool showSuccessDialog = true,

    /// Width of the CONFIRM dialog, unscaled (`.sp` is applied here). ADDED
    /// 21/9/2026 — defaults to the 500 every existing caller had; the User
    /// Access confirmations pass Figma's 411.
    double confirmWidth = 500,

    /// ADDED 1/10/2026 (Services mobile QA p.13): the success step's title
    /// (20) and message (18) read bigger than the confirm step they follow
    /// (20 / 14). When true the success step uses 18 / 14 instead. Defaults
    /// to false so every existing caller is unchanged.
    bool compactSuccess = false,

    /// ADDED 13/10/2026 (Time Tracker owner): the SUCCESS step's width,
    /// unscaled (`.sp` applied). Null keeps 500.
    double? successWidth,

    /// ADDED 7/10/2026 (animation + haptic standard). Opt-in; defaults keep
    /// every existing caller unchanged.
    ///  * [destructive]: delete / remove / log-out confirmations — the confirm
    ///    content shakes ONCE (`ShakeOnce`), "Yes" fires a HIGH haptic and "No"
    ///    a HIGH one (X-14: every Cancel / No is HIGH).
    ///  * [scaleIn]: every other confirmation — the dialog scales in
    ///    (`ScaleInContent`), "No" fires HIGH, "Yes" keeps MEDIUM.
    bool destructive = false,
    bool scaleIn = false,
  }) async {
    final outerContext = context;

    // ✅ CREATE A COMPLETER TO TRACK WHEN EVERYTHING IS DONE
    final completer = Completer<void>();

    await showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      // Delete / remove / log out "are you sure" -> shake once + high haptic;
      // every other confirm scales in.
      destructive: HapticController.isDestructiveText(
        '$confirmTitle $confirmSubtitle $confirmYesText',
      ),
      builder: (dlgCtx) {
        final isMobile = ContextExtension(dlgCtx).isPhone;
        final Widget dialog = Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: confirmWidth.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    confirmLottie,
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.scaleDown,
                    repeat: true,
                    animate: true,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmTitle,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmSubtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  // Bug report (Settings mobile p.16/p.18): on a phone-width
                  // window the two fixed-width buttons were wider than the
                  // dialog, so "Confirm" / "Yes" ran past its right edge.
                  // Each button keeps its 135 on a wide window but shrinks to
                  // share the dialog's width on a narrow one.
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: No/Discard left, Yes/Submit right in both languages
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 135.sp),
                          child: customButton(
                            fullWidth: true,
                            title: confirmNoText,
                            // No / Cancel is always HIGH (X-14).
                            haptic: HapticController.high,
                            function: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              onNoPressed?.call();
                              // ✅ COMPLETE THE FLOW WHEN USER SAYS NO
                              if (!completer.isCompleted) {
                                completer.complete();
                              }
                            },
                            textStyle: StyleText.fontSize15Weight400.copyWith(
                              color: AppColors.text,
                            ),
                            width: isMobile ? 115.sp : 135.sp,
                            height: 38.sp,
                            radius: 4.r,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                      SizedBox(height: 0, width: 15.sp),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 135.sp),
                          child: customButton(
                            fullWidth: true,
                            title: confirmYesText,
                            haptic: destructive
                                ? HapticController.high
                                : HapticController.medium,
                            function: () async {
                              // 1) Close the confirm dialog FIRST
                              final nav = Navigator.of(
                                dlgCtx,
                                rootNavigator: true,
                              );
                              if (nav.canPop()) {
                                nav.pop();
                              }

                              // 2) Brief delay
                              await Future.delayed(
                                const Duration(milliseconds: 120),
                              );

                              // 3) If comment required, show comment dialog
                              bool proceed = true;
                              if (comment && commentController != null) {
                                if (!outerContext.mounted) return;
                                proceed = await CustomDialogManager
                                    ._showCommentDialog(
                                  context: outerContext,
                                  controller: commentController,
                                  submitText: commentSubmitText,
                                  discardText: commentDiscardText,
                                  reasonTitle: customReasonTitle,
                                  reasonIconAsset: customReasonIconAsset,
                                  onSubmit: onCommentSubmit,
                                  onDiscard: onCommentDiscard,
                                  isRequired: commentRequired,
                                );

                                if (!proceed) {
                                  // ✅ COMPLETE THE FLOW WHEN COMMENT IS DISCARDED
                                  if (!completer.isCompleted) {
                                    completer.complete();
                                  }
                                  return;
                                }
                              }

                              // 4) Run the confirm logic. B2 FIX: only proceed to
                              // the success dialog if it actually succeeded.
                              bool confirmOk;
                              try {
                                if (!outerContext.mounted) return;
                                confirmOk =
                                    await CustomDialogManager.runWithLoading(
                                  outerContext,
                                  onConfirm,
                                );
                              } catch (e) {
                                confirmOk = false;
                              }

                              if (!confirmOk) {
                                // The action failed — do NOT show a false success.
                                if (!completer.isCompleted) {
                                  completer.complete();
                                }
                                return;
                              }

                              // 5) Show success dialog (unless the caller opted out)
                              if (showSuccessDialog) {
                                if (!outerContext.mounted) return;
                                await CustomDialogManager._showSuccessDialog(
                                  context: outerContext,
                                  lottiePath: successLottie,
                                  title: successTitle,
                                  subtitle: successSubtitle,
                                  compact: compactSuccess,
                                  width: successWidth,
                                );

                                onSuccessDismissed?.call();
                              }

                              // ✅ COMPLETE THE FLOW AFTER SUCCESS DIALOG
                              if (!completer.isCompleted) {
                                completer.complete();
                              }

                              // ✅ CALL onSuccessComplete AFTER EVERYTHING IS DONE
                              onSuccessComplete?.call();
                            },
                            textStyle: StyleText.fontSize15Weight400.copyWith(
                              color: AppColors.textButton,
                            ),
                            width: isMobile ? 115.sp : 135.sp,
                            height: 38.sp,
                            radius: 4.r,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (destructive) return ShakeOnce(child: dialog);
        if (scaleIn) return ScaleInContent(child: dialog);
        return dialog;
      },
    );

    // ✅ WAIT FOR THE ENTIRE FLOW TO COMPLETE
    await completer.future;
  }

  static Future<void> showUpload({
    required BuildContext context,
    required Future<void> Function() onBrowse,
    VoidCallback? onDiscard,
  }) async {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = ContextExtension(context).isPhone;
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    await showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: isLight ? AppColors.white : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: SizedBox(
              width: 560.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: badge + title
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomSvgImage(
                            assetPath:
                                'assets/icons_assets/main_icons_assets/ic_upload.svg',
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.contain,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        isArabic ? 'رفع' : 'Upload',
                        style: StyleText.fontSize20Weight500.copyWith(
                          color:
                              isLight ? AppColors.blackButton : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Drop zone (visual)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    decoration: BoxDecoration(
                      color:
                          isLight ? AppColors.card : AppColors.chatBackground,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomSvgImage(
                          assetPath:
                              "assets/icons_assets/main_icons_assets/ic_cloud_upload.svg",
                          width: 100.sp,
                          height: 100.sp,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          isArabic
                              ? 'اسحب وأفلت الملفات هنا'
                              : 'Drag & Drop files here',
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          isArabic ? 'أو' : 'Or',
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Actions
                  Row(
                    textDirection: TextDirection
                        .ltr, // X-73: Cancel left, action right in both languages

                    children: [
                      customButton(
                        title: isArabic ? 'إلغاء' : 'Discard',
                        function: () {
                          Navigator.of(dlgCtx, rootNavigator: true).maybePop();
                          onDiscard?.call();
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.text,
                        ),
                        width: isMobile ? 120.sp : 150.sp,
                        height: 44.sp,
                        radius: 8.r,
                        color: AppColors.darkGrey,
                      ),
                      const Spacer(),
                      customButton(
                        title: isArabic ? 'تصفح الملفات' : 'Browse Files',
                        function: () async {
                          // Close the card first, then run the real upload flow.
                          Navigator.of(dlgCtx, rootNavigator: true).maybePop();
                          await Future.delayed(
                            const Duration(milliseconds: 120),
                          );
                          await onBrowse();
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 120.sp : 150.sp,
                        height: 44.sp,
                        radius: 8.r,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<bool> _showCommentDialog({
    required BuildContext context,
    required TextEditingController controller,
    required String submitText,
    required String discardText,
    required String reasonTitle,

    /// SVG for the reason dialog's header icon. Null keeps the historical
    /// title-based guess — see the note at the icon itself.
    String? reasonIconAsset,
    // B2 FIX: returns whether the submit action succeeded.
    Future<bool> Function()? onSubmit,
    VoidCallback? onDiscard,
    bool isRequired = false,
  }) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // 1) add this helper near the top of the file (outside the widget/class)
    String toWesternDigits(String s) {
      const east = [
        // D-145: Western digits in Arabic too.
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      ];
      const west = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      for (var i = 0; i < east.length; i++) {
        s = s.replaceAll(east[i], west[i]);
      }
      return s;
    }

    String toEasternDigits(String s) {
      const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      const west = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      for (var i = 0; i < west.length; i++) {
        s = s.replaceAll(west[i], east[i]);
      }
      return s;
    }

    final isMobile = ContextExtension(context).isPhone;
    // FIX 25/9/2026 (services bug report p8 — duplicated "requires your
    // approval" notifications): Submit had no in-flight guard, so a second
    // tap while `onSubmit` was still awaiting ran the whole action again —
    // approving twice and notifying the next approver twice.
    bool isSubmitting = false;

    final result = await showAppDialog<bool>(
      context: context,
      barrierDismissible: !isRequired,
      useRootNavigator: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: SizedBox(
              width: 500.sp,
              child: StatefulBuilder(
                builder: (context, setState) {

                  const int kMaxChars = 500;
                  final int len = controller.text.characters.length;
                  isArabic
                      ? '${toEasternDigits(kMaxChars.toString())}/${toEasternDigits(len.toString())}' // AR: ٥٠٠/٠
                      : '${toWesternDigits(len.toString())}/${toWesternDigits(kMaxChars.toString())}'; // EN: 0/500

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          // ADDED 22/9/2026 — [reasonIconAsset]. The icon used
                          // to be a two-way guess off the TITLE: "Reason Of
                          // Approval" got a tick, and anything else got the red
                          // rejection cross. That was fine while the only two
                          // callers were approve and reject, but a third reason
                          // (Knowledge Hub's "Reason Of Editing") then showed a
                          // rejection icon on an edit. A caller that knows its
                          // own icon now passes it; the title guess stays as the
                          // default so every existing caller is untouched.
                          if (reasonIconAsset != null)
                            SizedBox(
                              child: CustomSvgImage(
                                assetPath: reasonIconAsset,
                                width: 30.w,
                                height: 30.h,
                                fit: BoxFit.fill,
                              ),
                            )
                          else if (reasonTitle ==
                              S.of(context).reasonOfApproval)
                            Container(
                              width: 30.sp,
                              height: 30.sp,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: SizedBox(
                                child: Icon(
                                  Icons.check,
                                  color: AppColors.textButton,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              child: CustomSvgImage(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_action_close_circle.svg",
                                width: 30.w,
                                height: 30.h,
                                fit: BoxFit.fill,
                              ),
                            ),
                          SizedBox(width: 5.sp),
                          Text(
                            reasonTitle,
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.sp),
                      CustomValidatedTextFieldMaster(
                        label: S.of(context).Justifications,
                        hint: S.of(context).Texthere,
                        controller: controller,
                        height: 72.sp,
                        maxLines: 3,
                        showCharCount: true,
                        textDirection:
                            isArabic ? TextDirection.rtl : TextDirection.ltr,
                        onChanged: (value) {
                          setState(() {});
                        },
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.blackButton
                                  : AppColors.white,
                        ),
                      ),
                      SizedBox(height: 15.sp),
                      Row(
                        textDirection: TextDirection
                            .ltr, // X-73: No/Discard left, Yes/Submit right in both languages
                        children: [
                          customButton(
                            title: discardText,
                            function: () {
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(false);
                              onDiscard?.call();
                            },
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                            ),
                            width: isMobile ? 120.sp : 150.sp,
                            height: 38.sp,
                            radius: 8.r,
                            color: AppColors.darkGrey,
                          ),
                          const Spacer(),
                          // ✅ DISABLE BUTTON when field is empty and required
                          Builder(
                            builder: (btnContext) {
                              final textValue = controller.text;
                              final trimmedValue = textValue.trim();
                              final isEmpty = trimmedValue.isEmpty;
                              final shouldDisable = isRequired && isEmpty;

                              return Opacity(
                                opacity: shouldDisable ? 0.5 : 1.0,
                                child: IgnorePointer(
                                  ignoring: shouldDisable,
                                  child: customButton(
                                    title: submitText,
                                    function: () async {
                                      if (isSubmitting) return;
                                      isSubmitting = true;
                                      // B2 FIX: pop with the real success result so
                                      // the caller aborts (no success dialog) when
                                      // the submit action failed.
                                      bool submitOk;
                                      try {
                                        submitOk = onSubmit == null
                                            ? true
                                            : await CustomDialogManager
                                                .runWithLoading(
                                                btnContext,
                                                onSubmit,
                                              );
                                      } catch (e) {
                                        submitOk = false;
                                      }
                                      if (!btnContext.mounted) return;
                                      if (Navigator.of(
                                        btnContext,
                                        rootNavigator: true,
                                      ).canPop()) {
                                        if (!btnContext.mounted) return;
                                        Navigator.of(
                                          btnContext,
                                          rootNavigator: true,
                                        ).pop(submitOk);
                                      }
                                      isSubmitting = false;
                                    },
                                    textStyle: StyleText.fontSize16Weight500
                                        .copyWith(color: AppColors.textButton),
                                    width: isMobile ? 120.sp : 150.sp,
                                    height: 38.sp,
                                    radius: 8.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}
