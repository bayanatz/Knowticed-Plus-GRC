import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/custom_elevated_button.dart';

class CupertinoTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeChanged;

  const CupertinoTimePicker({
    super.key,
    required this.onDateTimeChanged,
  });

  @override
  _CupertinoTimePickerState createState() => _CupertinoTimePickerState();
}

class _CupertinoTimePickerState extends State<CupertinoTimePicker> {
  TimeOfDay endTime = TimeOfDay.now();
  ButtonStyle buttonStyle(Color buttonColor) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return ElevatedButton.styleFrom(
        backgroundColor: buttonColor, //AppColors.bubbleColor,
        minimumSize: isTablet ? Size(0.1.w, 0.053.h) : Size(0.3.w, 0.05.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return AlertDialog(
      content: SizedBox(
        height: 0.15.h,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime.now(),
          onDateTimeChanged: widget.onDateTimeChanged,
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 0.025.h),
          child: SizedBox(
            height: isVertical ? 0.04.h : null,
            child: Row(
              // direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: CustomElevatedButton(
                    buttonStyle: buttonStyle(AppColors.colorGreydark),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    fontSize: isTablet
                        ? (isVertical
                            ? FontConstants.fontSize018.h
                            : FontConstants.fontSize025.h)
                        : FontConstants.fontSize021.h,
                    buttonText: "Cancel".tr,
                    textColor: AppColors.colorBlack,
                    fontweight: FontWeight.w600,
                  ),
                ),
                Container(width: 0.025.w),
                Expanded(
                  child: CustomElevatedButton(
                    buttonStyle: buttonStyle(AppColors.bubbleColor),
                    onPressed: () {
                      setState(() {
                        widget.onDateTimeChanged;
                      });

                      Navigator.of(context).pop();
                    },
                    buttonText: "Set Time".tr,
                    fontSize: isTablet
                        ? (isVertical
                            ? FontConstants.fontSize018.h
                            : FontConstants.fontSize025.h)
                        : FontConstants.fontSize021.h,
                    fontweight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
