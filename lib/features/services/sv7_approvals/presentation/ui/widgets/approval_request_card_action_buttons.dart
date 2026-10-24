/// Module: services / sv7_approvals / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: approval_request_card_action_buttons.dart
/// Purpose: Reject/Approve action-button row for ApprovalRequestCard. Pure UI
///          — the actual mutation (dialog submit handler) is built and owned
///          by the parent card, which supplies the two onTap callbacks.
///          Extracted from approval_request_card.dart to keep the parent file
/// under 800 LOC ().
/// Author: Amr Mesbah
/// Created at: 02/07/2026
library;

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class ApprovalRequestCardActionButtons extends StatelessWidget {
  final bool isLightMode;
  final VoidCallback onRejectTap;
  final VoidCallback onApproveTap;

  const ApprovalRequestCardActionButtons({
    super.key,
    required this.isLightMode,
    required this.onRejectTap,
    required this.onApproveTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final gap = 12.w;
        final btnW = (constraints.maxWidth - gap) / 2;

        return Row(
          children: [
            SizedBox(
              width: btnW,
              height: 38.sp,
              child: GestureDetector(
                onTapDown: hapticDown(onRejectTap, HapticLevel.high),
                onTap: onRejectTap,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isLightMode ? AppColors.white : AppColors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.red),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // The Reject icon was wrapped in
                      // a 22.sp red circle while Approve used a bare 24.sp svg,
                      // so the two buttons never matched — and the svg is
                      // already a circular badge, so the wrapper clipped it.
                      CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_status_rejected.svg",
                        width: 24.sp,
                        height: 24.sp,
                        fit: BoxFit.scaleDown,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        S.of(context).Reject,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: btnW,
              height: 38.sp,
              child: GestureDetector(
                onTapDown: hapticDown(onApproveTap, HapticLevel.medium),
                onTap: onApproveTap,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isLightMode ? AppColors.white : AppColors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.lightGreen),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage.natural(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_status_approved_circle.svg",
                        width: 24.sp,
                        height: 24.sp,
                        fit: BoxFit.scaleDown,
                      ),
                      SizedBox(width: 8.w),
                      // A stray `bottom: 3.sp` padding
                      // pushed the Approve label off the baseline that Reject
                      // sits on, so the two labels looked like different type.
                      Text(
                        S.of(context).Approve,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.lightGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
