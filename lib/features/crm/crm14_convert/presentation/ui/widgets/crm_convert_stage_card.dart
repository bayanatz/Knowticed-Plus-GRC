// Module: crm / crm14_convert
// ****************** FILE INFO ******************
// File Name: crm_convert_stage_card.dart
// Purpose: Extracted grid card displaying a CRM conversion stage
// Author: Mohand Adel
// Created At: 07/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm14_convert/domain/entities/crm_convert_stage.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmConvertStageCard extends StatelessWidget {
  final CrmConvertStage stage;
  final VoidCallback onTap;

  const CrmConvertStageCard({
    super.key,
    required this.stage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('d MMM yyyy', Get.locale.toString()).format(stage.updatedAt);
    final String stageName = stage.nameEn.isNotEmpty ? stage.nameEn : 'New';
    final String authorName =
        stage.updatedBy.isNotEmpty ? stage.updatedBy : 'Aya Ali';

    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 48.sp,
              height: 48.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Center(
                child: CustomSvgImage(
                  assetPath: CrmAssets.crmConvert,
                  width: 22.sp,
                  height: 22.sp,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          stageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.sp,
                          vertical: 2.sp,
                        ),
                        decoration: BoxDecoration(
                          color: stage.isActive
                              ? AppColors.green
                              : AppColors.orange,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                        child: Text(
                          stage.isActive ? 'Active' : 'Inactive',
                          style: StyleText.fontSize10Weight400.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.listView,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: '${FormatHelper.localizedString(
                              englishName: 'Checklist',
                              arabicName: 'قائمة التحقق',
                            )}:',
                            value: '${stage.checklistItems.length}',
                          ),
                          fontSize: 12.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Flexible(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.crmPerson,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: '${S.current.crmBy} :',
                            value: authorName,
                          ),
                          fontSize: 12.sp,
                          iconSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.sp),
                  CardInfoRow(
                    info: CardInfo(
                      icon: CustomSvgImage(
                        assetPath: CrmAssets.crmCalendar,
                        width: 12.sp,
                        height: 12.sp,
                        color: AppColors.darkGrey,
                      ),
                      label: '${S.current.crmLastUpdate}:',
                      value: formattedDate,
                    ),
                    fontSize: 12.sp,
                    iconSize: 12.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
