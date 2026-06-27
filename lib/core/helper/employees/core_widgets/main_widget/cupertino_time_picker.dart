import 'package:flutter/cupertino.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/employees/core_widgets/buttons/main_custom_icon_button.dart';


import 'package:demo_app/core/theme/app_font_size.dart';

class CupertinoTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeChanged;

  const CupertinoTimePicker({
    Key? key,
    required this.onDateTimeChanged,
  }) : super(key: key);

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
          child: Container(
            height: isVertical ? 0.04.h : null,
            child: Row(
              // direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: MainCustomIconButton(
                    buttonStyle: buttonStyle(AppColors.colorGreydark),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    buttonText: "Cancel".tr,
                  ),
                ),
                Container(width: 0.025.w),
                Expanded(
                  child: MainCustomIconButton(
                    buttonStyle: buttonStyle(AppColors.bubbleColor),
                    onPressed: () {
                      setState(() {
                        widget.onDateTimeChanged;
                      });

                      Navigator.of(context).pop();
                    },
                    buttonText: "Set Time".tr,
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
