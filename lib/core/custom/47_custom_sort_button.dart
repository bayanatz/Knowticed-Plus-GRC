/// Module: Core · Custom · Sort Button
/// Description: Reusable generic sort button with dropdown, extracted from
///              SortDropdownWidgetRole (account_status/search_and_filter).
///              When an item is selected the WHOLE container turns
///              AppColors.primary and the svg + text turn
///              AppColors.textButton. The selected menu item is highlighted
///              with a primary background as well.
/// Author: Knowticed Team
/// Date: 06/07/2026
/// Dependencies: CustomDropdown (1-custom_dropdwon.dart), flutter_screenutil,
///               AppColors, AppTextStyles, CustomSvgImage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/custom/1-custom_dropdwon.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/theme/app_text_styles.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
class CustomSortButton<T> extends StatelessWidget {
  static const String _defaultSvg =
      'assets/icons_assets/main_icons_assets/sort_lines.svg';

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
  final double? width, height;

  /// Kept for source compatibility. [CustomDropdown] sizes its overlay to the
  /// trigger, so set [width] instead — this value is ignored.
  final double? menuWidth;

  /// Gap between the trigger and the overlay.
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

    // When the title is hidden the trigger is icon-only, so the selected
    // label CustomDropdown renders is collapsed to zero size.
    final TextStyle triggerTextStyle = showTitle
        ? AppTextStyles.font14BlackRegularCairo.copyWith(color: contentColor)
        : const TextStyle(fontSize: 0, height: 0, color: Colors.transparent);

    return SizedBox(
      width: width ?? 100.sp,
      height: height ?? 40.h,
      child: CustomDropdown<T>(
        value: value,
        // ✅ WHOLE button container takes AppColors.primary when selected.
        fillColor: hasSelection ? AppColors.primary : AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        triggerPadding: EdgeInsets.symmetric(horizontal: 8.w),
        overlayOffset: yOffset.sp,
        itemHeight: 35.h,
        hint: showTitle ? title : '',
        hintStyle: triggerTextStyle,
        valueStyle: triggerTextStyle,
        itemStyle: AppTextStyles.font14BlackCairo,
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(end: showTitle ? 8.sp : 0),
          child: CustomSvgImage.natural(
            assetPath: svgPath,
            fit: BoxFit.scaleDown,
            color: contentColor,
          ),
        ),
        // The sort trigger has no chevron — the svg is the whole affordance.
        suffixIcon: const SizedBox.shrink(),
        items: items
            .map((T item) => DropdownItem<T>(
                  value: item,
                  label: labelBuilder(item),
                ))
            .toList(),
        onChanged: (T v) {
          // ✅ Tapping the already-selected item deselects it (toggle).
          onChanged(v == value ? null : v);
        },
      ),
    );
  }
}
