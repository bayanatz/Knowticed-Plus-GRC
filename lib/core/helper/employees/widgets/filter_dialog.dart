import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart' hide themeController;
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/employees/core_widgets/calender_package/calendar_date_picker2.dart';
import 'package:demo_app/core/helper/employees/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/date_picker_class.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/column_request_data.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/filters_appbar.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

// ignore: must_be_immutable
class FilterDialog extends StatefulWidget {
  FilterDialog(
      {super.key,
      required this.statusValue,
      this.delayValue,
      this.delayState,
      required this.statusState,
      required this.dateValue,
      required this.dateValueState,
      this.employessScreen = false,
      required this.dropDownItems});
  String? statusValue;
  String? delayValue;
  List<String> dropDownItems;
  ValueChanged<String?>? statusState;
  ValueChanged<String?>? delayState;
  String dateValue;
  ValueChanged<String>? dateValueState;
  bool employessScreen;
  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  // date picker function
  //String dateValue = "Date";
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  DateTime? selectedDate;
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];
  Future<void> _selectDate(BuildContext context) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        _rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        CalendarDatePicker2Type.range);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null && picked != selectedDate) {
      setState(() {
        _rangeDatePickerValueWithDefaultValue = picked;
        selectedDate = picked[
            0]; // get the first element in the array which is the selected date
        // final DateFormat formatter = DateFormat('dd/MM/yyyy');
        // String formattedDate = formatter.format(picked[0] as DateTime);
        // String formattedDate2 = formatter.format(picked.last as DateTime);
        widget.dateValue =
            "${'From'.tr} ${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!).tr} ${picked[0]!.year} ${'To'.tr} ${picked.last!.day} ${DateFormat.MMM().format(picked.last!).tr} ${picked.last!.year}";
        widget.dateValueState!(widget.dateValue);
        startDate.text =
            widget.dateValue.substring(0, widget.dateValue.indexOf('To'.tr));
        endDate.text = widget.dateValue.substring(
            widget.dateValue.indexOf('To'.tr) + 2, widget.dateValue.length - 1);
      });
    }
  }

  final HapticController hapticController = Get.put(HapticController());

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    List<Widget> childrens = [
      Container(
        height: 0.06.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.scrim,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 0.01.w : 0.02.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.dateValue,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: Get.locale.toString().contains('en')
                      ? isTablet
                          ? FontConstants.fontSize022.h
                          : FontConstants.fontSize016.h
                      : isTablet
                          ? FontConstants.fontSize019.h
                          : FontConstants.fontSize013.h,
                  fontWeight: FontWeight.w500,
                  height: 0.002.h,
                  color: widget.dateValue == "Date"
                      ? Theme.of(context).colorScheme.scrim
                      : Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  hapticController.triggerHapticFeedback(
                      vibration: VibrateType.mediumImpact,
                      hapticFeedback: HapticFeedback.mediumImpact);
                  _selectDate(context);
                },
                child: SvgPicture.asset("assets/images/calendarpick.svg"),
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: isTablet ? 0 : 0.02.h,
        width: isTablet ? 0.02.w : 0,
      ),
      CustomDropdownButton2(
        hint: "Status",
        borded: false,
        buttonHeight: 0.06.h,
        buttonWidth: double.infinity,
        dropdownWidth: isTablet ? 0.28.w : 0.35.w,
       
        buttonPadding:
            EdgeInsets.symmetric(horizontal: isTablet ? 0.01.w : 0.02.w),
        value: widget.statusValue,
        dropdownItems: widget.dropDownItems,
        onChanged: (value) {
          setState(() {
            widget.statusValue = value;
            // widget.statusState(widget.statusValue);
          });
        },
      )
    ];
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 0.2.w : 0.1.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        height: isTablet
            ? widget.employessScreen
                ? isPortrait
                    ? 0.38.h
                    : 0.45.h
                : 0.26.h
            : 0.33.h,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 0.015.w, vertical: isPortrait ? 0.02.h : 0.015.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FiltersAppBar(
                  imageUrl: "assets/images/filter_table.svg", title: "Filter"),
              !isTablet
                  ? Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 0.06.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.scrim,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 0.01.w : 0.02.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.dateValue,
                                  style:
                                      AppFontStyle.cairoRegularStyle.copyWith(
                                    fontSize:
                                        Get.locale.toString().contains('en')
                                            ? isTablet
                                                ? FontConstants.fontSize022.h
                                                : FontConstants.fontSize016.h
                                            : isTablet
                                                ? FontConstants.fontSize019.h
                                                : FontConstants.fontSize013.h,
                                    fontWeight: FontWeight.w500,
                                    height: 0.002.h,
                                    color: widget.dateValue == "Date"
                                        ? Theme.of(context).colorScheme.scrim
                                        : Theme.of(context)
                                            .colorScheme
                                            .inverseSurface,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    hapticController.triggerHapticFeedback(
                                        vibration: VibrateType.mediumImpact,
                                        hapticFeedback:
                                            HapticFeedback.mediumImpact);
                                    _selectDate(context);
                                  },
                                  child: SvgPicture.asset(
                                      "assets/images/calendarpick.svg"),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 0.02.h,
                        ),
                        CustomDropdownButton2(
                          hint: "Status",
                          borded: false,
                          buttonHeight: 0.06.h,
                          buttonWidth: double.infinity,
                          dropdownWidth: 0.75.w,
                        
                          buttonPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 0.01.w : 0.02.w),
                          value: widget.statusValue,
                          dropdownItems: widget.dropDownItems,
                          onChanged: (value) {
                            setState(() {
                              widget.statusValue = value;
                              // widget.statusState(widget.statusValue);
                            });
                          },
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _selectDate(context);
                                },
                                child: ColumnRequestData(
                                     fillColor: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorLightGrey
                              : AppColors.colorBlack,
                                  title: "Start Date",
                                  textController: startDate,
                                  isTextField: true,
                                  hint: "Start Date",
                                  enabled: false,
                                  isOptional: false,
                                  hideTitle: true,
                                  isExpanded: true,
                                  hasPrefix: true,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons/newCalenderFixed.svg",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 0.02.w,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  _selectDate(
                                    context,
                                  );
                                },
                                child: ColumnRequestData(
                                     fillColor: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorLightGrey
                              : AppColors.colorBlack,
                                  title: "End Date",
                                  textController: endDate,
                                  hideTitle: true,
                                  isTextField: true,
                                  hint: "End Date",
                                  isOptional: false,
                                  isExpanded: true,
                                  enabled: false,
                                  hasPrefix: true,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons/newCalenderFixed.svg",
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.025.h),
                          child: CustomDropdownButton2(
                            hint: "Status",
                            borded: false,
                            buttonHeight: isPortrait ? 0.05.h : 0.06.h,
                            buttonWidth: 0.7.w,
                            //buttonWidth: double.infinity,
                            dropdownWidth: isTablet
                                ? isPortrait
                                    ? 0.55.w
                                    : 0.28.w
                                : 0.35.w,
                           
                            buttonPadding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 0.01.w : 0.02.w),
                            value: widget.statusValue,
                            dropdownItems: widget.dropDownItems,
                            onChanged: (value) {
                              setState(() {
                                widget.statusValue = value;
                                widget.statusState!(widget.statusValue);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
              widget.employessScreen
                  ? SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(top: 0.025.h),
                        child: CustomDropdownButton2(
                          hint: "Delay",
                          borded: false,
                          buttonHeight: 0.06.h,
                          //buttonWidth: double.infinity,
                          dropdownWidth: isTablet ? 0.28.w : 0.35.w,
                       
                          buttonPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 0.01.w : 0.02.w),
                          value: widget.delayValue,
                          dropdownItems: [
                            'Less than 30 minutes'.tr,
                            'More than 30 minutes'.tr,
                          ],
                          onChanged: (value) {
                            setState(() {
                              widget.delayValue = value;
                              widget.delayState!(value);
                            });
                          },
                        ),
                      ),
                    )
                  : const SizedBox(),
              SizedBox(
                height: 0.02.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: widget.employessScreen ? 0.00 : 0.015.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    MainCustomIconButton(
                      onPressed: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact);
                        setState(() {
                          widget.statusValue = null;
                          widget.delayValue = null;
                          widget.dateValue = "Date";
                          widget.statusState!(widget.statusValue);
                          widget.delayState!(widget.delayValue);
                          widget.dateValueState!(widget.dateValue);
                        });
                      },
                      buttonText: "Reset".tr,
                   
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: isTablet
                            ? isPortrait
                                ? Size(0.15.w, 0.045.h)
                                : Size(0.07.w, 0.05.h)
                            : Size(0.36.w, 0.05.h),
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.shadow),
                        ),
                      ),
                    ),
                    MainCustomIconButton(
                      onPressed: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.heavyImpact,
                            hapticFeedback: HapticFeedback.heavyImpact);
                        widget.statusValue == null
                            ? null
                            : setState(() {
                                widget.statusValue;
                                widget.statusState!(widget.statusValue);
                              });
                        widget.dateValue == "Date"
                            ? null
                            : setState(() {
                                widget.dateValue;
                                widget.dateValueState!(widget.dateValue);
                              });
                        Navigator.pop(context);
                      },
                      buttonText: "Apply".tr,
                   
                      buttonStyle: widget.dateValue == "Date" &&
                              widget.statusValue == null
                          ? ElevatedButton.styleFrom(
                              minimumSize: isTablet
                                  ? isPortrait
                                      ? Size(0.15.w, 0.045.h)
                                      : Size(0.07.w, 0.05.h)
                                  : Size(0.36.w, 0.05.h),
                              backgroundColor: AppColors.GreyBack,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                               
                              ),
                            )
                          : ElevatedButton.styleFrom(
                              minimumSize: isTablet
                                  ? isPortrait
                                      ? Size(0.15.w, 0.045.h)
                                      : Size(0.07.w, 0.05.h)
                                  : Size(0.36.w, 0.05.h),
                              backgroundColor: AppColors.signOut,
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              
                              ),
                            ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
