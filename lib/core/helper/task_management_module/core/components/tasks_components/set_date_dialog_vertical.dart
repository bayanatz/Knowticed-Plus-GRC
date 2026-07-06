import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/selection_user.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/checklist_item.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/date_time_in_arabic.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/custom_calendar_picker.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/cupertino_time_picker.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/filters_appbar.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/two_container_widget.dart';

class SetDateDialogVertical extends StatefulWidget {
  final String board;
  final CardModel cardModel;

  final CheckListItems? currentListItem;
  final CardCheckLists? currentCheckList;

  const SetDateDialogVertical({
    super.key,
    required this.board,
    required this.cardModel,
    this.currentListItem,
    required this.currentCheckList,
  });
  @override
  _SetDateDialogVerticalState createState() => _SetDateDialogVerticalState();
}

class _SetDateDialogVerticalState extends State<SetDateDialogVertical> {
  final HapticController hapticController = Get.put(HapticController());
  TaskDetailsController taskController = Get.find();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String hintDate = "DD/MM/YYYY";

  ////
  // String? startDateValue;
  // String? startTimeValue;
  // String? endDateValue;
  // String? endTimeValue;
  ////

  List<DateTime?> selectedDate = [DateTime.now()];

  /// English
  TextEditingController? controllerStartTime;
  TextEditingController? controllerEndTime;
  TextEditingController? controllerStartDate;
  TextEditingController? controllerEndDate;

  /// Arabic
  TextEditingController? controllerStartTimeArabic;
  TextEditingController? controllerEndTimeArabic;
  TextEditingController? controllerStartDateArabic;
  TextEditingController? controllerEndDateArabic;

  @override
  void initState() {
    super.initState();

    /// English
    controllerStartTime = TextEditingController();
    controllerEndTime = TextEditingController();
    controllerStartDate = TextEditingController();
    controllerEndDate = TextEditingController();

    /// Arabic
    controllerStartTimeArabic = TextEditingController();
    controllerEndTimeArabic = TextEditingController();
    controllerStartDateArabic = TextEditingController();
    controllerEndDateArabic = TextEditingController();

    if (widget.currentListItem != null) {
      if (widget.currentListItem!.itemStartDate != null &&
          widget.currentListItem!.itemStartDate!.isNotEmpty) {
        controllerStartDate!.text = widget.currentListItem!.itemStartDate!.last;
        // Translate and set the Arabic controller
        controllerStartDateArabic!.text =
            translateDateTask(widget.currentListItem!.itemStartDate!.last);
      }

      if (widget.currentListItem!.itemStartTime != null &&
          widget.currentListItem!.itemStartTime!.isNotEmpty) {
        controllerStartTime!.text = widget.currentListItem!.itemStartTime!.last;

        // Translate and set the Arabic controller
        controllerStartTimeArabic!.text =
            translateTime(widget.currentListItem!.itemStartTime!.last);
      }

      if (widget.currentListItem!.itemEndDate != null &&
          widget.currentListItem!.itemEndDate!.isNotEmpty) {
        controllerEndDate!.text = widget.currentListItem!.itemEndDate!.last;
        // Translate and set the Arabic controller
        controllerEndDateArabic!.text =
            translateDateTask(widget.currentListItem!.itemEndDate!.last);
      }

      if (widget.currentListItem!.itemEndTime != null &&
          widget.currentListItem!.itemEndTime!.isNotEmpty) {
        controllerEndTime!.text = widget.currentListItem!.itemEndTime!.last;

        // Translate and set the Arabic controller
        controllerEndTimeArabic!.text =
            translateTime(widget.currentListItem!.itemEndTime!.last);
      }
    }
  }

  int _selectedIndex = 0; // Track the selected container index
  String errorMessage = ''; // Track the error message
  bool isAllChecked = false;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    bool isNotEmpty(TextEditingController controller) {
      return controller.text.isNotEmpty;
    }

    if (isNotEmpty(controllerStartDate!) || isNotEmpty(controllerEndDate!)) {
      isAllChecked = true;
    } else {
      isAllChecked = false;
    }

    bool isButtonEnabled = isAllChecked;

    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 0.135.w : 0.05.w,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 0.02.w : 0.04.w, vertical: 0.02.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FiltersAppBar(
                    imageUrl: 'assets/icons_assets/main_icons_assets/icons_calendar.svg',
                    title: "Set Dates",
                    iconColor: AppColors.textButton,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TwoContainersWidget(
                      onContainerTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 0.02.h,
                  ),
                  Column(
                    children: [
                      Container(
                        width: isTablet ? 0.5.w : double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: themeController.currentTheme ==
                                  AppColors.lightTheme
                              ? AppColors.colorLightGrey
                              : AppColors.darkBackGround,
                        ),
                        child: CustomCalendarPicker(
                          isReviewJob: isTablet ? true : false,
                          calendarType: CalendarDatePicker2Type.single,
                          selectedDate: selectedDate,
                          firstDate: DateTime.now(),
                          selectedDateState: (value) {
                            setState(() {
                              selectedDate = value;
                              _updateSelectedDate();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 0.02.h,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: isTablet ? 0.33.w : 0.4.w,
                            child: ColumnRequestData(
                              fillColor: Colors.transparent,
                              title: "Start Date",
                              isTextField: true,
                              hint: hintDate,
                              enabled: false,
                              dropWidth: double.infinity,
                              isOptional: false,
                              isExpanded: true,
                              hasPrefix: true,
                              hasSuffix: true,
                              suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                              textController:
                                  Get.locale.toString().contains('en')
                                      ? controllerStartDate
                                      : controllerStartDateArabic,
                            ),
                          ),
                          SizedBox(
                            width: 0.02.w,
                          ),
                          SizedBox(
                            width: isTablet ? 0.33.w : 0.4.w,
                            child: GestureDetector(
                              onTap: () {
                                if (_selectedIndex == 0) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoTimePicker(
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
                                          setState(() {
                                            startTime = TimeOfDay.fromDateTime(
                                                newDateTime);
                                            controllerStartTime =
                                                TextEditingController(
                                                    text: startTime
                                                        ?.format(context));

                                            controllerStartTimeArabic =
                                                TextEditingController(
                                                    text: translateTime(
                                                        controllerStartTime!
                                                            .text));
                                          });
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              child: ColumnRequestData(
                                fillColor: Colors.transparent,
                                title: "",
                                isTextField: true,
                                textController:
                                    Get.locale.toString().contains('en')
                                        ? controllerStartTime
                                        : controllerStartTimeArabic,
                                hint: "00:00",
                                dropWidth: double.infinity,
                                isOptional: false,
                                isExpanded: true,
                                hasPrefix: true,
                                enabled: false,
                                hasSuffix: true,
                                suffixUrl: "assets/icons_assets/task_assets/ClockCircleIcon.svg",
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 0.02.h,
                      ),
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: isTablet ? 0.33.w : 0.4.w,
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "End Date",
                                  isTextField: true,
                                  hint: hintDate,
                                  enabled: false,
                                  isOptional: false,
                                  isExpanded: true,
                                  hasPrefix: true,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                                  textController:
                                      Get.locale.toString().contains('en')
                                          ? controllerEndDate
                                          : controllerEndDateArabic,
                                ),
                              ),
                              SizedBox(
                                width: 0.02.w,
                              ),
                              SizedBox(
                                width: isTablet ? 0.33.w : 0.4.w,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_selectedIndex == 1) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoTimePicker(
                                            onDateTimeChanged:
                                                (DateTime newDateTime) {
                                              setState(() {
                                                endTime =
                                                    TimeOfDay.fromDateTime(
                                                        newDateTime);
                                                controllerEndTime =
                                                    TextEditingController(
                                                        text: endTime
                                                            ?.format(context));
                                                controllerEndTimeArabic =
                                                    TextEditingController(
                                                        text: translateTime(
                                                            controllerEndTime!
                                                                .text));
                                              });
                                            },
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: ColumnRequestData(
                                    fillColor: Colors.transparent,
                                    title: "",
                                    isTextField: true,
                                    textController:
                                        Get.locale.toString().contains('en')
                                            ? controllerEndTime
                                            : controllerEndTimeArabic,
                                    hint: "00:00",
                                    isOptional: false,
                                    isExpanded: true,
                                    hasPrefix: true,
                                    enabled: false,
                                    hasSuffix: true,
                                    suffixUrl:
                                        "assets/icons_assets/task_assets/ClockCircleIcon.svg",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_selectedIndex != 1 &&
                              controllerEndDate!.text.isEmpty)
                            Positioned(
                                child: Container(
                              color: Colors.transparent,
                              height: isTablet ? 0.08.h : 0.072.h,
                              width: isTablet ? 0.68.w : 0.82.w,
                            )),
                        ],
                      ),
                      SizedBox(
                        height: 0.02.h,
                      ),
                      if (errorMessage != "")
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 0.02.h : 0.01.h),
                          child: SizedBox(
                            //     color: Colors.amber,
                            width: isTablet ? 0.68.w : 0.82.w,
                            child: Text(
                              errorMessage,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                  fontSize: isPortrait
                                      ? FontConstants.fontSize018.h
                                      : FontConstants.fontSize016.h,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.delete),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: isTablet ? 0.01.h : 0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.01.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact,
                              );
                              setState(() {
                                // Parse the start and end dates from the text controllers
                                DateTime? selectedStartDate;
                                DateTime? selectedEndDate;
                                DateTime today = DateTime.now();

                                if (controllerStartDate!.text.isNotEmpty) {
                                  selectedStartDate = DateFormat('dd/MM/yyyy')
                                      .parse(controllerStartDate!.text);
                                }
                                if (controllerEndDate!.text.isNotEmpty) {
                                  selectedEndDate = DateFormat('dd/MM/yyyy')
                                      .parse(controllerEndDate!.text);
                                }

                                // Check if both times are set but both dates are missing
                                if ((endTime != null &&
                                        controllerEndDate!.text.isEmpty) &&
                                    (startTime != null &&
                                        controllerStartDate!.text.isEmpty)) {
                                  errorMessage =
                                      "Please Set Both Dates Before Proceeding.";
                                }
                                // Check if neither date is set
                                else if ((endTime == null &&
                                        controllerEndDate!.text.isEmpty) &&
                                    (startTime == null &&
                                        controllerStartDate!.text.isEmpty)) {
                                  errorMessage =
                                      "Please Set At Least One Date Before Proceeding.";
                                }
                                // Check if end date is missing
                                else if ((endTime != null &&
                                    controllerEndDate!.text.isEmpty)) {
                                  errorMessage =
                                      "Please Set The End Date Before Proceeding.";
                                }
                                // Check if start date is missing
                                else if ((startTime != null &&
                                    controllerStartDate!.text.isEmpty)) {
                                  errorMessage =
                                      "Please Set The Start Date Before Proceeding.";
                                }

                                // Check if end date is earlier than start date
                                else if (selectedEndDate != null &&
                                    selectedStartDate != null &&
                                    selectedEndDate
                                        .isBefore(selectedStartDate)) {
                                  errorMessage =
                                      "End date cannot be earlier than the start date which is ${DateFormat('dd/MM/yyyy').format(selectedStartDate)}.";
                                } else {
                                  // Clear the error message and proceed if no errors
                                  errorMessage = "";
                                  // Add your proceed logic here
                                }
                              });
                              if (isButtonEnabled && errorMessage == "") {
                                controller.updateCard(
                                  currentListItem: widget.currentListItem,
                                  currentCheckList: widget.currentCheckList,
                                  cardModel: widget.cardModel,
                                  board: widget.board,
                                  listItemStartDate:
                                      controllerStartDate!.text.isNotEmpty
                                          ? controllerStartDate?.text
                                          : null,
                                  listItemEndDate:
                                      controllerEndDate!.text.isNotEmpty
                                          ? controllerEndDate!.text
                                          : null,
                                  listItemStartTime:
                                      controllerStartTime!.text.isNotEmpty
                                          ? controllerStartTime!.text
                                          : null,
                                  listItemEndTime:
                                      controllerEndTime!.text.isNotEmpty
                                          ? controllerEndTime!.text
                                          : null,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isButtonEnabled
                                  ? AppColors.signOut
                                  : AppColors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              minimumSize: Size(0.13.h, 0.05.h),
                            ),
                            child: Text(
                              'Add'.tr,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize026.h,
                                fontWeight: FontWeight.w500,
                                height: 2,
                                color: AppColors.textButton,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Method to update the selected date based on the selected index
  void _updateSelectedDate() {
    if (selectedDate.isNotEmpty && selectedDate.first != null) {
      DateTime date = selectedDate.first!;
      String formattedDate = _formatDate(date);

      if (_selectedIndex == 0) {
        // Update the start date controller
        controllerStartDate?.text = formattedDate;

        // Translate and update the Arabic start date controller
        controllerStartDateArabic?.text = translateDateTask(formattedDate);
      } else if (_selectedIndex == 1) {
        // Update the end date controller
        controllerEndDate?.text = formattedDate;

        // Translate and update the Arabic end date controller
        controllerEndDateArabic?.text = translateDateTask(formattedDate);
      }
    }
  }

  // Method to format date to string
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
