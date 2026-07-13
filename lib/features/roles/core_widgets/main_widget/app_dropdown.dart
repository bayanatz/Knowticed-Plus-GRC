// Last update: 2/10/2024

import 'package:demo_app/core/constants/app_assets.dart';
import 'package:demo_app/core/constants/space_helper.dart';
import 'package:demo_app/core/theme/app_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/extension/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// REMOVED_MODULE: import 'package:demo_app/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:demo_app/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/theme/app_colors.dart';

class AppDropdown extends StatelessWidget {
  AppDropdown(
      {super.key,
      this.customButton,
      required this.onChanged,
      required this.items,
      required this.textButton,
      this.end,
      this.hintText,
      this.value,
      this.customSpacing,
      this.menuWidth,
      this.width,
      this.height,
      this.textColor,
      this.splashColorOn = true,
      this.showDropdownIcon = true,
      this.validator,
      this.fillColor,
      this.svgIconPath,
      this.textStyle,
      this.menuItemHeight,
      this.showErrorBorder = false,
      this.isSelectedItemHasBackGround = false,
      this.borderRadius,
      this.isAllCornersRounded = false,
      this.yOffset = 0,
      this.xOffset = 0});
  bool isAllCornersRounded;
  double xOffset;
  double? borderRadius;
  Widget? customButton;
  final bool isSelectedItemHasBackGround;
  double? menuItemHeight;
  final Function(dynamic) onChanged;
  final List<DropdownMenuItem> items;
  final String? textButton;
  final String? hintText;
  final dynamic value;
  final Widget? customSpacing;
  final bool splashColorOn, showErrorBorder;
  final bool showDropdownIcon;
  final Color? textColor;
  final String? svgIconPath;
  final TextStyle? textStyle;
  final String? Function(dynamic)? validator;
  final double? height, width, menuWidth;
  final double? end;
  final Color? fillColor;
  double yOffset;

  @override
  Widget build(BuildContext context) {
    yOffset = yOffset.abs();
    // print("//////// init state called${yOffset}");
    if (!context.isArabic) {
      yOffset = -1 * yOffset;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: splashColorOn ? AppColors.primary : Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: DropdownButtonFormField2(
        decoration: InputDecoration(
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          filled: true,
          fillColor: fillColor ?? AppColors.field,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          errorStyle: AppTextStyles.font12RedRegularCairo,
          focusedBorder: showErrorBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                  borderSide: const BorderSide(color: Colors.red),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                  borderSide: BorderSide.none,
                ),
          disabledBorder: showErrorBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                  borderSide: const BorderSide(color: Colors.red),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                  borderSide: BorderSide.none,
                ),
          enabledBorder: showErrorBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                  borderSide: const BorderSide(color: Colors.red),
                )
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                  borderSide: BorderSide.none,
                ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
        ),
        validator: validator,
        customButton: customButton ??
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  svgIconPath != null
                      ? _buildIconSection()
                      : const SizedBox.shrink(),
                  //    horizontalSpace(10),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsetsDirectional.only(start: 10.sp),
                          child: _buildDropdownText())),
                  customSpacing ?? const SizedBox(),
                  showDropdownIcon
                      ? Padding(
                          padding: EdgeInsetsDirectional.only(end: end ?? 8.w),
                          child: SizedBox(
                            child: SvgPicture.asset(
                              AppAssets.arrowDown,
                              height: 22.sp,
                              width: 22.sp,
                              colorFilter: ColorFilter.mode(
                                  AppColors.secondaryBlack, BlendMode.srcIn),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
        menuItemStyleData: MenuItemStyleData(
          padding: EdgeInsets.symmetric(
              horizontal: isSelectedItemHasBackGround ? 0 : 8.sp),
          height: menuItemHeight ?? 25.h,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        value: value,
        dropdownStyleData: DropdownStyleData(
          elevation: 10,
          offset: Offset(yOffset, xOffset),

          padding: EdgeInsets.zero,
          width: menuWidth,
          maxHeight: 150.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.r),

            color: fillColor ?? AppColors.field,
          ),
        ),
        hint: Text(
          (hintText ?? 'Choose Here').tr,
          style: AppTextStyles.font12SecondaryBlackCairoRegular,
          overflow: TextOverflow.ellipsis,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'sort'.tr,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.text,
          ),
        ),
        if (textButton != null) ...[
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              (textButton ?? hintText ?? 'Choose here').tr,
              style: value != null
                  ? textStyle ?? AppTextStyles.font12BlackCairoRegular
                  : AppTextStyles.font12SecondaryBlackCairoRegular,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  SvgPicture _buildIconDropdown() {
    return SvgPicture.asset(
      svgIconPath!,
      width: 14.w,
      height: 6.h,
      fit: BoxFit.fill,
      colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
    );
  }

  _buildIconSection() {
    return Row(
      children: [
        horizontalSpace(11),
        _buildIconDropdown(),
      ],
    );
  }
}
