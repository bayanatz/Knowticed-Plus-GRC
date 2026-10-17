/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_confirm_dialog.dart
/// Description: Declares `_DialogShell`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grc_module/core/custom/inputs/custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';
import 'package:grc_module/core/custom/helpers/custom_svg.dart';

import 'package:grc_module/core/theme/app_animations.dart';

part 'custom_confirm_dialog/confirm_dialog.dart';
part 'custom_confirm_dialog/comment_dialog_state.dart';
part 'custom_confirm_dialog/message_dialog.dart';
part 'custom_confirm_dialog/show_confirm_dialog.dart';

// ─────────────────────────────────────────────
//  SHARED HELPERS
// ─────────────────────────────────────────────

/// Rounded dialog shell used by every dialog.
class _DialogShell extends StatelessWidget {
  final Widget child;
  final double? width;

  //
  const _DialogShell({required this.child, this.width});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: width ?? 420.w,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.card
              : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.totalBlack.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(-3, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.r),
        child: child,
      ),
    );
  }
}

/// Yellow primary button (matches your customButton style).
Widget _primaryBtn({
  required String label,
  required VoidCallback onTap,
  VoidCallback? haptic,
  double? width,
}) {
  // Haptic on finger-down (X-104); the action stays on the tap.
  return GestureDetector(
    onTapDown: haptic == null ? null : (_) => haptic(),
    onTap: onTap,
    child: Container(
      width: width,
      height: 36.sp,
      decoration: BoxDecoration(
        color: AppColors.primary, // #FFDE59
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.textButton,
          ),
        ),
      ),
    ),
  );
}

/// Grey/neutral secondary button.
Widget _secondaryBtn({
  required String label,
  required VoidCallback onTap,
  VoidCallback? haptic,
  double? width,
}) {
  // Haptic on finger-down (X-104); the action stays on the tap.
  return GestureDetector(
    onTapDown: haptic == null ? null : (_) => haptic(),
    onTap: onTap,
    child: Container(
      width: width,
      height: 36.sp,
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
//  2.  SUCCESS DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showSuccessDialog(
///   context: context,
///   title: 'Request Cancelation',
///   subtitle: 'You Successfully Requested Cancelation For This Request',
/// );
/// ```
Future<void> showSuccessDialog({
  required BuildContext context,
  String title = 'Success',
  String subtitle = 'Operation completed successfully.',
  String closeLabel = 'Close',
  VoidCallback? onClose,

  /// Optional custom Lottie animation path.
  /// Defaults to assets/lottie_assets/main_lottie_assets/lottie_approved.json
  String? lottieAsset,

  /// Whether the Lottie animation should loop. Defaults to false (plays once).
  bool repeat = false,
}) {
  return showAppDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
    builder: (_) => _SuccessDialog(
      title: title,
      subtitle: subtitle,
      closeLabel: closeLabel,
      onClose: onClose,
      lottieAsset: lottieAsset,
      repeat: repeat,
    ),
  );
}

/// Same shell as [showErrorDialog] with the attention animation, for the
/// "you cannot continue yet" guards that are not errors — nothing broke, the
/// form is simply incomplete.
Future<void> showWarningDialog({
  required BuildContext context,
  String title = 'Missing Information',
  String subtitle = 'Complete the highlighted fields to continue.',
  String closeLabel = 'Close',
  VoidCallback? onClose,
  String? lottieAsset,
  bool repeat = false,
}) {
  return showErrorDialog(
    context: context,
    title: title,
    subtitle: subtitle,
    closeLabel: closeLabel,
    onClose: onClose,
    lottieAsset: lottieAsset ??
        'assets/lottie_assets/main_lottie_assets/lot_status_attention.json',
    repeat: repeat,
  );
}

// ─────────────────────────────────────────────
//  3.  COMMENT / JUSTIFICATION DIALOG
// ─────────────────────────────────────────────
///
/// Usage:
/// ```dart
/// showCommentDialog(
///   context: context,
///   title: 'Reason Of Cancellation',
///   fieldLabel: 'Justifications',
///   onSubmit: (text) { /* use text */ },
/// );
/// ```
Future<void> showCommentDialog({
  required BuildContext context,
  String title = 'Comment',
  String fieldLabel = 'Justifications',
  String hint = 'Text here',
  String? submitLabel,
  String? discardLabel,
  int maxLength = 500,
  TextDirection textDirection = TextDirection.ltr,

  /// SVG for the title icon; null = yellow circle with a pencil.
  String? titleIconAsset,
  void Function(String comment)? onSubmit,
  VoidCallback? onDiscard,
}) {
  return showAppDialog(
    context: context,
    barrierColor: AppColors.totalBlack.withValues(alpha: 0.4),
    builder: (_) => _CommentDialog(
      title: title,
      fieldLabel: fieldLabel,
      hint: hint,
      submitLabel: submitLabel ??
          (Get.locale?.languageCode == 'ar' ? 'إرسال' : 'Submit'),
      discardLabel: discardLabel ??
          (Get.locale?.languageCode == 'ar' ? 'تجاهل' : 'Discard'),
      maxLength: maxLength,
      textDirection: textDirection,
      titleIconAsset: titleIconAsset,
      onSubmit: onSubmit,
      onDiscard: onDiscard,
    ),
  );
}

class _CommentDialog extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String hint;
  final String submitLabel;
  final String discardLabel;
  final int maxLength;
  final TextDirection textDirection;
  final String? titleIconAsset;
  final void Function(String)? onSubmit;
  final VoidCallback? onDiscard;

  const _CommentDialog({
    required this.title,
    required this.fieldLabel,
    required this.hint,
    required this.submitLabel,
    required this.discardLabel,
    required this.maxLength,
    required this.textDirection,
    this.titleIconAsset,
    this.onSubmit,
    this.onDiscard,
  });

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _UploadDialog extends StatefulWidget {
  final BuildContext parentContext; // ← added
  final String dialogTitle;
  final String titleFieldLabel;
  final String titleFieldHint;
  final String submitLabel;
  final String discardLabel;
  final TextDirection textDirection;
  final String? headerIconAsset;
  final List<String>? allowedExtensions;
  final bool showSuccessOnSubmit;
  final String successTitle;
  final String successSubtitle;
  final String? successLottieAsset;
  final void Function(PlatformFile, String)? onSubmit;

  const _UploadDialog({
    required this.parentContext,
    required this.dialogTitle,
    required this.titleFieldLabel,
    required this.titleFieldHint,
    required this.submitLabel,
    required this.discardLabel,
    required this.textDirection,
    required this.showSuccessOnSubmit,
    required this.successTitle,
    required this.successSubtitle,
    this.headerIconAsset,
    this.allowedExtensions,
    this.successLottieAsset,
    this.onSubmit,
  });

  @override
  State<_UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<_UploadDialog> {
  PlatformFile? _pickedFile;
  final TextEditingController _titleCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  void _handleSubmit() {
    setState(() => _submitted = true);
    if (_pickedFile == null) return;
    if (_titleCtrl.text.trim().isEmpty) return;

    // Close upload dialog
    Navigator.of(context).pop();

    // Fire callback
    widget.onSubmit?.call(_pickedFile!, _titleCtrl.text.trim());

    // Show success dialog using the parent context (still mounted)
    if (widget.showSuccessOnSubmit) {
      showSuccessDialog(
        context: widget.parentContext,
        title: widget.successTitle,
        subtitle: widget.successSubtitle,
        lottieAsset: widget.successLottieAsset,
        onClose: () {},
      );
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return _DialogShell(
      width: 430.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              _TitleIcon(
                assetPath:
                    "assets/icons_assets/main_icons_assets/ic_cloud_upload.svg",
                fallback: Icon(
                  Icons.attach_file,
                  size: 18.r,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.dialogTitle,
                style: StyleText.fontSize14Weight600.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ── STEP 1: Drop zone (shown when no file picked) ──
          if (_pickedFile == null) ...[
            _buildDropZone(lightMode),
            SizedBox(height: 16.h),
            // Only a Discard button in step 1
            Align(
              alignment: Alignment.centerRight,
              child: _secondaryBtn(
                label: widget.discardLabel,
                haptic: HapticController.medium, // discard
                onTap: () {
                  Navigator.of(context).pop();
                },
                width: 120.w,
              ),
            ),
          ],

          // ── STEP 2: File picked → show file card + title field ──
          if (_pickedFile != null) ...[
            _buildFileCard(),
            SizedBox(height: 16.h),

            // Title field (only after file is selected)
            Text(
              widget.titleFieldLabel,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6.h),
            CustomTextField(
              hint: widget.titleFieldHint,
              controller: _titleCtrl,
              fillColor: AppColors.card,
              required: _submitted,
              textDirection: widget.textDirection,
              onChanged: (_) => setState(() {}),
            ),

            // Action buttons — yellow on the RIGHT edge in every language (X-73)
            Row(
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: _secondaryBtn(
                    label: widget.discardLabel,
                    haptic: HapticController.medium, // discard
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _primaryBtn(
                    label: widget.submitLabel,
                    haptic: HapticController.medium, // submit
                    onTap: _handleSubmit,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildDropZone(bool lightMode) {
    return GestureDetector(
      onTapDown: hapticDown(_pickFile, HapticLevel.medium),
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        height: 150.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_action_upload_rounded.svg',
              width: 60.w,
              height: 60.h,
              fit: BoxFit.fill,
            ),
            SizedBox(height: 8.h),
            Text(
              'Drag & Drop files here',
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Or',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileCard() {
    final file = _pickedFile!;
    final extension = file.extension ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.secondaryText.withValues(alpha: .5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomSvgImage(
            assetPath: _getFileIcon(extension),
            width: 28.r,
            height: 28.r,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  _formatBytes(file.size),
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTapDown: (_) => HapticController.high(),
            onTap: () => setState(() => _pickedFile = null),
            child: CustomSvgImage(
              assetPath:
                  "assets/icons_assets/main_icons_assets/ic_status_document_removed.svg",
              width: 15.w,
              height: 15.h,
              fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/ic_file_pdf.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ic_file_powerpoint.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/ic_file_doc.svg';
      case 'png':
        return 'assets/icons_assets/main_icons_assets/ic_media_image.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/ic_media_image.svg';
    }
  }
}

// ─────────────────────────────────────────────
//  SHARED: Title row icon widget
// ─────────────────────────────────────────────
class _TitleIcon extends StatelessWidget {
  final String? assetPath;
  final Widget? fallback;

  const _TitleIcon({this.assetPath, this.fallback});

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Container(
        width: 30.r,
        height: 30.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: Center(
          child: CustomSvgImage(
            assetPath: assetPath!,
            width: 20.r,
            height: 20.r,
            fit: BoxFit.scaleDown,
          ),
        ),
      );
    }
    // CHANGED 17/10/2026 (Moataz: "the circle red needs to be yellow"):
    // the default was a red ✕ circle; it is now the Time Tracker dialog
    // header (TtDialogHeader) — yellow circle, pencil in the button colour.
    return fallback ??
        Container(
          width: 30.r,
          height: 30.r,
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: CustomSvgImage(
            assetPath:
                'assets/icons_assets/main_icons_assets/ic_action_edit_square.svg',
            color: AppColors.textButton,
          ),
        );
  }
}

//showConfirmDialog(
//   context: context,
//   title: 'Request To Cancellation',
//   subtitle: 'Are You Sure You Want to Cancel This Request?',
//   // lottieAsset: 'assets/lottie_assets/main_lottie_assets/lot_status_attention.json', // default
//   onConfirm: () { /* your action */ },
// );

// showSuccessDialog(
// context: context,
// title: 'Request Cancelation',
// subtitle: 'You Successfully Requested Cancelation For This Request',
// // lottieAsset: 'assets/lottie_assets/main_lottie_assets/lot_status_approved.json', // default
// onClose: () { /* optional */ },
// );

//showCommentDialog(
//   context: context,
//   title: 'Reason Of Cancellation',
//   fieldLabel: 'Justifications',
//   titleIconAsset: 'assets/icons_assets/main_icons_assets/ic_status_blocked_minus_circle.svg',
//   textDirection: TextDirection.ltr, // or rtl for Arabic
//   onSubmit: (text) { /* use comment text */ },
// );

//showUploadDialog(
//   context: context,
//   allowedExtensions: ['pdf', 'png', 'jpg'],
//   headerIconAsset: 'assets/icons_assets/main_icons_assets/ic_media_attach_square.svg',
//   onSubmit: (file, titleName) { /* handle upload */ },
// );
