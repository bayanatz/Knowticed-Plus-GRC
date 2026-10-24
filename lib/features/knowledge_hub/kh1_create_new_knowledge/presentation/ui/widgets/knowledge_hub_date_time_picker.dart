/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/widgets
/// ************************* FILE INFO *************************** ///
/// File Name: knowledge_hub_date_time_picker.dart
/// Description: Date & time picker helpers for scheduling knowledge publishing.
/// Author: Amr Mesbah
/// Created at: 11/10/2025
library;

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/pickers/custom_time_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/features/knowledge_hub/helpers/kh_log.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Brand-themed wrapper for the native [showTimePicker] dialog.
///
/// - Time display + AM/PM: SELECTED = [AppColors.textButton] on an
///   [AppColors.primary] background; UNSELECTED = [AppColors.text].
/// - Cancel (left) is a grey button, OK (right) is a primary button, so both
///   read as the app's buttons.
Widget themedKnowledgeTimePicker(BuildContext context, Widget? child) {
  WidgetStateColor sel(Color selected, Color unselected) =>
      WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? selected : unselected,
      );

  return Theme(
    data: Theme.of(context).copyWith(
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.card,
        // Big hour : minute display.
        hourMinuteColor: sel(AppColors.primary, AppColors.card),
        hourMinuteTextColor: sel(AppColors.textButton, AppColors.text),
        // AM / PM.
        dayPeriodColor: sel(AppColors.primary, AppColors.card),
        dayPeriodTextColor: sel(AppColors.textButton, AppColors.text),
        dayPeriodBorderSide: BorderSide(color: AppColors.border),
        // Dial.
        dialHandColor: AppColors.primary,
        dialBackgroundColor: AppColors.card,
        dialTextColor: sel(AppColors.textButton, AppColors.text),
        entryModeIconColor: AppColors.text,
        helpTextStyle: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.text,
        ),
        // Action buttons: Cancel (left) grey, OK (right) primary.
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.secondaryButton,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: AppColors.textButton,
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}

class KnowledgeHubDateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final Function(DateTime) onDateSelected;
  final Function(TimeOfDay) onTimeSelected;
  final bool lightMode;

  const KnowledgeHubDateTimePicker({
    super.key,
    required this.label,
    required this.date,
    required this.time,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.blackButton,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _DateField(
                date: date,
                onDateSelected: onDateSelected,
                lightMode: lightMode,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 1,
              child: _TimeField(
                time: time,
                onTimeSelected: onTimeSelected,
                lightMode: lightMode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final Function(DateTime) onDateSelected;
  final bool lightMode;

  const _DateField({
    required this.date,
    required this.onDateSelected,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => _showDatePicker(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.chatBackground,
        ),
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: 8.sp,
          vertical: 10.sp,
        ),
        child: Row(
          children: [
            Text(
              date == null
                  ? S.of(context).khDateHint
                  : DateFormat('dd/MM/yyyy').format(date!),
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const Spacer(),
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_time_calendar.svg',
              height: 16.h,
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
      khLog('Selected date: ${pickedDate.toString()}');
    }
  }
}

class _TimeField extends StatelessWidget {
  final TimeOfDay? time;
  final Function(TimeOfDay) onTimeSelected;
  final bool lightMode;

  const _TimeField({
    required this.time,
    required this.onTimeSelected,
    required this.lightMode,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = MaterialLocalizations.of(context)
        .formatTimeOfDay(time ?? TimeOfDay.now(), alwaysUse24HourFormat: true);

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () => _showTimePicker(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: AppColors.chatBackground,
        ),
        padding: EdgeInsetsDirectional.only(
          start: 8.w,
          end: 10.w,
          top: 10.w,
          bottom: 10.w,
        ),
        child: Row(
          children: [
            Text(
              time == null ? '00:00' : formattedTime,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const Spacer(),
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/ic_time_clock.svg',
              height: 16.h,
              width: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final pickedTime = await showKpTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => themedKnowledgeTimePicker(context, child),
    );

    if (pickedTime != null) {
      onTimeSelected(pickedTime);
      if (!context.mounted) return;
      khLog('Selected time: ${pickedTime.format(context)}');
    }
  }
}
