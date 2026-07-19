/// Module: GRC Policy Management
/// Description: Read-only card widget for a single Control, shown in the
///              Controls list on the Policy Details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-15
/// Dependencies: Flutter SDK, AppColors, AppTheme, ControlEntity, ControlStatus
/// Revision History: 2026-07-15 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: control_card_widget.dart
/// Purpose: Contains ControlCardWidget, a read-only list-item card that
///          displays a single ControlEntity's status, score, weight,
///          frequency dates, and last edit. Tapping opens it for editing.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 15/7/2026

import 'package:demo_app/core/custom/16-custom_card_styles.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_entity.dart';
import 'package:demo_app/features/grc/control/domain/entities/control_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

/// class name: [ControlCardWidget]
///
/// purpose: read-only list-item card for a single [ControlEntity]. Used by
///          the Controls section of the Policy Details page.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 15/7/2026
class ControlCardWidget extends StatelessWidget {
  final ControlEntity control;
  final VoidCallback onTap;

  const ControlCardWidget({
    super.key,
    required this.control,
    required this.onTap,
  });

  Color _statusColor(ControlStatus status) {
    switch (status) {
      case ControlStatus.active:
        return AppColors.green;
      case ControlStatus.inactive:
        return AppColors.orange;
      case ControlStatus.scheduled:
        return AppColors.primary;
      case ControlStatus.expired:
        return AppColors.red;

      case ControlStatus.unassigned:
        return AppColors.colorGrey;
      case ControlStatus.draft:
        return AppColors.colorGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final dateFormat = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: CardStyles.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    text: '${'Control Status'.tr}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                    children: [
                      TextSpan(
                        text: control.status.value.tr,
                        style: StyleText.fontSize12Weight500
                            .copyWith(color: _statusColor(control.status)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '${'Score'.tr}: ${control.score}',
                    style: StyleText.fontSize12Weight500
                        .copyWith(color: AppColors.text),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              isArabic ? control.controlsNameAr : control.controlsNameEn,
              style:
                  StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'Start Date'.tr}: ${dateFormat.format(control.startDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
                Text(
                  '${'End Date'.tr}: ${dateFormat.format(control.endDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'Control Weight'.tr}: ${control.controlsWeight.toStringAsFixed(0)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
                Text(
                  '${'Last Edit'.tr}: ${dateFormat.format(control.lastModifiedDate)}',
                  style: StyleText.fontSize12Weight400
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
