// ****************** FILE INFO ******************
// File Name: crm_merge_level_card.dart
// Purpose: Display card for CRM Merge Level with merge icon, range info, and status
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_card_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmMergeLevelCard extends StatelessWidget {
  final CrmMergeLevelModel level;
  final VoidCallback? onTap;

  const CrmMergeLevelCard({
    super.key,
    required this.level,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = kpIsPhoneLayout(context);
    final String title = isArabic ? level.nameAr : level.nameEn;
    final String lastUpdate = level.audit != null
        ? DateFormat('d MMM yyyy').format(level.audit!.updatedAt)
        : '7 Jun 2026';
    final String creator = level.audit != null
        ? CrmCardHelper.resolveCreatorName(
            level.audit!.updatedBy,
            isArabic: isArabic,
          )
        : (isArabic ? 'آية علي' : 'Aya Ali');

    final String rangeValue =
        '${level.rangeFrom.toStringAsFixed(0)}%-${level.rangeTo.toStringAsFixed(0)}%';

    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Left: Icon rounded box
            Container(
              width: isMobile ? 48.sp : 50.sp,
              height: isMobile ? 48.sp : 50.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: CrmAssets.crmMergeIcon,
                width: isMobile ? 24.sp : 24.sp,
                height: isMobile ? 24.sp : 24.sp,
                color: AppColors.secondaryBlack,
              ),
            ),
            SizedBox(width: isMobile ? 10.sp : 12.sp),

            // Middle: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Row 1: Title and Status Chip
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title.isNotEmpty
                              ? title
                              : S.current.crmMergePossibleLevel,
                          style: (isMobile
                                  ? StyleText.fontSize13Weight600
                                  : StyleText.fontSize14Weight600)
                              .copyWith(
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      CrmCardHelper.buildInlineStatusChip(
                        isActive: level.isActive,
                        isArabic: isArabic,
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4.sp : 8.sp),

                  if (isMobile) ...<Widget>[
                    // Mobile Row 2: Range (left) and By (right)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CardInfoRow(
                            fontSize: 10.sp,
                            iconSize: 11.sp,
                            info: CardInfo(
                              label: '${S.current.crmRange}:',
                              value: rangeValue,
                              icon: CustomSvgImage(
                                assetPath: AppAssets.filter,
                                width: 11.sp,
                                height: 11.sp,
                                color: AppColors.black,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6.sp),
                        Expanded(
                          child: CardInfoRow(
                            fontSize: 10.sp,
                            iconSize: 11.sp,
                            info: CardInfo(
                              label: S.current.crmBy,
                              value: creator,
                              icon: CustomSvgImage(
                                assetPath: AppAssets.crmGroup,
                                width: 11.sp,
                                height: 11.sp,
                                color: AppColors.black,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.sp),

                    // Mobile Row 3: Last Update
                    CardInfoRow(
                      fontSize: 10.sp,
                      iconSize: 11.sp,
                      info: CardInfo(
                        label: '${S.current.crmLastUpdate}:',
                        value: lastUpdate,
                        icon: CustomSvgImage(
                          assetPath: AppAssets.timeSelectorIcon,
                          width: 11.sp,
                          height: 11.sp,
                          color: AppColors.black,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  ] else ...<Widget>[
                    // Tablet/Desktop: Single 3-column metadata row
                    CrmCardHelper.buildCardMetaRow(
                      context: context,
                      countLabel: '${S.current.crmRange}:',
                      countValue: rangeValue,
                      countIcon: AppAssets.filter,
                      creator: creator,
                      lastUpdate: lastUpdate,
                      isArabic: isArabic,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
