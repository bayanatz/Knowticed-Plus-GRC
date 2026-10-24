/// Module: roles/shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_actions.dart
/// Description: `MobileExportActions` widget — split out of `mobile_export_widgets.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../mobile_export_widgets.dart';

// Split from mobile_export_widgets.dart to keep every file under 700 lines.

// ═══════════════════════════════════════════════════════════════════════════
// ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// The two action buttons every step ends with — Figma 6975:23577 / 6975:23715
/// (Clear Filter + Preview N Matches), 6976:24707 / 6976:24709 (Clear Filter +
/// Next) and 6975:23853 / 6975:24025 (Discard + Export).
///
/// The secondary sits at x = 15 and the primary's right edge at x = 360, both
/// 135x38 — so the row is a `spaceBetween` inside the page gutter. Sizes come
/// from `customButton`, which pins 38 tall and radius 8 app-wide; the 135 is
/// asked for through `width`, which that helper honours.
class MobileExportActions extends StatelessWidget {
  const MobileExportActions({
    super.key,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.primaryIcon,
    this.secondaryWidth,
    this.primaryHugsContent = false,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;

  /// A disabled primary keeps its place and greys out rather than disappearing,
  /// so the row never reflows while the user is filling the form in.
  final bool primaryEnabled;

  /// Asset path for the 16 glyph the Export button carries; null draws a
  /// text-only button (Preview / Next).
  final String? primaryIcon;

  /// Width of the secondary button when it is not the standard 135 — the
  /// Active Directory frame draws its Clear Filter 150 wide (x = 15 to 165).
  final double? secondaryWidth;

  /// Lets the primary button size to its own label instead of being pinned.
  ///
  /// Needed by "Preview 142 Matches": the frame hugs that one (8 of padding,
  /// right edge on the 360 gutter) precisely because the label is longer than
  /// 135, and `customButton` centres its text inside whatever `width` it is
  /// given rather than shrinking it — so a pinned 135 would clip the count.
  final bool primaryHugsContent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: secondaryLabel,
          function: onSecondary,
          width: (secondaryWidth ?? MobileExportMetrics.buttonWidth).w,
          color: AppColors.darkGrey,
          textColor: AppColors.text,
        ),
        if (primaryIcon == null)
          customButton(
            title: primaryLabel,
            function: primaryEnabled ? onPrimary : () {},
            // null width + wrapContent is what makes the button hug; a width
            // is only passed when the label is known to fit it.
            width:
                primaryHugsContent ? null : MobileExportMetrics.buttonWidth.w,
            wrapContent: primaryHugsContent,
            color:
                primaryEnabled ? AppColors.primary : AppColors.secondaryButton,
            textColor:
                primaryEnabled ? AppColors.textButton : AppColors.secondaryText,
          )
        else
          // Not `customButtonWithSvg`: that helper measures its own width from
          // the title and only honours `fixedWidth`, and the icon+label here
          // has to land on the same 135 as the button beside it. `customButton`
          // takes `width` directly, so the glyph is composed into the title row
          // through a Stack-free Row inside a SizedBox of that exact width.
          SizedBox(
            width: MobileExportMetrics.buttonWidth.w,
            child: GestureDetector(
              onTapDown: primaryEnabled ? (_) => HapticController.low() : null,
              onTap: primaryEnabled ? onPrimary : null,
              child: Container(
                height: 38.sp,
                decoration: BoxDecoration(
                  color: primaryEnabled
                      ? AppColors.primary
                      : AppColors.secondaryButton,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvgImage(
                      assetPath: primaryIcon!,
                      width: 16.sp,
                      height: 16.sp,
                      color: primaryEnabled
                          ? AppColors.textButton
                          : AppColors.secondaryText,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      primaryLabel,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: primaryEnabled
                            ? AppColors.textButton
                            : AppColors.secondaryText,
                        letterSpacing: -0.5061,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
