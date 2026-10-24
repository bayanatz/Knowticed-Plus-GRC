// ****************** FILE INFO ******************
// File Name: crm_billing_contract_card.dart
// Purpose: Card widget displaying Billing & Contract template item in the listing
// Author: Mohand Adel
// Created At: 06/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm13_billing_and_contracts/data/models/crm_billing_contract_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmBillingContractCard extends StatelessWidget {
  final CrmBillingContractModel item;
  final VoidCallback? onTap;

  const CrmBillingContractCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String title = FormatHelper.localizedString(
      englishName: item.nameEn,
      arabicName: item.nameAr,
    );

    final String lastUpdated = FormatHelper.formatDate(
      item.updatedAt ?? item.createdAt,
      Localizations.localeOf(context).toString(),
    );
    final String updatedBy = item.updatedBy.trim().isEmpty
        ? 'System'
        : FormatHelper.formatEmailToName(item.updatedBy);

    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48.sp,
              height: 48.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: CrmAssets.crmBillingContracts,
                width: 24.sp,
                height: 24.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 14.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.sp),
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath: AppAssets.calendar,
                        width: 14.sp,
                        height: 14.sp,
                        color: AppColors.secondaryBlack,
                      ),
                      SizedBox(width: 6.sp),
                      Text(
                        '${S.current.crmLastUpdate}: $lastUpdated',
                        style: StyleText.fontSize12Weight400.copyWith(
                          color: AppColors.secondaryBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      CustomSvgImage(
                        assetPath: AppAssets.crmPerson,
                        width: 14.sp,
                        height: 14.sp,
                        color: AppColors.secondaryBlack,
                      ),
                      SizedBox(width: 6.sp),
                      Flexible(
                        child: Text(
                          '${S.current.crmBy}$updatedBy',
                          style: StyleText.fontSize12Weight400.copyWith(
                            color: AppColors.secondaryBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
