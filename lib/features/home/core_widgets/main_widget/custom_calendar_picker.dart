import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/home/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/features/home/core_widgets/calender_package/src/widgets/calendar_date_picker2.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

// ignore: must_be_immutable
class CustomCalendarPicker extends StatefulWidget {
  CustomCalendarPicker(
      {super.key,
      this.firstDate,
      required this.calendarType,
      this.isReviewJob = false,
      this.isHome = false,
      required this.selectedDate,
      required this.selectedDateState});
  final CalendarDatePicker2Type calendarType;
  DateTime? firstDate;
  List<DateTime?> selectedDate;
  ValueChanged<List<DateTime?>> selectedDateState;
  bool? isReviewJob;
  bool? isHome;

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  List<DateTime> selectedDate = [DateTime.now()];

  @override
  Widget build(BuildContext context) {
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double isReviewJob =
        isPortrait ? FontConstants.fontSize016.h : FontConstants.fontSize024.h;
    return CalendarDatePicker2(
      isHome: widget.isHome!,
      config: CalendarDatePicker2Config(
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: DateTime(2100),
        rangeBidirectional: true,
        calendarViewMode: DatePickerMode.day,
        centerAlignModePicker: true,
        dayBorderRadius: BorderRadius.circular(8),
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
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : FontConstants.fontSize015.w,
          fontWeight: FontWeight.w600,
          color: AppColors.switchSettings,
        ),
        controlsTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: widget.isReviewJob == true
                ? isReviewJob
                : FontConstants.fontSize015.w,
            fontWeight: FontWeight.w600,
            color: AppColors.switchSettings,
            height: 1.45),
        selectedYearTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: widget.isReviewJob == true
                ? isReviewJob
                : FontConstants.fontSize015.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onInverseSurface),
        selectedDayHighlightColor: AppColors.switchSettings,
        dayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: widget.isReviewJob == true
                ? isReviewJob
                : widget.isHome == true
                    ? FontConstants.fontSize013.w
                    : (FontConstants.fontSize023.h),
            height: widget.isReviewJob == true
                ? 1.6
                : widget.isHome == true
                    ? (isLargeTablet ? 1.7 : 1.6)
                    : 0,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.inverseSurface),
        selectedDayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : widget.isHome == true
                  ? FontConstants.fontSize013.w
                  : FontConstants.fontSize023.h,
          fontWeight: FontWeight.w500,
          height:
              widget.isReviewJob == true ? 1.6 : (isLargeTablet ? 1.7 : 1.6),
          color: AppColors.textButton,
        ),
        selectedRangeDayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : FontConstants.fontSize015.w,
          fontWeight: FontWeight.w500,
          color: AppColors.colorWhite,
          height: 0.0019.h,
        ),
        yearTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : FontConstants.fontSize015.w,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        todayTextStyle: AppFontStyle.cairoRegularStyle.copyWith(
          fontSize: widget.isReviewJob == true
              ? isReviewJob
              : widget.isHome == true
                  ? FontConstants.fontSize013.w
                  : FontConstants.fontSize023.h,
          fontWeight: FontWeight.w500,
          height: isLargeTablet ? 1.6 : 1.6,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        selectedRangeHighlightColor: AppColors.bubbleColor,
        customModePickerIcon: Container(),
        calendarType: widget.calendarType,
      ),
      value: widget.selectedDate,
      onValueChanged: ((value) {
        setState(() {
          widget.selectedDate = value;
          widget.selectedDateState(widget.selectedDate);
        });
      }),
    );
  }
}
