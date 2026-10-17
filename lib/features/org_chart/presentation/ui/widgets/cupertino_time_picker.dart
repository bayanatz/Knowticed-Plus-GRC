import 'package:grc_module/core/extensions/context_extensions.dart'
    show kpIsPhoneLayout;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grc_module/core/custom/buttons/custom_button.dart';
import 'package:grc_module/core/extensions/screen_fraction_extension.dart';
import 'package:grc_module/core/theme/app_colors.dart';
import 'package:grc_module/generated/l10n.dart';

class CupertinoTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeChanged;

  const CupertinoTimePicker({
    super.key,
    required this.onDateTimeChanged,
  });

  @override
  State<CupertinoTimePicker> createState() => _CupertinoTimePickerState();
}

class _CupertinoTimePickerState extends State<CupertinoTimePicker> {
  TimeOfDay endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    !kpIsPhoneLayout(context);
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
              textDirection: TextDirection
                  .ltr, // X-73: Cancel left, action right in both languages

              // direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: customButton(
                    title: S.of(context).Cancel,
                    color: AppColors.darkerGrey,
                    function: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Container(width: 0.025.w),
                Expanded(
                  child: customButton(
                    title: S.of(context).setTime,
                    color: AppColors.primary,
                    function: () {
                      setState(() {
                        widget.onDateTimeChanged;
                      });

                      Navigator.of(context).pop();
                    },
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
