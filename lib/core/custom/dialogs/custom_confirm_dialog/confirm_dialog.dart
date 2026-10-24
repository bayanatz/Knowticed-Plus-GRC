/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: confirm_dialog.dart
/// Description: `_ConfirmDialog` widget — split out of `11-custom_confirm_dialog.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_confirm_dialog.dart';

// Split from 11-custom_confirm_dialog.dart to keep every file under 700 lines.

class _ConfirmDialog extends StatelessWidget implements DestructiveDialog {
  /// Delete / remove / log out wording -> shake once; otherwise scale.
  @override
  bool get isDestructive =>
      HapticController.isDestructiveText('$title $subtitle $confirmLabel');

  final String title;
  final String subtitle;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? lottieAsset;
  final bool repeat;
  final Widget? iconWidget;

  const _ConfirmDialog({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.lottieAsset,
    this.repeat = true,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: DialogWidth.small.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          // Icon
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

          SizedBox(height: 16.h),

          // Buttons row
          Row(
            // Yellow always on the RIGHT edge, Discard / Cancel on the LEFT
            // (X-73, final 15 Oct) — in Arabic too, so the row is not mirrored.
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _secondaryBtn(
                width: context.isPhone ? 135.sp : 135.sp,
                label: cancelLabel,
                haptic: HapticController.high, // Cancel is always HIGH (X-14)
                onTap: () {
                  Navigator.of(context).pop();
                  onCancel?.call();
                },
              ),
              _primaryBtn(
                width: context.isPhone ? 135.sp : 135.sp,
                label: confirmLabel,
                haptic: HapticController.high, // confirm "are you sure"
                onTap: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
              ),
            ],
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconWidget != null) return iconWidget!;
    return Lottie.asset(
      lottieAsset ??
          'assets/lottie_assets/main_lottie_assets/lot_status_confirmation.json',
      width: 90.r,
      height: 90.r,
      repeat: repeat,
    );
  }
}
