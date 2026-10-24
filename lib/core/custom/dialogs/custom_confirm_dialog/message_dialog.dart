/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: message_dialog.dart
/// Description: `_MessageDialog` widget — split out of `11-custom_confirm_dialog.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../custom_confirm_dialog.dart';

// Split from 11-custom_confirm_dialog.dart to keep every file under 700 lines.

class _MessageDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String closeLabel;
  final VoidCallback? onClose;
  final String lottieAsset;
  final bool repeat;

  const _MessageDialog({
    required this.title,
    required this.subtitle,
    required this.closeLabel,
    required this.lottieAsset,
    this.onClose,
    this.repeat = false,
  });

  @override
  Widget build(BuildContext context) {
    return _DialogShell(
      width: DialogWidth.small.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16.h),
          Lottie.asset(lottieAsset, width: 90.r, height: 90.r, repeat: repeat),
          SizedBox(height: 16.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 16.h),
          _primaryBtn(
            label: closeLabel,
            width: 140.w,
            haptic: HapticController.high, // Close is HIGH (X-14)
            onTap: () {
              Navigator.of(context).pop();
              onClose?.call();
            },
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
