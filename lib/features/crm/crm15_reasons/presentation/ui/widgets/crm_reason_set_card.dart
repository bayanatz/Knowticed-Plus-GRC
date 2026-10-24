// Module: crm / crm15_reasons
// ****************** FILE INFO ******************
// File Name: crm_reason_set_card.dart
// Purpose: Extracted grid card for a CRM reason-set category
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm15_reasons/domain/entities/crm_reason.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmReasonSetCard extends StatelessWidget {
  final CrmReasonSetDefinition reasonSet;
  final VoidCallback onTap;

  const CrmReasonSetCard({
    super.key,
    required this.reasonSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: withHaptic(onTap, HapticLevel.low),
        borderRadius: BorderRadius.circular(10.sp),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40.sp,
                height: 40.sp,
                decoration: BoxDecoration(
                  color: AppColors.disabledGrey,
                  borderRadius: BorderRadius.circular(8.sp),
                ),
                child: Center(
                  child: CustomSvgImage(
                    assetPath: CrmAssets.crmReasons,
                    width: 22.sp,
                    height: 22.sp,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              SizedBox(width: 12.sp),
              Expanded(
                child: Text(
                  reasonSet.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight500,
                ),
              ),
            ],
          ),
        ),
      );
}
