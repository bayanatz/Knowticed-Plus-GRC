/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: filter_bar_item.dart
/// Description: Declares `FilterBarItem`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.
library;

import 'package:flutter/material.dart';
import 'package:grc_module/core/helper/arabic_number_format.dart';
import 'package:grc_module/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:grc_module/core/helper/data_grc_module/core/extensions/extensions.dart';

import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_theme.dart';

import 'package:grc_module/core/theme/haptic_controller.dart';

class FilterBarItem extends StatelessWidget {
  const FilterBarItem({
    required this.isSelected,
    required this.title,
    required this.numberOfItems,
    required this.onTap,
    this.color,
    super.key,
  });
  final bool isSelected;
  final String title;
  final int numberOfItems;
  final Function()? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    bool isTablet = !kpIsPhoneLayout(context);
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap == null
          ? null
          : () {
              HapticController.low(); // filter widget
              onTap!();
            },
      child: Row(
        spacing: 16.sp,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 45.sp : 35.sp,
            height: isTablet ? 45.sp : 35.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isSelected ? AppColors.primary : AppColors.card),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              ContextExtension(context).isArabic
                  ? ArabicDigits(numberOfItems.toString()).toArabicNumbers()
                  : numberOfItems.toString(),
              textAlign: TextAlign.center,
              style: StyleText.fontSize20Weight500.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? AppColors.textButton : AppColors.secondaryText,
              ),
            ),
          ),
          Text(
            title,
            style: (isSelected
                    ? StyleText.fontSize16Weight500
                    : StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.secondaryBlack,
                      ))
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
