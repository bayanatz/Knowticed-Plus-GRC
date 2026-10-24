/// Module: core/custom/buttons
/// Description: THE Approve / Reject pair and the status bar that replaces it
///              once a decision exists. ADDED 17/10/2026 (Moataz: "if you are
///              sure it is a duplication, fix it"). Built from the Time Tracker
///              version (owner-reviewed 13/10/2026) and replaces the four
///              module copies (Inventory ×3 `ApprovalButtons`, Services
///              `ApprovalButtons`).
///
///              • Reject left, Approve right (X-73 — the positive action sits
///                at the right edge in both languages).
///              • Phone: one row of equal columns across the width.
///                Tablet: equal fixed-width buttons at the end of the card.
///              • Reject = high haptic, Approve = medium.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract final class ApprovalIcons {
  static const String approve =
      'assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg';
  static const String reject =
      'assets/icons_assets/main_icons_assets/ic_status_rejected_circle.svg';
  static const String canceled =
      'assets/icons_assets/main_icons_assets/ic_action_close_circle_bold.svg';
}

/// Outlined action button: coloured border, icon + label.
/// [high] = destructive haptic (Reject / Cancel).
class CustomOutlinedActionButton extends StatelessWidget {
  const CustomOutlinedActionButton({
    super.key,
    required this.label,
    required this.svgPath,
    required this.color,
    required this.onTap,
    this.high = false,
    this.filled = false,
    this.fillColor,
    this.tintIcon = false,
  });

  final String label;
  final String svgPath;
  final Color color;
  final VoidCallback onTap;
  final bool high;

  /// Yellow filled (Send Reminder) instead of outlined.
  final bool filled;

  /// A solid fill with white content — the red "Cancel" (an outlined Cancel
  /// read as disabled, owner 13/10/2026).
  final Color? fillColor;

  /// Draw the SVG in the content colour (false = its own colours).
  final bool tintIcon;

  @override
  Widget build(BuildContext context) {
    final Color? solid = fillColor;
    final Color fg = solid != null
        ? AppColors.white
        : (filled ? AppTheme.readableOn(AppColors.primary) : color);
    return ShrinkOnTap(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // X-104: haptic on finger-down, action on the tap.
        onTapDown: (_) =>
            high ? HapticController.high() : HapticController.medium(),
        onTap: onTap,
        child: Container(
          height: ButtonSizing.height,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: solid ?? (filled ? AppColors.primary : AppColors.card),
            borderRadius: BorderRadiusDirectional.circular(8.r),
            border: filled || solid != null ? null : Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              tintIcon
                  ? CustomSvgImage(
                      assetPath: svgPath,
                      width: 18.r,
                      height: 18.r,
                      fit: BoxFit.contain,
                      color: fg)
                  : CustomSvgImage.natural(
                      assetPath: svgPath, width: 22.r, height: 22.r),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(color: fg)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A row of action buttons: on a phone equal columns across the full width,
/// on a tablet equal fixed-width buttons at the end. Always left-to-right so
/// the positive (last) button stays on the right edge in Arabic too.
class CustomActionRow extends StatelessWidget {
  const CustomActionRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool phone = context.isPhone;
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: 12.w),
          if (phone)
            Expanded(child: children[i])
          else
            SizedBox(width: 170.w, child: children[i]),
        ],
      ],
    );
  }
}

/// The decision as an outlined bar ("✓ Approved", "⊘ Rejected", …) at the end
/// of the card — full width on a phone, 200 wide on a tablet.
class CustomStatusBar extends StatelessWidget {
  const CustomStatusBar({
    super.key,
    required this.label,
    required this.color,
    required this.svgPath,
  });

  final String label;
  final Color color;
  final String svgPath;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        width: context.isPhone ? double.infinity : 200.w,
        height: ButtonSizing.height,
        padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadiusDirectional.circular(8.r),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomSvgImage.natural(
                assetPath: svgPath, width: 24.r, height: 24.r),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize16Weight500.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Approve / Reject while [myState] is pending; the status bar once the
/// request (or [documentState], the whole request's state) is decided.
class CustomApproveRejectButtons extends StatelessWidget {
  const CustomApproveRejectButtons({
    super.key,
    required this.myState,
    required this.onApprove,
    required this.onReject,
    this.documentState,
    this.showReject = true,
  });

  /// This approver's own step: 'pending' | 'approved' | 'rejected'.
  final String? myState;

  /// The whole request: a cancelled / decided request shows its status even
  /// when this approver's step is still pending.
  final String? documentState;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  /// false = approve-only tier (the Approve button takes the full width).
  final bool showReject;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String doc = documentState?.toLowerCase().trim() ?? '';
    final String mine = myState?.toLowerCase().trim() ?? '';

    if (doc.contains('cancel')) {
      return CustomStatusBar(
          label: s.Canceled,
          color: AppColors.red,
          svgPath: ApprovalIcons.canceled);
    }
    // The whole request's decision wins over this approver's own step.
    final String decided =
        (doc == 'rejected' || doc == 'approved') ? doc : mine;
    if (decided == 'rejected') {
      return CustomStatusBar(
          label: s.Rejected,
          color: AppColors.red,
          svgPath: ApprovalIcons.reject);
    }
    if (decided == 'approved') {
      return CustomStatusBar(
          label: s.Approved,
          color: AppColors.lightGreen,
          svgPath: ApprovalIcons.approve);
    }
    if (mine != 'pending') return const SizedBox.shrink();

    return CustomActionRow(children: <Widget>[
      if (showReject)
        CustomOutlinedActionButton(
          label: s.reject,
          svgPath: ApprovalIcons.reject,
          color: AppColors.red,
          high: true,
          onTap: onReject,
        ),
      CustomOutlinedActionButton(
        label: s.approve,
        svgPath: ApprovalIcons.approve,
        color: AppColors.lightGreen,
        onTap: onApprove,
      ),
    ]);
  }
}
