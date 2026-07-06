// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :14/November/2023
// Objectives: this is a widget to customize column of the requests
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_size.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/theme/app_text_styles.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_description_text_field.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_textfield_new.dart';

// ignore: must_be_immutable
class ColumnRequestData extends StatefulWidget {
  ColumnRequestData({
    super.key,
    this.dropdownValue,
    this.dropDownValueState,
    required this.title,
    required this.isTextField,
    required this.hint,
    required this.isOptional,
    this.isSetting = false,
    this.maxlength,
    this.hideTitle = false,
    this.hasPrefix = false,
    this.hasSuffix = false,
    this.isRequestDialogMobile = false,
    this.prefixIcon,
    this.heightField,
    this.suffixUrl,
    this.dropDownItems,
    this.hasPadding,
    this.fillColor,
    this.buttonWidth,
    this.controllerState,
    this.validator,
    this.controllerfinishState,
    this.textController,
    this.suffixHasColor,
    this.readOnly,
    this.sizerSuffix,
    this.initialValue,
    this.maxlines,
    this.dropWidth,
    this.enabled = true,
    this.removeSpace = false,
    this.isEdit = false,
    this.isRequired = false,
    this.hassSuffixState,
    this.enabledState,
    this.editField,
    this.prefixUrl,
    this.showLengthCounter = false,
    this.isPriority,
    required this.isExpanded,
  });
  String? dropdownValue;
  ValueChanged<String?>? dropDownValueState;
  final String title;
  bool isTextField;
  bool? removeSpace;
  bool showLengthCounter;
  bool? isRequired;
  String hint;
  bool isExpanded;
  bool isOptional;
  int? maxlength;
  List<String>? dropDownItems;
  String? Function(String?)? validator;
  final bool? isSetting;
  final bool hideTitle;
  final bool? hasPrefix;
  bool? hasSuffix;
  final String? suffixUrl;
  final int? maxlines;
  double? heightField = 36.h;
  final String? initialValue;
  final Widget? prefixIcon;
  final bool? hasPadding;
  final bool? readOnly;
  final bool? isRequestDialogMobile;
  final Color? fillColor;
  final double? buttonWidth;
  final double? dropWidth;
  final double? sizerSuffix;
  final bool? suffixHasColor;
  final bool? isEdit;
  ValueChanged<bool?>? hassSuffixState;
  TextEditingController? textController;
  ValueChanged<String?>? controllerState;
  ValueChanged? controllerfinishState;
  bool enabled;
  ValueChanged<bool>? enabledState;
  void Function()? editField;
  final String? prefixUrl;
  final bool? isPriority;
  @override
  State<ColumnRequestData> createState() => _ColumnRequestDataState();
}

class _ColumnRequestDataState extends State<ColumnRequestData> {
  bool isEditMode = false;
  TextEditingController settingReason = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextEditingController settingReason = TextEditingController();
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.hideTitle
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.symmetric(
                    //horizontal: 11,
                    vertical: widget.hasPadding == true
                        ? 0
                        : isTablet
                            ? widget.removeSpace == true
                                ? 0
                                : 0.0.h
                            : 0),
                child: Row(
                  children: [
                    RichText(
                      text: TextSpan(
                          text: widget.title.tr,
                          style: AppTextStyles.font14BlackCairoMedium,
                          children: widget.isOptional
                              ? [
                                  WidgetSpan(
                                      child: SizedBox(
                                    width: 0.01.w,
                                  )),
                                  TextSpan(
                                      text: "(${'Optional'.tr})",
                                      style: AppFontStyle.cairoRegularStyle
                                          .copyWith(
                                        fontSize: isPortrait
                                            ? FontConstants.fontSize019.h
                                            : FontConstants.fontSize022.h,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).colorScheme.scrim,
                                      ))
                                ]
                              : widget.isRequired == true
                                  ? [
                                      WidgetSpan(
                                          child: SizedBox(
                                        width: 0.01.w,
                                      )),
                                      TextSpan(
                                          text: "Required".tr,
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                            fontSize: isTablet
                                                ? isPortrait
                                                    ? FontConstants
                                                        .fontSize019.h
                                                    : FontConstants
                                                        .fontSize022.h
                                                : FontConstants.fontSize014.h,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.delete,
                                          ))
                                    ]
                                  : []),
                    ),
                    if (widget.isEdit == true && !isEditMode) const Spacer(),
                    // if (widget.isEdit == true && !isEditMode)
                      // InkWell(
                      //   onTap: widget.editField,
                      //   /*onTap: () {
                      //     ()=>widget.editField;
                      //     setState(() {
                      //       widget.enabled = !widget.enabled;
                      //       widget.enabledState!(widget.enabled);
                      //     });
                      //   },*/
                      //   child: SvgPicture.asset(
                      //     'assets/icons_assets/main_icons_assets/isEditIcon.svg',
                      //     height: orientation ? 0.02.h : null,
                      //   ),
                      // ),
                  ],
                ),
              ),
        widget.isTextField
            ? widget.isExpanded
                ? widget.isSetting == true
                    ? CustomDescriptionTextField(
                        hint: widget.hint,
                        controller: widget.textController ?? settingReason,
                        maxLength: widget.maxlength ?? 600,
                        enabled: widget.enabled,
                      )
                    : SizedBox(
                        height: isTablet
                            ? (orientation ? 0.05.h : null)
                            : widget.heightField,
                        child: CustomTextFieldContainer(
                          showLengthCounter: widget.showLengthCounter,
                          maxLength: 500,
                          initialValue: widget.initialValue,
                          readOnly: widget.readOnly ?? false,
                          hint: widget.hint,
                          hasPrefix: widget.hasPrefix,
                          enabled: widget.enabled,
                          validator: widget.validator,
                          prefixIcon: widget.prefixIcon,
                          hasSuffix: widget.hasSuffix,
                          suffixUrl: widget.suffixUrl,
                          maxLines: widget.maxlines,
                          fillColor: widget.fillColor,
                          sizerSuffix: widget.sizerSuffix,
                          hassSuffixState: (value) {
                            setState(() {
                              //  widget.hasSuffix = value;
                              // widget.hassSuffixState!(widget.hasSuffix);
                            });
                          },
                          suffixHasColor: widget.suffixHasColor,
                          textController:
                              widget.textController ?? settingReason,
                          controllerfinishState: (value) {
                            setState(() {
                               widget.controllerfinishState!(
                                  widget.textController);
                            });
                          },
                          controllerState: (value) {
                            setState(() {
                              // widget.controllerState!(value);
                            });
                          },
                        ),
                      )
                : Container(
                    height: 0.06.h,
                    width: 0.2.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: Get.locale.toString().contains('en')
                                  ? 0.01.w
                                  : 0,
                              right: Get.locale.toString().contains('en')
                                  ? 0
                                  : 0.01.w),
                          child: Text(
                            widget.hint.tr,
                            style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: Get.locale.toString().contains('en')
                                    ? FontConstants.fontSize019.h
                                    : FontConstants.fontSize017.h,
                                fontWeight: FontWeight.w500,
                                height: 0.002.h,
                                color: Theme.of(context).colorScheme.scrim),
                          ),
                        ),
                        // ignore: deprecated_member_use
                        widget.hasSuffix == true
                            ? Padding(
                                padding: EdgeInsets.only(
                                    right: Get.locale.toString().contains('en')
                                        ? 0.01.w
                                        : 0,
                                    left: Get.locale.toString().contains('en')
                                        ? 0
                                        : 0.01.w),
                                child: SvgPicture.asset(
                                  widget.suffixUrl as String,
                                  // ignore: deprecated_member_use
                                  color: Theme.of(context).colorScheme.scrim,
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  )
            : CustomDropdownButton2(
                hint: widget.hint.tr,
                prefixUrl: widget.prefixUrl,
                borded: false,
                buttonHeight: isTablet
                    ? isPortrait
                        ? 0.05.h
                        : 0.06.h
                    : 38.h,
                buttonWidth:
                    widget.buttonWidth ?? (isTablet ? 0.2.w : double.infinity),

                dropdownWidth: widget.dropWidth ??
                    (isTablet
                        ? 0.2.w
                        : widget.isRequestDialogMobile == true
                            ? 0.86.w
                            : 0.75.w),
                buttonColor: widget.fillColor,
                backColor: widget.fillColor ?? Colors.transparent,
                buttonDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.radius),
                  color: widget.fillColor,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.scrim,
                  ),
                ),

                buttonPadding:
                    EdgeInsets.symmetric(horizontal: isTablet ? 0.01.w : 8.w),
                value: widget.dropdownValue, //requestType,
                dropdownItems: widget.isSetting == true
                    ? [
                        "Personal Information".tr,
                        "Health Insurance".tr,
                        "Additional Information".tr
                      ]
                    : widget.dropDownItems ??
                        ["Sick Leave".tr, "Permission".tr, "Vacation".tr],
                onChanged: (value) {
                  setState(() {
                    if (widget.isPriority != null) {
                      if (widget.isPriority == true) {
                        widget.dropdownValue = value;
                      }
                      widget.dropDownValueState!(widget.dropdownValue);
                    } else {
                      widget.dropdownValue = value;
                      widget.dropDownValueState!(widget.dropdownValue);
                    }

                    //requestType = value;
                  });
                },
              )
      ],
    );
  }
}
