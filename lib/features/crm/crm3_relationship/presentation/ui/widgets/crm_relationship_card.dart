// ****************** FILE INFO ******************
// File Name: crm_relationship_card.dart
// Purpose: Display card for CRM Relationship Categories matching Figma mobile design
// Author: Mohand Adel
// Created At: 12/08/2026

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
import 'package:knowticed_plus/features/crm/crm3_relationship/data/models/crm_relationship_category_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmRelationshipCard extends StatelessWidget {
  final CrmRelationshipCategoryModel category;
  final VoidCallback? onTap;

  const CrmRelationshipCard({
    required this.category,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isMobile = kpIsPhoneLayout(context);
    final String title = isArabic ? category.nameAr : category.nameEn;
    final bool isActive = category.status.toLowerCase() == 'active';
    final String lastUpdate = category.audit != null
        ? DateFormat('d MMM yyyy').format(category.audit!.updatedAt)
        : '7 Jun 2026';
    final String creator = category.audit != null
        ? CrmCardHelper.resolveCreatorName(
            category.audit!.updatedBy,
            isArabic: isArabic,
          )
        : (isArabic ? 'آية علي' : 'Aya Ali');

    final String typeValue = category.types.isNotEmpty
        ? category.types
            .map((t) => isArabic
                ? (t.nameAr.isNotEmpty ? t.nameAr : t.nameEn)
                : (t.nameEn.isNotEmpty ? t.nameEn : t.nameAr))
            .join(', ')
        : (isArabic ? 'مكالمة' : 'Call');

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
            // Left: Icon rounded box / background image
            Container(
              width: isMobile ? 48.sp : 50.sp,
              height: isMobile ? 48.sp : 50.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.r),
                image: category.iconUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(category.iconUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: category.iconUrl.isEmpty
                  ? CustomSvgImage(
                      assetPath: AppAssets.crmRelationship,
                      width: isMobile ? 24.sp : 24.sp,
                      height: isMobile ? 24.sp : 24.sp,
                      color: AppColors.secondaryBlack,
                    )
                  : null,
            ),
            SizedBox(width: isMobile ? 10.sp : 12.sp),

            // Middle: Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Row 1: Title and Status Chip
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title.isNotEmpty
                              ? title
                              : (isArabic ? 'منظمة' : 'Organization'),
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
                        isActive: isActive,
                        isArabic: isArabic,
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 4.sp : 8.sp),

                  if (isMobile) ...<Widget>[
                    // Mobile Row 2: Type (left) and By (right)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: CardInfoRow(
                            fontSize: 10.sp,
                            iconSize: 11.sp,
                            info: CardInfo(
                              label: '${S.current.crmType}:',
                              value: typeValue,
                              icon: CustomSvgImage(
                                assetPath: AppAssets.crmSections,
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
                              label: isArabic ? 'بواسطة:' : 'By:',
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
                        label: isArabic ? 'آخر تحديث:' : 'Last Update:',
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
                      countLabel: S.current.crmType,
                      countValue: typeValue,
                      countIcon: AppAssets.crmSections,
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
