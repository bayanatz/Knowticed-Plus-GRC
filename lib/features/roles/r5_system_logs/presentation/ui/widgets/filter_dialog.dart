import 'package:grc_module/features/home/main_controller/core_widgets/main_widget/filters_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grc_module/features/onboarding/o2_intro/presentation/ui/pages/onboarding.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:grc_module/core/custom/5-custom_button.dart';

import 'package:grc_module/core/custom/date_time_in_arabic.dart';
import 'package:grc_module/core/theme/haptic_controller.dart';

import 'package:grc_module/core/theme/app_font_size.dart';
import 'package:grc_module/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';
import 'package:grc_module/core/helper/main_helper/arabic_number_format.dart';
import 'package:grc_module/core/custom/1-custom_dropdwon.dart';

import '../../../../../../core/custom/53_custom_date_pic.dart';
import '../../../../../home/main_controller/core_widgets/main_widget/column_request_data.dart';
import 'package:grc_module/generated/l10n.dart';
import 'package:grc_module/core/helper/main_helper/extensions.dart';
// REMOVED_MODULE: import 'package:grc_module/features/skeleton/authentication/welcome_screen/views/mobile_view/nav_bar.dart';

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
              "${S.of(context).from} ${Get.locale.toString().contains('ar') ? ArabicDigits(picked[0]!.day.toString()).toArabicNumbers() : picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${Get.locale.toString().contains('ar') ? ArabicDigits(picked[0]!.year.toString()).toArabicNumbers() : picked[0]!.year}";
        } else {
          systemLogsController.toDate = picked[0];
          systemLogsController.endDate.text =
              "${S.of(context).to} ${Get.locale.toString().contains('ar') ? ArabicDigits(picked.last!.day.toString()).toArabicNumbers() : picked.last!.day} ${DateFormat.MMM().format(picked.last!)} ${Get.locale.toString().contains('ar') ? ArabicDigits(picked.last!.year.toString()).toArabicNumbers() : picked.last!.year}";
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
    return BlocBuilder<SystemLogsController, SystemLogsState>(
        bloc: Get.find<SystemLogsController>(),
        builder: (context, state) {
      final controller = Get.find<SystemLogsController>();
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
                    imageUrl: "assets/icons_assets/main_icons_assets/filter_sliders.svg",
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
                              suffixUrl: "assets/icons_assets/roles_assets/calendar.svg",
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
                              suffixUrl: "assets/icons_assets/roles_assets/calendar.svg",
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
                              onTap: () async {
                                final TimeOfDay? picked =
                                    await showTimePicker(
                                  context: context,
                                  initialTime:
                                      controller.startTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    controller.startTime = picked;
                                  });
                                }
                              },
                              child: ColumnRequestData(
                                fillColor: Colors.transparent,
                                title: "From",
                                textController:
                                    Get.locale.toString().contains('en')
                                        ? controllerStartStart
                                        : TextEditingController(
                                            text: ArabicDigits(
                                                controllerStartStart.text).toArabicNumbers()),
                                isTextField: true,
                                hint: "From",
                                enabled: false,
                                isOptional: false,
                                hideTitle: true,
                                isExpanded: true,
                                hasPrefix: true,
                                hasSuffix: true,
                                suffixUrl: "assets/icons_assets/form_builder_assets/radio_circle_empty.svg",
                              ),
                            ),
                          ),
                          SizedBox(width: 0.02.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final TimeOfDay? picked =
                                    await showTimePicker(
                                  context: context,
                                  initialTime:
                                      controller.endTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    controller.endTime = picked;
                                  });
                                }
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
                                            text: ArabicDigits(
                                                controllerEndStart.text).toArabicNumbers()),
                                hideTitle: true,
                                isTextField: true,
                                hint: "To",
                                isOptional: false,
                                isExpanded: true,
                                enabled: false,
                                hasPrefix: true,
                                hasSuffix: true,
                                suffixUrl: "assets/icons_assets/form_builder_assets/radio_circle_empty.svg",
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
                            child: CustomDropdown<String>(
                              hint: S.of(context).role,
                              value: controller.roleValue,
                              itemHeight: isPortrait ? 0.05.h : 0.065.h,
                              items: controller.accessNames
                                  .map((e) =>
                                      FormatHelper.capitalize(e.toLowerCase()))
                                  .map((e) => DropdownItem<String>(
                                        value: e,
                                        label: e,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  List<String> arabicRoles = controller
                                      .accessNames
                                      .map((e) => e)
                                      .toList();
                                  controller.updateRoleValue(
                                      Get.locale.toString().contains('en')
                                          ? value
                                          : controller.accessNames[
                                              arabicRoles.indexOf(value)]);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 0.02.w,
                          ),
                          Expanded(
                            child: CustomDropdown<String>(
                              hint: S.of(context).action,
                              value: controller.actionValue,
                              itemHeight: isPortrait ? 0.05.h : 0.065.h,
                              items: controller.actions
                                  .map((e) => e)
                                  .map((e) => DropdownItem<String>(
                                        value: e,
                                        label: e,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  List<String> arabicActions = controller
                                      .actions
                                      .map((e) => e)
                                      .toList();
                                  controller.updateActionValue(
                                      Get.locale.toString().contains('en')
                                          ? value
                                          : controller.actions[
                                              arabicActions.indexOf(value)]);
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
                        child: CustomDropdown<String>(
                          hint: S.of(context).country,
                          value: controller.countryValue,
                          itemHeight: isPortrait ? 0.05.h : 0.065.h,
                          items: controller.countries
                              .map((e) => DropdownItem<String>(
                                    value: e,
                                    label: e,
                                  ))
                              .toList(),
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
                        child: CustomDropdown<String>(
                          hint: "City",
                          value: controller.cityValue,
                          itemHeight: isPortrait ? 0.05.h : 0.065.h,
                          items: controller.cities
                              .map((e) => DropdownItem<String>(
                                    value: e,
                                    label: e,
                                  ))
                              .toList(),
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
                      customButton(
                        function: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.mediumImpact,
                              hapticFeedback: HapticFeedback.mediumImpact);
                          setState(() {
                            widget.roleValue = null;
                            widget.delayValue = null;
                            // resetFilter() emits SystemLogsUpdated itself, so
                            // the old explicit GetX update() is redundant.
                            controller.resetFilter();
                          });
                        },
                        title: S.of(context).Reset,
                        color: AppColors.colorGreydark,
                      ),
                      BlocBuilder<SystemLogsController, SystemLogsState>(
                        bloc: Get.find<SystemLogsController>(),
                        builder: (context, state) {
                        return customButton(
                          function: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);
                            controller.isFilter = true;
                            controller.searchAndFilterLogs();
                            // searchAndFilterLogs() above already emits
                            // SystemLogsUpdated via searchLogs/filterLogs.
                            widget.roleValue == null
                                ? null
                                : setState(() {
                                    widget.roleValue;
                                  });
                            Navigator.pop(context);
                          },
                          title: S.of(context).Apply,
                          color: !systemLogsController.isThereFilter()
                              ? AppColors.greyDark
                              : AppColors.signOut,
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
