import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/calender/utiles/calendar_components.dart/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/calender/utiles/calendar_components.dart/custom_calendar_picker.dart';
import 'package:demo_app/core/local_widgets/buttons/main_custom_button.dart';
import 'package:demo_app/core/local_widgets/custom_schedule_or_now_dialog.dart';
import 'package:demo_app/core/local_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/local_widgets/filters_appbar.dart';
import 'package:demo_app/core/helper/main_helper/date_time_in_arabic.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/onboarding/welcome_screen/views/mobile_view/nav_bar.dart';

class RescheduleDialog extends StatefulWidget {
  RescheduleDialog({
    super.key,
    this.isEdit = false,
    required this.dialogName,
    required this.confirmationDialogBody,
    this.selectedDateTime,
    required this.onDateTimeSelected,
    required this.onButtonPressed,
  });
  bool? isEdit;
  String dialogName;
  String confirmationDialogBody;
  String? selectedDateTime;
  final Function(String) onDateTimeSelected;
  void Function() onButtonPressed;

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  bool isEnabledDesc = false;

  List<DateTime?> selectedDate = [DateTime.now()];
  String formattedSelectedDate = '';

  int selectedIndex = -1;

  TimeOfDay? startTime;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    String formattedSelectedDate =
        DateFormat('EEEE, dd MMMM yyyy').format(selectedDate[0]!);
    String arabicFormattedDate =
        translateDateFormatToArabic(formattedSelectedDate);
    print(arabicFormattedDate);

    String getFormattedDateTime() {
      String formattedDate =
          DateFormat('dd MMMM yyyy').format(selectedDate[0]!);
      String formattedTime = DateFormat('hh:mm a').format(DateTime(
        selectedDate[0]!.year,
        selectedDate[0]!.month,
        selectedDate[0]!.day,
        startTime?.hour ?? DateTime.now().hour,
        startTime?.minute ?? DateTime.now().minute,
      ));

      return '$formattedDate, $formattedTime';
    }

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? (isPortrait ? 0.1.w : 0.18.w) : 0.05.w,
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
          child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        height: null,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.015.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.0.h),
                child: FiltersAppBar(
                    imageUrl: "assets/icons_assets/main_icons_assets/SmallCalendar.svg",
                    title: isTablet
                        ? "Select Date & Time For Rescheduling ${widget.dialogName}"
                        : "Select Date & Time"),
              ),
              isPortrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: isTablet ? 0.45.w : 0.85.w,

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.0),
                            color: themeController.currentTheme ==
                                    AppColors.lightTheme
                                ? AppColors.colorLightGrey
                                : AppColors.darkBackGround,
                          ),

                          /// Calender Widget
                          child: CustomCalendarPicker(
                            isReviewJob: isTablet ? true : false,
                            calendarType: CalendarDatePicker2Type.single,
                            selectedDate: selectedDate,
                            selectedDateState: (value) {
                              setState(() {
                                selectedDate = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 0.02.h,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Get.locale.toString().contains('en')
                                  ? formattedSelectedDate
                                  : arabicFormattedDate,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isTablet
                                      ? FontConstants.fontSize015.h
                                      : FontConstants.fontSize020.h,
                                  fontWeight: FontWeight.w600,
                                   letterSpacing: Get.locale.toString().contains('en')
                                      ?  1.1 :null,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  height: 1.4),
                            ),
                            SizedBox(
                              height: isPortrait ? 0.01.h : 0.02.h,
                            ),
                            SingleChildScrollView(
                              child: Container(
                                height: 0.25.h,
                                width: 0.5.w,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.shadow,
                                    ),
                                  ),
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.time,
                                    initialDateTime: DateTime.now(),
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      setState(() {
                                        startTime =
                                            TimeOfDay.fromDateTime(newDateTime);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: 0.15.w,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.0),
                              color: themeController.currentTheme ==
                                      AppColors.lightTheme
                                  ? AppColors.colorLightGrey
                                  : AppColors.darkBackGround,
                            ),

                            /// Calender Widget
                            child: CustomCalendarPicker(
                              isReviewJob: true,
                              calendarType: CalendarDatePicker2Type.single,
                              selectedDate: selectedDate,
                              selectedDateState: (value) {
                                setState(() {
                                  selectedDate = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isPortrait ? 0.03.w : 0.02.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Get.locale.toString().contains('en')
                                  ? formattedSelectedDate
                                  : arabicFormattedDate,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize015.h
                                      : FontConstants.fontSize028.h,
                                  fontWeight: FontWeight.w600,
                                   letterSpacing: Get.locale.toString().contains('en')
                                      ?  1.1 :null,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  height: 1.4),
                            ),
                            SizedBox(
                              height: isPortrait ? 0.01.h : 0.02.h,
                            ),
                            SingleChildScrollView(
                              child: Container(
                                height: isPortrait ? 0.25.h : 0.35.h,
                                width: isPortrait ? 0.3.w : 0.27.w,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.shadow,
                                    ),
                                  ),
                                  child: CupertinoDatePicker(
                                    mode: CupertinoDatePickerMode.time,
                                    initialDateTime: DateTime.now(),
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      setState(() {
                                        startTime =
                                            TimeOfDay.fromDateTime(newDateTime);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
              SizedBox(
                height: isPortrait ? 0.03.h : 0.04.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    isPortrait
                        ? Expanded(
                            child: MainCustomButton(
                              buttonText: 'Schedule',
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomScheduleOrNowDialog(
                                      titleText:
                                          'Reschedule ${widget.dialogName}'.tr,
                                      isNow: true,
                                      bodyText:
                                          '${widget.confirmationDialogBody.tr} ${Get.locale.toString().contains('en') ? getFormattedDateTime() : convertToArabicDateTime(getFormattedDateTime())} ${"?".tr}',
                                      onDateTimeSelected: (selectedDateTime) {},
                                      yesOnPressed: () {
                                        widget.selectedDateTime =
                                            getFormattedDateTime();
                                        widget.onDateTimeSelected(
                                            widget.selectedDateTime!);
                                        // widget.onButtonPressed();
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ResponseDialog(
                                                title: "Done",
                                                subtitle:
                                                    "You Successfully Rescheduled The ${widget.dialogName} Date",
                                                lottieAsset:
                                                    "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                              );
                                            });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          )
                        : SizedBox(
                            width: 0.16.w,
                            child: MainCustomButton(
                              buttonText: 'Schedule',
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomScheduleOrNowDialog(
                                      titleText:
                                          'Reschedule ${widget.dialogName}'.tr,
                                      isNow: true,
                                      bodyText:
                                          '${widget.confirmationDialogBody.tr} ${getFormattedDateTime()} ?',
                                      onDateTimeSelected: (selectedDateTime) {},
                                      yesOnPressed: () {
                                        widget.selectedDateTime =
                                            getFormattedDateTime();
                                        widget.onDateTimeSelected(
                                            widget.selectedDateTime!);
                                        //    widget.onButtonPressed();
                                        Navigator.of(context).pop();
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ResponseDialog(
                                                title: "Done",
                                                subtitle:
                                                    "You Successfully Rescheduled The ${widget.dialogName} Date",
                                                lottieAsset:
                                                    "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                              );
                                            });
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
