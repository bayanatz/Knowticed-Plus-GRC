/// Module: services_management_module
/// Description: Toolbar row (error navigation + "remove selection"/"add
///              row" actions) for the bulk-upload request-preview screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: AppColors, StyleText, customButtonWithSvg
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from upload_details.dart
///     (fix item 5 — page LOC reduction).
library;

import 'package:knowticed_plus/core/custom/buttons/bulk_upload_toolbar_button.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class UploadDetailsToolbar extends StatelessWidget {
  final bool isArabic;
  final bool lightMode;
  final int totalErrorCount;
  final int currentErrorIndex;
  final VoidCallback onPrevError;
  final VoidCallback onNextError;
  final VoidCallback onRemoveSelection;
  final VoidCallback onAddRow;

  const UploadDetailsToolbar({
    super.key,
    required this.isArabic,
    required this.lightMode,
    required this.totalErrorCount,
    required this.currentErrorIndex,
    required this.onPrevError,
    required this.onNextError,
    required this.onRemoveSelection,
    required this.onAddRow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 30.sp,
          width: 138.sp,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTapDown: hapticDown(onPrevError, HapticLevel.low),
                onTap: onPrevError,
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: CustomSvgImage.natural(
                    assetPath: isArabic
                        ? 'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg'
                        : 'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg',
                    width: 15.sp,
                    height: 15.sp,
                    color: totalErrorCount == 0
                        ? AppColors.grey
                        : (lightMode
                            ? AppColors.blackButton
                            : AppColors.whiteShadow),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 9.sp),
              Text(
                '${S.of(context).error}: ',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
              Text(
                totalErrorCount > 0
                    ? '${currentErrorIndex + 1}/$totalErrorCount'
                    : '$totalErrorCount',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 9.sp),
              GestureDetector(
                onTapDown: hapticDown(onNextError, HapticLevel.low),
                onTap: onNextError,
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: CustomSvgImage.natural(
                    assetPath: isArabic
                        ? 'assets/icons_assets/main_icons_assets/ic_nav_chevron_left.svg'
                        : 'assets/icons_assets/main_icons_assets/ic_nav_chevron_right.svg',
                    width: 15.sp,
                    height: 15.sp,
                    color: totalErrorCount == 0
                        ? AppColors.grey
                        : (lightMode
                            ? AppColors.blackButton
                            : AppColors.whiteShadow),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        bulkUploadToolbarButton(
          tool: BulkUploadTool.removeSelection,
          title: S.of(context).removeSelection,
          onTap: onRemoveSelection,
        ),
        SizedBox(width: 15.sp),
        bulkUploadToolbarButton(
          tool: BulkUploadTool.addRow,
          title: S.of(context).row,
          onTap: onAddRow,
        ),
      ],
    );
  }
}
