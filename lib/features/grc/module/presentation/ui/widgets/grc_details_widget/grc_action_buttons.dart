/// Module: GRC Module Management
/// Description: Provides the Edit and Delete action buttons shown at the top
///              of the GRC Module details page (and, since 2026-07-15, the
///              Policy Details page) in view mode.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-29
/// Dependencies: AppColors, AppTheme, customButtonWithSvg, showConfirmDialog
/// Revision History: 2026-06-29 - Initial creation
///                    2026-06-30 - Added onDeleteTap callback (Mohamed Magdy Abdelkhalek)
///                    2026-07-15 - Made the delete confirm dialog's title/
///                                 subtitle/icon overridable so other GRC
///                                 pages (e.g. Policy Details) can reuse this
///                                 widget with their own wording
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_action_buttons.dart
/// Purpose: Contains GrcActionButtons, a row of Edit and Delete buttons
///          reused across GRC detail pages.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 29/6/2026

import 'package:grc_module/core/custom/11_custom_confirm_diaolog.dart';
import 'package:grc_module/core/custom/6_custom_button_with_svg.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/features/grc/shared/helpers/grc_l10n.dart';

class GrcActionButtons extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;
  final String deleteDialogTitle;
  final String deleteDialogSubtitle;
  final String deleteDialogIconAsset;

  const GrcActionButtons({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
    this.deleteDialogTitle = "Deleting GRC Module",
    this.deleteDialogSubtitle =
        "Are You Sure You Want To Delete This GRC Module ?",
    this.deleteDialogIconAsset =
        "assets/icons_assets/data_grc_assets/delete-module.svg",
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        customButtonWithSvg(
          colorBorder: AppColors.primary,
          space: 10.w,
          radius: 8.r,
          widthImage: 16.w,
          heightImage: 16.h,
          image: "assets/icons_assets/data_grc_assets/edit_pen.svg",
          title: isTablet ? S.of(context).Edit : "",
          function: onEditTap,
          width: isTablet ? 135.w : 40.w,
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
        ),
        SizedBox(width: 10.w),
        customButtonWithSvg(
          colorBorder: AppColors.red,
          space: 10.w,
          radius: 8.r,
          widthImage: 16.w,
          heightImage: 16.h,
          image: "assets/icons_assets/organization_chart_assets/trashd.svg",
          title: isTablet ? S.of(context).Delete : "",
          function: () {
            showConfirmDialog(
              context: context,
              title: grcTr(context, deleteDialogTitle),
              cancelLabel: S.of(context).no,
              confirmLabel: S.of(context).yes,
              iconWidget: SvgPicture.asset(deleteDialogIconAsset),
              subtitle: grcTr(context, deleteDialogSubtitle),
              onConfirm: onDeleteTap,
            );
          },
          width: isTablet ? 135.w : 40.w,
          color: AppColors.red,
          textStyle:
              StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}
