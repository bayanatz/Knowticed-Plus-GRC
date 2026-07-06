// Last edit 13/8/2023 by mazen
// ignore_for_file: deprecated_member_use

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';

import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/haptic/haptic_controller.dart';

class CustomDropdownButton2 extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Alignment? hintAlignment;
  final Alignment? valueAlignment;
  final double? buttonHeight, buttonWidth, iconHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final BoxDecoration? buttonDecoration;
  final int? buttonElevation;
  final Widget? icon;
  final TextStyle? dropDownTextStyle;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight, dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final bool? isSignUpMobile;
  final Offset offset;
  final bool? borded;
  final bool? preferred;
  final Color? backColor;
  final Color? buttonColor;
  final bool? conditionToCheck;
  final bool? isSettings;
  final bool isBottomSheet;
  final bool hasPrefix;
  final String? prefixUrl;
  final bool? isCompany;
  final bool? isArabic;
  final Color? subColor;
  const CustomDropdownButton2({
    this.isCompany,
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.iconHeight,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.subColor,
    this.borded = false,
    this.isSignUpMobile = false,
    this.conditionToCheck = false,
    this.isSettings = false,
    this.preferred,
    this.buttonColor,
    this.prefixUrl,
    this.hasPrefix = false,
    this.backColor,
    this.valueAlignment,
    this.isBottomSheet = false,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.icon,
    this.dropDownTextStyle,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    this.itemPadding,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.isArabic,
    this.offset = const Offset(0, 0),
    super.key,
  });

  @override
  State<CustomDropdownButton2> createState() => _CustomDropdownButton2State();
}

class _CustomDropdownButton2State extends State<CustomDropdownButton2> {
  final HapticController hapticController = Get.put(HapticController());

  bool filled = false;
  Color _borderColor = AppColors.colorGrey;
  final FocusNode _focusNode = FocusNode();
  ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    _borderColor = widget.borded == true || filled == true
        ? Theme.of(context).colorScheme.onInverseSurface
        : AppColors.colorGrey;
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        //To avoid long text overflowing.
        isExpanded: true,

        hint: Row(
          children: [
            Focus(
              focusNode: _focusNode,
              onFocusChange: (hasFocus) {
                setState(() {
                  filled == true
                      ? _borderColor =
                      Theme.of(context).colorScheme.onInverseSurface
                      : _borderColor = hasFocus
                      ? AppColors.lightPrimary
                      : AppColors.colorGrey;
                });
              },
              child: Container(
                //  alignment: widget.hintAlignment,
                // color: Theme.of(context).colorScheme.background,
                color: widget.subColor ??
                    (themeController.currentTheme == AppColors.lightTheme
                        ? AppColors.colorLightGrey
                        : AppColors.colorBlack),
                child: Text(
                  widget.hint.tr,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: widget.dropDownTextStyle ??
                      AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: orientation == Orientation.portrait
                            ? isTablet
                            ? FontConstants.fontSize016.h
                            : widget.isSettings == true
                            ? FontConstants.fontSize017.h
                            : widget.isSignUpMobile == true
                            ? FontConstants.fontSize018.h
                            : FontConstants.fontSize016.h
                            : FontConstants.fontSize022.h,
                        height: orientation == Orientation.portrait
                            ? widget.isSignUpMobile == true && !isTablet
                            ? 1.6
                            : 0.00125.h
                            : 0.0020.h,
                        color: widget.isSignUpMobile == false
                            ? AppColors.colorGrey
                            : Theme.of(context).colorScheme.scrim,
                      ),
                ),
              ),
            ),
          ],
        ),
        value: widget.value,
        items: widget.dropdownItems.map((item) {
          bool isSelected = item == widget.value;
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              color: isSelected ? AppColors.primary : Colors.transparent, // Apply green background inside dropdown only
              child: Padding(
                padding:  EdgeInsets.all(8.w),
                child: Row(
                  children: [
                    widget.prefixUrl != null
                        ? Padding(
                      padding: EdgeInsets.only(right: 11.w),
                      child: Transform.scale(
                          scale: 1.1,
                          child: SvgPicture.asset(
                            item == "Urgent".tr
                                ? 'assets/icons_assets/main_icons_assets/urgentBell.svg'
                                : item == "Important".tr
                                ? 'assets/icons_assets/main_icons_assets/important.svg'
                                : item == "Medium".tr
                                ? 'assets/icons_assets/main_icons_assets/medium.svg'
                                : item == "Low".tr
                                ? 'assets/icons_assets/main_icons_assets/lowPriority.svg'
                                : "",
                            height: 19.h,
                          )),
                    )
                        : const SizedBox.shrink(),
                    Text(
                      widget.isArabic == true
                          ? '$item. ابق إيجابيًا'
                          : widget.isCompany == true
                          ? '$item. Stay positive'
                          : item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isSelected
                          ? AppTextStyles.font12BlackCairo.copyWith(
                        //edited by mazen for create searvice
                        fontFamily: widget.isCompany == true ? item : null,
                        // fontSize: orientation == Orientation.portrait
                        //     ? isTablet
                        //         ? FontConstants.fontSize016.h
                        //         : widget.isSettings == true
                        //             ? FontConstants.fontSize017.h
                        //             : widget.isSignUpMobile == true
                        //                 ? FontConstants.fontSize018.h
                        //                 : 12.sp
                        //     : FontConstants.fontSize025.h,
                        height: isTablet
                            ? orientation == Orientation.portrait
                            ? widget.isSignUpMobile == true && !isTablet
                            ? 1.6
                            : 0.00125.h
                            : 0.0020.h
                            : 1.6, //1.6
                        // color:
                        //     Theme.of(context).colorScheme.onInverseSurface,
                      )
                          : AppTextStyles.font12BlackCairo.copyWith(
                        fontFamily: widget.isCompany == true ? item : null,
                        color: AppColors.textdeactivecolor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
        selectedItemBuilder: (context) => widget.dropdownItems.map((item) {
          return Row(
            children: [
              widget.prefixUrl != null ?
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SvgPicture.asset(
                  item == "Urgent".tr
                      ? 'assets/icons_assets/main_icons_assets/urgentBell.svg'
                      : item == "Important".tr
                      ? 'assets/icons_assets/main_icons_assets/important.svg'
                      : item == "Medium".tr
                      ? 'assets/icons_assets/main_icons_assets/medium.svg'
                      : item == "Low".tr
                      ? 'assets/icons_assets/main_icons_assets/lowPriority.svg'
                      : "",
                  height: 19,
                ),
              ) : const SizedBox.shrink(),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  widget.isArabic == true
                      ? '$item. ابق إيجابيًا'
                      : widget.isCompany == true
                      ? '$item. Stay positive'
                      : item,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.font12BlackCairo.copyWith(
                    //edited by mazen for create searvice
                    fontFamily: widget.isCompany == true ? item : null,
                    height: isTablet
                        ? orientation == Orientation.portrait
                        ? widget.isSignUpMobile == true && !isTablet
                        ? 1.6
                        : 0.00125.h
                        : 0.0020.h
                        : 1.6, //1.6
                    // color:
                    //     Theme.of(context).colorScheme.onInverseSurface,

                  ),
                ),
              ),
            ],
          );
        }).toList(),
        buttonStyleData: ButtonStyleData(
          height: widget.buttonHeight ?? 0.040.h,
          width: widget.buttonWidth ?? 0.08.w,
          padding: widget.buttonPadding ??
              EdgeInsets.only(
                left: 0.020.w,
              ),
          decoration: BoxDecoration(
            // ignore: unrelated_type_equality_checks
            color: widget.subColor ??
                (themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorLightGrey
                    : AppColors.colorBlack),
            borderRadius: BorderRadius.circular(AppSize.radius),

            //  color: Theme.of(context).colorScheme.inversePrimary,
          ),
          elevation: widget.buttonElevation,
        ),
        iconStyleData: IconStyleData(
          icon: Padding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 0.4 : 8.w),
            child: SvgPicture.asset(
              ImagePaths.getImagePath(context, 'arrow_down_mobile'),
              height: orientation == Orientation.portrait
                  ? isTablet
                  ? 0.02.h
                  : 0.02.h
                  : widget.iconHeight ?? 0.03.h,
              width: orientation == Orientation.portrait ? 0.07.w : 0.01.h,
              color: widget.value != null
                  ? Theme.of(context).colorScheme.onInverseSurface
                  : null,
            ),
          ),
          // iconSize: iconSize ?? 22,
          iconEnabledColor: widget.iconEnabledColor,
          iconDisabledColor: widget.iconDisabledColor,
        ),

        dropdownStyleData: DropdownStyleData(
          //Max height for the dropdown menu & becoming scrollable if there are more items. If you pass Null it will take max height possible for the items.
          maxHeight: widget.dropdownHeight ?? 0.250.h, //200,
          width: widget.dropdownWidth ?? 0.2.w,
          decoration: widget.dropdownDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.radius),
              ),
          elevation: widget.dropdownElevation ?? 8,
          //Null or Offset(0, 0) will open just under the button. You can edit as you want.
          offset: widget.offset,
          //Default is false to show menu below button
          isOverButton: false,
          // scrollbarTheme: ScrollbarThemeData(
          //   radius: widget.scrollbarRadius ?? Radius.circular(0.040.r),
          //   thickness: widget.scrollbarThickness != null
          //       ? MaterialStateProperty.all<double>(widget.scrollbarThickness!)
          //       : null,
          //   thumbVisibility: widget.scrollbarAlwaysShow != null
          //       ? MaterialStateProperty.all<bool>(widget.scrollbarAlwaysShow!)
          //       : null,
          // ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: orientation == Orientation.portrait
              ? isTablet
              ? 0.055.w
              : 35.h
              : 0.025.w,
          padding: widget.itemPadding ??
              EdgeInsets.all(0),
        ),
      ),
    );
  }
}
