import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/date_picker_class.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_drop_down_menu.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_elevated_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/filters_appbar.dart';

class InvitedMembersFilter extends StatefulWidget {
  InvitedMembersFilter({
    super.key,
    this.statusValue,
    this.statusState,
    required this.startDateValue,
    required this.endDateValue,
    required this.starDateValueState,
    required this.endDateValueState,
    required this.statusDropDownItems,
    required this.onApplyPressed,
    required this.onResetPressed,
  });

  String? statusValue;
  List<String> statusDropDownItems;
  ValueChanged<String?>? statusState;
  final void Function() onApplyPressed;
  final void Function() onResetPressed;
  String? startDateValue;
  String? endDateValue;
  ValueChanged<String> starDateValueState;
  ValueChanged<String> endDateValueState;

  @override
  State<InvitedMembersFilter> createState() => _InvitedMembersFilterState();
}

class _InvitedMembersFilterState extends State<InvitedMembersFilter> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController startDateArabicController = TextEditingController();
  TextEditingController endDateArabicController = TextEditingController();

  final HapticController hapticController = Get.put(HapticController());

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
      context,
      [],
      now,
      null, //DateTime.now(),
      CalendarDatePicker2Type.single,
    );

    if (picked != null && picked.isNotEmpty) {
      setState(() {
        // Format the selected date to "dd MMM yyyy"
        String formattedDate = DateFormat('dd MMM yyyy').format(picked[0]!);

        if (isStartDate) {
          widget.startDateValue = formattedDate; // Save formatted date directly
          startDateArabicController.text = translateTime(formattedDate);
          startDateController.text = formattedDate; // Set formatted date
          widget.starDateValueState(startDateController.text);
        } else {
          widget.endDateValue = formattedDate; // Save formatted date directly
          endDateArabicController.text = translateTime(formattedDate);
          endDateController.text = formattedDate; // Set formatted date
          widget.endDateValueState(endDateController.text);
        }
      });
    }
  }

  bool isAllChecked = false;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    startDateController.text = widget.startDateValue ?? "";
    endDateController.text = widget.endDateValue ?? "";
    bool isNotEmpty(TextEditingController controller) {
      return controller.text.isNotEmpty;
    }

    bool isNotEmptyString(String? value) {
      return value != null && value.isNotEmpty;
    }

    if (isNotEmpty(startDateController) ||
        isNotEmpty(startDateController) ||
        isNotEmptyString(widget.statusValue)) {
      isAllChecked = true;
    } else {
      isAllChecked = false;
    }

    bool isButtonEnabled = isAllChecked;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? (isPortrait ? 0.1.w : 0.2.w) : 0.1.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.inversePrimary),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? 0.025.w : 0.015.w,
              vertical: isPortrait ? 0.015.h : 0.015.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FiltersAppBar(
                imageUrl: "assets/icons_assets/main_icons_assets/filter_table.svg",
                title: "Filter",
                iconColor: AppColors.textButton,
              ),
              ///////////////////////////////////// tablet section///////////////////////////////////
              isTablet
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectDate(context, true), // Start date
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "Start Date",
                                  textController:
                                      Get.locale.toString().contains('en')
                                          ? startDateController
                                          : startDateArabicController,
                                  hideTitle: true,
                                  isTextField: true,
                                  hint: "Select Start Date",
                                  isOptional: false,
                                  isExpanded: true,
                                  enabled: false,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                                ),
                              ),
                            ),
                            SizedBox(width: 0.02.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _selectDate(context, false), // End date
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "End Date",
                                  textController:
                                      Get.locale.toString().contains('en')
                                          ? endDateController
                                          : endDateArabicController,
                                  hideTitle: true,
                                  isTextField: true,
                                  hint: "Select End Date",
                                  isOptional: false,
                                  isExpanded: true,
                                  enabled: false,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.02.h),
                        Row(
                          children: [
                            Expanded(
                              child: CustomDropdownButton2(
                                hint: "Status",
                                borded: false,
                                buttonHeight: (isPortrait ? 0.05.h : 0.055.h),
                                dropdownWidth: isTablet
                                    ? (isPortrait ? 0.365.w : 0.275.w)
                                    : 0.35.w,
                                buttonDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: themeController.currentTheme ==
                                          AppColors.lightTheme
                                      ? AppColors.colorLightGrey
                                      : AppColors.colorBlack,
                                ),
                                buttonPadding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 0.01.w : 0.02.w),
                                value: widget.statusValue,
                                dropdownItems: widget.statusDropDownItems,
                                onChanged: (value) {
                                  setState(() {
                                    widget.statusValue = value;
                                    widget.statusState!(value);
                                  });
                                },
                              ),
                            ),
                            SizedBox(width: 0.02.w),
                            Expanded(child: Container()),
                          ],
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 0.02.h),
                            child: Text(
                              errorMessage.tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize016.h
                                      : FontConstants.fontSize018.h,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.delete),
                            ),
                          ),
                      ],
                    )
                  ///////////////////////////////////// end of tablet section///////////////////////////////////
                  :
                  ///////////////////////////////////// mobile section      ///////////////////////////////////
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => _selectDate(context, true), // Start date
                          child: ColumnRequestData(
                            fillColor: Colors.transparent,
                            title: "Start Date",
                            textController: Get.locale.toString().contains('en')
                                ? startDateController
                                : startDateArabicController,
                            hideTitle: true,
                            isTextField: true,
                            hint: "Select Start Date",
                            isOptional: false,
                            isExpanded: true,
                            enabled: false,
                            hasSuffix: true,
                            suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                          ),
                        ),
                        SizedBox(height: 0.02.h),
                        GestureDetector(
                          onTap: () => _selectDate(context, false), // End date
                          child: ColumnRequestData(
                            fillColor: Colors.transparent,
                            title: "End Date",
                            textController: Get.locale.toString().contains('en')
                                ? endDateController
                                : endDateArabicController,
                            hideTitle: true,
                            isTextField: true,
                            hint: "Select End Date",
                            isOptional: false,
                            isExpanded: true,
                            enabled: false,
                            hasSuffix: true,
                            suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                          ),
                        ),
                        SizedBox(height: 0.02.h),
                        CustomDropdownButton2(
                          hint: "Status",
                          borded: false,
                          buttonHeight: 0.05.h,
                          dropdownWidth: 0.75.w,
                          buttonWidth: double.infinity,
                          buttonDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorLightGrey
                                : AppColors.colorBlack,
                          ),
                          buttonPadding: EdgeInsets.only(
                              left: Get.locale.toString().contains('en')
                                  ? 0.02.w
                                  : 0.01.w,
                              right: Get.locale.toString().contains('en')
                                  ? 0.01.w
                                  : 0.02.w),
                          value: widget.statusValue,
                          dropdownItems: widget.statusDropDownItems,
                          onChanged: (value) {
                            setState(() {
                              widget.statusValue = value;
                              widget.statusState!(value);
                            });
                          },
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 0.02.h),
                            child: Text(
                              errorMessage.tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize016.h
                                      : FontConstants.fontSize018.h,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.delete),
                            ),
                          ),
                      ],
                    ),
              ///////////////////////////////////// end of mobile section///////////////////////////////////
              SizedBox(height: 0.02.h),
              Padding(
                padding: EdgeInsets.only(bottom: 0.005.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CustomElevatedButton(
                      onPressed: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.mediumImpact,
                            hapticFeedback: HapticFeedback.mediumImpact);
                        Navigator.of(context).pop();
                        widget.onResetPressed();
                      },
                      buttonText: "Reset".tr,
                      fontSize: isTablet
                          ? (isPortrait
                              ? FontConstants.fontSize017.h
                              : FontConstants.fontSize022.h)
                          : FontConstants.fontSize016.h,
                      textColor: AppColors.colorBlack,
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: isPortrait
                            ? Size(0.15.w, 0.045.h)
                            : Size(0.07.w, 0.05.h),
                        backgroundColor: AppColors.colorGreydark,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
                    CustomElevatedButton(
                      onPressed: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.heavyImpact,
                            hapticFeedback: HapticFeedback.heavyImpact);

                        setState(() {
                          // Parse the start and end dates from the text controllers
                          DateTime? selectedStartDate;
                          DateTime? selectedEndDate;

                          if (startDateController.text.isNotEmpty) {
                            selectedStartDate = DateFormat('dd MMM yyyy').parse(
                                startDateController
                                    .text); // Use the same format
                          }
                          if (endDateController.text.isNotEmpty) {
                            selectedEndDate = DateFormat('dd MMM yyyy').parse(
                                endDateController.text); // Use the same format
                          }

                          // Check if both dates are set
                          if (selectedStartDate != null &&
                              selectedEndDate != null) {
                            // Check if end date is before start date
                            if (selectedEndDate.isBefore(selectedStartDate)) {
                              errorMessage =
                                  "End Date Cannot Be Before Start Date.";
                            } else {
                              errorMessage =
                                  ""; // Clear the error message if dates are valid
                            }
                          }
                        });

                        // Check if there's no error before applying
                        if (isButtonEnabled && errorMessage.isEmpty) {
                          //  Navigator.pop(context);
                          widget.onApplyPressed();
                        }
                        if (isButtonEnabled && errorMessage == "") {
                          Navigator.pop(context);
                          widget.onApplyPressed();
                        }
                      },
                      buttonText: "Apply".tr,
                      fontSize: isPortrait
                          ? FontConstants.fontSize017.h
                          : FontConstants.fontSize022.h,
                      fontweight: FontWeight.w600,
                      textColor: AppColors.textButton,
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: isPortrait
                            ? Size(0.15.w, 0.045.h)
                            : Size(0.07.w, 0.05.h),
                        backgroundColor: isButtonEnabled
                            ? AppColors.signOut
                            : AppColors.grey,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          side: BorderSide(color: Colors.transparent),
                        ),
                      ),
                    ),
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
