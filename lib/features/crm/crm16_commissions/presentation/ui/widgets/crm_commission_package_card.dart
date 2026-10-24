// Module: crm / crm16_commissions
// ****************** FILE INFO ******************
// File Name: crm_commission_package_card.dart
// Purpose: Extracted grid card for a commission package
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm16_commissions/domain/entities/crm_commission_package.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmCommissionPackageCard extends StatelessWidget {
  final CrmCommissionPackage package;
  final VoidCallback onTap;

  const CrmCommissionPackageCard({
    super.key,
    required this.package,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String applyOn =
        package.domains.isEmpty ? '-' : package.domains.first.applyOn;
    final String frequency = package.domains.isEmpty
        ? package.tiersFrequency
        : package.domains.first.frequency;
    final String countries =
        package.countries.isEmpty ? '-' : package.countries.join(', ');

    return InkWell(
      onTap: withHaptic(onTap, HapticLevel.low),
      borderRadius: BorderRadius.circular(10.sp),
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.sp),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 80.sp,
              height: 80.sp,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Center(
                child: CustomSvgImage(
                  assetPath: CrmAssets.crmCommission,
                  width: 48.sp,
                  height: 48.sp,
                  color: AppColors.black,
                ),
              ),
            ),
            SizedBox(width: 16.sp),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          package.nameEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize16Weight600
                              .copyWith(color: AppColors.text),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.sp,
                          vertical: 4.sp,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkGrey,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                        child: Text(
                          'Not Assigned',
                          style: StyleText.fontSize10Weight400
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp),
                  _metadataRow(
                    left: CardInfo(
                      icon: _metadataIcon(CrmAssets.crmCommissionType),
                      label: 'Compensation Type:',
                      value: package.compensationCategory,
                    ),
                    right: CardInfo(
                      icon: _metadataIcon(AppAssets.crmCategoryIcon),
                      label: 'Apply on:',
                      value: applyOn,
                    ),
                  ),
                  SizedBox(height: 8.sp),
                  _metadataRow(
                    left: CardInfo(
                      icon: _metadataIcon(CrmAssets.crmFrequency),
                      label: 'Frequency:',
                      value: frequency,
                    ),
                    right: CardInfo(
                      icon: _metadataIcon(CrmAssets.crmCountry),
                      label: 'Countries:',
                      value: countries,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metadataRow({required CardInfo left, required CardInfo right}) => Row(
        children: <Widget>[
          Expanded(
            child: CardInfoRow(
              info: left,
              fontSize: 14.sp,
              iconSize: 14.sp,
            ),
          ),
          SizedBox(width: 16.sp),
          Expanded(
            child: CardInfoRow(
              info: right,
              fontSize: 14.sp,
              iconSize: 14.sp,
            ),
          ),
        ],
      );

  Widget _metadataIcon(String assetPath) => CustomSvgImage(
        assetPath: assetPath,
        width: 14.sp,
        height: 14.sp,
        color: AppColors.greyIcon,
      );
}
