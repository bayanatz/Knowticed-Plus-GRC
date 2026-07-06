// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
/// Date of Last Edit :23/April/2024 By Abdullah Ibrahim
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/success_dialog.dart';
import 'package:demo_app/core/theme/app_font_size.dart';import 'package:demo_app/core/helper/task_management_module/task/controller/task_details_controller.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/board_model/board_model.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_checklists.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

import 'package:demo_app/core/helper/task_management_module/core/constant/enum.dart';
import 'package:demo_app/core/haptic/haptic_controller.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/calendar_components.dart/date_picker_class.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_create_task_container.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/main_yellow_button.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tasks_components/custom_container_header_mobile.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/tracking_time_components/track_time_subwidget/column_request_data.dart';

class CopyCardDialouge extends StatefulWidget {
  CopyCardDialouge({
    super.key,
    required this.title,
    required this.onPressed,
    required this.iconUrl,
    this.textController,
    this.isMove = false,
    this.isCheckList = false,
    this.isAttachment = false,
    this.isDates = false,
    this.isCard = false,
    this.isEditCheckList = false,
    this.isReschedule = false,
    this.board,
    this.department,
    this.isCreatingCard,
    this.cardModel,
    this.boardModel,
    this.currentCheckList,
  });

  final String title;
  final String iconUrl;
  final bool? isReschedule;
  final bool? isMove;
  final bool? isCheckList;
  final bool? isAttachment;
  final bool? isDates;
  final bool? isCard;
  final bool? isCreatingCard;
  final bool? isEditCheckList;
  final String? board;
  final String? department;
  BoardModel? boardModel;
  final CardModel? cardModel;
  final void Function() onPressed;
  final CardCheckLists? currentCheckList;
  TextEditingController? textController;
  @override
  State<CopyCardDialouge> createState() => _CopyCardDialougeState();
}

class _CopyCardDialougeState extends State<CopyCardDialouge> {
  String? listValue;
  String? notifyValue;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final HapticController hapticController = Get.put(HapticController());
  final TaskDetailsController taskController = Get.put(TaskDetailsController());

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;

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
        // final DateFormat formatter = DateFormat('dd/MM/yyyy');
        // String formattedDate = formatter.format(picked[0] as DateTime);
        // String formattedDate2 = formatter.format(picked.last as DateTime);
        hintStartDate =
            "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
        // widget.dateValueState(widget.dateValue);
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

  String hintStartDate = "DD/MM/YYYY";
  String hintEndDate = "DD/MM/YYYY";

  TextEditingController titleCont = TextEditingController();
  TextEditingController controllerStartTime = TextEditingController();
  TextEditingController controllerEndTime = TextEditingController();
  TextEditingController controllerStartDate = TextEditingController();
  TextEditingController controllerEndDate = TextEditingController();

  @override
  void initState() {
    taskController.fileName = null;
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
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return GetBuilder<TaskDetailsController>(
      builder: (controller) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? (orientation ? 0.12.w : 0.33.w) : 0.04.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            height: widget.isDates == true
                ? isTablet
                    ? (orientation ? 0.33.h : 0.41.h)
                    : 0.315.h
                : widget.isCard == true
                    ? 0.59.h
                    : isTablet
                        ? (orientation ? 0.23.h : 0.29.h)
                        : 0.23.h,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      isTablet ? (orientation ? 0.025.w : 0.015.w) : 0.04.w),
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
                    widget.isMove == true
                        ? ColumnRequestData(
                            fillColor: Colors.transparent,
                            title: "Choose list to move the card to",
                            isTextField: false,
                            hint: "Choose List",
                            isOptional: false,
                            isExpanded: true,
                            hasSuffix: true,
                            buttonWidth: isTablet
                                ? (orientation ? 0.55.w : 0.55.h)
                                : 0.84.w,
                            dropWidth: isTablet
                                ? (orientation ? 0.5.w : 0.52.h)
                                : 0.84.w,
                            dropDownItems: ['To Do'.tr, 'Doing'.tr, "Done".tr],
                            dropdownValue: listValue,
                            dropDownValueState: (value) {
                              setState(() {
                                listValue = value;
                              });
                            },
                          )
                        : widget.isDates == true
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _selectStartDate(
                                              context,
                                            ).then((value) =>
                                                print(hintStartDate));
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
                                            suffixUrl:
                                                "assets/icons_assets/main_icons_assets/calendar2.svg",
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
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: FontConstants
                                                            .fontSize025.h,
                                                      )),
                                                  content: SizedBox(
                                                    height: 0.15.h,
                                                    child: CupertinoDatePicker(
                                                      mode:
                                                          CupertinoDatePickerMode
                                                              .time,
                                                      initialDateTime:
                                                          DateTime.now(),
                                                      onDateTimeChanged:
                                                          (DateTime
                                                              newDateTime) {
                                                        setState(() {
                                                          startTime = TimeOfDay
                                                              .fromDateTime(
                                                                  newDateTime);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        print(startTime);
                                                      },
                                                      child: Text('OK',
                                                          style: AppFontStyle
                                                              .cairoRegularStyle
                                                              .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize:
                                                                FontConstants
                                                                    .fontSize020
                                                                    .h,
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
                                            hint: "12:00 PM",
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
                                  SizedBox(
                                    height: 0.015.h,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            _selectEndDate(
                                              context,
                                            ).then((value) {
                                              print(hintEndDate);
                                            });
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
                                            suffixUrl:
                                                "assets/icons_assets/main_icons_assets/calendar2.svg",
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
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: FontConstants
                                                            .fontSize025.h,
                                                      )),
                                                  content: SizedBox(
                                                    height: 0.15.h,
                                                    child: CupertinoDatePicker(
                                                      mode:
                                                          CupertinoDatePickerMode
                                                              .time,
                                                      initialDateTime:
                                                          DateTime.now(),
                                                      onDateTimeChanged:
                                                          (DateTime
                                                              newDateTime) {
                                                        setState(() {
                                                          endTime = TimeOfDay
                                                              .fromDateTime(
                                                                  newDateTime);
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        print(endTime);
                                                      },
                                                      child: Text('OK',
                                                          style: AppFontStyle
                                                              .cairoRegularStyle
                                                              .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize:
                                                                FontConstants
                                                                    .fontSize020
                                                                    .h,
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
                                            hint: "12:00 PM",
                                            isOptional: false,
                                            textController: controllerEndTime,
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
                                  )
                                ],
                              )
                            : widget.isCard == true
                                ? CustomCreateTaskContainer(
                                    isProject: false,
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    currentBoardName:
                                        GetUtils.capitalize(widget.board!)!,
                                    /* currentBoardName: GetUtils.capitalize(widget
                                        .boardModel!
                                        .boardName!
                                        .boardgName!
                                        .last)!,*/
                                  )
                                : Stack(
                                    children: [
                                      Column(
                                        children: [
                                          ColumnRequestData(
                                            fillColor: Colors.transparent,
                                            title: widget.isCheckList == true
                                                ? "List Name".tr
                                                : widget.isAttachment == true
                                                    ? "Choose Attachment".tr
                                                    : "Name".tr,
                                            isTextField: true,
                                            textController:
                                                widget.textController,
                                            hint: widget.isAttachment == true
                                                ? controller.fileName ??
                                                    "Click Here".tr
                                                : "Text Here".tr,
                                            isOptional: false,
                                            isExpanded: true,
                                            readOnly:
                                                widget.isAttachment == true
                                                    ? true
                                                    : false,
                                          ),
                                        ],
                                      ),
                                      if (widget.isAttachment == true)
                                        Positioned(
                                          top: 0.029.h,
                                          left: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              print("sasa ${widget.board},${widget.department}");
                                              controller.pickAndUploadFile(
                                                  boardName: widget.board!,
                                                  department: widget.department!,
                                                  cardName: widget.cardModel!.cardName!.cardName!.last,
                                                  taskID: widget.cardModel!.cardId!,
                                                  isBoardAsset: false);

                                              // controller.pickAndUploadFile(
                                              //
                                              //    widget.cardModel!.cardName!
                                              //        .cardName!.last);
                                            },
                                            child: Container(
                                              height: 0.045.h,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                color: Colors.transparent,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                    if (widget.isCreatingCard == null ||
                        widget.isCreatingCard != true)
                      Padding(
                        padding: EdgeInsets.only(top: 0.02.h),
                        child: Padding(
                          padding: EdgeInsets.only(top: 0.0.h),
                          child: ReusableElevatedButton(
                            buttonText: widget.isMove == true
                                ? "Move Card".tr
                                : widget.isCheckList == true
                                    ? "Add".tr
                                    : widget.isAttachment == true
                                        ? "Add".tr
                                        : widget.isDates == true
                                            ? "Add".tr
                                            : widget.isEditCheckList == true
                                                ? 'Save'.tr
                                                : 'Create'.tr,
                            onPressed: () async {
                              widget.onPressed();
                              hapticController.triggerHapticFeedback(
                                  vibration: VibrateType.heavyImpact,
                                  hapticFeedback: HapticFeedback.heavyImpact);

                              if (widget.isDates == true) {
                                if (startTime != null &&
                                    endTime != null &&
                                    selectedStartDate != null &&
                                    selectedEndDate != null) {
                                  await controller.updateCard(
                                    cardModel: widget.cardModel!,
                                    board: widget.board!,
                                    startTime: startTime?.format(context),
                                    endTime: endTime?.format(context),
                                    startDate: selectedStartDate?.toString(),
                                    endDate: selectedEndDate?.toString(),
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

                              if (widget.isCheckList == true &&
                                  widget.textController!.text.isNotEmpty) {
                                await controller.updateCard(
                                  currentCheckList: widget.currentCheckList,
                                  cardModel: widget.cardModel!,
                                  board: widget.board!,
                                  checkList: widget.textController!.text,
                                );
                              }
                              if (widget.isEditCheckList == true &&
                                  widget.textController!.text.isNotEmpty) {
                                await controller.updateCard(
                                  cardModel: widget.cardModel!,
                                  board: widget.board!,
                                  currentCheckList: widget.currentCheckList,
                                  checkList: widget.textController!.text,
                                );
                              }
                              if (widget.isAttachment == true) {
                                await controller.updateCard(
                                  cardModel: widget.cardModel!,
                                  board: widget.board!,
                                  attachment: "attached",
                                );
                              }

                              if (widget.isMove == true) {
                                if (listValue != null) {
                                  await controller.updateCard(
                                    cardModel: widget.cardModel!,
                                    board: widget.board!,
                                    boardModel: widget.boardModel!,
                                    cardStatus: listValue == "To Do"
                                        ? "todo"
                                        : listValue!.toLowerCase(),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const SuccessDialog(
                                        title: "Failure",
                                        subtitle: "Please select a list",
                                        lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
                                      );
                                    },
                                  );
                                }
                              }

                              if (listValue != null &&
                                  startTime == null &&
                                  endTime == null &&
                                  selectedStartDate == null &&
                                  selectedEndDate == null &&
                                  widget.isDates != true) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SuccessDialog(
                                      title: "Successful".tr,
                                      subtitle: widget.isMove == true
                                          ? "Card Moved Successfully".tr
                                          : widget.isCheckList == true
                                              ? "${"Checklist".tr} ${widget.textController!.text.capitalize} ${"Added Successfuly".tr}"
                                              : widget.isAttachment == true
                                                  ? "Attachment Added Successfuly"
                                                      .tr
                                                  : widget.isDates == true
                                                      ? "Task deadlines are set successfully"
                                                          .tr
                                                          .tr
                                                      : widget.isEditCheckList ==
                                                              true
                                                          ? "${"Checklist".tr} ${widget.textController!.text.capitalize} ${"Updated Successfuly".tr}"
                                                          : "Card Created Successfully"
                                                              .tr,
                                      lottieAsset: "assets/lottie_assets/main_lottie_assets/lottie_successful.json",
                                    );
                                  },
                                );
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
    controllerStartDate.dispose();
    controllerEndDate.dispose();
    controllerStartTime.dispose();
    controllerEndTime.dispose();
    titleCont.dispose();
    super.dispose();
  }
}
