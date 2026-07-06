// Date Created :3/April/2024
// Developer Name : Abdullah Ibarhim
//App Version : Version 2
// Objectives: this is a widget to customize create,edit, card deadline
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/date_picker_class.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';

/// Date Created :17/April/2024
/// Developer Name : Abdullah Ibrahim
/// App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
/// Objectives: represents the add edit card deadline dialog
///
class AddEditCardDeadlineDialouge extends StatefulWidget {
  const AddEditCardDeadlineDialouge({
    super.key,
    required this.title,
    required this.onPressed,
    required this.iconUrl,
    this.isEditDates = false,
    this.board,
    this.cardModel,
  });

  final String title;
  final String iconUrl;
  final bool? isEditDates;
  final String? board;
  final CardModel? cardModel;
  final void Function() onPressed;
  @override
  State<AddEditCardDeadlineDialouge> createState() =>
      _AddEditCardDeadlineDialougeState();
}

class _AddEditCardDeadlineDialougeState
    extends State<AddEditCardDeadlineDialouge> {
  TaskDetailsController taskController = Get.find();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final HapticController hapticController = Get.put(HapticController());
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String hintStartDate = "DD/MM/YYYY";
  String hintEndDate = "DD/MM/YYYY";
  String hintStartTime = "12:00 AM";
  String hintEndTime = "12:00 AM";

  late TextEditingController controllerStartTime = TextEditingController();
  late TextEditingController controllerEndTime = TextEditingController();
  late TextEditingController controllerStartDate = TextEditingController();
  late TextEditingController controllerEndDate = TextEditingController();

  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];
  Future<void> _selectDate(
    BuildContext context,
  ) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        _rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        null, //DateTime.now(),
        CalendarDatePicker2Type.range);

    if (picked != null &&
        picked != selectedStartDate &&
        picked != selectedEndDate) {
      setState(() {
        _rangeDatePickerValueWithDefaultValue = picked;
        if (picked.isNotEmpty) {
          selectedStartDate = picked[0];
          hintStartDate =
              "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
        }
        if (picked.length > 1) {
          selectedEndDate = picked[1];
          hintEndDate =
              "${picked[1]!.day} ${DateFormat.MMM().format(picked[1]!)} ${picked[1]!.year}";
        }
      });
    }
  }

  List<DateTime?> _rangeStartDatePickerValueWithDefaultValue = [];
  List<DateTime?> _rangeEndDatePickerValueWithDefaultValue = [];
  Future<void> _selectStartDate(BuildContext context) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        _rangeStartDatePickerValueWithDefaultValue,
        DateTime.now(),
        null,
        CalendarDatePicker2Type.single);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null && picked != selectedStartDate) {
      setState(() {
        _rangeStartDatePickerValueWithDefaultValue = picked;
        selectedStartDate = picked[
            0]; // get the first element in the array which is the selected date
        hintStartDate =
            "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
      });
    }
  }

  Future<void> _selectEndDate(
    BuildContext context,
  ) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        _rangeEndDatePickerValueWithDefaultValue,
        DateTime.now(),
        null,
        CalendarDatePicker2Type.single);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        _rangeEndDatePickerValueWithDefaultValue = picked;
        selectedEndDate = picked[0];
        hintEndDate =
            "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
      });
    }
  }

  @override
  void initState() {
    if (widget.isEditDates == true) {
      _rangeDatePickerValueWithDefaultValue = [
        DateTime.parse(widget.cardModel!.startDate!.startDate!.last.toString()),
        DateTime.parse(widget.cardModel!.endDate!.endDate!.last.toString()),
      ];
      hintStartDate = DateFormat("dd/MM/yyyy").format(DateTime.parse(
          widget.cardModel!.startDate!.startDate!.last.toString()));
      hintEndDate = DateFormat("dd/MM/yyyy").format(
          DateTime.parse(widget.cardModel!.endDate!.endDate!.last.toString()));
      hintEndTime = widget.cardModel!.endTime!.endTime!.last.toString();
      hintStartTime = widget.cardModel!.startTime!.startTime!.last.toString();
    }
    controllerStartTime = TextEditingController();
    controllerEndTime = TextEditingController();
    controllerStartDate = TextEditingController();
    controllerEndDate = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controllerStartTime =
        TextEditingController(text: startTime?.format(context));
    controllerEndTime = TextEditingController(text: endTime?.format(context));
    controllerStartDate = TextEditingController(text: hintStartDate);
    controllerEndDate = TextEditingController(text: hintEndDate);

    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Dialog(
          insetPadding:
              EdgeInsets.symmetric(horizontal: isTablet ? 0.33.w : 0.04.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            height: isTablet ? 0.41.h : 0.315.h,
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isTablet ? 0.015.w : 0.04.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.01.h),
                      child: CustomRowWithIcons(
                        iconPath: widget.iconUrl,
                        title: widget.title.tr,
                        hideDelete: true,
                        onArrowPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  widget.isEditDates == true
                                      ? _selectStartDate(
                                          context,
                                        )
                                      : _selectDate(context);
                                  /*
                                  _selectStartDate(
                                    context,
                                  ).then((value) => print(hintStartDate));
                                  */
                                },
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "Start Date",
                                  isTextField: true,
                                  hint: hintStartDate,
                                  isOptional: false,
                                  enabled: false,
                                  isExpanded: true,
                                  hasPrefix: true,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTablet ? 0.03.h : 0.04.w,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Select Time".tr,
                                            style: AppFontStyle
                                                .cairoRegularStyle
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onInverseSurface,
                                              fontWeight: FontWeight.w800,
                                              fontSize:
                                                  FontConstants.fontSize025.h,
                                            )),
                                        content: SizedBox(
                                          height: 0.15.h,
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.time,
                                            initialDateTime: DateTime.now(),
                                            onDateTimeChanged:
                                                (DateTime newDateTime) {
                                              setState(() {
                                                startTime =
                                                    TimeOfDay.fromDateTime(
                                                        newDateTime);
                                              });
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              print(startTime);
                                            },
                                            child: Text('OK',
                                                style: AppFontStyle
                                                    .cairoRegularStyle
                                                    .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: FontConstants
                                                      .fontSize020.h,
                                                )),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "",
                                  isTextField: true,
                                  textController: controllerStartTime,
                                  hint: hintStartTime,
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
                          height: 0.015.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  widget.isEditDates == true
                                      ? _selectEndDate(
                                          context,
                                        )
                                      : _selectDate(context);
                                  /*
                                  _selectEndDate(
                                    context,
                                  ).then((value) {
                                    print(hintEndDate);
                                  });
                                  */
                                },
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "End Date",
                                  isTextField: true,
                                  hint: hintEndDate,
                                  enabled: false,
                                  isOptional: false,
                                  isExpanded: true,
                                  // textController: ,
                                  hasPrefix: true,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTablet ? 0.03.h : 0.04.w,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Select Time".tr,
                                            style: AppFontStyle
                                                .cairoRegularStyle
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onInverseSurface,
                                              fontWeight: FontWeight.w800,
                                              fontSize:
                                                  FontConstants.fontSize025.h,
                                            )),
                                        content: SizedBox(
                                          height: 0.15.h,
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.time,
                                            initialDateTime: DateTime.now(),
                                            onDateTimeChanged:
                                                (DateTime newDateTime) {
                                              setState(() {
                                                endTime =
                                                    TimeOfDay.fromDateTime(
                                                        newDateTime);
                                              });
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              print(endTime);
                                            },
                                            child: Text('OK',
                                                style: AppFontStyle
                                                    .cairoRegularStyle
                                                    .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: FontConstants
                                                      .fontSize020.h,
                                                )),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: ColumnRequestData(
                                  fillColor: Colors.transparent,
                                  title: "",
                                  isTextField: true,
                                  hint: hintEndTime,
                                  isOptional: false,
                                  textController: controllerEndTime,
                                  isExpanded: true,
                                  hasPrefix: true,
                                  enabled: false,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons_assets/task_assets/ClockCircleIcon.svg",
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.02.h),
                      child: Padding(
                        padding: EdgeInsets.only(top: 0.0.h),
                        child: ReusableElevatedButton(
                          buttonText:
                              widget.isEditDates == true ? "Save".tr : 'Add'.tr,
                          onPressed: () async {
                            widget.onPressed();
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);

                            if (widget.isEditDates == true) {
                              if (startTime != null ||
                                  endTime != null ||
                                  selectedStartDate != null ||
                                  selectedEndDate != null) {
                                await controller
                                    .updateCard(
                                  cardModel: widget.cardModel!,
                                  board: widget.board!,
                                  startTime: startTime?.format(context),
                                  endTime: endTime?.format(context),
                                  startDate: selectedStartDate?.toString(),
                                  endDate: selectedEndDate?.toString(),
                                )
                                    .then((value) {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SuccessDialog(
                                        title: "Successful".tr,
                                        subtitle: widget.isEditDates == false
                                            ? "Task deadlines are set successfully"
                                                .tr
                                            : "Task deadlines are updated successfully"
                                                .tr,
                                        lottieAsset:
                                            "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                      );
                                    },
                                  );
                                });
                              }
                            } else {
                              if (startTime != null &&
                                  endTime != null &&
                                  selectedStartDate != null &&
                                  selectedEndDate != null) {
                                await controller
                                    .updateCard(
                                  cardModel: widget.cardModel!,
                                  board: widget.board!,
                                  startTime: startTime?.format(context),
                                  endTime: endTime?.format(context),
                                  startDate: selectedStartDate?.toString(),
                                  endDate: selectedEndDate?.toString(),
                                )
                                    .then(
                                  (value) {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SuccessDialog(
                                          title: "Successful".tr,
                                          subtitle: widget.isEditDates == false
                                              ? "Task deadlines are set successfully"
                                                  .tr
                                              : "Task deadlines are updated successfully"
                                                  .tr,
                                          lottieAsset:
                                              "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const SuccessDialog(
                                      title: "Failure",
                                      subtitle: "Please Fill All The Fields",
                                      lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                    );
                                  },
                                );
                              }
                            }

                            setState(() {});
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controllerStartTime.dispose();
    controllerEndTime.dispose();
    controllerStartDate.dispose();
    controllerEndDate.dispose();

    super.dispose();
  }
}
