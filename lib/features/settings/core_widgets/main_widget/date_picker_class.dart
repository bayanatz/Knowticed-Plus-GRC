//Date Created :18/September/2023
// Developer Name : Mazen shabaan
//App Version : Version tablet
// Date of Last Edit :5/October/2023 by mazen
// Objectives: this class  created to customize the new calendar picker
//import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/settings/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/features/settings/core_widgets/calender_package/src/utils/dialog.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

class DatePicker {
  Future<List<DateTime?>?> showDatePicker(
      BuildContext context,
      List<DateTime?> rangeDatePickerValueWithDefaultValue,
      DateTime? datetime,
     // DateTime? firstDate,
      
      CalendarDatePicker2Type? calendarType) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize =
        isPortrait ? FontConstants.fontSize019.h : FontConstants.fontSize028.h;
    return showCalendarDatePicker2Dialog(
 
        context: context,
        barrierColor: AppColors.barrierColor,
        dialogBackgroundColor: Theme.of(context).colorScheme.inversePrimary,
        barrierDismissible: true,
        value: rangeDatePickerValueWithDefaultValue,
        config: CalendarDatePicker2WithActionButtonsConfig(
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),

          calendarViewMode: DatePickerMode.day,
          closeDialogOnCancelTapped: true,
          closeDialogOnOkTapped: true,
          currentDate: datetime, //widget.dateTimeNow ?? DateTime.now(),
          centerAlignModePicker: true,
          dayBorderRadius: BorderRadius.circular(8),
          buttonPadding: EdgeInsets.symmetric(
              horizontal: isTablet
                  ? isPortrait
                      ? 0.05.w
                      : 0.029.w
                  : 0.03.w,
              vertical: 0.01.h),
          customModePickerIcon: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 0.004.w : 0.014.w,
                vertical: isTablet ? 0.0.h : 0.02.h),
            child: SvgPicture.asset(
              'assets/images/downArrow.svg',
              fit: BoxFit.fitHeight,
              color: AppColors.lightPrimary,
              height: isTablet ? 0.053.h : null,
            ),
          ),

          okButton: Container(
            height: 0.05.h,
            width: isTablet
                ? isPortrait
                    ? 0.2.w
                    : 0.14.w
                : 0.38.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.switchSettings,
            ),
            child: Center(
              child: Text(
                'Set Date'.tr,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textButton,
                    height: isTablet ? 1.6 : 0.002.h),
              ),
            ),
          ),
          cancelButton: Container(
            height: 0.05.h,
            width: isTablet
                ? isPortrait
                    ? 0.2.w
                    : 0.14.w
                : 0.38.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.colorGreydark,
            ),
            child: Center(
              child: Text(
                'Cancel'.tr,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textCal,
                    height: isTablet ? 1.6 : 0.002.h),
              ),
            ),
          ),

          lastMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 0 : 3.14,
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              // ignore: deprecated_member_use
              color: AppColors.lightPrimary,
            ),
          ),
          nextMonthIcon: Transform.rotate(
            angle: Get.locale.toString().contains('en') ? 3.14 : 0,
            child: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              // ignore: deprecated_member_use
              color: AppColors.lightPrimary,
            ),
          ),
          weekdayLabelTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.switchSettings,
          ),

          controlsTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.switchSettings,
              height: 1.45),
          selectedYearTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1.6,
               color: Theme.of(context).colorScheme.secondaryContainer
              ),
          selectedDayHighlightColor: AppColors.switchSettings,
          dayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: fontSize,
              height: 1.6,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.secondaryContainer),
          selectedDayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            
        height: 1.6,
            color: AppColors.textButton,
          ),
        
          selectedRangeDayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textButton,
         height: 1.6,
          ),
          yearTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.secondaryContainer
          ),
          todayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
           height: 1.6,
            color: Theme.of(context).colorScheme.secondaryContainer
          ),
        
          selectedRangeHighlightColor: AppColors.bubbleColor,
          
          calendarType: calendarType, //CalendarDatePicker2Type.range,
        ),
        dialogSize: isTablet
            ? isPortrait
                ? Size(0.6.w, 0.38.h)
                : Size(0.4.w, 0.55.h)
            : Size(0.99.w, 0.532.h),
        borderRadius: BorderRadius.circular(10),
        useSafeArea: true);
  }
}
