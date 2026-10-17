/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dialog_manager.dart
/// Description: Declares `CustomDialogManager`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

/// ******************* FILE INFO *******************
/// File Name: custom_dialog.dart
/// Description: this is custom success or comment or select dialog for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025
/// Relocated to core/custom (57); imports repointed to core/custom equivalents.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grc_module/core/constants/app_assets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/custom/inputs/custom_validated_textfield.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:grc_module/core/theme/app_animations.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/custom/feedback/circle_progress.dart';

part 'custom_dialog_manager/custom_dialog_manager_statics.dart';
part 'custom_dialog_manager/custom_dialog_manager_statics2.dart';

class CustomDialogManager {
  /// Shows a blocking loading indicator while [task] runs, then closes it.
  ///
  /// ADDED 30/9/2026 (Role QA p.9, p.19, p.20, p.40): after "Yes" / "Continue"
  /// the confirm dialog closed and nothing happened on screen until the
  /// request came back, so the user could not tell anything was going on.
  static Future<T> runWithLoading<T>(
    BuildContext context,
    Future<T> Function() task,
  ) async {
    // An OverlayEntry, not a dialog route: callers' onConfirm bodies pop their
    // own routes (loaders, pages) and a route on top would swallow that pop.
    final OverlayState? overlay =
        context.mounted ? Overlay.maybeOf(context, rootOverlay: true) : null;
    OverlayEntry? entry;
    if (overlay != null) {
      entry = OverlayEntry(
        builder: (_) => Stack(
          children: [
            ModalBarrier(
              dismissible: false,
              color: AppColors.totalBlack.withValues(alpha: 0.5),
            ),
            Center(
              child: SizedBox(
                width: 70,
                height: 70,
                child: CircleProgressMaster.inline(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.lightPrimary,
                  ),
                  backgroundColor: AppColors.white.withValues(alpha: 0.6),
                  strokeWidth: 2.0,
                ),
              ),
            ),
          ],
        ),
      );
      overlay.insert(entry);
    }
    try {
      return await task();
    } finally {
      entry?.remove();
    }
  }

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
    /// every existing caller unchanged. [destructive]: the confirm content
    /// shakes once, "Yes" HIGH / "No" LOW haptic. [scaleIn]: the dialog scales
    /// in, "No" LOW / "Yes" MEDIUM.
    bool destructive = false,
    bool scaleIn = false,
  }) =>
      _CustomDialogManagerStatics.showDialogFlow(
        context: context,
        confirmLottie: confirmLottie,
        confirmTitle: confirmTitle,
        confirmSubtitle: confirmSubtitle,
        confirmYesText: confirmYesText,
        confirmNoText: confirmNoText,
        onConfirm: onConfirm,
        onNoPressed: onNoPressed,
        commentRequired: commentRequired,
        successLottie: successLottie,
        successTitle: successTitle,
        successSubtitle: successSubtitle,
        comment: comment,
        commentController: commentController,
        commentSubmitText: commentSubmitText,
        commentDiscardText: commentDiscardText,
        customReasonTitle: customReasonTitle,
        customReasonIconAsset: customReasonIconAsset,
        onCommentSubmit: onCommentSubmit,
        onCommentDiscard: onCommentDiscard,
        onSuccessDismissed: onSuccessDismissed,
        onSuccessComplete: onSuccessComplete,
        showSuccessDialog: showSuccessDialog,
        confirmWidth: confirmWidth,
        compactSuccess: compactSuccess,
        successWidth: successWidth,
        destructive: destructive,
        scaleIn: scaleIn,
      );

  /// Standalone success/acknowledgement dialog, for screens that just need to
  /// confirm something worked without the confirm -> comment -> success flow.
  /// Auto-closes after a short delay, same as the flow's final step.
  /// Persistent message dialog — same look as [showSuccess] but it stays until
  /// the user dismisses it.
  ///
  /// Use this for errors and warnings. [showSuccess] auto-closes after ~1.5s,
  /// which is fine for a confirmation but loses the message on a failure the
  /// user needs to read (e.g. a CSV upload listing the missing columns).
  static Future<void> showMessage({
    required BuildContext context,
    required String lottiePath,
    required String title,
    String subtitle = '',
    // ADDED 21/9/2026 — when set, the dialog has no OK button and closes
    // itself after this long (it can still be dismissed by tapping outside).
    Duration? closeAfter,
    // ADDED 13/10/2026 (Time Tracker owner) — the dialog's width, unscaled
    // (`.sp` applied). Null keeps 500.
    double? width,
  }) {
    BuildContext? dialogContext;
    if (closeAfter != null) {
      Future<void>.delayed(closeAfter, () {
        final BuildContext? ctx = dialogContext;
        // `mounted` first: if the user already tapped the barrier, the
        // element is gone and Navigator.of would throw.
        if (ctx != null &&
            ctx.mounted &&
            (ModalRoute.of(ctx)?.isCurrent ?? false)) {
          Navigator.of(ctx, rootNavigator: true).maybePop();
        }
      });
    }
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogContext = ctx;
        return Dialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 500.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottiePath,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: 20.h),
                  // Role QA p.4 / p.38: long titles wrapped to two big lines on a phone.
                  // Kept on one line, scaled down only when it doesn't fit.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: StyleText.fontSize20Weight500.copyWith(
                        color: Theme.of(ctx).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    SizedBox(height: 18.h),
                    // Flexible + scroll: this dialog carries error text of
                    // unbounded length (a failed role save lists every restricted
                    // permission — one such message ran 1029px past the bottom of
                    // a min-height Column, which has nowhere to put the excess).
                    // The Lottie, title and OK button keep their intrinsic size;
                    // only the message scrolls, so the button stays reachable.
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize18Weight500.copyWith(
                            color: Theme.of(ctx).brightness == Brightness.light
                                ? AppColors.secondaryText
                                : AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (closeAfter == null) ...[
                    SizedBox(height: 20.h),
                    customButton(
                      title: S.of(ctx).ok2,
                      function: () =>
                          Navigator.of(ctx, rootNavigator: true).maybePop(),
                      textStyle: StyleText.fontSize15Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      radius: 4.r,
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Persistent dialog hosting a single text field and one confirm action.
  ///
  /// Added for the form-builder "download as PDF/Excel" flow, which needs a
  /// filename field plus a Download button. [showMessage] and [showSuccess] are
  /// message-only, and [showDialogFlow]'s comment step is bound to a
  /// confirm→success sequence, so neither fits an input-then-act dialog.
  ///
  /// Built from the core widgets (CustomTextField, customButton) so it matches
  /// the rest of core/custom. [onConfirm] runs *after* the dialog is dismissed,
  /// so callers are free to push further dialogs from it.
  static Future<void> showInput({
    required BuildContext context,
    required TextEditingController controller,
    required String title,
    required String confirmText,
    required VoidCallback onConfirm,
    String? fieldLabel,
    Widget? leadingIcon,

    /// Dialog width, or null for the 500 default. ADDED.
    ///
    /// INTERPRETED IN `.sp` — pass the raw design number (`360`), not `360.sp`,
    /// the same contract `CustomTextField.height` and `CustomDropdown.height`
    /// carry. A pre-scaled value would be scaled twice.
    ///
    /// 500 is a lot of box for one short field: this dialog is a title, one
    /// input and a button, so at 500 the input stretches most of the way
    /// across the screen for a value that is usually a few words. Defaults to
    /// 500, so every existing call site is unchanged.
    double? width,

    /// ADDED 17/10/2026 (opt-in): when set, a grey Cancel button sits at the
    /// left edge and [confirmText] at the right edge of one row (X-73), for
    /// edit dialogs that must offer a way out besides tapping the barrier.
    /// Null keeps the single right-aligned button every caller had.
    String? cancelText,
    String? hint,
    int maxLines = 1,
  }) {
    return showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.light
            ? AppColors.white
            : AppColors.chatBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Padding(
          // CHANGED: was 24.r. showInput's box is a title, one field and a
          // button, so 24 all round was most of what made the dialog feel
          // oversized even after the width came down. The other dialogs in
          // this file keep 24.r — they carry a 70.sp Lottie and two lines of
          // centred copy, which need the air.
          padding: EdgeInsets.all(12.sp),
          child: SizedBox(
            width: (width ?? 500).sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (leadingIcon != null) ...[
                      leadingIcon,
                      SizedBox(width: 8.w),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: StyleText.fontSize18Weight500.copyWith(
                          color: Theme.of(ctx).brightness == Brightness.light
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                CustomTextField(
                  controller: controller,
                  label: fieldLabel,
                  hint: hint,
                  maxLines: maxLines,
                ),
                SizedBox(height: 20.h),
                if (cancelText != null)
                  Row(
                    // X-73: Cancel at the left edge, the action at the right
                    // edge, in both languages.
                    textDirection: TextDirection.ltr,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      customButton(
                        title: cancelText,
                        function: () =>
                            Navigator.of(ctx, rootNavigator: true).maybePop(),
                        color: AppColors.darkGrey,
                        textColor: AppColors.text,
                        haptic: HapticController.high,
                      ),
                      customButton(
                        title: confirmText,
                        function: () {
                          Navigator.of(ctx, rootNavigator: true).maybePop();
                          onConfirm();
                        },
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: customButton(
                      title: confirmText,
                      function: () {
                        Navigator.of(ctx, rootNavigator: true).maybePop();
                        onConfirm();
                      },
                      textStyle: StyleText.fontSize15Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 135.sp,
                      height: 38.sp,
                      radius: 4.r,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Auto-closing success dialog (no button).
  ///
  /// [closeAfter] ADDED 21/9/2026 — how long it stays up; defaults to the
  /// 1.5 s every existing caller had.
  static Future<void> showSuccess({
    required BuildContext context,
    required String lottiePath,
    required String title,
    String subtitle = '',
    Duration closeAfter = const Duration(milliseconds: 1500),
  }) =>
      _showSuccessDialog(
        context: context,
        lottiePath: lottiePath,
        title: title,
        subtitle: subtitle,
        closeAfter: closeAfter,
      );

  /// Upload dialog — shown BEFORE the file picker.
  ///
  /// ADDED 29/8/2026. The Upload toolbar action used to jump straight into the
  /// OS file picker; this shows the drag-and-drop card first (per the design),
  /// and only runs [onBrowse] — the caller's real upload flow — when the user
  /// taps "Browse Files". [onDiscard] (optional) runs on Discard / dismiss.
  ///
  /// The drop area is visual: real OS drag-and-drop needs a desktop-drop
  /// package and platform channel wiring, which this card does not add — the
  /// working path is the Browse Files button.
  static Future<void> showUpload({
    required BuildContext context,
    required Future<void> Function() onBrowse,
    VoidCallback? onDiscard,
  }) =>
      _CustomDialogManagerStatics.showUpload(
        context: context,
        onBrowse: onBrowse,
        onDiscard: onDiscard,
      );

  /// Generic content dialog — the manager's chrome around ANY child widget.
  ///
  /// ADDED 2/9/2026. [showMessage], [showInput], [showUpload] and [showExport]
  /// each hard-code their own body, so a caller with an existing widget to show
  /// (the chat attachment menu, for one) had no way in and fell back to
  /// `Get.defaultDialog`, which is styled nowhere and ignores this file's
  /// radius/background rules. This is that way in: same [Dialog] shell as
  /// [showUpload], no body of its own.
  ///
  /// Pass [backgroundColor] `Colors.transparent` together with
  /// [padding] `EdgeInsets.zero` when the [child] already paints its own card,
  /// otherwise you get two stacked backgrounds.
  ///
  /// Returns whatever the child pops with, so it can also be used for pickers:
  /// `Navigator.of(ctx, rootNavigator: true).pop(value)`.
  static Future<T?> showContent<T>({
    required BuildContext context,
    required Widget child,
    double? width,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    bool barrierDismissible = true,
    // ADDED 13/10/2026 (Time Tracker owner V2): the content scrolls when the
    // phone keyboard leaves too little room (it overflowed). Opt-in — a child
    // that sizes itself with Expanded / Flexible must keep the default.
    bool scrollable = false,
  }) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return showAppDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: true,
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: backgroundColor ??
              (isLight ? AppColors.white : AppColors.chatBackground),
          // `Colors.transparent` above would still show the default elevation
          // shadow, so drop it whenever the caller supplies its own surface.
          elevation: backgroundColor == Colors.transparent ? 0 : null,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(12.sp),
            child: scrollable
                ? SingleChildScrollView(
                    child: width == null
                        ? child
                        : SizedBox(width: width, child: child),
                  )
                : (width == null
                    ? child
                    : SizedBox(width: width, child: child)),
          ),
        );
      },
    );
  }

  /// Export dialog — a file-name field then Discard / Download.
  ///
  /// ADDED 29/8/2026. Replaces the old filter+preview export dialog for the
  /// simple "name it and download" flow: [onDownload] receives the raw file
  /// name the user typed (the caller adds the extension and runs the export).
  static Future<void> showExport({
    required BuildContext context,
    required Future<void> Function(String fileName) onDownload,
    String? initialFileName,
    // ADDED 13/10/2026 (Time Tracker owner): the dialog's width, as given.
    // Null keeps 300 (phone) / 500.
    double? width,
  }) =>
      _CustomDialogManagerStatics2.showExport(
        context: context,
        onDownload: onDownload,
        initialFileName: initialFileName,
        width: width,
      );

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
  }) =>
      _CustomDialogManagerStatics._showCommentDialog(
        context: context,
        controller: controller,
        submitText: submitText,
        discardText: discardText,
        reasonTitle: reasonTitle,
        reasonIconAsset: reasonIconAsset,
        onSubmit: onSubmit,
        onDiscard: onDiscard,
        isRequired: isRequired,
      );

  // REPLACE the whole method with this:
  static Future<void> _showSuccessDialog({
    required BuildContext context,
    required String lottiePath,
    required String title,
    required String subtitle,
    Duration closeAfter = const Duration(milliseconds: 1500),
    bool compact = false,
    double? width,
  }) async {
    BuildContext? dialogCtx; // capture the dialog's own context

    // IMPORTANT: barrierDismissible=false so users can't dismiss before auto-close
    await showAppDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx; // <-- capture
        return Dialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 500.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottiePath,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: 20.h),
                  // Role QA p.4 / p.38: long titles wrapped to two big lines on a phone.
                  // Kept on one line, scaled down only when it doesn't fit.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: (compact
                              ? StyleText.fontSize18Weight500
                              : StyleText.fontSize20Weight500)
                          .copyWith(
                        color: Theme.of(ctx).brightness == Brightness.light
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  // Same reason as showMessage(): the subtitle can be long
                  // enough to overflow a min-height Column, so it scrolls.
                  Flexible(
                    child: SingleChildScrollView(
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: (compact
                                ? StyleText.fontSize14Weight500
                                : StyleText.fontSize18Weight500)
                            .copyWith(
                          color: Theme.of(ctx).brightness == Brightness.light
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    // Schedule the auto-close tied to the captured dialog context
    await Future.delayed(closeAfter);

    // FIXED 25/8/2026: this threw "Looking up a deactivated widget's ancestor
    // is unsafe" whenever the success dialog was already gone by the time the
    // 1500ms above elapsed — the user tapped the barrier (this dialog is
    // `barrierDismissible: true`), or the route beneath it was popped.
    //
    // `canPop()` could not prevent it: the ancestor lookup happens INSIDE
    // `Navigator.of`, so it throws before there is a NavigatorState to ask.
    // `Element.mounted` is the check that has to come first — and when it is
    // false there is nothing to do anyway, because the dialog this would have
    // closed is already closed.
    //
    // FIXED 1/10/2026 (Services mobile QA p.18, black screen): `mounted` is
    // still true while a barrier-dismissed dialog plays its exit animation,
    // and `canPop()` only says the navigator has SOME route to pop — so a tap
    // just before the timer fired made this pop the page underneath instead.
    // Pop only when this dialog's own route is still the top one.
    if (dialogCtx != null && dialogCtx!.mounted) {
      final ModalRoute<dynamic>? route = ModalRoute.of(dialogCtx!);
      if (route != null && route.isCurrent) {
        Navigator.of(dialogCtx!, rootNavigator: true).pop();
      }
    }
  }
}
