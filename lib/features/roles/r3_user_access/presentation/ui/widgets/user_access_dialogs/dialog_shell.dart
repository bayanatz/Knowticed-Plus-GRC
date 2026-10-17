/// Module: roles/r3_user_access
///
///*************************** FILE INFO ****************************///
/// File Name: dialog_shell.dart
/// Description: `_DialogShell` widget — split out of `user_access_dialogs.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../user_access_dialogs.dart';

// Split from user_access_dialogs.dart to keep every file under 700 lines.

// ══════════════════════════════════════════════════════════════════════════
// Dialog building blocks — styled to match CustomDialogManager's dialogs.
// ══════════════════════════════════════════════════════════════════════════

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.iconPath,
    required this.title,
    required this.confirmText,
    required this.onConfirm,
    required this.onDiscard,
    required this.children,
  });

  /// SVG asset path for the header badge.
  final String iconPath;
  final String title;
  final String confirmText;

  /// A null [onConfirm] renders the primary button disabled — used while the
  /// schedule dialog has no date picked yet.
  final VoidCallback? onConfirm;
  final VoidCallback onDiscard;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        // EDIT 29/8/2026: 24 → 12. The shell is a fixed 420 wide, so the old
        // padding spent 48 of that on margin and squeezed the date field and
        // the reminder row for no gain.
        padding: EdgeInsets.all(12.r),
        child: SizedBox(
          width: 420.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primary,
                    child: CustomSvgImage(
                      assetPath: iconPath,
                      width: 16.sp,
                      height: 16.sp,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize16Weight400,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.sp),
              ...children,
              SizedBox(height: 24.sp),
              Row(
                textDirection: TextDirection
                    .ltr, // X-73: Cancel left, action right in both languages

                children: [
                  customButton(
                    title: UserAccessStrings.discard(context),
                    color: AppColors.darkGrey,
                    textStyle: StyleText.fontSize15Weight400
                        .copyWith(color: AppColors.text),
                    width: isMobile ? 115.sp : 160.sp,
                    function: onDiscard,
                  ),
                  Spacer(),
                  customButton(
                    title: confirmText,
                    // EDIT 29/8/2026: the disabled state is `darkGrey`, not a
                    // 40%-opacity primary. Faded primary still read as the
                    // brand colour — a dimmed live button rather than a dead
                    // one — and it sat next to Discard, which is already
                    // `darkGrey`, so "disabled" and "secondary" now share one
                    // colour and only the primary state stands out.
                    color: onConfirm == null
                        ? AppColors.darkGrey
                        : AppColors.primary,
                    width: isMobile ? 115.sp : 160.sp,
                    function: onConfirm ?? () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
