// ****************** FILE INFO ******************
// File Name: crm_billing_color_tile.dart
// Purpose: Color display and picker trigger tile for Billing & Contracts
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmBillingColorTile extends StatelessWidget {
  final String label;
  final String hex;
  final Color color;
  final VoidCallback? onTap;
  final bool isInteractive;

  const CrmBillingColorTile({
    super.key,
    required this.label,
    required this.hex,
    required this.color,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget tileContent = Container(
      height: 38.sp,
      padding: EdgeInsets.symmetric(horizontal: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hex,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.black,
            ),
          ),
          Container(
            width: 18.sp,
            height: 18.sp,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize12Weight500.copyWith(
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 6.sp),
        if (isInteractive && onTap != null)
          InkWell(
            onTap: withHaptic(onTap, HapticLevel.low),
            borderRadius: BorderRadius.circular(8.sp),
            child: tileContent,
          )
        else
          tileContent,
      ],
    );
  }
}
