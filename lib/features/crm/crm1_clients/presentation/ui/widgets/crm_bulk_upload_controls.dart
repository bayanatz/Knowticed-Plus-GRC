// ****************** FILE INFO ******************
// File Name: crm_bulk_upload_controls.dart
// Purpose: Small controls used by the CRM bulk-upload review page
// Author: Mohand Adel
// Created At: 11/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/dialogs/default_dialog.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

class CrmBulkUploadFilterButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CrmBulkUploadFilterButton({
    required this.title,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return customButtonWithSvg(
      title: title,
      function: onTap,
      textStyle: StyleText.fontSize12Weight400
          .copyWith(color: AppTheme.readableOn(AppColors.blackButton)),
      color: AppColors.blackButton,
      image: '',
      widthImage: 12.sp,
      heightImage: 12.sp,
      colorBorder: AppColors.transparent,
      svgColor: AppTheme.readableOn(AppColors.blackButton),
    );
  }
}

class CrmBulkUploadErrorCountButton extends StatelessWidget {
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const CrmBulkUploadErrorCountButton({
    required this.count,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: hapticDown(onTap, HapticLevel.low),
      onTap: onTap,
      child: Container(
        height: 38.sp,
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSvgImage(
              assetPath: AppAssets.crmArrowLeft,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.black,
            ),
            SizedBox(width: 6.sp),
            Text(
              S.current.crmErrorCount(count),
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.red,
              ),
            ),
            SizedBox(width: 6.sp),
            CustomSvgImage(
              assetPath: AppAssets.crmArrowRight,
              width: 20.sp,
              height: 20.sp,
              color: AppColors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class CrmBulkUploadWarningDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const CrmBulkUploadWarningDialog({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      autoClose: false,
      width: 560.sp,
      customIconWidget: Container(
        width: 84.sp,
        height: 84.sp,
        margin: EdgeInsets.only(top: 24.sp, bottom: 16.sp),
        decoration: BoxDecoration(
          color: AppColors.red,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '!',
            style: StyleText.fontSize24Weight600
                .copyWith(color: AppColors.white, fontWeight: FontWeight.bold)
                .copyWith(
                  fontSize: 48.sp,
                ),
          ),
        ),
      ),
      title: title,
      subTitle: subtitle,
    );
  }
}
