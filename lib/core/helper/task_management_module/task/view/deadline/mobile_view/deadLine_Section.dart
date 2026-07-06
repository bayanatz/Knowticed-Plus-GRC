import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/date_picker_class.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/dialogs/add_edit_card_deadline_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/set_date_dialog.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/app_strings.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/image_paths.dart';
import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/view/deadline/mobile_view/date_item.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';

class DeadlineSection extends StatefulWidget {
  DeadlineSection({
    super.key,
    required this.cardModel,
    required this.board,
    required this.toggleShowMembers,
    this.isEditDates = false,
  });
  final bool? isEditDates;
  final CardModel cardModel;
  final String board;
  final VoidCallback toggleShowMembers;

  @override
  State<DeadlineSection> createState() => _DeadlineSectionState();
}

class _DeadlineSectionState extends State<DeadlineSection> {
  final TaskDetailsController controller = Get.find();

  final HapticController hapticController = Get.put(HapticController());



  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  late TextEditingController controllerStartTime = TextEditingController();
  late TextEditingController controllerEndTime = TextEditingController();
  late TextEditingController controllerStartDate = TextEditingController();
  late TextEditingController controllerEndDate = TextEditingController();


  List<DateTime?> _rangeEndDatePickerValueWithDefaultValue = [];

  List<DateTime?> _rangeStartDatePickerValueWithDefaultValue = [];
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];

  String hintStartDate = "DD/MM/YYYY";
  String hintEndDate = "DD/MM/YYYY";
  String hintStartTime = "12:00 AM";
  String hintEndTime = "12:00 AM";
  @override

  void initState() {
    if (true) {
      _rangeDatePickerValueWithDefaultValue = [
        DateTime.parse(widget.cardModel.startDate!.startDate!.last.toString()),
        DateTime.parse(widget.cardModel.endDate!.endDate!.last.toString()),
      ];
      hintStartDate = DateFormat("dd/MM/yyyy").format(DateTime.parse(
          widget.cardModel.startDate!.startDate!.last.toString()));
      hintEndDate = DateFormat("dd/MM/yyyy").format(
          DateTime.parse(widget.cardModel.endDate!.endDate!.last.toString()));
      hintEndTime = widget.cardModel.endTime!.endTime!.last.toString();
      hintStartTime = widget.cardModel.startTime!.startTime!.last.toString();
    }
    controllerStartTime = TextEditingController();
    controllerEndTime = TextEditingController();
    controllerStartDate = TextEditingController();
    controllerEndDate = TextEditingController();

    super.initState();
  }
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
  void dispose() {
    controllerStartTime.dispose();
    controllerEndTime.dispose();
    controllerStartDate.dispose();
    controllerEndDate.dispose();

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    controllerStartTime =
        TextEditingController(text: startTime?.format(context));
    controllerEndTime = TextEditingController(text: endTime?.format(context));
    controllerStartDate = TextEditingController(text: hintStartDate);
    controllerEndDate = TextEditingController(text: hintEndDate);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30.sp,
                width: 30.sp,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                padding: EdgeInsets.all(6),
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/icons_calendar.svg",
                    height: 16.h,
                    width: 16.w,
                    color: AppColors.black,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Task Deadline",
                style: AppTextStyles.font16BlackMediumCairo,
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  if (widget.cardModel!.cardCreator!.cardCreator!.last ==
                      Get.find<MainCoreEmployeeController>()
                          .employeeEntity!
                          .email!) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddEditCardDeadlineDialouge(
                          title: "Task Deadline",
                          cardModel: widget.cardModel,
                          board: widget.board,
                          onPressed: () {},
                          isEditDates: true,
                          iconUrl: 'assets/icons_assets/task_assets/taskDeadline.svg',
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const SuccessDialog(
                          title: "Warning",
                          subtitle: "Only Task Owner Can Edit Deadline",
                          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                        );
                      },
                    );
                  }

                  // setState(() {
                  //   _isEditing = !_isEditing;
                  // });

                },
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/isEditIcon.svg',
                  color: AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 26),
          /// Start Date
          GestureDetector(
            onTap: () {
              widget.isEditDates == true
                  ? _selectStartDate(
                context,
              )
                  : _selectDate(context);

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

          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Select Time".tr,
                        style: AppTextStyles
                            .font16BlackRegularCairo
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


          /// End Date
         // Text("End Date", style: AppTextStyles.font14BlackCairoMedium),
          GestureDetector(
            onTap: () {
              widget.isEditDates == true
                  ? _selectEndDate(
                context,
              )
                  : _selectDate(context);
            },
            child: ColumnRequestData(
              fillColor: Colors.transparent,
              title: "End Date",
              isTextField: true,
              hint: hintEndDate,
              enabled: false,
              isOptional: false,
              isExpanded: true,
              textController: controllerEndDate,
              hasPrefix: true,
              hasSuffix: true,
              suffixUrl: "assets/icons_assets/main_icons_assets/calendar2.svg",
            ),
          ),
          SizedBox(height: 4),
          // Obx(() => GestureDetector(
          //   onTap:(){},
          //   child: DateItem(
          //     date: selectedEndDate.value != null
          //         ? DateFormat("dd/MM/yyyy").format(selectedEndDate.value!)
          //         : "Not set",
          //   ),
          // )),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Select Time".tr,
                        style: AppTextStyles
                            .font16BlackRegularCairo
                            .copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onInverseSurface,
                          fontWeight: FontWeight.w800,
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
                            style: AppTextStyles
                                .font16BlackRegularCairo
                                .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  );
                },
              );
            },
            child: ColumnRequestData(
              fillColor: Colors.transparent,
              title: "End Time",
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
          SizedBox(height: 9),
          // End Time
          SizedBox(height: 4),
          // Obx(() => GestureDetector(
          //   onTap: (){},
          //   child: DateItem(
          //     date: selectedEndTime.value != null
          //         ? selectedEndTime.value!.format(context)
          //         : "Not set",
          //   ),
          // )),
        ],
      ),
    );
  }
}
