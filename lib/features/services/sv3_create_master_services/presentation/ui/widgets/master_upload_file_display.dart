/// Module: services_management_module
/// Description: "Uploaded file" card (file name/size + edit/delete actions +
///              stat rows) shown once a step's Excel file has been parsed on
///              the master upload screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: CustomSvgImage, CustomEditIcon, CustomDeleteIcon, AppColors,
///              StyleText
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from master_upload.dart
///     (fix item 5 — page LOC reduction).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/buttons/custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MasterUploadFileDisplay extends StatelessWidget {
  final String fileName;
  final String totalServicesLabel;
  final String totalServicesValue;
  final String totalDepartmentsLabel;
  final String totalDepartmentsValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MasterUploadFileDisplay({
    super.key,
    required this.fileName,
    required this.totalServicesLabel,
    required this.totalServicesValue,
    required this.totalDepartmentsLabel,
    required this.totalDepartmentsValue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 18/10/2026 (Moataz): no border around the file, and the totals sit on
    // the same line as the file; the fake "62 KB" size is gone.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Wraps on narrow widths (phone) instead of overflowing.
        Expanded(
          child: Wrap(
            spacing: 32.sp,
            runSpacing: 12.sp,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50.sp,
                    height: 50.sp,
                    decoration: BoxDecoration(
                      color: AppColors.darkBackGround.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: CustomSvgImage(
                        assetPath:
                            'assets/icons_assets/main_icons_assets/ic_file_excel.svg',
                        width: 43.sp,
                        height: 43.sp,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.sp),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 280.sp),
                    child: Text(
                      fileName,
                      maxLines: 2,
                      style: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.text,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              _StatItem(
                icon:
                    'assets/icons_assets/main_icons_assets/ic_comms_customer_service.svg',
                label: totalServicesLabel,
                value: totalServicesValue,
              ),
              _StatItem(
                icon:
                    'assets/icons_assets/main_icons_assets/ic_building_office.svg',
                label: totalDepartmentsLabel,
                value: totalDepartmentsValue,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.sp),
        CustomEditIcon(
          color: AppColors.primary,
          borderColor: Colors.transparent,
          svgColor: AppColors.textButton,
          title: S.of(context).edit,
          textStyle: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.textButton,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          onTap: onEdit,
        ),
        SizedBox(width: 10.sp),
        CustomDeleteIcon(
          color: AppColors.red,
          borderColor: Colors.transparent,
          svgColor: AppColors.white,
          title: S.of(context).delete,
          textStyle: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          onTap: onDelete,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomSvgImage.natural(
          assetPath: icon,
          width: 22.sp,
          height: 22.sp,
          color: AppColors.primary,
        ),
        SizedBox(width: 10.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.text,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
