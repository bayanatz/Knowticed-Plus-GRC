/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_time_picker.dart
/// Purpose: THE time picker of the app — a scroll wheel (hour / minute /
///          AM-PM drums) in a dialog with Cancel and Set Time.
/// Author: Knowticed Plus team
/// Created at: 22/10/2026
///
/// WHY THIS EXISTS
/// ---------------
/// Owner, 22/10/2026: "remove this thing, I don't want to see it" — Flutter's
/// round clock-face picker (`showTimePicker`). It was called from 16 places
/// (To-Do, Time Tracker, Knowledge Hub, Messages, System Logs, Form Builder,
/// CRM, HR). [showKpTimePicker] takes the same arguments and returns the same
/// `TimeOfDay?`, so each call site swaps one name. Do not call
/// `showTimePicker` directly anywhere in the app.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_filter_frame.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Function Name: [showKpTimePicker]
///
/// Purpose: Ask for a time with the scroll wheel.
///
/// Parameters:
///   [BuildContext] context
///   [TimeOfDay] initialTime — where the wheels start.
///   [TransitionBuilder?] builder — accepted so call sites written for
///     `showTimePicker` keep compiling; their theme wrappers were for the
///     clock face and are not applied.
///
/// Return type: [Future<TimeOfDay?>] — null when cancelled.
Future<TimeOfDay?> showKpTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  TransitionBuilder? builder,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (_) => _KpTimePickerDialog(initialTime: initialTime),
  );
}

class _KpTimePickerDialog extends StatefulWidget {
  const _KpTimePickerDialog({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_KpTimePickerDialog> createState() => _KpTimePickerDialogState();
}

class _KpTimePickerDialogState extends State<_KpTimePickerDialog> {
  late TimeOfDay _time = widget.initialTime;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 22/10/2026 — Owner: the same header as every other dialog
              // (icon in the yellow circle + title).
              CustomDialogHeader(
                title: S.of(context).setTime,
                icon: AppAssets.timeSelectorIcon,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: StyleText.fontSize20Weight500
                          .copyWith(color: AppColors.secondaryBlack),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                        now.year, now.month, now.day, _time.hour, _time.minute),
                    onDateTimeChanged: (DateTime t) =>
                        _time = TimeOfDay(hour: t.hour, minute: t.minute),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                // X-73: Cancel left, action right in both languages.
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  Expanded(
                    child: customButton(
                      title: S.of(context).Cancel,
                      color: AppColors.darkerGrey,
                      function: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: customButton(
                      title: S.of(context).setTime,
                      color: AppColors.primary,
                      function: () => Navigator.of(context).pop(_time),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
