/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: show_confirm_dialog.dart
/// Description: `showConfirmDialog()`, `_SuccessDialog` widget, `showErrorDialog()` and 1 more — split out of `11-custom_confirm_dialog.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_confirm_dialog.dart';

// Split from 11-custom_confirm_dialog.dart to keep every file under 700 lines.

// ─────────────────────────────────────────────
//  1.  CONFIRM DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showConfirmDialog(
///   context: context,
///   title: 'Request To Cancellation',
///   subtitle: 'Are You Sure You Want to Cancel This Request?',
///   onConfirm: () { /* your action */ },
/// );
/// ```
Future<void> showConfirmDialog({
  required BuildContext context,
  String title = 'Confirm',
  String subtitle = 'Are you sure you want to proceed?',
  String confirmLabel = 'Yes',
  String cancelLabel = 'No',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,

  /// Optional custom Lottie animation path.
  /// Defaults to assets/lottie_assets/main_lottie_assets/lottie_attention.json
  String? lottieAsset,

  /// Whether the Lottie animation should loop. Defaults to true.
  bool repeat = true,

  /// Fallback icon widget if you want to bypass Lottie entirely
  Widget? iconWidget,

  /// ADDED 17/10/2026 (opt-in): a delete / remove confirm shakes once as it
  /// appears (X-15) instead of scaling in. Null keeps the old entrance.
  bool? destructive,
}) {
  return showAppDialog(
    context: context,
    destructive: destructive,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
    builder: (_) => _ConfirmDialog(
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      lottieAsset: lottieAsset,
      repeat: repeat,
      iconWidget: iconWidget,
    ),
  );
}

class _SuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String closeLabel;
  final VoidCallback? onClose;
  final String? lottieAsset;
  final bool repeat;

  const _SuccessDialog({
    required this.title,
    required this.subtitle,
    required this.closeLabel,
    this.onClose,
    this.lottieAsset,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: 410.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          // Lottie success animation
          _buildIcon(),
          SizedBox(height: 16.h),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Lottie.asset(
      lottieAsset ??
          'assets/lottie_assets/main_lottie_assets/lot_status_approved.json',
      width: 90.r,
      height: 90.r,
      repeat: repeat,
    );
  }
}

// ─────────────────────────────────────────────
//  2b. ERROR / WARNING DIALOG
// ─────────────────────────────────────────────
///
/// The failure-side counterpart to [showSuccessDialog].
///
/// WHY THIS EXISTS
/// ---------------
/// Failures and validation guards used to be surfaced with
/// `ScaffoldMessenger.showSnackBar`. A snackbar is the wrong instrument for
/// them: it auto-dismisses after a few seconds, it can be covered by the
/// keyboard or a bottom sheet, and on tablet — the primary form factor here —
/// it lands in a corner far from the control the user just pressed. A message
/// the user has to act on (fix the title, pick a member, complete the dates)
/// has to persist until it is acknowledged.
///
/// [showSuccessDialog] dismisses on a barrier tap because nothing is required
/// of the user. This one renders an explicit Close button for the same reason
/// in reverse: acknowledging the failure should be a deliberate act.
///
/// Usage:
/// ```dart
/// showErrorDialog(
///   context: context,
///   title: 'Something Went Wrong',
///   subtitle: state.errorMessage!,
///   closeLabel: 'Close',
/// );
/// ```
Future<void> showErrorDialog({
  required BuildContext context,
  String title = 'Something Went Wrong',
  String subtitle = 'The action could not be completed.',
  String closeLabel = 'Close',
  VoidCallback? onClose,

  /// Defaults to assets/lottie_assets/main_lottie_assets/lot_status_error.json.
  String? lottieAsset,
  bool repeat = false,
}) {
  return showAppDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
    builder: (_) => _MessageDialog(
      title: title,
      subtitle: subtitle,
      closeLabel: closeLabel,
      onClose: onClose,
      lottieAsset: lottieAsset ??
          'assets/lottie_assets/main_lottie_assets/lot_status_error.json',
      repeat: repeat,
    ),
  );
}

// ─────────────────────────────────────────────
//  4.  UPLOAD / ATTACHMENT DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showUploadDialog(
///   context: context,
///   onSubmit: (file, title) { /* handle upload */ },
/// );
/// ```
Future<void> showUploadDialog({
  required BuildContext context,
  String dialogTitle = 'Adding Attachment',
  String titleFieldLabel = 'Title Name',
  String titleFieldHint = 'Text here',
  String submitLabel = 'Submit',
  String discardLabel = 'Discard',
  TextDirection textDirection = TextDirection.ltr,
  String? headerIconAsset,
  List<String>? allowedExtensions,

  /// Custom success title/subtitle, or null to skip success dialog
  String successTitle = 'Attachment Added',
  String successSubtitle = 'Your attachment has been added successfully.',
  bool showSuccessOnSubmit = true,

  /// Optional custom Lottie animation path for the success dialog shown after submit.
  String? successLottieAsset,
  void Function(PlatformFile file, String titleName)? onSubmit,
}) {
  return showAppDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
    builder: (_) => _UploadDialog(
      parentContext: context, // ← pass the parent context
      dialogTitle: dialogTitle,
      titleFieldLabel: titleFieldLabel,
      titleFieldHint: titleFieldHint,
      submitLabel: submitLabel,
      discardLabel: discardLabel,
      textDirection: textDirection,
      headerIconAsset: headerIconAsset,
      allowedExtensions: allowedExtensions,
      showSuccessOnSubmit: showSuccessOnSubmit,
      successTitle: successTitle,
      successSubtitle: successSubtitle,
      successLottieAsset: successLottieAsset,
      onSubmit: onSubmit,
    ),
  );
}
