/// Module: core / custom / buttons
///
///*************************** FILE INFO ****************************///
/// File Name: bulk_upload_toolbar_button.dart
/// Description: The small black toolbar button of every bulk-upload preview
///              (Remove Selection · Duplication · + Row).
/// Author: Moataz Handousa
/// Created at: 18/10/2026
///
/// Figma "Bulkupload" section (QVFDXSnFPExQVOIycX9ECb 4867:82571): the three
/// preview tools are one style — black fill, white label and icon — in both
/// themes. Services had three different ones (card-coloured, outlined, white),
/// so every bulk-upload screen uses this one now.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// The three bulk-upload preview tools, with their Figma icons.
enum BulkUploadTool {
  removeSelection(
      'assets/icons_assets/main_icons_assets/ic_action_minus_circle.svg'),
  duplicate('assets/icons_assets/main_icons_assets/ic_action_copy.svg'),
  addRow('assets/icons_assets/main_icons_assets/ic_action_plus.svg');

  const BulkUploadTool(this.iconPath);
  final String iconPath;
}

Widget bulkUploadToolbarButton({
  required BulkUploadTool tool,
  required String title,
  required VoidCallback onTap,
}) {
  return customButtonWithSvg(
    title: title,
    function: onTap,
    textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.white),
    // True black, not the `black` token: that token is #2D2D2D, the same as
    // the dark-mode page background, so the buttons vanished in dark mode
    // (18/10/2026). Pure black reads on both the light and the dark page.
    color: const Color(0xFF000000),
    svgColor: AppColors.white,
    image: tool.iconPath,
    widthImage: 16.sp,
    heightImage: 16.sp,
    colorBorder: AppColors.transparent,
  );
}
