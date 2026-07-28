/// Module: Core · Custom · Sort Button
/// Description: Reusable generic sort button with dropdown, extracted from
///              SortDropdownWidgetRole (account_status/search_and_filter).
///              When an item is selected the WHOLE container turns
///              AppColors.primary and the svg + text turn
///              AppColors.textButton. The selected menu item is highlighted
///              with a primary background as well.
/// Author: Knowticed Team
/// Date: 06/07/2026
/// Dependencies: AppDropdown, flutter_svg, flutter_screenutil, get,
///               AppColors, AppTextStyles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:demo_app/core/local_widgets/main_widget/app_dropdown.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class CustomSortButton<T> extends StatelessWidget {
  static const String _defaultSvg =
      'assets/icons_assets/main_icons_assets/sort_filter.svg';

  /// Currently selected item (null = nothing selected → neutral colors).
  final T? value;

  /// Items shown in the dropdown menu.
  final List<T> items;

  /// Builds the display label of each item.
  final String Function(T item) labelBuilder;

  final ValueChanged<T?> onChanged;

  /// Button label (translated with .tr). Hidden when [showTitle] is false
  /// (e.g. icon-only on mobile).
  final String title;
  final bool showTitle;

  final String svgPath;
  final double? width, height, menuWidth;
  final double yOffset;

  const CustomSortButton({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.title = 'Sort',
    this.showTitle = true,
    this.svgPath = _defaultSvg,
    this.width,
    this.height,
    this.menuWidth,
    this.yOffset = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = value != null;
    final Color contentColor =
        hasSelection ? AppColors.textButton : AppColors.text;

    return SizedBox(
      width: width ?? 100.sp,
      height: height ?? 40.h,
      child: AppDropdown(
        height: height ?? 40.h,
        yOffset: yOffset.sp,
        borderRadius: 8.r,
        isAllCornersRounded: true,
        value: value,
        width: double.infinity,
        menuWidth: menuWidth ?? 150.sp,
        // ✅ WHOLE button container takes AppColors.primary when selected.
        fillColor: hasSelection ? AppColors.primary : AppColors.field,
        // ✅ Menu keeps its neutral color — never changes with selection.
        menuColor: AppColors.field,
        menuItemHeight: 35.h,
        customButton: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          width: width ?? 100.sp,
          decoration: BoxDecoration(
            color: hasSelection ? AppColors.primary : AppColors.field,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                fit: BoxFit.scaleDown,
                color: contentColor,
              ),
              if (showTitle) SizedBox(width: 8.sp),
              if (showTitle)
                Text(
                  title.tr,
                  style: AppTextStyles.font14BlackRegularCairo.copyWith(
                    color: contentColor,
                  ),
                ),
            ],
          ),
        ),
        textButton: title.tr,
        isSelectedItemHasBackGround: true,
        items: items.map((T item) {
          final bool isSelected = value == item;
          return DropdownMenuItem<T>(
            value: item,
            child: Container(
              alignment: AlignmentDirectional.centerStart, // ✅ RTL support
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              width: double.infinity,
              height: double.infinity,
              color: isSelected ? AppColors.primary : Colors.transparent,
              child: Text(
                labelBuilder(item),
                style: AppTextStyles.font14BlackCairo.copyWith(
                  color:
                      isSelected ? AppColors.textButton : AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        onChanged: (dynamic v) {
          // ✅ Tapping the already-selected item deselects it (toggle).
          if (v is T && v == value) {
            onChanged(null);
          } else if (v is T?) {
            onChanged(v);
          }
        },
      ),
    );
  }
}
