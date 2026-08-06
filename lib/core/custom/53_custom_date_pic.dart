import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import 'package:grc_module/core/theme/app_theme.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/core/custom/32-custom_svg.dart';
import 'package:grc_module/generated/l10n.dart';


class DatePicker {
  Future<List<DateTime?>?> showDatePicker(
      BuildContext context,
      List<DateTime?> rangeDatePickerValueWithDefaultValue,
      DateTime? currentDate,
      CalendarDatePicker2Type? calendarType,
      {DateTime? firstDate}) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return showCalendarDatePicker2Dialog(
        context: context,
        dialogBackgroundColor: AppColors.card,
        barrierDismissible: true,
        value: rangeDatePickerValueWithDefaultValue,
        config: CalendarDatePicker2WithActionButtonsConfig(
          firstDate: firstDate ?? DateTime(1900),
          lastDate: DateTime(2100),

          dayBuilder: ({
            required DateTime date,
            BoxDecoration? decoration,
            bool? isDisabled,
            bool? isSelected,
            bool? isToday,
            TextStyle? textStyle,
          }) {
            return Center(
              child: Container(
                  width: 25.sp,
                  height: 25.sp,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: isSelected == true
                          ? AppColors.primary
                          : AppColors.field,
                      border: Border.all(
                        color: date.day == DateTime.now().day &&
                            date.month == DateTime.now().month &&
                            date.year == DateTime.now().year
                            ? AppColors.primary
                            : AppColors.transparent,
                      )),
                  child: Center(
                      child: Text(
                        date.day.toString(),
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: isSelected == true
                              ? AppColors.white
                              : AppColors.secondaryText,
                        ),
                      ))),
            );
          },
          calendarViewMode: CalendarDatePicker2Mode.day,
          closeDialogOnCancelTapped: true,
          closeDialogOnOkTapped: true,
          currentDate: currentDate, //widget.dateTimeNow ?? DateTime.now(),
          centerAlignModePicker: true,
          dayBorderRadius: BorderRadius.circular(8),

          customModePickerIcon: CustomSvgImage(
   assetPath: 'assets/icons_assets/main_icons_assets/chevron_down.svg',
   height: isTablet ? 16.sp : null,
   fit: BoxFit.fitHeight,
   color: AppColors.primary,
 ),

          okButton: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(bottom: 0.sp),
              child: Container(
                height: 38.sp,
                width: isTablet ? 150.sp : 120.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.primary,
                ),
                child: Center(
                  child: Text(
                    S.current.setDate,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.textButton),
                  ),
                ),
              ),
            ),
          ),

          cancelButton: GestureDetector(
            child: Padding(
              padding: EdgeInsets.only(bottom: 0.sp),
              child: Container(
                height: 38.sp,
                width: isTablet ? 150.sp : 120.sp,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.secondaryButton,
                ),
                child: Center(
                  child: Text(
                    S.current.Cancel,
                    style: StyleText.fontSize14Weight400.copyWith(),
                  ),
                ),
              ),
            ),
          ),


          lastMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 0 : 3.14,
            child: CustomSvgImage.natural(
   assetPath: 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg',
 ),
          ),
          nextMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 3.14 : 0,
            child: CustomSvgImage.natural(
   assetPath: 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg',
 ),
          ),
          weekdayLabelTextStyle: StyleText.fontSize16Weight400
              .copyWith(color: AppColors.primary),

          controlsTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.primary),
          selectedYearTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.primary),
          selectedDayHighlightColor: AppColors.primary,
          dayTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),
          selectedDayTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),

          yearTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.text),
          todayTextStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.text),
          buttonPadding:
          EdgeInsets.symmetric(horizontal: isTablet ? 35.sp : 14.sp),
          selectedRangeHighlightColor: AppColors.primary,
          calendarType: calendarType, //CalendarDatePicker2Type.range,
        ),
        dialogSize: isTablet ? Size(460.sp, 320.sp) : Size(320.w, 320.h),
        borderRadius: BorderRadius.circular(10),
        useSafeArea: true);
  }
}
