/// Objectives: single "requirement met / not met" row used by the reset
/// password checklist.
///
/// Visual port of Knowticed's CheckRow: a tinted checkbox glyph followed by the
/// requirement text, 0.01.h of top padding per row.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/core/theme/app_theme.dart';

class CheckRow extends StatelessWidget {
  const CheckRow({super.key, required this.isChecked, required this.text});

  final bool isChecked;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: isChecked
                ? 'assets/icons_assets/main_icons_assets/checkbox_checked_yellow.svg'
                : 'assets/icons_assets/main_icons_assets/checkbox_empty_outline.svg',
            height: 0.025.h,
            color: AppColors.lightPrimary,
          ),
          SizedBox(width: 0.01.w),
          Expanded(
            child: Text(
              text.tr,
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: FontConstants.fontSize018.h,
                color: AppColors.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
