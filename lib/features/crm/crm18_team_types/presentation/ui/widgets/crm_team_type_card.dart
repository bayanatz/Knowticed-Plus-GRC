// Module: crm / crm18_team_types
// ****************** FILE INFO ******************
// File Name: crm_team_type_card.dart
// Purpose: Compact grid card for a CRM team type
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm18_team_types/domain/entities/crm_team_type.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// A selectable card representing one team type and its activation state.
class CrmTeamTypeCard extends StatelessWidget {
  final CrmTeamType teamType;
  final VoidCallback onTap;

  const CrmTeamTypeCard({
    super.key,
    required this.teamType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: withHaptic(onTap, HapticLevel.low),
        borderRadius: BorderRadius.circular(10.sp),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10.sp),
          ),
          child: Row(children: <Widget>[
            Container(
              width: 42.sp,
              height: 42.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: CustomSvgImage(
                assetPath: AppAssets.crmGroup,
                width: 24.sp,
                height: 24.sp,
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Text(
                teamType.nameEn,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.text),
              ),
            ),
            SizedBox(width: 12.sp),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 3.sp),
              decoration: BoxDecoration(
                color: teamType.isActive ? AppColors.green : AppColors.orange,
                borderRadius: BorderRadius.circular(3.sp),
              ),
              child: Text(
                teamType.isActive ? 'Active' : 'Inactive',
                style: StyleText.fontSize10Weight400
                    .copyWith(color: AppColors.white),
              ),
            ),
          ]),
        ),
      );
}
