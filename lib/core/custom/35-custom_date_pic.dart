import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import 'package:demo_app/core/theme/app_theme.dart';
import 'package:demo_app/core/theme/app_colors.dart';


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

          customModePickerIcon: SvgPicture.asset(
            'assets/icons_assets/main_icons_assets/downArrow.svg',
            fit: BoxFit.fitHeight,
            color: AppColors.primary,
            height: isTablet ? 16.sp : null,
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
                    'Set Date'.tr,
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
                    'Cancel'.tr,
                    style: StyleText.fontSize14Weight400.copyWith(),
                  ),
                ),
              ),
            ),
          ),


          lastMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 0 : 3.14,
            child: SvgPicture.asset(
              'assets/icons_assets/main_icons_assets/back_icon.svg',
              // ignore: deprecated_member_use
              color: AppColors.primary,
            ),
          ),
          nextMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 3.14 : 0,
            child: SvgPicture.asset(
              'assets/icons_assets/main_icons_assets/back_icon.svg',
              // ignore: deprecated_member_use
              color: AppColors.primary,
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
