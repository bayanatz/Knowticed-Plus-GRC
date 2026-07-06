// Last edit 13/8/2023 by mazen
// ignore_for_file: deprecated_member_use

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/theme_controller.dart';
import 'package:demo_app/core/helper/task_management_module/borad/controller/board_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';

class CustomProgressDropdown extends StatefulWidget {
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
  final bool? isProgressDialog;
  final bool? isProgressDialogColorCode;
  final bool isBottomSheet;
  final bool hasPrefix;
  final String? prefixUrl;
  final String board;
  final CardModel card;

  const CustomProgressDropdown({
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    required this.board,
    required this.card,
    this.iconHeight,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.borded = false,
    this.isProgressDialogColorCode = false,
    this.isProgressDialog = false,
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
    this.offset = const Offset(0, 0),
    super.key,
  });

  @override
  State<CustomProgressDropdown> createState() => _CustomDropdownButton2State();
}

class _CustomDropdownButton2State extends State<CustomProgressDropdown> {
  final HapticController hapticController = Get.put(HapticController());

  bool filled = false;
  Color _borderColor = AppColors.colorGrey;
  final FocusNode _focusNode = FocusNode();
  ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    Color getColor(double value) {
      if (value <= 20) {
        return AppColors.delete;
      } else if (value <= 40) {
        return AppColors.warning;
      } else if (value <= 70) {
        return AppColors.signOut;
      } else {
        return AppColors.unBlock;
      }
    }

    Color getProgressColor(String value) {
      if (value == "red") {
        return AppColors.delete;
      } else if (value == "orange") {
        return AppColors.warning;
      } else if (value == "yellow") {
        return AppColors.yellowColor;
      } else {
        return AppColors.unBlock;
      }
    }

    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    _borderColor = widget.borded == true || filled == true
        ? Theme.of(context).colorScheme.onInverseSurface
        : AppColors.colorGrey;
    return GetBuilder<TaskDetailsController>(builder: (controller) {
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
                  color: widget.backColor ??
                      Theme.of(context).colorScheme.background,
                  child: Text(
                    widget.hint.tr,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: widget.dropDownTextStyle ??
                        AppTextStyles.font16BlackRegularCairo.copyWith(
                          fontSize: orientation == Orientation.portrait
                              ? isTablet
                                  ? 16.h
                                  : widget.isSettings == true
                                      ? 17.h
                                      : widget.isSignUpMobile == true
                                          ? 18.h
                                          : 16.h
                              : 22.h,
                          height: orientation == Orientation.portrait
                              ? widget.isSignUpMobile == true && !isTablet
                                  ? 1.6
                                  : 0.00125.h
                              : 0.0020.h,
                          color: widget.isSignUpMobile == false
                              ? AppColors.colorGrey
                              : AppColors.red,
                        ),
                  ),
                ),
              ),
            ],
          ),
          value: controller.loading ? "0" : widget.value,
          items: controller.loading
              ? ["0"].map((item) {
                  bool isSelected = item == widget.value;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        if (widget.isProgressDialog == false)
                          SizedBox(
                            height: 0.01.h,
                            width: isTablet
                                ? (isVertical ? 0.2.w : 0.15.w)
                                : 0.18.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: double.parse(item) / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  item == "0"
                                      ? getProgressColor("0")
                                      : getProgressColor(widget
                                              .card.progressIndicator!.colors![
                                          widget.card.progressIndicator!
                                              .progressPercentage!
                                              .indexOf(item)]),
                                ),
                              ),
                            ),
                          ),
                        if (widget.isProgressDialog == false) const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.isProgressDialog == false
                                  ? 0.02.w
                                  : 0),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              "$item%",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isSelected
                                  ? AppFontStyle.cairoRegularStyle.copyWith(
                                      //edited by mazen for create searvice
                                      fontSize: orientation ==
                                              Orientation.portrait
                                          ? isTablet
                                              ? FontConstants.fontSize016.h
                                              : widget.isSettings == true
                                                  ? FontConstants.fontSize017.h
                                                  : widget.isSignUpMobile ==
                                                          true
                                                      ? FontConstants
                                                          .fontSize018.h
                                                      : FontConstants
                                                          .fontSize016.h
                                          : FontConstants.fontSize025.h,
                                      height: isTablet
                                          ? orientation == Orientation.portrait
                                              ? widget.isSignUpMobile == true &&
                                                      !isTablet
                                                  ? 1.6
                                                  : 0.00125.h
                                              : 0.0020.h
                                          : 1.6, //1.6
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                      fontWeight: FontWeight.w500,
                                    )
                                  : AppFontStyle.cairoRegularStyle.copyWith(
                                      fontSize: orientation ==
                                              Orientation.portrait
                                          ? isTablet
                                              ? FontConstants.fontSize016.h
                                              : widget.isSettings == true
                                                  ? FontConstants.fontSize017.h
                                                  : widget.isSignUpMobile ==
                                                          true
                                                      ? FontConstants
                                                          .fontSize018.h
                                                      : FontConstants
                                                          .fontSize016.h
                                          : FontConstants.fontSize025.h,
                                      height: isTablet
                                          ? orientation == Orientation.portrait
                                              ? widget.isSignUpMobile == true &&
                                                      !isTablet
                                                  ? 1.6
                                                  : 0.00125.h
                                              : 0.0020.h
                                          : 1.6, //1.6
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              : widget.dropdownItems.map((item) {
                  bool isSelected = item == widget.value;
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Row(
                      children: [
                        if (widget.isProgressDialog == false)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    minHeight: AppSize.h8,
                                    value: double.parse(item) / 100,
                                    backgroundColor: AppColors.grey,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      item == "0"
                                          ? getProgressColor("0")
                                          : getProgressColor(widget.card
                                                  .progressIndicator!.colors![
                                              widget.card.progressIndicator!
                                                  .progressPercentage!
                                                  .indexOf(item)]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.isProgressDialog == false
                                  ? 0.02.w
                                  : 0),
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Text(
                              Get.locale.toString().contains('en')
                                  ? "$item%"
                                  : "${convertNumberToArabic(item)}%",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isSelected
                                  ? AppFontStyle.cairoRegularStyle.copyWith(
                                      //edited by mazen for create searvice
                                      fontSize: orientation ==
                                              Orientation.portrait
                                          ? isTablet
                                              ? FontConstants.fontSize016.h
                                              : widget.isSettings == true
                                                  ? FontConstants.fontSize017.h
                                                  : widget.isSignUpMobile ==
                                                          true
                                                      ? FontConstants
                                                          .fontSize018.h
                                                      : FontConstants
                                                          .fontSize016.h
                                          : FontConstants.fontSize025.h,
                                      height: isTablet
                                          ? orientation == Orientation.portrait
                                              ? widget.isSignUpMobile == true &&
                                                      !isTablet
                                                  ? 1.6
                                                  : 1.6
                                              : 0.0020.h
                                          : 1.6, //1.6
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                      fontWeight: FontWeight.w500,
                                    )
                                  : AppFontStyle.cairoRegularStyle.copyWith(
                                      fontSize: orientation ==
                                              Orientation.portrait
                                          ? isTablet
                                              ? FontConstants.fontSize016.h
                                              : widget.isSettings == true
                                                  ? FontConstants.fontSize017.h
                                                  : widget.isSignUpMobile ==
                                                          true
                                                      ? FontConstants
                                                          .fontSize018.h
                                                      : FontConstants
                                                          .fontSize016.h
                                          : FontConstants.fontSize025.h,
                                      height: isTablet
                                          ? orientation == Orientation.portrait
                                              ? widget.isSignUpMobile == true &&
                                                      !isTablet
                                                  ? 1.6
                                                  : 0.00125.h
                                              : 0.0020.h
                                          : 1.6, //1.6
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          onChanged: widget.onChanged,
          selectedItemBuilder: widget.selectedItemBuilder,
          buttonStyleData: ButtonStyleData(
            height: widget.buttonHeight ?? 0.040.h,
            width: widget.buttonWidth ?? 0.08.w,
            padding: widget.buttonPadding ??
                EdgeInsets.only(
                  left: 0.020.w,
                ),
            decoration: widget.buttonDecoration ??
                BoxDecoration(
                    color: widget.buttonColor ??
                        Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: widget.borded == false
                        ? Border.all(
                            color: widget.value == widget.hint
                                ? Theme.of(context).colorScheme.errorContainer
                                // ignore: unrelated_type_equality_checks
                                : themeController.currentTheme ==
                                        AppColors.darkTheme
                                    ? widget.isBottomSheet == true
                                        ? Theme.of(context)
                                            .colorScheme
                                            .errorContainer
                                        : Colors.transparent
                                    : _borderColor,
                          )
                        : Border.all(
                            color: Colors.transparent,
                          )
                    //  color: Theme.of(context).colorScheme.inversePrimary,
                    ),
            elevation: widget.buttonElevation,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding: EdgeInsets.only(right: 8.w),
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
            padding: widget.dropdownPadding,
            decoration: widget.dropdownDecoration ??
                BoxDecoration(
                  // color:Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors
                        .transparent, //Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  // color: AppColors.colorWhite,
                ),
            elevation: widget.dropdownElevation ?? 8,
            //Null or Offset(0, 0) will open just under the button. You can edit as you want.
            offset: widget.offset,
            //Default is false to show menu below button
            isOverButton: false,
          ),
          menuItemStyleData: MenuItemStyleData(
            height: orientation == Orientation.portrait
                ? isTablet
                    ? 0.055.w
                    : 0.035.h
                : 0.025.w,
            padding: widget.itemPadding ??
                EdgeInsets.only(left: 0.010.w, right: 0.010.w),
          ),
        ),
      );
    });
  }
}

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

///

class CustomProgressColorDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final Map<String, String> dropdownItemsMap;
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
  final bool? isProgressDialog;
  final bool? isProgressDialogColorCode;
  final bool isBottomSheet;
  final bool hasPrefix;
  final String? prefixUrl;
  final CardModel card;
  final String board;

  const CustomProgressColorDropdown({
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.iconHeight,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.borded = false,
    this.isProgressDialogColorCode = false,
    this.isProgressDialog = false,
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
    this.offset = const Offset(0, 0),
    super.key,
    required this.dropdownItemsMap,
    required this.card,
    required this.board,
  });

  @override
  State<CustomProgressColorDropdown> createState() =>
      _CustomProgressColorDropdownState();
}

class _CustomProgressColorDropdownState
    extends State<CustomProgressColorDropdown> {
  final HapticController hapticController = Get.put(HapticController());
  TaskDetailsController taskController = Get.put(TaskDetailsController());
  bool filled = false;
  Color _borderColor = AppColors.colorGrey;
  final FocusNode _focusNode = FocusNode();
  String colorValue = '';
  ThemeController themeController = Get.put(ThemeController());

  @override
  void initState() {
    widget.dropdownItemsMap.remove(0);
    widget.dropdownItems.removeAt(0);
    taskController.updateColorDropDown(widget.card);
    //taskController.cardProgressPercentageList!.removeAt(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(double value) {
      if (value <= 20) {
        return AppColors.delete;
      } else if (value <= 40) {
        return AppColors.warning;
      } else if (value <= 70) {
        return AppColors.signOut;
      } else {
        return AppColors.unBlock;
      }
    }
    widget.dropdownItemsMap.removeWhere((key, value) => key == '0');
    widget.dropdownItems.remove(0);

    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    _borderColor = widget.borded == true || filled == true
        ? Theme.of(context).colorScheme.onInverseSurface
        : AppColors.colorGrey;
    return DropdownButtonHideUnderline(
      child: GetBuilder<BoardController>(builder: (controller) {
        return DropdownButton2(
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
                  color: widget.backColor ??
                      Theme.of(context).colorScheme.error,
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
                              : AppColors.red,
                        ),
                  ),
                ),
              ),
            ],
          ),
          value: taskController
              .cardProgressPercentageValue, // widget.card.progressIndicator!.progressPercentage![0], // widget.value,
          items: /* widget.card.progressIndicator!.progressPercentage!*/
              taskController.cardProgressPercentageList!.map((item) {
            bool isSelected = item == widget.value;
            colorValue = taskController
                .cardColorsList![
                    taskController.cardProgressPercentageList!.indexOf(item)]
                .capitalize!;
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            widget.isProgressDialog == false ? 0.0002.w : 0),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        Get.locale.toString().contains('en')
                            ? "$item%"
                            : "${convertNumberToArabic(item)}%",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:AppTextStyles.font12SecondaryBlackCairoRegular
                      ),
                    ),
                  ),
                  if (widget.isProgressDialog == false) const Spacer(),
                  if (widget.isProgressDialog == false)
                    ColorDropdown(
                      color: controller.getProgressColor(
                          taskController.cardColorsList![taskController
                              .cardProgressPercentageList!
                              .indexOf(item)]),
                      hint: "Color Code".tr,
                      value: colorValue,
                      dropdownItems: const [
                        "Red",
                        "Orange",
                        "Yellow",
                        "Green",
                      ],
                      onChanged: (value) {
                        List<String> colors = taskController.cardColorsList!;
                        List<String> percentage =
                        widget.card.progressIndicator!.progressPercentage!;
                        setState(() {
                          print(widget
                              .card.progressIndicator!.progressPercentage!
                              .indexOf(item));

                          //print(item);
                          print(value);
                          taskController.updateColorList(
                              context,
                              colors,
                              value!.toLowerCase(),
                              taskController.cardProgressPercentageList!
                                  .indexOf(item));

                          /// UPDATE CARD INDICATOR COLOR VALUE

                          /*controller.updateCard(
                            cardModel: widget.card,
                            board: widget.board,
                            progressIndicators: percentage,
                            progressColor: updatedColors,
                          );*/

                          //widget.dropdownItemsMap[item.key] = value!.toLowerCase();
                        });
                      },
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: widget.onChanged,
          selectedItemBuilder: widget.selectedItemBuilder,
          buttonStyleData: ButtonStyleData(
            height: widget.buttonHeight ?? 0.040.h,
            width: widget.buttonWidth ?? 0.08.w,
            padding: widget.buttonPadding ??
                EdgeInsets.only(
                  left: 0.020.w,
                ),
            decoration: widget.buttonDecoration ??
                BoxDecoration(
                    color: widget.buttonColor ??
                        Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: widget.borded == false
                        ? Border.all(
                            color: widget.value == widget.hint
                                ? Theme.of(context).colorScheme.errorContainer
                                // ignore: unrelated_type_equality_checks
                                : themeController.currentTheme ==
                                        AppColors.darkTheme
                                    ? widget.isBottomSheet == true
                                        ? Theme.of(context)
                                            .colorScheme
                                            .errorContainer
                                        : Colors.transparent
                                    : _borderColor,
                          )
                        : Border.all(
                            color: Colors.transparent,
                          )
                    //  color: Theme.of(context).colorScheme.inversePrimary,
                    ),
            elevation: widget.buttonElevation,
          ),
          iconStyleData: IconStyleData(
            icon: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 8.w),
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
            padding: widget.dropdownPadding,
            decoration: widget.dropdownDecoration ??
                BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors
                        .transparent, //Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  // color: AppColors.colorWhite,
                ),
            elevation: widget.dropdownElevation ?? 8,
            //Null or Offset(0, 0) will open just under the button. You can edit as you want.
            offset: widget.offset,
            //Default is false to show menu below button
            isOverButton: false,
          ),
          menuItemStyleData: MenuItemStyleData(
            height: orientation == Orientation.portrait
                ? isTablet
                    ? 0.055.w
                    : 0.035.h
                : 0.025.w,
            padding: widget.itemPadding ??
                EdgeInsets.only(left: 0.010.w, right: 0.010.w),
          ),
        );
      }),
    );
  }
}

//////////////////////////////////////////

class ColorDropdown extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
  Color? color;

  ColorDropdown({
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.color,
    super.key,
  });

  @override
  State<ColorDropdown> createState() => _ColorDropdownState();
}

class _ColorDropdownState extends State<ColorDropdown> {
  final HapticController hapticController = Get.put(HapticController());

  bool filled = false;
  Color _borderColor = AppColors.colorGrey;
  final FocusNode _focusNode = FocusNode();
  ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    Color getColor(double value) {
      if (value <= 20) {
        return AppColors.delete;
      } else if (value <= 40) {
        return AppColors.warning;
      } else if (value <= 70) {
        return AppColors.signOut;
      } else {
        return AppColors.unBlock;
      }
    }

    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    _borderColor = filled == true
        ? Theme.of(context).colorScheme.onInverseSurface
        : AppColors.colorGrey;
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        hint: Focus(
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
            color: Theme.of(context).colorScheme.error,
            child: Text(
              widget.hint.tr,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: orientation == Orientation.portrait
                    ? isTablet
                        ? FontConstants.fontSize016.h
                        : FontConstants.fontSize016.h
                    : FontConstants.fontSize022.h,
                height: orientation == Orientation.portrait
                    ? !isTablet
                        ? 1.6
                        : 0.00125.h
                    : 0.0020.h,
                color: AppColors.colorGrey,
              ),
            ),
          ),
        ),
        value: widget.value,
        items: widget.dropdownItems.map((item) {
          bool isSelected = item == widget.value;
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  item.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isSelected
                      ? AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation == Orientation.portrait
                        ? isTablet
                        ? FontConstants.fontSize016.h
                        : FontConstants.fontSize016.h
                        : FontConstants.fontSize015.w,
                    height: isTablet
                        ? orientation == Orientation.portrait
                        ? !isTablet
                        ? 1.6
                        : 0.00125.h
                        : 0.0020.h
                        : 1.6, //1.6
                    color: item.toLowerCase() == "red"
                        ? AppColors.delete
                        : item.toLowerCase() == "green"
                        ? AppColors.unBlock
                        : item.toLowerCase() == "orange"
                        ? AppColors.warning
                        : AppColors.yellowColor,
                    // color:widget.color,
                    fontWeight: FontWeight.w500,
                  )
                      : AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: orientation == Orientation.portrait
                        ? isTablet
                        ? FontConstants.fontSize016.h
                        : FontConstants.fontSize016.h
                        : FontConstants.fontSize025.h,
                    height: isTablet
                        ? orientation == Orientation.portrait
                        ? !isTablet
                        ? 1.6
                        : 0.00125.h
                        : 0.0020.h
                        : 1.6, //1.6
                    color: item.toLowerCase() == "red"
                        ? AppColors.delete
                        : item.toLowerCase() == "green"
                        ? AppColors.unBlock
                        : item.toLowerCase() == "orange"
                        ? AppColors.warning
                        : AppColors.yellowColor,
                    //color: widget.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
        buttonStyleData: ButtonStyleData(
          height: isTablet
              ? isVertical
                  ? 0.05.h
                  : 0.056.h
              : 0.045.h,
          width: isTablet ? (isVertical ? 0.14.w : 0.09.w) : 0.21.w, //110
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 0.01.w : 0.02.w),
          decoration: BoxDecoration(
            color: AppColors.white,
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.4),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: widget.value != null ? widget.color : null,
            ),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 0.250.h, //200,
          width: isTablet
              ? (isVertical ? 0.14.w : 0.09.w)
              : 0.21.w, //110,// 0.2.w,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.transparent,
            ),
            // color: AppColors.colorWhite,
          ),
          elevation: 8,
          offset: const Offset(0, 0),
          isOverButton: false,
        ),
        menuItemStyleData: MenuItemStyleData(
          height: orientation == Orientation.portrait
              ? isTablet
                  ? 0.055.w
                  : 0.035.h
              : 0.025.w,
          padding: EdgeInsets.only(left: 0.010.w, right: 0.010.w),
        ),
      ),
    );
  }
}

