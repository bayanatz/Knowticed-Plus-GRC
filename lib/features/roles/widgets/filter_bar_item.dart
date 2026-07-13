import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class FilterBarItem extends StatelessWidget {
  FilterBarItem(
      {required this.isSelected,
      required this.title,
      required this.numberOfItems,
      required this.onTap,
      this.color,
      super.key});
  bool isSelected;
  String title;
  int numberOfItems;
  Function()? onTap;
  Color? color;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        spacing: 16.sp,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isTablet ? 45.sp : 35.sp,
            height: isTablet ? 45.sp : 35.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isSelected ? AppColors.primary : AppColors.field),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              context.isArabic
                  ? numberOfItems.toString().toArabicNumbers()
                  : numberOfItems.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.font20BlackCairoMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText),
            ),
          ),
          Text(title,
              style: (isSelected
                      ? AppTextStyles.font16BlackMediumCairo
                      : AppTextStyles.font16SecondaryBlackCairoMedium)
                  .copyWith(color: color))
        ],
      ),
    );
  }
}
