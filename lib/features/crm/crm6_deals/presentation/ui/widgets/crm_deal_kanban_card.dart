// ****************** FILE INFO ******************
// File Name: crm_deal_kanban_card.dart
// Purpose: Individual deal card in Pipeline Kanban stage column with progress bar matching Figma
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/helpers/crm_assets.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmDealKanbanCard extends StatelessWidget {
  final CrmClientDealModel deal;
  final VoidCallback? onTap;

  const CrmDealKanbanCard({
    super.key,
    required this.deal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: withHaptic(onTap, HapticLevel.low),
        borderRadius: BorderRadius.circular(8.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Category & Trend Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    deal.category,
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.sp),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: CrmAssets.crmChartLineSolid,
                      width: 13.sp,
                      height: 13.sp,
                      color: deal.isPositiveTrend
                          ? AppColors.green
                          : AppColors.darkGrey,
                    ),
                    SizedBox(width: 4.sp),
                    Text(
                      deal.likelihood,
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)
                          .copyWith(
                            color: deal.isPositiveTrend
                                ? AppColors.green
                                : AppColors.darkGrey,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 6.sp),

            // 2. Deal Title / Summary
            Text(
              deal.dealNameEn,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
                fontSize: 11.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 10.sp),

            // 3. Progress & Amount Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Progress Label + Percentage + Visual Progress Bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            FormatHelper.localizedString(
                              englishName: 'Progress',
                              arabicName: 'التقدم',
                            ),
                            style: StyleText.fontSize10Weight400
                                .copyWith(color: AppColors.fullBlack)
                                .copyWith(
                                  color: AppColors.darkGrey,
                                  fontSize: 11.sp,
                                ),
                          ),
                          Text(
                            '${deal.progress.toInt()}%',
                            style: StyleText.fontSize10Weight400
                                .copyWith(color: AppColors.fullBlack)
                                .copyWith(
                                  color: AppColors.darkGrey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.sp),
                      // Horizontal Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3.r),
                        child: LayoutBuilder(
                          builder:
                              (BuildContext ctx, BoxConstraints constraints) {
                            final double progressFraction =
                                (deal.progress / 100.0).clamp(0.0, 1.0);
                            return Stack(
                              children: <Widget>[
                                Container(
                                  height: 5.sp,
                                  width: constraints.maxWidth,
                                  color: const Color(0xFFEFF2F6),
                                ),
                                Container(
                                  height: 5.sp,
                                  width:
                                      constraints.maxWidth * progressFraction,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAB308),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.sp),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: AppAssets.crmPrice,
                      width: 13.sp,
                      height: 13.sp,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(width: 4.sp),
                    Text(
                      '\$${deal.amount.toInt()}',
                      style: StyleText.fontSize12Weight400.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.sp),

            // Divider line
            Container(
              height: 1.sp,
              color: AppColors.background,
              margin: EdgeInsets.only(bottom: 8.sp),
            ),

            // 4. Assignee & Date Row
            Row(
              children: <Widget>[
                // Assignee (Avatar + Name + Department)
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 24.sp,
                        height: 24.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: CustomSvgImage(
                          assetPath: AppAssets.crmPerson,
                          width: 12.sp,
                          height: 12.sp,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(width: 6.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              deal.assignedEmployee,
                              style: StyleText.fontSize10Weight400
                                  .copyWith(color: AppColors.fullBlack)
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (deal.department.isNotEmpty)
                              Text(
                                deal.department,
                                style: StyleText.fontSize10Weight400
                                    .copyWith(color: AppColors.fullBlack)
                                    .copyWith(
                                      color: AppColors.darkGrey,
                                      fontSize: 8.sp,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 6.sp),

                // Date Range
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: CrmAssets.crmCalendar,
                      width: 12.sp,
                      height: 12.sp,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(width: 3.sp),
                    Text(
                      deal.startDate,
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)
                          .copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 9.sp,
                          ),
                    ),
                    Text(
                      ' → ',
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)
                          .copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 9.sp,
                          ),
                    ),
                    CustomSvgImage(
                      assetPath: CrmAssets.crmCalendarCheck,
                      width: 12.sp,
                      height: 12.sp,
                      color: AppColors.darkGrey,
                    ),
                    SizedBox(width: 3.sp),
                    Text(
                      deal.closeDate,
                      style: StyleText.fontSize10Weight400
                          .copyWith(color: AppColors.fullBlack)
                          .copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 9.sp,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
