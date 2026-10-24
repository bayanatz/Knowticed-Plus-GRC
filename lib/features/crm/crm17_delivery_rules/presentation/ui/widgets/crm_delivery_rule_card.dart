// Module: crm / crm17_delivery_rules
// ****************** FILE INFO ******************
// File Name: crm_delivery_rule_card.dart
// Purpose: Grid card for a delivery fee rule
// Author: Mohand Adel
// Created At: 08/10/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/cards/custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm17_delivery_rules/domain/entities/crm_delivery_rule.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmDeliveryRuleCard extends StatelessWidget {
  final CrmDeliveryRule rule;
  final VoidCallback onTap;

  const CrmDeliveryRuleCard({
    super.key,
    required this.rule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String lastUpdated =
        DateFormat('d MMM yyyy', Get.locale.toString()).format(rule.updatedAt);
    final String ruleName = rule.nameEn.isNotEmpty ? rule.nameEn : 'Rule Name';

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
                  assetPath: CrmAssets.crmDeliveryRules,
                  width: 24.sp,
                  height: 24.sp,
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
                          ruleName,
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
                          color: rule.isActive
                              ? AppColors.green
                              : AppColors.orange,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                        child: Text(
                          rule.isActive ? 'Active' : 'Inactive',
                          style: StyleText.fontSize10Weight400.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: CardInfoRow(
                          info: CardInfo(
                            icon: CustomSvgImage(
                              assetPath: AppAssets.grid,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: 'Based on:',
                            value: rule.basedOn,
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
                              assetPath: CrmAssets.crmCalendar,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            label: '${S.current.crmLastUpdate}:',
                            value: lastUpdated,
                          ),
                          fontSize: 12.sp,
                          iconSize: 12.sp,
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
