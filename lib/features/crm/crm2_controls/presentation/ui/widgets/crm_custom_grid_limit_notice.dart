// ****************** FILE INFO ******************
// File Name: crm_custom_grid_limit_notice.dart
// Purpose: Yellow notice banner explaining the maximum four fields limit
// Author: Mohand Adel
// Created At: 10/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmCustomGridLimitNotice extends StatelessWidget {
  const CrmCustomGridLimitNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 18.sp,
            color: AppColors.textButton,
          ),
          SizedBox(width: 8.sp),
          Expanded(
            child: Text(
              S.current.crmMax4FieldsCanBeSelected,
              style: StyleText.fontSize12Weight500.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
