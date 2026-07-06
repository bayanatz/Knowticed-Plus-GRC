import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/features/roles/core_widgets/calender_package/calendar_date_picker2.dart';
import 'package:demo_app/features/roles/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/date_picker_class.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/cupertino_time_picker.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_drop_down_menu.dart';
import 'package:demo_app/features/roles/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/column_request_data.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/filters_appbar.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';

import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/roles/system_logs/controller/system_logs_controller.dart';
// REMOVED_MODULE: import 'package:demo_app/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

// ignore: must_be_immutable
class FilterDialog extends StatefulWidget {
  FilterDialog(
      {super.key,
      required this.roleValue,
      this.delayValue,
      this.employessScreen = false,
      required this.dropDownItems});
  String? roleValue;
  String? delayValue;
  List<String> dropDownItems;
  ValueChanged<String>? dateValueState;
  bool employessScreen;
  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  SystemLogsController systemLogsController = Get.find();
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        systemLogsController.rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        CalendarDatePicker2Type.single);
    if (picked != null &&
        picked.lastOrNull != systemLogsController.selectedDate) {
      setState(() {
        systemLogsController.rangeDatePickerValueWithDefaultValue = picked;
        systemLogsController.selectedDate = picked[0];
        if (isStartDate) {
          systemLogsController.fromDate = picked[0];
          systemLogsController.startDate.text =
              "${'From'.tr} ${Get.locale.toString().contains('ar') ? convertNumberToArabic(picked[0]!.day.toString()) : picked[0]!.day} ${DateFormat.MMM().format(picked[0]!).tr} ${Get.locale.toString().contains('ar') ? convertNumberToArabic(picked[0]!.year.toString()) : picked[0]!.year}";
        } else {
          systemLogsController.toDate = picked[0];
          systemLogsController.endDate.text =
              "${'To'.tr} ${Get.locale.toString().contains('ar') ? convertNumberToArabic(picked.last!.day.toString()) : picked.last!.day} ${DateFormat.MMM().format(picked.last!).tr} ${Get.locale.toString().contains('ar') ? convertNumberToArabic(picked.last!.year.toString()) : picked.last!.year}";
        }
      });
    }
  }

  final HapticController hapticController = Get.find();

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerEndStart = TextEditingController(
        text: systemLogsController.endTime?.format(context));

    TextEditingController controllerStartStart = TextEditingController(
        text: systemLogsController.startTime?.format(context));
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<SystemLogsController>(builder: (controller) {
      return Dialog(
        insetPadding:
            EdgeInsets.symmetric(horizontal: isTablet ? 0.2.w : 0.1.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 0.015.w, vertical: isPortrait ? 0.02.h : 0.015.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FiltersAppBar(
                    imageUrl: "assets/images/filter_table.svg",
                    title: "Filter"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _selectDate(context, true);
                            },
                            child: ColumnRequestData(
                              fillColor: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorLightGrey
                                  : AppColors.colorBlack,
                              title: "Start Date",
                              textController: controller.startDate,
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
                        SizedBox(width: 0.02.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _selectDate(context, false);
                            },
                            child: ColumnRequestData(
                              fillColor: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorLightGrey
                                  : AppColors.colorBlack,
                              title: "End Date",
                              textController: controller.endDate,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoTimePicker(
                                      onDateTimeChanged:
                                          (DateTime newDateTime) {
                                        setState(() {
                                          controller.startTime =
                                              TimeOfDay.fromDateTime(
                                                  newDateTime);
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                              child: ColumnRequestData(
                                fillColor: Colors.transparent,
                                title: "From",
                                textController:
                                    Get.locale.toString().contains('en')
                                        ? controllerStartStart
                                        : TextEditingController(
                                            text: convertNumberToArabic(
                                                controllerStartStart.text)),
                                isTextField: true,
                                hint: "From",
                                enabled: false,
                                isOptional: false,
                                hideTitle: true,
                                isExpanded: true,
                                hasPrefix: true,
                                hasSuffix: true,
                                suffixUrl: "assets/images/circle_icon.svg",
                              ),
                            ),
                          ),
                          SizedBox(width: 0.02.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoTimePicker(
                                      onDateTimeChanged:
                                          (DateTime newDateTime) {
                                        setState(() {
                                          controller.endTime =
                                              TimeOfDay.fromDateTime(
                                                  newDateTime);
                                        });
                                      },
                                    );
                                  },
                                );
                              },
                              child: ColumnRequestData(
                                fillColor: themeController.currentTheme ==
                                        AppColors.lightTheme
                                    ? AppColors.colorLightGrey
                                    : AppColors.colorBlack,
                                title: "To",
                                textController:
                                    Get.locale.toString().contains('en')
                                        ? controllerEndStart
                                        : TextEditingController(
                                            text: convertNumberToArabic(
                                                controllerEndStart.text)),
                                hideTitle: true,
                                isTextField: true,
                                hint: "To",
                                isOptional: false,
                                isExpanded: true,
                                enabled: false,
                                hasPrefix: true,
                                hasSuffix: true,
                                suffixUrl: "assets/images/circle_icon.svg",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.025.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomDropdownButton2(
                              hint: "Role".tr,
                              borded: false,
                              buttonHeight: isPortrait ? 0.05.h : 0.065.h,
                              buttonWidth: 0.7.w,
                              dropdownWidth: isTablet
                                  ? isPortrait
                                      ? 0.27.w
                                      : 0.275.w
                                  : 0.35.w,
                            
                              buttonPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 0.01.w : 0.02.w),
                              value: controller.roleValue?.tr,
                              dropdownItems: controller.accessNames
                                  .map((e) => capitalize(e.toLowerCase()).tr)
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  List<String>? arabicRoles = controller
                                      .accessNames
                                      .map((e) => e.tr)
                                      .toList();
                                  controller.updateRoleValue(
                                      Get.locale.toString().contains('en')
                                          ? value
                                          : controller.accessNames[
                                              arabicRoles.indexOf(value!)]);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 0.02.w,
                          ),
                          Expanded(
                            child: CustomDropdownButton2(
                              hint: "Action".tr,
                              borded: false,
                              buttonHeight: isPortrait ? 0.05.h : 0.065.h,
                              dropdownWidth: isTablet
                                  ? isPortrait
                                      ? 0.27.w
                                      : 0.275.w
                                  : 0.35.w,
                             
                              buttonPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 0.01.w : 0.02.w),
                              value: controller.actionValue?.tr,
                              dropdownItems:
                                  controller.actions.map((e) => e.tr).toList(),
                              onChanged: (value) {
                                setState(() {
                                  List<String>? arabicActions = controller
                                      .actions
                                      .map((e) => e.tr)
                                      .toList();
                                  controller.updateActionValue(
                                      Get.locale.toString().contains('en')
                                          ? value
                                          : controller.actions[
                                              arabicActions.indexOf(value!)]);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.025.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomDropdownButton2(
                          hint: "Country".tr,
                          borded: false,
                          buttonHeight: isPortrait ? 0.05.h : 0.065.h,
                          dropdownWidth: isTablet ? 0.275.w : 0.35.w,
                        
                          buttonPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 0.01.w : 0.02.w),
                          value: controller.countryValue,
                          dropdownItems: controller.countries,
                          onChanged: (value) {
                            setState(() {
                              controller.updateCountryValue(value);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 0.02.w,
                      ),
                      Expanded(
                        child: CustomDropdownButton2(
                          hint: "City",
                          borded: false,
                          buttonHeight: isPortrait ? 0.05.h : 0.065.h,
                          dropdownWidth: isTablet ? 0.275.w : 0.35.w,
                        
                          buttonPadding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 0.01.w : 0.02.w),
                          value: controller.cityValue,
                          dropdownItems: controller.cities,
                          onChanged: (value) {
                            setState(() {
                              controller.updateCityValue(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0.02.h),
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
                            widget.roleValue = null;
                            widget.delayValue = null;
                            systemLogsController.update();
                            controller.resetFilter();
                          });
                        },
                        buttonText: "Reset".tr,
                        buttonStyle: ElevatedButton.styleFrom(
                          minimumSize: isTablet
                              ? isPortrait
                                  ? Size(0.15.w, 0.045.h)
                                  : Size(0.07.w, 0.05.h)
                              : Size(0.36.w, 0.05.h),
                          backgroundColor: AppColors.colorGreydark,
                          shape: RoundedRectangleBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            side: BorderSide(
                                color: Theme.of(context).colorScheme.shadow),
                          ),
                        ),
                      ),
                      GetBuilder<SystemLogsController>(builder: (_) {
                        return MainCustomIconButton(
                          onPressed: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);
                            controller.isFilter = true;
                            controller.searchAndFilterLogs();
                            widget.roleValue == null
                                ? null
                                : setState(() {
                                    widget.roleValue;
                                    systemLogsController.update();
                                  });
                            Navigator.pop(context);
                          },
                          buttonText: "Apply".tr,
                          buttonStyle: !systemLogsController.isThereFilter()
                              ? ElevatedButton.styleFrom(
                                  minimumSize: isTablet
                                      ? isPortrait
                                          ? Size(0.15.w, 0.045.h)
                                          : Size(0.07.w, 0.05.h)
                                      : Size(0.36.w, 0.05.h),
                                  backgroundColor: AppColors.greyDark,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
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
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                        );
                      })
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
