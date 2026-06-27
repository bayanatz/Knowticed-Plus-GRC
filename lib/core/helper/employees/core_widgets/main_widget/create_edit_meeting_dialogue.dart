// Date Created :22/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :22/November/2023
// Objectives: this is a widget to customize create,edit,reschedule.cancel  meeting dialogues in meetings  screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/employees/core_widgets/calender_package/src/models/calendar_date_picker2_config.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/date_picker_class.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';
import 'package:demo_app/core/helper/employees/core_widgets/dialogs/response_dialog.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/column_request_data.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/filters_appbar.dart';
import 'package:demo_app/core/enums/enum.dart';

import 'package:demo_app/core/helper/main_helper/haptic_controller.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_font_size.dart';



class CreateEditMeetingDialouge extends StatefulWidget {
  const CreateEditMeetingDialouge(
      {super.key,
      required this.title,
      required this.iconUrl,
      this.isCancel = false,
      this.isReschedule = false});

  final String title;
  final String iconUrl;
  final bool? isReschedule;
  final bool? isCancel;

  @override
  State<CreateEditMeetingDialouge> createState() =>
      _CreateEditMeetingDialougeState();
}

class _CreateEditMeetingDialougeState extends State<CreateEditMeetingDialouge> {
  String? repeatValue;
  String? notifyValue;
  final HapticController hapticController = Get.put(HapticController());
  DateTime? selectedDate;
  List<DateTime?> _rangeDatePickerValueWithDefaultValue = [];
  Future<void> _selectDate(BuildContext context) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        _rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        CalendarDatePicker2Type.single);
    // change the selected the  with the picked date
    // ignore: unrelated_type_equality_checks
    if (picked != null && picked != selectedDate) {
      setState(() {
        _rangeDatePickerValueWithDefaultValue = picked;
        selectedDate = picked[
            0]; // get the first element in the array which is the selected date
        // final DateFormat formatter = DateFormat('dd/MM/yyyy');
        // String formattedDate = formatter.format(picked[0] as DateTime);
        // String formattedDate2 = formatter.format(picked.last as DateTime);
        hintDate =
            "${picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${picked[0]!.year}";
        // widget.dateValueState(widget.dateValue);
      });
    }
  }

  String hintDate = "DD/MM/YYYY";
  TextEditingController titleCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
          horizontal: isTablet
              ? isPortrait
                  ? 0.155.w
                  : 0.16.w
              : 0.02.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        height: widget.isReschedule == true
            ? isTablet
                ?isPortrait?0.4.h :0.45.h
                : 0.5.h
            : widget.isCancel == true
                ? isTablet
                    ? isPortrait?0.29.h :0.45.h
                    : 0.42.h
                : isPortrait?0.46.h :0.57.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.02.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: isPortrait ? 0.01.h : 0.02.h),
                  child: FiltersAppBar(
                    imageUrl: widget.iconUrl,
                    title: widget.title,
                  ),
                ),
                widget.isReschedule == true || widget.isCancel == true
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal:isPortrait?0: 0.02.w),
                        child: ColumnRequestData(
                          title: "${'Why'.tr} ${widget.title.tr} ${'?'.tr}",
                          isTextField: true,
                          hint: "Enter your reason",
                          isOptional: false,
                          isExpanded: true,
                          fillColor:
                              Theme.of(context).colorScheme.inversePrimary,
                          hasSuffix: true,
                          suffixUrl: "assets/images/closefield.svg",
                          maxlength: 120,
                                       isDescription: true,

                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 0.31.w,
                            child: ColumnRequestData(
                              title: Get.locale.toString().contains('en')
                                  ? "${'Meeting'.tr} ${'Name'.tr}"
                                  : "${'Name'.tr} ${'Meeting'.tr} ",
                              isTextField: true,
                              hint: "${'Meeting'.tr} ${'title'.tr}",
                              isOptional: false,
                              textController: titleCont,
                              isExpanded: true,
                              fillColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              hasPrefix: true,
                              hasSuffix: true,
                              suffixUrl: "assets/images/closefield.svg",
                            ),
                          ),
                          SizedBox(
                            width: 0.31.w,
                            child: ColumnRequestData(
                              title: "Description",
                              isTextField: true,
                              hint: Get.locale.toString().contains('en')
                                  ? "Meeting Description"
                                  : "${'Description'.tr} ${'Meeting'.tr} ",
                              isOptional: false,
                              isExpanded: true,
                              hasSuffix: true,
                              fillColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              hasPrefix: true,
                              suffixUrl: "assets/images/closefield.svg",
                            ),
                          ),
                        ],
                      ),
                widget.isCancel == true
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: 0.01.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: SizedBox(
                                width: isTablet
                                    ? isPortrait
                                        ? widget.isReschedule==true?0.315.w :0.21.w
                                        : 0.3
                                    : 0.6.w,
                                child: ColumnRequestData(
                                  title: "Date",
                                  isTextField: true,
                                  enabled: false,
                                  hint: hintDate,
                                  isOptional: false,
                                  isExpanded: isTablet ? true : true,
                                  fillColor: isTablet
                                      ? Theme.of(context)
                                          .colorScheme
                                          .inversePrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                  hasSuffix: true,
                                  suffixUrl: "assets/icons/newCalenderFixed.svg",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: isTablet
                                  ? isPortrait
                                      ?widget.isReschedule==true?0.315.w :0.21.w
                                      : null
                                  : 0.42.w,
                              child: ColumnRequestData(
                                title: "Time",
                                isTextField: true,
                                hint: "00:00 ${'To'.tr} 00:00",
                                isOptional: false,
                                fillColor: isTablet
                                    ? Theme.of(context)
                                        .colorScheme
                                        .inversePrimary
                                    : Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                isExpanded: isTablet ? true : true,
                                hasSuffix: true,
                                suffixUrl: "assets/images/circle_icon.svg",
                              ),
                            ),
                            widget.isReschedule == true
                                ? Container(
                                    width: isTablet ? 0.0.w : 0,
                                  )
                                : ColumnRequestData(
                                    title: "Repeat",
                                    isTextField: false,
                                    hint: "Weekly",
                                    isOptional: false,
                                    isExpanded: false,
                                    hasSuffix: true,
                                    dropDownItems: const ['Weekly', 'Monthly'],
                                    dropdownValue: repeatValue,
                                    dropDownValueState: (value) {
                                      setState(() {
                                        repeatValue = value;
                                      });
                                    },
                                  )
                          ],
                        ),
                      ),
                widget.isCancel == true || widget.isReschedule == true
                    ? const SizedBox.shrink()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 0.42.w,
                            child: ColumnRequestData(
                              title: "Invite Member",
                              isTextField: true,
                              hint: "Invite Member",
                              isOptional: false,
                              hasPrefix: true,
                              fillColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              isExpanded: true,
                              hasSuffix: true,
                              suffixUrl: "assets/images/closefield.svg",
                            ),
                          ),
                          ColumnRequestData(
                            title: "Notify Me",
                            isTextField: false,
                            hint: "1 H Before",
                            isOptional: false,
                            isExpanded: false,
                            hasSuffix: true,
                            dropDownItems: ["1 H Before".tr, "2 H Before".tr],
                            dropdownValue: notifyValue,
                            dropDownValueState: (value) {
                              setState(() {
                                notifyValue = value;
                              });
                            },
                          )
                        ],
                      ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 0.025.h, left: 0.02.w, right: 0.02.w),
                  child: MainCustomIconButton(
                    isDisabled: titleCont.text != '' ||
                            hintDate != "DD/MM/YYYY" ||
                            repeatValue != null
                        ? false
                        : true,
                    onPressed: titleCont.text != '' ||
                            hintDate != "DD/MM/YYYY" ||
                            repeatValue != null
                        ? () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ResponseDialog(
                                  title: "Successful",
                                  subtitle: widget.isReschedule == true
                                      ? "${'Meeting'.tr} ${'Rescheduled'.tr} ${'And'.tr} ${'Send Notifications'.tr}"
                                      : widget.isCancel == true
                                          ? "${'Meeting'.tr} ${'Cancelled'.tr} ${'And'.tr} ${'Send Notifications'.tr}"
                                          : "${'Meeting'.tr} ${'Created'.tr} ${'And'.tr} ${'Send Notifications'.tr}",
                                  lottieAsset: "assets/images/correct.json",
                                );
                              },
                            );
                          }
                        : () {},
                    buttonText:
                        "${widget.title.tr} ${'And'.tr} ${'Send Notifications'.tr}",
                 
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
